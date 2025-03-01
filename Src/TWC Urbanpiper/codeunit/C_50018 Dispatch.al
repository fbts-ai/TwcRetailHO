codeunit 50018 "Dispatch"
{
    trigger OnRun()
    var
    begin
        dispatchorder;

    end;

    local procedure dispatchOrder()
    var
        receipt: text;
        trans: record "LSC POS Transaction";
        api_status: Boolean;
        orderID: BigInteger;
        upOrderStatus: Record "UP Order Status";
        errorMessage: Text;
    begin
        receipt := func.GetSelectedReceiptNo();
        if receipt <> '' then begin
            orderID := func.GetSelectedOrderID();
            if func.IsOrderCancelled(orderID) then begin
                Message('This order is cancelled, this transaction will be voided');
            end
            else begin
                trans.Reset();
                // trans.SetFilter(OrderId, Format(orderID));
                trans.SetFilter("Receipt No.", receipt);
                if trans.FindLast() then begin
                    if (trans.OrderStatus = trans.OrderStatus::"Food Ready") then begin
                        progress.Open('Please wait...');

                        if trans.OrderStatus <> trans.OrderStatus::Acknowledged then
                            Acknowledge();
                        if trans.OrderStatus <> trans.OrderStatus::"Food Ready" then
                            Markfoodready();
                        // 2023-08-02 UP does not support dispatch/completed status update api calls on productionenvironment.
                        // func.CallOrderUpdateAPI('Completed', api_status, errorMessage);
                        func.UpdatePOSTransactionTableOrderStatus('Completed', receipt, orderID);
                        // !// 2023-08-02 UP does not support dispatch/completed status update api calls on production environment.
                        func.RefreshActiveGrid();
                        progress.Close();
                    end
                    else
                        Error('Order Status is not in food ready state');




                end;
            end;

        end;
    end;

    // [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC Hospitality POS Startup", 'OnBeforeExecuteCommand', '', true, true)]
    local procedure OnBeforeExecuteCommand(
       ActiveDiningArea: Record "LSC Dining Area";
       ActiveServiceFlow: Record "LSC Hospitality Service Flow";
       CurrentReceipt: Code[20];
       MenuLine: Record "LSC POS Menu Line";
       var CommandRun: Boolean;
       var HospitalityTypeTemp: Record "LSC Hospitality Type" temporary;
       var IsHandled: Boolean
   )
    var
        receipt: text;
        EposCtrl: Codeunit "LSC POS Control Interface";
        trans: record "LSC POS Transaction";
        api_status: Boolean;
        orderID: BigInteger;
        upOrderStatus: Record "UP Order Status";
        errorMessage: Text;
    begin
        if (ActiveServiceFlow.ID = 'TAKE-AWAY-FLOW') and (MenuLine.Command = 'HOSP-ORDEREDIT') then begin
            receipt := EPosCtrl.GetDataGridKeyValue(EPosCtrl.ActiveDataGrid);

            if receipt <> '' then begin
                orderID := func.GetSelectedOrderID();
                if func.IsOrderCancelled(orderID) then begin
                    Message('This order is cancelled, this transaction will be voided');
                end
                else begin
                    trans.Init();
                    trans.SetFilter(OrderId, Format(orderID));
                    if trans.FindLast() then begin
                        if (trans.OrderStatus = trans.OrderStatus::"Food Ready") then begin
                            func.CallOrderUpdateAPI('Completed', api_status, errorMessage);
                        end
                        else
                            Error('Order Status is not in food ready state');
                    end;
                end;
            end;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSCIN Calculate Tax", 'OnBeforeCalculateTaxOnSelectedLine', '', false, false)]
    local procedure OnBeforeCalculateTaxOnSelectedLine(var POSTransLine: Record "LSC POS Trans. Line"; var Ishandled: Boolean)
    var
        upheader: Record "UP Header";
    begin
        upheader.SetFilter(receiptNo, POSTransLine."Receipt No.");
        upheader.SetFilter(order_details_channel, 'ConsumerApp');
        if upheader.FindFirst() then begin
            Ishandled := true;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Transaction Events", 'OnAfterRunCommand', '', false, false)]
    local procedure OnAfterRunCommand(
          var Command: Code[20];
          var CurrInput: Text;
          var POSMenuLine: Record "LSC POS Menu Line";
          var POSTransaction: Record "LSC POS Transaction";
          var POSTransLine: Record "LSC POS Trans. Line"
      )
    var
        pos: Codeunit "LSC POS Transaction";
        pos_events: Codeunit "LSC POS Transaction Events";
        session: Codeunit "LSC POS Session";
        transaction: record "LSC POS Transaction";
        tender: text;
        header: record "UP Header";

        amount: decimal;
        config: text;
        cancel_with_discount: decimal;
        header1: Record "UP Header";
        item: Record Item;
        transline: Record "LSC POS Trans. Line";
        transline1: Record "LSC POS Trans. Line";
        upline: Record "UP Line";
        upline1: Record "UP Line";
        lineNo: Integer;

        kot: text;
        kot_header: record "LSC KOT Header";
        packing: Codeunit "Packaging BOM";
    begin
        if command = 'EFT_RECOVER' then begin
            if pos.GetReceiptNo() <> '' then begin
                if (POSTransaction."Sales Type" = 'TAKEAWAY') or (POSTransaction."Sales Type" = 'PRE-ORDER') then begin
                    if POSTransaction.OrderType <> 'APP_DINE_IN' THEN BEGIN  //AlleRSN
                        progress.Open('Please wait...');
                        packing.AddPackingBOMItem(POSTransaction."Receipt No.");
                        progress.Close();
                    END;  //AlleRSN
                end;

                header1.SetFilter(order_details_id, Format(POSTransaction.OrderId));
                header1.SetFilter(receiptNo, POSTransaction."Receipt No.");
                header1.SetFilter(order_details_channel, 'ConsumerApp');
                if header1.FindLast() then begin
                    transaction.Reset();
                    transaction.SetFilter("Receipt No.", pos.GetReceiptNo());
                    if (transaction.FindLast()) and (transaction.OrderId <> 0) then begin
                        if transaction.OrderStatus = transaction.OrderStatus::CANCELLED then begin
                            //Ashish  pos.VoidTransaction();
                        end
                        else
                            if transaction.OrderStatus = transaction.OrderStatus::Completed then begin
                                pos.TotalPressed(true);
                                //amount := pos.GetOutstandingBalance();
                                amount := header1.order_details_payable_amount;
                                tender := getChannelTender(transaction.Channel);
                                pos.TenderKeyPressedEx(tender, format(amount));
                            end;
                    end;
                end

                else begin
                    transaction.Reset();
                    transaction.SetFilter("Receipt No.", pos.GetReceiptNo());
                    if (transaction.FindLast()) and (transaction.OrderId <> 0) then begin
                        if transaction.OrderStatus = transaction.OrderStatus::CANCELLED then begin
                            Message(format(transaction.OrderId) + ' order is cancelled');

                            kot_header.Reset();
                            kot_header.SetFilter("Receipt No.", transaction."Receipt No.");
                            if kot_header.FindLast() then begin
                                progress.Open('Please wait...');
                                kot := kot_header."KOT No.";
                                //Ashish
                                //  send_to_kds.VoidAllKOTLines(kot);
                                //Ashish  send_to_kds.ResendKOT(kot_header);
                                progress.Close();
                            end;

                            header.SetFilter(order_details_id, format(transaction.OrderId));
                            header.SetFilter(receiptNo, transaction."Receipt No.");
                            if header.FindLast() then begin
                                progress.Open('Please wait...');
                                if header.statusBeforeCanceled.ToUpper() <> 'FOOD READY' then begin
                                    applyCancellationDiscount(false);
                                end
                                else begin
                                    applyCancellationDiscount(true);
                                end;

                                amount := pos.GetOutstandingBalance();
                                tender := getChannelTender(transaction.Channel);
                                pos.TotalPressed(true);
                                pos.TenderKeyPressedEx(tender, format(amount));
                                progress.Close();
                            end;
                        end
                        else begin
                            if (transaction.OrderStatus = transaction.OrderStatus::"No Show") then begin
                                progress.Open('Please wait...');
                                applyCancellationDiscount(true);

                                amount := pos.GetOutstandingBalance();
                                tender := getChannelTender(transaction.Channel);
                                pos.TotalPressed(true);
                                pos.TenderKeyPressedEx(tender, format(amount));
                                progress.Close();
                            end
                            else begin
                                if (transaction.OrderStatus = transaction.OrderStatus::COMPLETED)
                                 or (transaction.OrderStatus = transaction.OrderStatus::Dispatched) then begin
                                    progress.Open('Please wait...');
                                    tender := getChannelTender(transaction.Channel);
                                    if tender = '' then
                                        tender := '1';

                                    pos.TotalPressed(true);
                                    //Ashish    pos.TenderKeyPressedEx(tender, format(pos.GetAmount()));
                                    progress.Close();
                                end;
                            end;
                        end;
                    end;
                end;
            end;
        end;
    end;

    local procedure applyCancellationDiscount(mfrDone: Boolean)
    var
        config: text;
        discount: decimal;
        pos: Codeunit "LSC POS Transaction";
    begin
        if mfrDone then
            config := func.GetConfig('UP', 'CANCEL_AFTER_MFR_DISCOUNT')
        else
            config := func.GetConfig('UP', 'CANCEL_BEFORE_MFR_DISCOUNT');

        if config <> '' then begin
            Evaluate(discount, config);
            //Ashish     pos.TotDiscPrPressed(format(discount), false);
            pos.TotalPressed(false);
        end;
    end;

    local procedure getChannelTender(channel: text) tender: text
    var
        config: record "TWC Configuration";
    begin
        config.SetFilter(Key_, 'UP');
        config.SetFilter(Name, '@' + channel + '_TENDERID');
        if config.FindLast() then
            tender := config.Value_
        else begin
            Message('Tender not configured for %1 channel orders \ Order will be processed by Cash!', channel);
            tender := '1';
        end;
    end;
    //ALLE_NICK_010224
    //For_testing
    local procedure Acknowledge()
    var
        upFunctions: Codeunit "UP Functions";
        caFunctions: Codeunit "CA Functions";
        api_status: Boolean;
        errorMessage: Text;
        EPosCtrl: Codeunit "LSC POS Control Interface";
        order_id: BigInteger;
        new_status: Enum "TWC Order Status";
        receipt: Text; //ALLE-AS-17102023
    begin
        order_id := upFunctions.GetSelectedOrderID();
        receipt := upFunctions.GetSelectedReceiptNo(); //ALLE-AS-17102023
        if not (upFunctions.IsOrderCancelled(order_id)) then begin
            caFunctions.CallOrderUpdateAPI('ACKNOWLEDGED', api_status, errorMessage, order_id, receipt); //ALLE-AS-17102023
            EposCtrl.RefreshDataGrid(EposCtrl.ActiveDataGrid());
        end
        else
            Error('Order is in Cancelled state, please click on Dispatch/Complete to clear the transaction from screen');
    end;

    local procedure Markfoodready()
    var
        upFunctions: Codeunit "UP Functions";
        caFunctions: Codeunit "CA Functions";
        api_status: Boolean;
        errorMessage: Text;
        EPosCtrl: Codeunit "LSC POS Control Interface";
        order_id: BigInteger;
        receipt: Text; //ALLE-AS-17102023

    begin
        order_id := upFunctions.GetSelectedOrderID();
        receipt := upFunctions.GetSelectedReceiptNo(); //ALLE-AS-17102023
        if not (upFunctions.IsOrderCancelled(order_id)) then begin
            caFunctions.CallOrderUpdateAPI('FOOD_READY', api_status, errorMessage, order_id, receipt); //ALLE-AS-17102023
            EposCtrl.RefreshDataGrid(EposCtrl.ActiveDataGrid());
        end
        else
            Error('Order is in Cancelled state, please click on Dispatch/Complete to clear the transaction from screen');
    end;

    var
        func: codeunit "UP Functions";
        //Ashish        send_to_kds: Codeunit "LSC Send to KDS";

        // CS-DBSRV01



        //// progress_displayed: Boolean;
        progress: dialog;
}
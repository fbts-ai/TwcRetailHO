codeunit 50027 "CA_Dispatch"
{
    trigger OnRun()
    var
        upFunctions: Codeunit "UP Functions";
        caFunctions: Codeunit "CA Functions";
        api_status: Boolean;
        errorMessage: Text;
        EPosCtrl: Codeunit "LSC POS Control Interface";
        orderID: BigInteger;
        receipt: text;
        trans: record "LSC POS Transaction";

    begin
        //Acknowledge();
        // Markfoodready();
        receipt := EPosCtrl.GetDataGridKeyValue(EPosCtrl.ActiveDataGrid);
        if receipt <> '' then begin
            orderID := upFunctions.GetSelectedOrderID();
            if upFunctions.IsOrderCancelled(orderID) then begin
                Message('This order is cancelled, this transaction will be voided');
            end
            else begin
                trans.Init();
                trans.SetFilter(OrderId, Format(orderID));
                if trans.FindLast() then begin
                    //  ALLE_NICK_010224
                    if trans.OrderStatus <> trans.OrderStatus::Acknowledged then
                        Acknowledge();
                    if trans.OrderStatus <> trans.OrderStatus::"Food Ready" then
                        Markfoodready();
                    if (trans.OrderStatus = trans.OrderStatus::"Food Ready") then begin
                        caFunctions.CallOrderUpdateAPI('COMPLETED', api_status, errorMessage, orderID, trans."Receipt No."); //ALLE-AS-17102023
                        EposCtrl.RefreshDataGrid(EposCtrl.ActiveDataGrid());
                    end
                    else
                        Error('Order Status is not in food ready state');

                end;
            end;

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
}
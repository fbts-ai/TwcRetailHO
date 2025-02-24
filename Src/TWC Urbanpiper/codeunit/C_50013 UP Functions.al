codeunit 50013 "UP Functions"
{
    SingleInstance = true;

    var
        counter: integer;
        lastrun: DateTime;

    trigger OnRun()
    var
    begin

    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Transaction Events", 'OnBeforeOnTimer', '', false, false)]
    local procedure MyProcedure()
    begin
        PrintPendingKot();
        RefreshActiveGrid();
    end;

    local procedure PrintPendingKot()
    var
        transaction: record "LSC POS Transaction";
        pos: codeunit "LSC POS Session";
        terminal: text;
    begin
        terminal := pos.TerminalNo();
        transaction.Reset();
        transaction.SetFilter(OrderId, '<>0');
        transaction.setfilter("Transaction Type", format(transaction."Transaction Type"::Sales));
        transaction.SetFilter("Sales Type", 'TAKEAWAY|PRE-ORDER');
        transaction.SetFilter(OrderStatus, '<%1', "TWC Order Status"::"KOT Printed");
        transaction.SetFilter("POS Terminal No.", terminal);
        transaction.SetFilter("Created on POS Terminal", terminal);
        if transaction.FindSet() then begin
            repeat begin
                PrintKOT(transaction."Receipt No.");
                transaction.OrderStatus := "TWC Order Status"::"KOT Printed";
                transaction.Modify();
            end
            until transaction.Next() = 0
        end;
    end;
    //Ashish
    procedure PrintKOT(receipt_no: text)
    var
        OposUtil: Codeunit "LSC POS OPOS Utility";
        func: Codeunit "UP Functions";
        kds: codeunit "LSC Send to KDS Interface";
    //        kds: codeunit "LSC Send to KDS";-YM-O

    begin
        kds.SendReceiptToKDS(
            receipt_no,
            "LSC KDS-Send Receipt to KDS"::"All Items",
            0,
            CurrentDateTime
        )
    end;

    procedure CallOrderUpdateAPI(p_order_Status: Text; requestStatus: Boolean; errorMessage: Text)
    var
        client: HttpClient;
        headers: HttpHeaders;
        content: HttpContent;
        responseMessage: HttpResponseMessage;
        responseString: Text;
        requestMessage: HttpRequestMessage;

        jsonText: Text;
        jObject: JsonObject;
        jtoken: JsonToken;

        statusToken: JsonToken;
        messageToken: JsonToken;
        orderID: BigInteger;
        posTransaction: Record "LSC POS Transaction";
        receiptNo: Text;

        config: text;
        up_key: text;
        up_updateurl: text;
    begin
        config := func.GetConfig('UP', 'UP_APIKEY');
        if config = '' then
            config := 'biz_adm_xOoaNxoOvYkw:43b672bd52cebace816c4a785de01f001133d05c';

        up_key := config;

        config := func.GetConfig('UP', 'UP_ORDERSTATUSURL');
        if config = '' then
            config := 'https://pos-int.urbanpiper.com/external/api/v1/orders/';

        up_updateurl := config;

        receiptNo := GetSelectedReceiptNo();

        if (receiptNo = '') then begin
            Error('Please select a line to proceed');
        end;

        posTransaction.SetFilter("Receipt No.", receiptNo);

        if posTransaction.FindFirst() then begin
            orderID := posTransaction.OrderId;
        end;

        jObject.add('new_status', p_order_Status);
        jObject.add('message', p_order_Status);
        jObject.WriteTo(jsonText);
        content.WriteFrom(jsonText);
        headers := client.DefaultRequestHeaders();
        headers.Add('Authorization', 'apikey ' + up_key);

        requestMessage.Method('PUT');
        requestMessage.Content(content);
        requestMessage.SetRequestUri(up_updateurl + Format(orderID) + '/status/');

        client.Send(requestMessage, responseMessage);
        responseMessage.Content().ReadAs(responseString);

        if not jtoken.ReadFrom(responseString) then
            Error('Invalid JSON document.');

        if not jtoken.IsObject() then
            Error('Expected a JSON object.');

        jObject := jtoken.AsObject();

        if not jObject.Get('status', statusToken) then
            Error('Value for status not found.');

        if not JObject.Get('message', messageToken) then
            Error('Value for message not found.');

        if responseMessage.HttpStatusCode = 200 then begin
            Message(Format(statusToken) + '-' + Format(messageToken));
            requestStatus := true;
            UpdatePOSTransactionTableOrderStatus(p_order_Status, receiptNo, orderID)
        end
        else begin
            Error(Format(statusToken) + '-' + Format(messageToken));
        end;
    end;

    procedure UpdatePOSTransactionTableOrderStatus(status: Text; receiptNo: Text; orderID: BigInteger)
    var
        POSTrans: Record "LSC POS Transaction";
        upHeader: Record "UP Header";
    begin
        POSTrans.SetFilter("Receipt No.", receiptNo);
        POSTrans.Init();
        if POSTrans.FindFirst() then begin
            Evaluate(POSTrans.OrderStatus, status);
            POSTrans.Modify()
        end;

        upHeader.Init();
        upHeader.SetFilter(order_details_id, Format(orderID));
        if upHeader.FindLast() then begin
            if (status = 'Acknowledged') then begin
                upHeader.acceptedOn := CurrentDateTime;
                upHeader.kotPrintedOn := CurrentDateTime; //ALLE-AS_09112023
                upHeader.current_status := upHeader.current_status::Acknowledged;
                upHeader.Modify();
            end
            else
                if (status = 'Food Ready') then begin
                    upHeader.mfrOn := CurrentDateTime;
                    upHeader.current_status := upHeader.current_status::"Food Ready";
                    upHeader.Modify();
                end
                else
                    if (status = 'Completed') then begin
                        upHeader.dispatchedOn := CurrentDateTime;
                        upHeader.current_status := upHeader.current_status::COMPLETED;
                        upHeader.Modify();
                    end;
        end;

    end;

    procedure IsOrderCancelled(orderID: BigInteger) cancelled: Boolean
    var
        upOrderStatus: Record "UP Order Status";
        posTransaction: Record "LSC POS Transaction";
    begin
        if orderID = 0 then begin
            Error('Order not selected');
            exit;
        end;

        posTransaction.Init();
        posTransaction.SetFilter(OrderId, Format(orderID));
        posTransaction.SetFilter(OrderStatus, Format(posTransaction.OrderStatus::CANCELLED));
        if (posTransaction.FindLast()) then begin
            cancelled := true;
        end
        else begin
            upOrderStatus.Init();
            upOrderStatus.SetFilter(upOrderStatus.order_no, Format(orderID));
            upOrderStatus.SetFilter(upOrderStatus.new_state, 'Cancelled');
            if (upOrderStatus.FindLast()) then begin
                cancelled := true;
            end
            else
                cancelled := false;
        end;
    end;

    procedure GetSelectedReceiptNo() receiptNo: Text
    var
        EposCtrl: Codeunit "LSC POS Control Interface";
    begin
        receiptNo := EPosCtrl.GetDataGridKeyValue(EPosCtrl.ActiveDataGrid);
    end;

    procedure GetSelectedOrderID() orderID: BigInteger
    var
        EposCtrl: Codeunit "LSC POS Control Interface";
        posTransaction: Record "LSC POS Transaction";
        receiptNo: Text;
    begin
        receiptNo := GetSelectedReceiptNo();
        posTransaction.SetFilter("Receipt No.", receiptNo);

        if posTransaction.FindFirst() then begin
            orderID := posTransaction.OrderId;
        end;
    end;

    procedure GetConfig(pKey: text; pName: text) value_: Text
    var
        twcConfiguration: Record "TWC Configuration";
    begin
        twcConfiguration.Init();
        twcConfiguration.SetFilter(Key_, '@' + pKey);
        twcConfiguration.SetFilter(Name, '@' + pName);
        if twcConfiguration.FindFirst() then
            value_ := twcConfiguration.Value_;
    end;

    procedure GetStoreID() storeID: Text
    var
        twcConfiguration: Record "TWC Configuration";
    begin
        twcConfiguration.Init();
        twcConfiguration.SetFilter(Key_, '@UP');
        twcConfiguration.SetFilter(Name, '@STORE_ID');
        if twcConfiguration.FindFirst() then begin
            storeID := twcConfiguration.Value_;
        end
        else
            Error('UP STORE_ID is not configured in TWC Configuration');
    end;

    procedure getNextReceiptNo(terminal: text) receiptNo: Text
    var
        posTransaction: Record "LSC POS Transaction";
        transactionHeader: Record "LSC Transaction Header";
        posID: Integer;
        transID: Integer;
        receiptID: Integer;
    begin
        posTransaction.Init();
        posTransaction.SetFilter("Receipt No.", '00000' + terminal + '*');
        if posTransaction.FindLast() then begin
            Evaluate(posID, CopyStr(posTransaction."Receipt No.", 11));
        end;

        transactionHeader.Init();
        transactionHeader.SetFilter("Receipt No.", '00000' + terminal + '*');
        if transactionHeader.FindLast() then begin
            Evaluate(transID, CopyStr(transactionHeader."Receipt No.", 11));
        end;

        if posID > transID then begin
            receiptNo := IncStr(posTransaction."Receipt No.");
        end
        else
            receiptNo := IncStr(transactionHeader."Receipt No.");

        if (posId = 0) and (transID = 0) then
            receiptNo := '00000' + terminal + '000000001';
    end;

    procedure GetSelectedOrderStatus() status: enum "TWC Order Status"
    var
        trans: record "LSC POS Transaction";
        receipt_no: text;
    begin
        receipt_no := GetSelectedReceiptNo();
        if receipt_no = '' then begin
            error('No transaction selected!');
        end;

        trans.SetFilter("Receipt No.", receipt_no);
        if trans.FindLast() then begin
            status := trans.OrderStatus;
        end;
    end;

    procedure ValidateStatusChange(prevState: enum "TWC Order Status"; newState: enum "TWC Order Status") valid: Boolean
    begin
        case newState of
            "TWC Order Status"::Acknowledged:
                case prevState of
                    "TWC Order Status"::Placed:
                        valid := true;
                end;
            "TWC Order Status"::"KOT Printed":
                case prevState of
                    "TWC Order Status"::Placed:
                        valid := true;
                    "TWC Order Status"::Acknowledged:
                        valid := true;
                end;
            "TWC Order Status"::"Food Ready":
                case prevState of
                    "TWC Order Status"::Placed:
                        valid := true;
                    "TWC Order Status"::Acknowledged:
                        valid := true;
                    "TWC Order Status"::"KOT Printed":
                        valid := true;
                end;
            "TWC Order Status"::Dispatched:
                case prevState of
                    "TWC Order Status"::"Food Ready":
                        valid := true;
                end;
            "TWC Order Status"::Completed:
                case prevState of
                    "TWC Order Status"::"Food Ready":
                        valid := true;
                    "TWC Order Status"::Dispatched:
                        valid := true;
                end;
            "TWC Order Status"::Cancelled:
                case prevState of
                    "TWC Order Status"::Placed:
                        valid := true;
                    "TWC Order Status"::Acknowledged:
                        valid := true;
                    "TWC Order Status"::"KOT Printed":
                        valid := true;
                    "TWC Order Status"::"Food Ready":
                        valid := true;
                end;
            "TWC Order Status"::"No Show":
                case prevState of
                    "TWC Order Status"::"Food Ready":
                        valid := true;
                end;
        end;
    end;

    procedure RefreshActiveGrid()
    var
        EPosCtrl: Codeunit "LSC POS Control Interface";
        activegrid: text;
    begin
        if EPosCtrl.PosIsActive() then begin
            activegrid := EposCtrl.ActiveDataGrid();
            if activegrid = '#HOSP-GRID' then begin
                EposCtrl.RefreshDataGrid(EposCtrl.ActiveDataGrid());
            end;
        end;
    end;

    var
        func: Codeunit "UP Functions";
}
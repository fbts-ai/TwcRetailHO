codeunit 50024 "CA Functions"
{
    trigger OnRun()
    var
    begin

    end;

    procedure








    CallOrderUpdateAPI(p_order_Status: Text; requestStatus: Boolean; errorMessage: Text; orderID: BigInteger; receiptnos: Text) valid: Boolean
    //ALLE-AS-17102023
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

        previousStatusToken: JsonToken;
        updatedStatusToken: JsonToken;
        messageToken: JsonToken;
        // orderID: BigInteger;
        EposCtrl: Codeunit "LSC POS Control Interface";

        posTransaction: Record "LSC POS Transaction";
        receiptNo: Text;
        upFunctions: Codeunit "UP Functions";
        pos: Codeunit "LSC POS Transaction";
        up_log: Record UP_Log;
        config: text;
        ca_key: text;
        ca_updateurl: text;
        status: text;

    begin
        config := upFunctions.GetConfig('CA', 'CA_APIKEY');
        if config = '' then
            config := 'ebbafe94-2c62-4f00-a860-ea309faab250';

        ca_key := config;

        config := upFunctions.GetConfig('CA', 'CA_ORDERSTATUSURL');
        if config = '' then
            config := 'https://testing-api.thirdwavecoffee.in/pos-ls-central-integration-svc/api/order/status/update';

        ca_updateurl := config;

        up_log.Init();
        up_log.OrderID := orderID;
        up_log.OrderStatus := p_order_Status;
        up_log.Message := 'Calling Consumer App API';
        up_log.Insert();

        if not (p_order_Status = 'ACKNOWLEDGED') then begin
            orderID := upFunctions.GetSelectedOrderID();
            receiptNo := upFunctions.GetSelectedReceiptNo();
        end
        else begin
            receiptNo := pos.GetReceiptNo();
        end;

        jObject.add('orderId', orderID);
        jObject.add('orderType', 'APP_PICKUP');
        jObject.add('posOrderId', receiptNo);
        jObject.add('orderStatus', p_order_Status);
        jObject.add('message', p_order_Status);
        jObject.add('ReceiptNo', receiptnos);//ALLE-AS-17102023

        jObject.WriteTo(jsonText);
        content.WriteFrom(jsonText);
        content.GetHeaders(headers);
        headers.Clear();
        headers.Add('X-API-VERSION', '1');
        headers.Add('X-API-KEY', ca_key);
        headers.Add('Content-Type', 'application/json');

        requestMessage.Method('POST');
        requestMessage.Content(content);
        requestMessage.SetRequestUri(ca_updateurl);

        client.Send(requestMessage, responseMessage);
        responseMessage.Content().ReadAs(responseString);
        if not jtoken.ReadFrom(responseString) then
            Error('Invalid JSON document.');
        if not jtoken.IsObject() then
            Error('Expected a JSON object.');
        jObject := jtoken.AsObject();
        if responseMessage.HttpStatusCode = 200 then begin
            if not jObject.Get('previousStatus', previousStatusToken) then
                Error('Value for previousStatus not found.');
            if not JObject.Get('updatedStatus', updatedStatusToken) then
                Error('Value for updatedStatus not found.');
            requestStatus := true;
            //   if (p_order_Status='FOOD_READY')or(p_order_Status='ACKNOWLEDGED')or(p_order_Status='COMPLETED')or(p_order_Status='CANCELLED')
            UpdatePOSTransactionTableOrderStatus(p_order_Status, receiptNo, orderID);
            if not (p_order_Status = 'ACKNOWLEDGED') then begin
                Message('Order Status Changed to' + Format(updatedStatusToken));
            end
        end
        else begin
            if not (p_order_Status = 'ACKNOWLEDGED') then begin
                if not jObject.Get('message', messageToken) then
                    Error('Value for message not found.');
                Error(Format(messageToken));
            end;
        end;
    end;

    procedure UpdatePOSTransactionTableOrderStatus(status: Text; receiptNo: Text; orderID: BigInteger)
    var
        POSTrans: Record "LSC POS Transaction";
        upHeader: Record "UP Header";
        lsStatus: Text;
    begin
        if status = 'FOOD_READY' then begin
            lsStatus := 'Food Ready';
        end
        else
            if status = 'ACKNOWLEDGED' then begin
                lsStatus := 'Acknowledged';
            end
            else
                if status = 'COMPLETED' then begin
                    lsStatus := 'Completed';
                end
                else
                    if status = 'CANCELLED' then begin
                        lsStatus := 'Cancelled';
                    end;
        POSTrans.SetFilter("Receipt No.", receiptNo);
        POSTrans.Init();
        if POSTrans.FindFirst() then begin
            Evaluate(POSTrans.OrderStatus, lsStatus);
            POSTrans.Modify()
        end;

        upHeader.Init();
        upHeader.SetFilter(order_details_id, Format(orderID));
        if upHeader.FindLast() then begin
            if (status = 'ACKNOWLEDGED') then begin
                upHeader.acceptedOn := CurrentDateTime;
                upHeader.kotPrintedOn := CurrentDateTime; //ALLE-AS_09112023
                upHeader.current_status := upHeader.current_status::Acknowledged;
                upHeader.Modify();
            end
            else
                if (status = 'FOOD_READY') then begin
                    upHeader.mfrOn := CurrentDateTime;
                    upHeader.current_status := upHeader.current_status::"Food Ready";
                    upHeader.Modify();
                end
                else
                    if (status = 'COMPLETED') then begin
                        upHeader.dispatchedOn := CurrentDateTime;
                        upHeader.current_status := upHeader.current_status::COMPLETED;
                        upHeader.Modify();
                    end
                    else
                        if (status = 'CANCELLED') then begin
                            upHeader.cancelledOn := CurrentDateTime;
                            upHeader.current_status := upHeader.current_status::CANCELLED;
                            upHeader.Modify();
                        end;
        end;

    end;
}
codeunit 50015 "UPQ Process Order Status"
{
    trigger OnRun()
    var
        client: HttpClient;
        headers: HttpHeaders;
        content: HttpContent;
        responseMessage: HttpResponseMessage;
        responseString: Text;
        jObject: JsonObject;
        JsonText: Text;
        storeid: Text;
        requestMessage: HttpRequestMessage;
        jtoken: JsonToken;
        jtoken2: JsonToken;

        orderUpdateToken: JsonToken;
        orderUpdateObj: JsonObject;

        OrderIDToken: JsonToken;
        OrderStatusToken: JsonToken;
        StoreIDToken: JsonToken;
        PrevStateToken: JsonToken;
        UpdateOnToken: JsonToken;

        orderID: BigInteger;
        orderStatus: Text[100];
        store: Text[100];
        prevState: Text[100];
        updatedOn: DateTime;

        jarr: JsonArray;
        i: Integer;

        upOrderStatus: Record "UP Order Status";
        upOrderStatus1: Record "UP Order Status";
        upOrderStatus2: Record "UP Order Status";

        upPrimaryID: BigInteger;

        posTransaction: Record "LSC POS Transaction";
        upHeader: Record "UP Header";

        config: text;
        api_key: text;
        orderstatus_url: text;
    begin
        config := func.GetConfig('UP', 'AZURE_APIKEY');
        if config = '' then
            config := '8c79d81528564b11848fc6a46a4d2705';

        api_key := config;

        config := func.GetConfig('UP', 'AZURE_GETORDERSTATUSURL');
        if config = '' then
            config := 'https://bce-apimanagement.azure-api.net/orderstatus';

        orderstatus_url := config;

        storeid := func.GetStoreID();
        jObject.add('storeid', storeid);

        jObject.WriteTo(jsonText);
        content.WriteFrom(jsonText);
        headers := client.DefaultRequestHeaders();
        headers.Add('Ocp-Apim-Subscription-Key', api_key);

        requestMessage.Method('POST');
        requestMessage.Content(content);
        requestMessage.SetRequestUri(orderstatus_url);

        client.Send(requestMessage, responseMessage);
        responseMessage.Content().ReadAs(responseString);

        if not jtoken.ReadFrom(responseString) then
            Error('Invalid JSON document.');

        if not jtoken.IsObject() then
            Error('Expected a JSON object.');

        jObject := jtoken.AsObject();

        if not jObject.Get('order_updates', Jtoken2) then
            Error('Value for order_updates not found.');

        if not jtoken2.IsArray then
            Error('Expected a JSON array.');

        jarr := jtoken2.AsArray();

        for i := 0 to jarr.Count - 1 do begin
            jarr.Get(i, orderUpdateToken);
            if orderUpdateToken.IsObject then begin
                orderUpdateObj := orderUpdateToken.AsObject();

                if not orderUpdateObj.Get('order_id', OrderIDToken) then
                    Error('Value for order_updates not found.');

                orderID := OrderIDToken.AsValue().AsBigInteger();

                if not orderUpdateObj.Get('new_state', OrderStatusToken) then
                    Error('Value for order_updates not found.');

                orderStatus := OrderStatusToken.AsValue().AsText();

                if not orderUpdateObj.Get('store_id', StoreIDToken) then
                    Error('Value for order_updates not found.');

                store := StoreIDToken.AsValue().AsText();

                if not orderUpdateObj.Get('old_state', PrevStateToken) then
                    Error('Value for order_updates not found.');

                prevState := PrevStateToken.AsValue().AsText();

                if not orderUpdateObj.Get('timestamp', UpdateOnToken) then
                    Error('Value for order_updates not found.');
                updatedOn := UpdateOnToken.AsValue().AsDateTime();

                upOrderStatus2.Init();
                upOrderStatus2.SetFilter(order_no, Format(orderID));
                if upOrderStatus2.FindFirst() then begin
                    if not (upOrderStatus2.new_state = orderStatus) then begin
                        upOrderStatus2.new_state := orderStatus;
                        upOrderStatus2.prev_state := prevState;
                        upOrderStatus2.updated_on := updatedOn;
                        upOrderStatus2.Modify();
                    end
                end
                else begin
                    upOrderStatus1.Init();
                    if upOrderStatus1.FindLast() then begin
                        upPrimaryID := upOrderStatus1.No_;
                    end;

                    upOrderStatus.Init();
                    upOrderStatus.SetFilter(upOrderStatus.No_, Format(upPrimaryID));
                    if upOrderStatus.FindFirst() then begin
                        upOrderStatus.No_ += 1;
                    end;

                    upOrderStatus.order_no := orderID;
                    upOrderStatus.new_state := orderStatus;
                    upOrderStatus.prev_state := prevState;
                    upOrderStatus.store_id := store;
                    upOrderStatus.updated_on := updatedOn;

                    upOrderStatus.Insert();
                end;

                upHeader.Init();
                upHeader.SetFilter(order_details_id, Format(orderID));

                if orderStatus = 'Cancelled' then begin
                    posTransaction.SetFilter(OrderId, Format(orderID));
                    if posTransaction.FindLast() then begin
                        posTransaction.OrderStatus := posTransaction.OrderStatus::CANCELLED;
                        posTransaction.Modify();
                    end;

                    if upHeader.FindLast() then begin
                        if not (upheader.current_status = upheader.current_status::CANCELLED) then begin
                            upHeader.statusBeforeCanceled := Format(upHeader.current_status);
                            upHeader.current_status := upHeader.current_status::CANCELLED;
                            upHeader.cancelledOn := CreateDateTime(Today, Time);
                            upHeader.Modify();
                        end;
                    end;
                end;
            end;
        end;
    end;

    var
        func: codeunit "UP Functions";
}
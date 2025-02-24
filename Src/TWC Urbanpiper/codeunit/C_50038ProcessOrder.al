codeunit 50038 "UPQProcessOrderforSingle store"
{
    trigger OnRun()
    var
        kot_func: Codeunit "KOT Functions";
        postrans: Codeunit "LSC POS Transaction";
        APISetup: Record TwcApiSetupUrl;
        hardwareProfile: Record "LSC POS Hardware Profile";
        opos: Codeunit "LSC POS OPOS Utility";

        ipos: Codeunit "LSC POS Hardware Interface";
    begin

        if not GetOrderDefaults() then begin
            Error('Order default STORE_ID, TERMINAL_ID, STAFF_ID not configured in TWC Configuration');
            exit;
        end;

        processOrder();
        //  postrans.MessageBeep('Order Received');
        // opos.Beeper();

        //        updateHardprofile();

    end;

    local procedure processOrder()
    var
        data: JsonArray;

        postrans: Codeunit "LSC POS Transaction";
        APISetup: Record TwcApiSetupUrl;
        hardwareProfile: Record "LSC POS Hardware Profile";
        opos: Codeunit "LSC POS OPOS Utility";
        Hardwareinterface: Codeunit "LSC POS Hardware Interface";
        ipos: Codeunit "LSC POS Hardware Interface";

    begin

        data := GetStoreOrders(func.GetStoreID());
        //Message(Format(data));

        hardwareProfile.Reset();
        hardwareProfile.SetRange("Profile ID", '##DEFAULT');
        IF hardwareProfile.FindFirst() then begin
            hardwareProfile."Tone1 Duration" := 5000;
            hardwareProfile.Validate("Tone1 Duration");
            hardwareProfile."Tone2 Pitch" := 2000;
            hardwareProfile.Validate("Tone1 Pitch");
            hardwareProfile."Tone1 Volume" := 5000;
            hardwareProfile.Validate("Tone1 Volume");

            //  Commit();
            hardwareProfile.Modify(true);
            Commit();

        end;

        processOrders(data);


        create_trans_cu.Run();

        opos.Beeper();
        //        ipos.Sound(1, 1000);

    end;

    local procedure processOrders(jorders: JsonArray)
    var
        jtoken: JsonToken;
        jorder: JsonObject;
        jitems: JsonArray;

        header: record "UP Header";
        line: record "UP Line";

        acceptedOn: datetime;
        cancelledOn: datetime;
        confirmedOn: datetime;
        current_status: Integer;

        customer_email: Text;
        customer_name: Text;
        customer_phone: Text;

        dispatchedOn: datetime;
        insertedOn: datetime;
        kotPrintedOn: datetime;
        mfrOn: datetime;

        order_details_channel: Text;
        order_details_created: datetime;
        order_details_delivery_datetime: datetime;
        order_details_discount: decimal;
        order_details_expected_pickup_time: datetime;
        order_details_instructions: Text;
        order_details_order_level_total_taxes: decimal;
        order_details_order_state: Text;
        order_details_order_subtotal: decimal;
        order_details_order_total: decimal;
        order_details_order_type: Text;
        order_details_ext_platforms_id: text;
        order_details_payable_amount: decimal;
        order_details_total_charges: decimal;
        order_details_total_taxes: decimal;
        order_items_total: decimal;
        order_payment_amount: decimal;
        order_store_merchant_ref_id: Text;
        order_store_name: Text;
        statusBeforeCanceled: Text;
        transaction_created: Boolean;
        order_details_id: BigInteger;
        order_details_tableno: Text;
        Transheader: Record "LSC Transaction Header";


    begin
        foreach jtoken in jorders do begin
            jorder := jtoken.AsObject();

            customer_name := getJsonField(jorder, 'customer_name');
            customer_email := getJsonField(jorder, 'customer_email');
            customer_phone := getJsonField(jorder, 'customer_phone');
            order_details_channel := getJsonField(jorder, 'order_details_channel');
            order_details_created := unixtimestamp2datetime(getJsonField(jorder, 'order_details_created'));
            order_details_delivery_datetime := unixtimestamp2datetime(getJsonField(jorder, 'order_details_delivery_datetime'));
            Evaluate(order_details_discount, getJsonField(jorder, 'order_details_discount'));
            order_details_expected_pickup_time := unixtimestamp2datetime(getJsonField(jorder, 'order_details_expected_pickup_time'));
            Evaluate(order_details_id, getJsonField(jorder, 'order_details_id'));
            order_details_ext_platforms_id := getJsonField(jorder, 'order_details_ext_platforms_id');
            order_details_instructions := getJsonField(jorder, 'order_details_instructions');
            Evaluate(order_details_order_level_total_taxes, getJsonField(jorder, 'order_details_order_level_total_taxes'));
            order_details_order_state := getJsonField(jorder, 'order_details_order_state');
            Evaluate(order_details_order_subtotal, getJsonField(jorder, 'order_details_order_subtotal'));
            Evaluate(order_details_order_total, getJsonField(jorder, 'order_details_order_total'));
            order_details_order_type := getJsonField(jorder, 'order_details_order_type');
            Evaluate(order_details_payable_amount, getJsonField(jorder, 'order_details_payable_amount'));
            Evaluate(order_details_total_charges, getJsonField(jorder, 'order_details_total_charges'));
            Evaluate(order_details_total_taxes, getJsonField(jorder, 'order_details_total_taxes'));
            Evaluate(order_payment_amount, getJsonField(jorder, 'order_payment_amount'));
            Evaluate(order_details_tableno, getJsonField(jorder, 'order_details_tableno'));
            order_store_merchant_ref_id := getJsonField(jorder, 'order_store_merchant_ref_id');
            order_store_name := getJsonField(jorder, 'order_store_name');


            if not jorder.get('items', jtoken) then
                Error('Expected items not found!');

            if not jtoken.IsArray() then
                Error('Expected items array not found!');


            header.Reset();
            header.SetFilter(order_details_id, format(order_details_id));
            if not header.FindFirst() then begin
                //Message(format(order_details_id));
                // if order_details_order_type = 'delivery' then begin
                header.Init();
                header.insertedOn := CreateDateTime(today(), time());
                header.customer_email := customer_email;
                header.customer_name := customer_name;
                header.customer_phone := customer_phone;
                header.order_details_channel := order_details_channel;
                header.order_details_created := order_details_created;
                header.order_details_delivery_datetime := order_details_delivery_datetime;
                header.order_details_discount := order_details_discount;
                header.order_details_expected_pickup_time := order_details_expected_pickup_time;
                header.order_details_id := order_details_id;
                header.order_details_ext_platforms_id := order_details_ext_platforms_id;
                //header.order_details_instructions := order_details_instructions;
                header.order_details_instructions := CopyStr(order_details_instructions, 1, MaxStrLen(header.order_details_instructions));//ALLE_NICK_161123
                header.order_details_order_level_total_taxes := order_details_order_level_total_taxes;
                header.order_details_order_state := order_details_order_state;
                header.order_details_order_subtotal := order_details_order_subtotal;
                header.order_details_order_total := order_details_order_total;
                header.order_details_order_type := order_details_order_type;
                header.order_details_payable_amount := order_details_payable_amount;
                header.order_details_total_charges := order_details_total_charges;
                header.order_details_total_taxes := order_details_total_taxes;
                header.order_details_tableno := order_details_tableno;
                header.Insert(true);
                jitems := jtoken.AsArray();
                processItems(jitems, order_details_id);
                //  end;
            end
            // else begin
            //     header.order_details_order_state := order_details_order_state;
            // end;
        end;


    end;

    local procedure processItems(jitems: JsonArray; order_details_id: BigInteger)
    var
        jtoken: JsonToken;
        jitem: JsonObject;
        jtaxes: JsonArray;
        jtax: JsonObject;
        jtoken1: JsonToken;

        line: record "UP Line";

        indent: Integer;
        line_no: Integer;
        order_id: BigInteger;
        order_items_discount: Decimal;
        order_items_instructions: Text;
        order_items_is_variant: Boolean;
        order_items_merchant_id: Text;
        order_items_price: Decimal;
        order_items_quantity: Integer;
        order_items_title: Text;
        order_items_total_with_tax: Decimal;
        parent_line_no: Integer;
        order_items_cgst_rate: Decimal;
        order_items_cgst_value: Decimal;
        order_items_sgst_rate: Decimal;
        order_items_sgst_value: Decimal;
        cuFunctions: Codeunit "CA Functions";

    begin

        foreach jtoken in jitems do begin
            indent := 0;
            jitem := jtoken.AsObject();

            Evaluate(line_no, getJsonField(jitem, 'line no')); // line_no
            Evaluate(order_items_discount, getJsonField(jitem, 'discount'));
            Evaluate(order_items_is_variant, getJsonField(jitem, 'is_variant'));
            Evaluate(order_items_price, getJsonField(jitem, 'price'));
            Evaluate(order_items_quantity, getJsonField(jitem, 'quantity'));
            Evaluate(order_items_total_with_tax, getJsonField(jitem, 'total'));
            Evaluate(parent_line_no, getJsonField(jitem, 'parent line no'));

            order_id := order_details_id;
            order_items_instructions := getJsonField(jitem, 'instructions');
            order_items_merchant_id := getJsonField(jitem, 'merchant_ref_no');
            order_items_title := getJsonField(jitem, 'title');

            if (parent_line_no <> 0) and (parent_line_no <> line_no) then
                indent := 1;

            line.line_no := line_no;
            line.indent := indent;
            line.order_id := order_details_id;
            line.order_items_discount := order_items_discount;
            line.order_items_instructions := order_items_instructions;
            line.order_items_is_variant := order_items_is_variant;
            line.order_items_merchant_id := order_items_merchant_id;
            line.order_items_price := order_items_price;
            line.order_items_quantity := order_items_quantity;
            line.order_items_title := order_items_title;
            line.order_items_total_with_tax := order_items_total_with_tax;
            line.parent_line_no := parent_line_no;

            if not jitem.get('taxes', jtoken1) then
                Error('Expected taxes not found!');

            jtax := jtoken1.AsObject();

            order_items_cgst_rate := ToDecimal(getJsonField(jtax, 'cgst_rate'));
            order_items_cgst_value := ToDecimal(getJsonField(jtax, 'cgst_value'));
            order_items_sgst_rate := ToDecimal(getJsonField(jtax, 'sgst_rate'));
            order_items_sgst_value := ToDecimal(getJsonField(jtax, 'sgst_value'));

            line.order_items_cgst_rate := order_items_cgst_rate;
            line.order_items_cgst_value := order_items_cgst_value;
            line.order_items_sgst_rate := order_items_sgst_rate;
            line.order_items_sgst_value := order_items_sgst_value;

            line.Insert(true);
            // end;
        end;
    end;

    local procedure ToDecimal(val: text) ret: decimal
    begin
        if val = '' then
            ret := 0
        else
            Evaluate(ret, val);
    end;

    local procedure unixtimestamp2datetime(timestampstr: text) val: DateTime
    var
        unix_date: DateTime;
        date_value: DateTime;
        timestamp: BigInteger;
    begin
        if timestampstr = '' then begin
            val := CreateDateTime(19000101D, 0T);
            exit;
        end;

        Evaluate(timestamp, timestampstr);
        unix_date := CreateDateTime(19700101D, 0T);
        date_value := unix_date + timestamp;

        val := date_value;
    end;

    local procedure getJsonField(jorder: JsonObject; token: text) val: Text
    var
        jt: JsonToken;
        jv: jsonvalue;
    begin
        if jorder.Contains(token) then begin
            jorder.Get(token, jt);
            if not jt.IsValue() then
                error('Expected %1 value not found!', token);

            jv := jt.AsValue();
            if not jv.IsNull then
                val := jt.AsValue().AsText();
        end
        else
            error('Expected %1 value not found!', token);

    end;

    procedure Getduration() duration: Text
    var
        twcConfiguration: Record "TWC Configuration";
    begin
        twcConfiguration.Init();
        twcConfiguration.SetFilter(Key_, '@duration');
        twcConfiguration.SetFilter(Name, '@duration');
        if twcConfiguration.FindFirst() then begin
            duration := twcConfiguration.Value_;
        end
        else
            Error('Duration is not configured in TWC Configuration');
    end;

    procedure GetStartDate() StartDate: Text
    var
        twcConfiguration: Record "TWC Configuration";
    begin
        twcConfiguration.Init();
        twcConfiguration.SetFilter(Key_, '@StartDate');
        twcConfiguration.SetFilter(Name, '@StartDate');
        if twcConfiguration.FindFirst() then begin
            StartDate := twcConfiguration.Value_;
        end
        else
            Error('Start Date is not configured in TWC Configuration');
    end;

    procedure GetEndDate() EndDate: Text
    var
        twcConfiguration: Record "TWC Configuration";
    begin
        twcConfiguration.Init();
        twcConfiguration.SetFilter(Key_, '@EndDate');
        twcConfiguration.SetFilter(Name, '@EndDate');
        if twcConfiguration.FindFirst() then begin
            EndDate := twcConfiguration.Value_;
        end
        else
            Error('End Date is not configured in TWC Configuration');
    end;

    procedure GetStoreOrders(storeid: text) data: JsonArray
    var
        client: HttpClient;
        headers: HttpHeaders;
        content: HttpContent;
        requestMessage: HttpRequestMessage;
        responseMessage: HttpResponseMessage;
        responseString: Text;
        jsonObj: JsonObject;
        jsonString: Text;

        jtoken: JsonToken;
        jtoken2: JsonToken;
        jtoken3: JsonToken;
        jorders: JsonArray;
        jobj: JsonObject;
        jarr: JsonArray;

        info: text;
        config: text;

        az_key: text;
        url_getstoreorder: text;
    begin
        jsonObj.add('storeid', storeid);
        jsonObj.add('run_type', 'MANUAL');
        //jsonObj.add('duration', Getduration);
        jsonObj.add('duration', -1);
        jsonObj.add('startDate', GetStartDate);
        jsonObj.add('endDate', GetEndDate);
        jsonObj.WriteTo(jsonString);
        content.WriteFrom(jsonString);

        config := func.GetConfig('UP', 'AZURE_KEY');
        if config = '' then
            config := '8c79d81528564b11848fc6a46a4d2705';

        az_key := config;

        config := func.GetConfig('UP', 'AZURE_GETSTOREORDERURL');
        if config = '' then
            config := 'https://bce-apimanagement.azure-api.net/order/GetStoreorder';

        url_getstoreorder := config;

        headers := client.DefaultRequestHeaders();
        headers.Add('Ocp-Apim-Subscription-Key', az_key);

        requestMessage.Method('POST');
        requestMessage.Content(content);
        requestMessage.SetRequestUri(url_getstoreorder);
        client.Send(requestMessage, responseMessage);

        responseMessage.Content().ReadAs(responseString);

        if not jtoken.ReadFrom(responseString) then
            error('Invalid json response!');

        if not jtoken.IsObject() then
            error('Expected a json object!');

        jobj := jtoken.AsObject();

        if not jobj.Get('orders', jtoken2) then
            error('Value for id not found!');

        if not jtoken2.IsArray then
            error('Expected orders json array!');

        jarr := jtoken2.AsArray();
        foreach jtoken in jarr do begin
            jobj := jtoken.AsObject();
            jobj.Get('order_details_id', jtoken3);

            if not jtoken3.IsValue() then
                error('Expected value for order_details_id!');

            if info <> '' then
                info := info + ', ';

            info := info + jtoken3.AsValue().AsText();
        end;

        data := jarr;
    end;

    local procedure GetOrderDefaults() result: Boolean
    var
        store: text;
        terminal: text;
        staff: text;

    begin
        store := getConfig('UP', 'STORE_ID');
        terminal := getConfig('UP', 'TERMINAL_ID');
        staff := getConfig('UP', 'STAFF_ID');

        create_trans_cu.SetOrderDefaults(store, terminal, staff);
        if (store <> '') and (terminal <> '') or (staff <> '') then
            result := true;
    end;

    local procedure getConfig(key_: text; name: text) value_: text
    var
        config: record "TWC Configuration";
    begin
        config.SetFilter(Key_, key_);
        config.SetFilter(Name, name);
        if config.FindLast() then begin
            value_ := config.Value_;
        end;
    end;


    var
        myInt: Integer;
        create_trans_cu: Codeunit "UP Create Transactions";

        store: text;
        terminal: text;
        staff: text;

        func: Codeunit "UP Functions";
}
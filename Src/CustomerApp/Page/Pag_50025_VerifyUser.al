page 50025 "Verify User"
{
    PageType = Card;
    ApplicationArea = All;
    UsageCategory = Administration;
    //SourceTable = TableName;
    Caption = 'Get User Info';
    ModifyAllowed = false;
    DeleteAllowed = false;

    layout
    {
        area(Content)
        {
            group(GroupName)
            {
                field(TokenID; TokenID)
                {
                    ApplicationArea = All;
                    ExtendedDatatype = Masked;
                    // HideValue = false;
                    trigger OnValidate()
                    var
                        Eposinterfsce: Codeunit "LSC POS Control Interface";
                        httpresponse: HttpResponseMessage;
                        postrans: Record "LSC POS Transaction";
                        Offers: Record Cust_App_Offers;  //AlleRSN 161123
                        rec_Offers: Record Cust_App_Offers; //AlleRSN 161123 
                        LSCPOSMenuLine4: Record "LSC POS Menu Line"; //ALLENICK_171123      

                    begin
                        twcapisetup.Get();
                        IF postrans.Get(POSEvent.GetReceiptNo()) then;
                        storeid := postrans."Store No.";
                        APIURL := twcapisetup.VerifyAPIUrl + 'token=' + TokenID + '&storeId=' + storeid;
                        httpresponse := CallServiceStatus(APIUrl, HTTPRequestTypeEnum::Get);
                        //Message('%1', httpresponse); //To be Remove

                        IF httpresponse.IsSuccessStatusCode then begin
                            httpresponse.Content().ReadAs(RespText);
                            userid := GetUserData(RespText);
                            //AlleRSN 161123 start

                            rec_Offers.Reset();
                            IF rec_Offers.FindLast() then;
                            Offers.Init();
                            Offers."Entry No." := rec_Offers."Entry No." + 1;
                            Offers.UserId := userid;
                            Offers."Receipt No" := postrans."Receipt No.";
                            Offers."Token ID" := TokenID;
                            LSCPOSMenuLine4.Reset();
                            LSCPOSMenuLine4.SetRange("Menu ID", '#APPCUSTOMER');
                            IF LSCPOSMenuLine4.FindFirst() then;
                            Offers."Wallet Balance" := LSCPOSMenuLine4."Wallet Balance";//ALLE_171123
                            Offers."Wave Coin Balance" := LSCPOSMenuLine4."Wave Coin Balance";//ALLENICK_171123
                            Offers.Insert(true);

                            //AlleRSN 161123 end
                        end;
                        //UpdateSubscription(Id, storeid, userID);
                        UpdateSubscription(Id, storeid, userid); //AlleRSN 301023

                        //Eposinterfsce.Refresh();
                        POSCTRL.RefreshMenu('##DEFAULT', '#SUBS');
                        Updateoffers(Id, storeid);
                        //postrans.CustAppUserId := userid; //AlleRSN 301023
                        //postrans.Modify(); //AlleRSN 301023
                        Message('Verify app scan successfully');//ALLE_NICK_010224
                        CurrPage.Close();
                    end;

                }
                field(storeid; storeid)
                {
                    ApplicationArea = all;
                    Visible = false;

                }
            }
        }
    }
    trigger OnOpenPage()
    begin
        //AlleRSN 101023 start
        IF postrans1.Get(POSEvent.GetReceiptNo()) then begin
            IF (postrans1."Sales Type" = 'TAKEAWAY') OR (postrans1."Sales Type" = 'PRE-ORDER') then begin
                Error('Not Allowed to Scan Verify App User');
            end;
        end;
        //AlleRSN 101023 end
        ClearAll();
    end;

    procedure GetUserData(responsemsg: Text): Code[20]
    var
        JSONManagement: Codeunit "JSON Management";
        Datajsonobject: Text;
        ObjectJSONManagement: Codeunit "JSON Management";
        firstname: Text;
        lastname: Text;
        mobilenum: Text;
        annivdate: Text;
        level: Text;
        i: Integer;
        levelname: Text;
        lscposclient: page "LSC POS Client";
        POSCTRL: Codeunit "LSC POS Control Interface";
        Leveljsonobject: Text;
        waveCoinjsonobject: Text;
        walletDetailsjsonobject: Text;
        buckettype: Text;
        balance: Text;
        coinValue: Text;
        MainBal: Text;
        PromoBal: Text;
        FavoJsonobject: Text;
        itemid: Text;
        prodname: Text;
        ArrayJSONManagement: Codeunit "JSON Management";
        JsonArrayText: Text;
        LSCPOSMenuLine1: Record "LSC POS Menu Line";
        LSCPOSMenuLine2: Record "LSC POS Menu Line";

    begin
        LSCPOSMenuLine.Reset();
        LSCPOSMenuLine.SetRange("Menu ID", '#APPCUSTOMER');
        IF LSCPOSMenuLine.FindFirst() then begin
            //IF Confirm('Do you want to overrite the customer details?') then begin
            LSCPOSMenuLine.DeleteAll();

            //end
            //else
            //  exit
        end;


        LSCPOSMenuLine.Reset();
        LSCPOSMenuLine.SetRange("Menu ID", '#FVRTS');
        IF LSCPOSMenuLine.FindFirst() then
            LSCPOSMenuLine.DeleteAll();



        POSCTRL.RefreshMenu('##DEFAULT', '#APPCUSTOMER');
        POSCTRL.RefreshMenu('##DEFAULT', '##SUBSCRIPTION');
        POSCTRL.RefreshMenu('##DEFAULT', '#FVRTS');

        IF RespText <> '' then begin
            JSONManagement.InitializeObject(RespText);
            if JSONManagement.GetArrayPropertyValueAsStringByName('data', Datajsonobject) then begin
                ObjectJSONManagement.InitializeObject(Datajsonobject);
                ObjectJSONManagement.GetStringPropertyValueByName('userId', Id);
                ObjectJSONManagement.GetStringPropertyValueByName('firstName', firstname);
                ObjectJSONManagement.GetStringPropertyValueByName('lastName', lastname);
                ObjectJSONManagement.GetStringPropertyValueByName('mobileNumber', mobilenum);
                ObjectJSONManagement.GetStringPropertyValueByName('anniversaryDate', annivdate);

                JSONManagement.InitializeObject(Datajsonobject);
                IF JSONManagement.GetArrayPropertyValueAsStringByName('levelDetails', Leveljsonobject) then begin

                    ObjectJSONManagement.InitializeObject(Leveljsonobject);
                    ObjectJSONManagement.GetStringPropertyValueByName('level', Level);
                    ObjectJSONManagement.GetStringPropertyValueByName('name', levelname);
                end;
                JSONManagement.InitializeObject(Datajsonobject);
                IF JSONManagement.GetArrayPropertyValueAsStringByName('waveCoinDetails', waveCoinjsonobject) then begin

                    ObjectJSONManagement.InitializeObject(waveCoinjsonobject);
                    ObjectJSONManagement.GetStringPropertyValueByName('bucketType', buckettype);
                    ObjectJSONManagement.GetStringPropertyValueByName('balance', balance);
                    ObjectJSONManagement.GetArrayPropertyValueAsStringByName('coinValue', coinValue);
                end;
                JSONManagement.InitializeObject(Datajsonobject);
                IF JSONManagement.GetArrayPropertyValueAsStringByName('walletDetails', walletDetailsjsonobject) then begin

                    ObjectJSONManagement.InitializeObject(walletDetailsjsonobject);
                    ObjectJSONManagement.GetStringPropertyValueByName('MAIN_BALANCE', MainBal);
                    ObjectJSONManagement.GetStringPropertyValueByName('PROMO_BALANCE', PromoBal);
                end;

                buckettype := 'WAVE COIN';

                LSCPOSMenuLine.Init();
                LSCPOSMenuLine.Validate("Profile ID", '##DEFAULT');
                LSCPOSMenuLine.Validate("Menu ID", '#APPCUSTOMER');
                LSCPOSMenuLine.Validate("Key No.", 1);
                LSCPOSMenuLine.Validate(CustAppUserId, id);
                LSCPOSMenuLine.Validate("Cust App Order", true);
                LSCPOSMenuLine.Validate(RowSpan, 2);
                LSCPOSMenuLine.Validate("Wallet Balance", MainBal);
                LSCPOSMenuLine.Validate("Wave Coin Balance", balance);
                LSCPOSMenuLine.Validate("Promo Balance", PromoBal);
                LSCPOSMenuLine."Mobile NO." := mobilenum; //ALLE_NICK_081123
                LSCPOSMenuLine.Description := firstname + ' ' + lastname;
                LSCPOSMenuLine.Insert();

                LSCPOSMenuLine.Init();
                LSCPOSMenuLine.Validate("Profile ID", '##DEFAULT');
                LSCPOSMenuLine.Validate("Menu ID", '#APPCUSTOMER');
                LSCPOSMenuLine.Validate("Key No.", 2);
                LSCPOSMenuLine.Description := levelname;
                LSCPOSMenuLine.Validate(CustAppUserId, id);
                LSCPOSMenuLine."Mobile NO." := mobilenum; //ALLE_NICK_081123
                LSCPOSMenuLine.Validate("Cust App Order", true);

                LSCPOSMenuLine.Validate("Wallet Balance", MainBal);
                LSCPOSMenuLine.Validate("Wave Coin Balance", balance);
                LSCPOSMenuLine.Validate("Promo Balance", PromoBal);
                LSCPOSMenuLine.Insert();

                LSCPOSMenuLine.Init();
                LSCPOSMenuLine.Validate("Profile ID", '##DEFAULT');
                LSCPOSMenuLine.Validate("Menu ID", '#APPCUSTOMER');
                LSCPOSMenuLine.Validate("Key No.", 3);
                LSCPOSMenuLine.Validate(CustAppUserId, id);
                LSCPOSMenuLine.Validate("Cust App Order", true);
                LSCPOSMenuLine."Mobile NO." := mobilenum; //ALLE_NICK_081123
                LSCPOSMenuLine.Validate("Wallet Balance", MainBal);
                LSCPOSMenuLine.Validate("Wave Coin Balance", balance);
                LSCPOSMenuLine.Validate("Promo Balance", PromoBal);
                LSCPOSMenuLine.Description := 'Wave Coin' + '\' + balance;
                LSCPOSMenuLine.Insert();

                LSCPOSMenuLine.Init();
                LSCPOSMenuLine.Validate("Profile ID", '##DEFAULT');
                LSCPOSMenuLine.Validate("Menu ID", '#APPCUSTOMER');
                LSCPOSMenuLine.Validate("Key No.", 5);
                LSCPOSMenuLine.Validate(CustAppUserId, id);
                LSCPOSMenuLine.Validate("Cust App Order", true);
                LSCPOSMenuLine."Mobile NO." := mobilenum; //ALLE_NICK_081123
                LSCPOSMenuLine.Validate("Wallet Balance", MainBal);
                LSCPOSMenuLine.Validate("Wave Coin Balance", balance);
                LSCPOSMenuLine.Validate("Promo Balance", PromoBal);
                LSCPOSMenuLine.Description := 'Promo Wallet' + '\' + PromoBal;
                LSCPOSMenuLine.Insert();

                LSCPOSMenuLine.Init();
                LSCPOSMenuLine.Validate("Profile ID", '##DEFAULT');
                LSCPOSMenuLine.Validate("Menu ID", '#APPCUSTOMER');
                LSCPOSMenuLine.Validate("Key No.", 6);
                LSCPOSMenuLine.Validate(CustAppUserId, id);
                LSCPOSMenuLine."Mobile NO." := mobilenum;  //ALLE_NICK_081123
                LSCPOSMenuLine.Validate("Cust App Order", true);
                LSCPOSMenuLine.Validate("Wallet Balance", MainBal);
                LSCPOSMenuLine.Validate("Wave Coin Balance", balance);
                LSCPOSMenuLine.Validate("Promo Balance", PromoBal);
                LSCPOSMenuLine.Description := 'Main Wallet' + '\' + MainBal;
                LSCPOSMenuLine.Insert();

                POSCTRL.RefreshMenuButton('##DEFAULT', '#APPCUSTOMER', 1);
                POSCTRL.RefreshMenuButton('##DEFAULT', '#APPCUSTOMER', 2);
                POSCTRL.RefreshMenuButton('##DEFAULT', '#APPCUSTOMER', 3);
                POSCTRL.RefreshMenuButton('##DEFAULT', '#APPCUSTOMER', 5);
                POSCTRL.RefreshMenuButton('##DEFAULT', '#APPCUSTOMER', 6);


                JSONManagement.InitializeObject(Datajsonobject);
                IF JSONManagement.GetArrayPropertyValueAsStringByName('favourites', JsonArrayText) then begin
                    ArrayJSONManagement.InitializeCollection(JsonArrayText);
                    for i := 0 to ArrayJSONManagement.GetCollectionCount() - 1 do begin
                        ArrayJSONManagement.GetObjectFromCollectionByIndex(FavoJsonobject, i);
                        ObjectJSONManagement.InitializeObject(FavoJsonobject);
                        ObjectJSONManagement.GetStringPropertyValueByName('posItemId', itemid);
                        ObjectJSONManagement.GetStringPropertyValueByName('productName', prodName);

                        LSCPOSMenuLine.Init();
                        LSCPOSMenuLine.Validate("Profile ID", '##DEFAULT');
                        LSCPOSMenuLine.Validate("Menu ID", '#FVRTS');
                        LSCPOSMenuLine.Validate("Key No.", i + 1);
                        LSCPOSMenuLine.Validate(Description, prodname);
                        LSCPOSMenuLine.Validate(Command, 'PLU_K');
                        LSCPOSMenuLine.Validate(Parameter, itemid);
                        LSCPOSMenuLine.Insert(true);
                    end;
                    //   POSCTRL.RefreshMenu('##DEFAULT', '#REORD');
                    POSCTRL.RefreshMenu('##DEFAULT', '#FVRTS');

                    exit(Id);

                end;
            end;
        end;
    end;
    //  end;

    procedure CallServiceStatus(RequestUrl: Text; RequestType: Enum HTTPRequestTypeEnum): HttpResponseMessage
    var
        httpWebClient: HttpClient;
        RequestHeaders: HttpHeaders;
        ResponseMessage: HttpResponseMessage;
        RequestMessage: HttpRequestMessage;
        ResponseText: Text;
        contentHeaders: HttpHeaders;
        RequestContent: HttpContent;
        Xml: Text;
        Instr: InStream;
        OutStrm: OutStream;
        Convert: Codeunit "Base64 Convert";
        TempBlob: Codeunit "Temp Blob";

    begin
        twcapisetup.Get();
        RequestHeaders := httpWebClient.DefaultRequestHeaders();

        case RequestType of
            RequestType::Get:
                begin
                    RequestMessage.GetHeaders(contentHeaders);
                    contentHeaders.Add('X-API-VERSION', Format(twcapisetup."X-API-VERSION"));
                    contentHeaders.Add('X-API-KEY', twcapisetup."X-API-KEY");
                    RequestMessage.SetRequestUri(RequestUrl);
                    RequestMessage.Method := 'GET';
                    httpWebClient.Send(RequestMessage, ResponseMessage);
                end;
        end;
        exit(ResponseMessage);
        //   ResponseMessage.Content().ReadAs(ResponseText);
        //  exit(ResponseText);
    end;

    local procedure UpdateSubscription(userid: Text; Storeid: Text; user_id: Code[20])
    var
        LSCPOSMenuLine1: Record "LSC POS Menu Line";
        i: Integer;
        Item: Record Item;
        usedqty: Decimal;
        totalqty: Decimal;
        usedqty1: Text;
        totalqty1: Text;
        j: Integer;
        k: Integer;
        id: Text;
        responseArray: JsonArray;
        responseArray1: JsonArray;
        responseArray2: JsonArray;
        json_Token: JsonToken;
        json_Object: JsonObject;
        userInfo_JsonObject: JsonObject;
        json_Methods: Codeunit JSON_Methods;
        retJsonValue: JsonValue; // this can be used when getting value from GetJsonValue method
        addressJsonObject: JsonObject;
        addressJsonToken: JsonToken;
        geoJsonObject: JsonObject;
        geoJsonToken: JsonToken;
        companyJsonObject: JsonObject;
        companyJsonToken: JsonToken;
        Json_Token1: JsonToken;
        Json_Token2: JsonToken;
        Json_Token3: JsonToken;
        title: Text;
        Desc: Text;
        userplanid: Text;
        keyno: Integer;
        jsonvalue: JsonValue;
        total: Integer;
        httpresponse: HttpResponseMessage;


    begin
        twcapisetup.Get();
        APIURL := twcapisetup.SubscriptionAPIUrl + 'userId=' + userid + '&storeId=' + Storeid;
        httpresponse := CallServiceStatus(APIUrl, HTTPRequestTypeEnum::Get);

        LSCPOSMenuLine.Reset();
        LSCPOSMenuLine.SetRange(Description, 'Subscriptions');
        IF LSCPOSMenuLine.FindFirst() then begin
            //Message('%1', LSCPOSMenuLine.Parameter);
            LSCPOSMenuLine1.Reset();
            LSCPOSMenuLine1.SetRange("Menu ID", LSCPOSMenuLine.Parameter);
            IF LSCPOSMenuLine1.FindFirst() then
                repeat
                    //   Message(LSCPOSMenuLine1.Parameter);
                    LSCPOSMenuLine2.Reset();
                    LSCPOSMenuLine2.SetRange("Menu ID", LSCPOSMenuLine1.Parameter);
                    IF LSCPOSMenuLine2.FindSet() then
                        LSCPOSMenuLine2.DeleteAll();
                    LSCPOSMenuLine1.Delete();
                until LSCPOSMenuLine1.Next() = 0;
        end;
        For i := 1 to 7 do begin
            LSCPOSMenuLine.Reset();
            LSCPOSMenuLine.Init();
            LSCPOSMenuLine.Validate("Profile ID", '##DEFAULT');
            LSCPOSMenuLine.Validate("Menu ID", '#SUBS');
            LSCPOSMenuLine.Validate("Key No.", i);
            LSCPOSMenuLine.Description := '';
            LSCPOSMenuLine.Insert();
        end;
        POSCTRL.RefreshMenu('##DEFAULT', '#SUBS');
        //Message('%1', RespText);
        IF httpresponse.IsSuccessStatusCode then begin
            httpresponse.Content.ReadAs(RespText);
            LSCPOSMenuLine.Reset();
            LSCPOSMenuLine.SetRange(Description, 'Subscriptions');
            IF LSCPOSMenuLine.FindFirst() then begin
                //Message('%1', LSCPOSMenuLine.Parameter);
                LSCPOSMenuLine1.Reset();
                LSCPOSMenuLine1.SetRange("Menu ID", LSCPOSMenuLine.Parameter);
                IF LSCPOSMenuLine1.FindFirst() then
                    repeat
                        //   Message(LSCPOSMenuLine1.Parameter);
                        LSCPOSMenuLine2.Reset();
                        LSCPOSMenuLine2.SetRange("Menu ID", LSCPOSMenuLine1.Parameter);
                        IF LSCPOSMenuLine2.FindSet() then
                            LSCPOSMenuLine2.DeleteAll();
                        LSCPOSMenuLine1.Delete();
                    until LSCPOSMenuLine1.Next() = 0;
            end;
            For i := 1 to 7 do begin
                LSCPOSMenuLine.Reset();
                LSCPOSMenuLine.Init();
                LSCPOSMenuLine.Validate("Profile ID", '##DEFAULT');
                LSCPOSMenuLine.Validate("Menu ID", '#SUBS');
                LSCPOSMenuLine.Validate("Key No.", i);
                LSCPOSMenuLine.Description := '';
                LSCPOSMenuLine.Insert();
            end;
            POSCTRL.RefreshMenu('##DEFAULT', '#SUBS');

            Clear(LSCPOSMenuLine1);
            Clear(LSCPOSMenuLine2);
            Clear(LSCPOSMenuLine3);
            Clear(LSCPOSMenuLine);
            Clear(totalqty);
            Clear(totalqty1);
            Clear(usedqty);
            Clear(usedqty1);

            if json_Token.ReadFrom(RespText) then begin
                json_Token.SelectToken('data', Json_Token1);
                if json_Token1.IsArray then   // json_Token.IsArray; json_Token.IsObject; json_Token.IsValue;
                    responseArray := json_Token1.AsArray();

                for i := 0 to responseArray.Count() - 1 do begin
                    // Get First Array Result
                    responseArray.Get(i, json_Token1);
                    // Convert JsonToken to JsonObject
                    if json_Token1.IsObject then begin
                        userInfo_JsonObject := json_Token1.AsObject();

                        Json_Token1.SelectToken('userPlans', Json_Token2);
                        if json_Token2.IsArray then   // json_Token.IsArray; json_Token.IsObject; json_Token.IsValue;
                            responseArray1 := json_Token2.AsArray();

                        for j := 0 to responseArray1.Count() - 1 do begin
                            responseArray1.Get(j, json_Token2);
                            // Convert JsonToken to JsonObject
                            if json_Token2.IsObject then begin
                                addressJsonObject := json_Token2.AsObject();


                                LSCPOSMenuLine.Reset();
                                LSCPOSMenuLine.SetRange(Description, 'Subscriptions');
                                IF LSCPOSMenuLine.FindFirst() then begin

                                    LSCPOSMenuLine2.Reset();
                                    LSCPOSMenuLine2.SetRange("Menu ID", LSCPOSMenuLine.Parameter);
                                    LSCPOSMenuLine2.SetRange("Key No.", keyno + 1);
                                    IF LSCPOSMenuLine2.FindFirst() then
                                        LSCPOSMenuLine2.DeleteAll();

                                    LSCPOSMenuLine1.Init();
                                    LSCPOSMenuLine1."Profile ID" := '##DEFAULT';
                                    LSCPOSMenuLine1.Validate("Profile ID");
                                    LSCPOSMenuLine1."Menu ID" := LSCPOSMenuLine.Parameter;

                                    LSCPOSMenuLine1.Validate("Menu ID");
                                    LSCPOSMenuLine1.Validate("Parameter Type", LSCPOSMenuLine1."Parameter Type"::Menu);


                                    LSCPOSMenuLine1.Description := json_Methods.GetJsonToken(userInfo_JsonObject, 'title').AsValue().AsTEXT() + ' - pack of ' + json_Methods.GetJsonToken(addressJsonObject, 'totalQuantity').AsValue().AsTEXT();
                                    LSCPOSMenuLine1.Validate(Description);
                                    LSCPOSMenuLine1.Command := 'MENU2';
                                    LSCPOSMenuLine1.Validate(Command);
                                    LSCPOSMenuLine1.Validate("Key No.");
                                    LSCPOSMenuLine1.IsSubscription := true;
                                    LSCPOSMenuLine1."Key No." := keyno + 1;
                                    IF LSCPOSMenuLine1."Key No." = 1 then
                                        LSCPOSMenuLine1.Validate(Parameter, '#PACK1')
                                    else
                                        if LSCPOSMenuLine1."Key No." = 2 then
                                            LSCPOSMenuLine1.Validate(Parameter, '#PACK2')
                                        else
                                            if LSCPOSMenuLine1."Key No." = 3 then
                                                LSCPOSMenuLine1.Validate(Parameter, '#PACK3')
                                            else
                                                if LSCPOSMenuLine1."Key No." = 4 then
                                                    LSCPOSMenuLine1.Validate(Parameter, '#PACK4')
                                                else
                                                    if LSCPOSMenuLine1."Key No." = 5 then
                                                        LSCPOSMenuLine1.Validate(Parameter, '#PACK5')
                                                    else
                                                        if LSCPOSMenuLine1."Key No." = 6 then
                                                            LSCPOSMenuLine1.Validate(Parameter, '#PACK6')
                                                        else
                                                            if LSCPOSMenuLine1."Key No." = 7 then
                                                                LSCPOSMenuLine1.Validate(Parameter, '#PACK7')
                                                            else
                                                                if LSCPOSMenuLine1."Key No." = 8 then
                                                                    LSCPOSMenuLine1.Validate(Parameter, '#PACK8')
                                                                else
                                                                    if LSCPOSMenuLine1."Key No." = 9 then
                                                                        LSCPOSMenuLine1.Validate(Parameter, '#PACK9');




                                    LSCPOSMenuLine1.Validate("Subscription ID", json_Methods.GetJsonToken(userInfo_JsonObject, 'id').AsValue().AsTEXT());
                                    LSCPOSMenuLine1.Validate("User Plan Id", json_Methods.GetJsonToken(addressJsonObject, 'userPlanId').AsValue().AsTEXT());
                                    LSCPOSMenuLine1.Validate(CustAppUserId, user_id);
                                    LSCPOSMenuLine1.Validate("Cust App Order", true);
                                    LSCPOSMenuLine1.Insert(true);
                                    userplanid := json_Methods.GetJsonToken(userInfo_JsonObject, 'id').AsValue().AsTEXT();

                                    keyno := LSCPOSMenuLine1."Key No.";
                                end;

                                json_Token2.SelectToken('products', Json_Token3);
                                if Json_Token3.IsArray then   // json_Token.IsArray; json_Token.IsObject; json_Token.IsValue;
                                    responseArray2 := json_Token3.AsArray();

                                for k := 0 to responseArray2.Count() - 1 do begin
                                    responseArray2.Get(k, json_Token3);
                                    if json_Token3.IsObject then begin

                                        geoJsonObject := json_Token3.AsObject();
                                        title := json_Methods.GetJsonToken(geoJsonObject, 'title').AsValue().AsTEXT();
                                        Desc := json_Methods.GetJsonToken(geoJsonObject, 'description').AsValue().AsTEXT();
                                        totalqty := json_Methods.GetJsonToken(addressJsonObject, 'totalQuantity').AsValue().AsInteger();
                                        usedqty := json_Methods.GetJsonToken(addressJsonObject, 'usedQuantity').AsValue().AsInteger();

                                        jsonvalue := json_Methods.GetJsonToken(geoJsonObject, 'posItemCode').AsValue();
                                        IF not jsonvalue.IsNull then begin
                                            IF totalqty - usedqty <> 0 then begin
                                                Clear(LSCPOSMenuLine3);
                                                LSCPOSMenuLine2.Init();
                                                LSCPOSMenuLine2."Profile ID" := '##DEFAULT';
                                                LSCPOSMenuLine2.Validate("Profile ID");
                                                LSCPOSMenuLine2."Menu ID" := LSCPOSMenuLine1.Parameter;
                                                LSCPOSMenuLine2.Validate("Menu ID");
                                                LSCPOSMenuLine2.Description := title + '-' + desc + '-' + Format(totalqty - usedqty);
                                                LSCPOSMenuLine2.Validate(Description);
                                                LSCPOSMenuLine2.Command := 'PLU_K';
                                                LSCPOSMenuLine2.Validate(Command);
                                                LSCPOSMenuLine2.IsSubscription := true;
                                                LSCPOSMenuLine2."Parameter Type" := LSCPOSMenuLine1."Parameter Type"::Item;
                                                LSCPOSMenuLine2.Validate("Parameter Type");
                                                LSCPOSMenuLine2.Parameter := json_Methods.GetJsonToken(geoJsonObject, 'posItemCode').AsValue().AsCode();
                                                IF Item.Get(json_Methods.GetJsonToken(geoJsonObject, 'posItemCode').AsValue().AsCode()) then begin
                                                    item."Subscription Item" := true;
                                                    Item.Modify();
                                                end;
                                                LSCPOSMenuLine2.Validate("Subscription ID", LSCPOSMenuLine1."Subscription ID");
                                                LSCPOSMenuLine2.Validate("User Plan Id", LSCPOSMenuLine1."User Plan Id");
                                                LSCPOSMenuLine2.Validate("Subscription Qty", totalqty - usedqty);
                                                LSCPOSMenuLine2.Validate(CustAppUserId, user_id);
                                                LSCPOSMenuLine2.Validate("Cust App Order", true);

                                                LSCPOSMenuLine3.Reset();
                                                LSCPOSMenuLine3.SetRange("Menu ID", LSCPOSMenuLine1.Parameter);
                                                // LSCPOSMenuLine3.SetRange("Profile ID", LSCPOSMenuLine2."Profile ID");
                                                IF LSCPOSMenuLine3.FindLast() then;

                                                // message(LSCPOSMenuLine3."Menu ID");
                                                LSCPOSMenuLine2."Key No." := LSCPOSMenuLine3."Key No." + 1;
                                                LSCPOSMenuLine2.Validate("Key No.");
                                                LSCPOSMenuLine2.Insert(true);
                                                POSCTRL.RefreshMenu('##DEFAULT', LSCPOSMenuLine1.Parameter);

                                            end;
                                        end;
                                    end;
                                end;


                            end;
                        end;
                        //  POSCTRL.RefreshMenu('##DEFAULT', '#SUBS');
                        //POSCTRL.RefreshMenu('##DEFAULT', '#PACK1');


                        //POSCTRL.comm
                    end;
                end;
            end;
        end;
        POSCTRL.RefreshMenu('##DEFAULT', '#SUBS');
        POSCTRL.RefreshMenu('##DEFAULT', '#PACK1');
    end;

    procedure Updateoffers(userid: Text; Storeid: Text)
    var
        JsonTkn: JsonToken;
        JsonObj: JsonObject;
        JsonArr: JsonArray;
        loyaltyDiscounts: JsonObject;

        JsonTknOrd: JsonToken;
        JsonObjOrd: JsonObject;

        JsonTknProd: JsonToken;
        JsonObjProd: JsonObject;
        JsonArrProd: JsonArray;

        bogojsntkn: JsonToken;
        bogoosnobj: JsonObject;
        bogojsnarr: JsonArray;
        iterator2: Integer;

        iterator: Integer;
        iterator1: Integer;
        json_Methods: Codeunit JSON_Methods;

        //for formatting the list
        TypeHelper: Codeunit "Type Helper";
        CRLF: Text;


        //Main Outer Object
        FirstName: Text;
        LastName: Text;
        // LoyaltyDisc: List of [Text];
        //LoyaltyDiscMain: List of [List of [Text]];

        //Order Disc Variables
        OrdDisc: List of [Text];
        OrdDiscMain: List of [List of [Text]];

        //Prod Disc Variables
        NameProdDisc: Text;
        CodeProdDisc: Text;
        ValueProdDisc: Text;
        TypeProdDisc: Text;

        ProductMsg: Text;
        ProductIterator: Text;
        ProdDisc: List of [Text];

        LSCPOSMenuLine: Record "LSC POS Menu Line";
        LSCPOSMenuLine1: Record "LSC POS Menu Line";
        LSCPOSMenuLine2: Record "LSC POS Menu Line";
        Item: Record Item;
        jsonvalue: JsonValue;

        Offers: Record Cust_App_Offers;
        rec_Offers: Record Cust_App_Offers;
        httpresponse: HttpResponseMessage;
        postrans: Record "LSC POS Transaction"; //AlleRSN 301023
        LSCPOSMenuLine4: Record "LSC POS Menu Line"; //AlleRSN 011123
        CartDiscCount: Integer;
        LoyDiscCount: Integer;
        ProdDiscCount: Integer;
        AddOnDiscCount: Integer;//AlleRSN 150124
    begin
        twcapisetup.Get();
        IF postrans.Get(POSEvent.GetReceiptNo()) then;  //AlleRSN 301023
        APIURL := twcapisetup.OffersAPIUrl + 'userId=' + userid + '&storeId=' + Storeid;
        httpresponse := CallServiceStatus(APIUrl, HTTPRequestTypeEnum::Get);

        CRLF := TypeHelper.CRLFSeparator();

        LSCPOSMenuLine2.Reset();
        LSCPOSMenuLine2.SetRange("Menu ID", 'LOYALTYDISCOUNTS');
        IF LSCPOSMenuLine2.FindSet() then
            LSCPOSMenuLine2.DeleteAll();


        LSCPOSMenuLine2.Reset();
        LSCPOSMenuLine2.SetRange("Menu ID", 'ORDERDISCOUNTS');
        IF LSCPOSMenuLine2.FindSet() then
            LSCPOSMenuLine2.DeleteAll();


        LSCPOSMenuLine2.Reset();
        LSCPOSMenuLine2.SetRange("Menu ID", 'PRODUCTDISCOUNTS');
        IF LSCPOSMenuLine2.FindSet() then
            LSCPOSMenuLine2.DeleteAll();

        //AlleRSN 150124 start
        LSCPOSMenuLine.Reset();
        LSCPOSMenuLine.SetRange("Menu ID", '#TWCOFFER');
        IF LSCPOSMenuLine.FindFirst() then begin
            LSCPOSMenuLine.DeleteAll();
        end;

        POSCTRL.RefreshMenu('##DEFAULT', '#TWCOFFER');
        //AlleRSN 150124 end

        //AlleRSN 011123 start
        LSCPOSMenuLine4.Reset();
        LSCPOSMenuLine4.SetRange("Menu ID", '#APPCUSTOMER');
        IF LSCPOSMenuLine4.FindFirst() then;

        //LSCPOSMenuLine.Validate("Profile ID", '##DEFAULT');
        //LSCPOSMenuLine.Validate("Menu ID", '#APPCUSTOMER');
        //AlleRSn 011123 end            

        IF httpresponse.IsSuccessStatusCode then begin
            httpresponse.Content.ReadAs(RespText);
            if JsonTkn.ReadFrom(RespText) then begin
                if JsonTkn.IsObject then begin
                    JsonObj := JsonTkn.AsObject();
                    JsonObj.Get('data', JsonTkn);
                    if JsonTkn.IsObject then begin
                        JsonObj := JsonTkn.AsObject();

                        rec_Offers.Reset();
                        rec_Offers.SetRange(UserId, json_Methods.GetJsonToken(JsonObj, 'userId').AsValue().AsText());
                        rec_Offers.SetFilter("Receipt No", '<>%1', postrans."Receipt No."); //AlleRSN 161123
                        IF rec_Offers.FindSet() then
                            rec_Offers.DeleteAll();

                        //Loyalty Discount Array Iteration
                        JsonObj.Get('loyaltyDiscounts', JsonTkn);
                        if JsonTkn.IsArray then begin
                            JsonArr := JsonTkn.AsArray();

                            for iterator := 0 to JsonArr.Count - 1 do begin
                                JsonArr.Get(iterator, JsonTkn);

                                if JsonTkn.IsObject then begin
                                    loyaltyDiscounts := JsonTkn.AsObject();

                                    loyaltyDiscounts.Get('products', JsonTknProd);
                                    if JsonTknProd.IsArray then begin
                                        JsonArrProd := JsonTknProd.AsArray();
                                        for iterator1 := 0 to JsonArrProd.Count - 1 do begin
                                            JsonArrProd.Get(iterator1, JsonTknProd);
                                            If JsonTknProd.IsObject then begin
                                                JsonObjProd := JsonTknProd.AsObject();

                                                rec_Offers.Reset();
                                                IF rec_Offers.FindLast() then;
                                                Offers.Init();
                                                Offers."Entry No." := rec_Offers."Entry No." + 1;
                                                Offers.UserId := json_Methods.GetJsonToken(JsonObj, 'userId').AsValue().AsText();
                                                Offers."Discount Id" := json_Methods.GetJsonToken(loyaltyDiscounts, 'discountId').AsValue().AsText();
                                                Offers.Code := json_Methods.GetJsonToken(loyaltyDiscounts, 'code').AsValue().AsText();
                                                Offers."Offer Type" := Offers."Offer Type"::loyaltyDiscounts;
                                                Offers."Discount Type" := json_Methods.GetJsonToken(loyaltyDiscounts, 'type').AsValue().AsText();
                                                Offers.appProductId := json_Methods.GetJsonToken(JsonObjProd, 'appProductId').AsValue().AsText();

                                                jsonvalue := json_Methods.GetJsonToken(JsonObjProd, 'posItemId').AsValue();
                                                IF not jsonvalue.IsNull then
                                                    Offers.posItemId := json_Methods.GetJsonToken(JsonObjProd, 'posItemId').AsValue().AsText();
                                                Offers.productName := json_Methods.GetJsonToken(JsonObjProd, 'productName').AsValue().AsText();
                                                Offers."Token ID" := TokenID;
                                                Offers."Receipt No" := postrans."Receipt No."; //AlleRSN 301023
                                                Offers."Wallet Balance" := LSCPOSMenuLine4."Wallet Balance";//AJ_alle_01112023
                                                Offers."Wave Coin Balance" := LSCPOSMenuLine4."Wave Coin Balance";//AJ_alle_01112023
                                                LoyDiscCount := LoyDiscCount + 1; //AlleRSN 150124
                                                Offers.Insert(true);

                                            end;
                                        end;

                                    end
                                    else begin
                                        rec_Offers.Reset();
                                        IF rec_Offers.FindLast() then;
                                        Offers.Init();
                                        Offers."Entry No." := rec_Offers."Entry No." + 1;
                                        Offers.UserId := json_Methods.GetJsonToken(JsonObj, 'userId').AsValue().AsText();
                                        Offers."Discount Id" := json_Methods.GetJsonToken(loyaltyDiscounts, 'discountId').AsValue().AsText();
                                        Offers.Code := json_Methods.GetJsonToken(loyaltyDiscounts, 'code').AsValue().AsText();
                                        Offers."Offer Type" := Offers."Offer Type"::loyaltyDiscounts;
                                        Offers."Discount Type" := json_Methods.GetJsonToken(loyaltyDiscounts, 'type').AsValue().AsText();
                                        //   Offers.appProductId := json_Methods.GetJsonToken(JsonObjProd, 'appProductId').AsValue().AsText();

                                        // jsonvalue := json_Methods.GetJsonToken(JsonObjProd, 'posItemId').AsValue();
                                        // IF not jsonvalue.IsNull then
                                        //   Offers.posItemId := json_Methods.GetJsonToken(JsonObjProd, 'posItemId').AsValue().AsText();
                                        //Offers.productName := json_Methods.GetJsonToken(JsonObjProd, 'productName').AsValue().AsText();
                                        Offers."Token ID" := TokenID;
                                        Offers."Receipt No" := postrans."Receipt No."; //AlleRSN 301023
                                        Offers."Wallet Balance" := LSCPOSMenuLine4."Wallet Balance";//AJ_alle_01112023
                                        Offers."Wave Coin Balance" := LSCPOSMenuLine4."Wave Coin Balance";//AJ_alle_01112023
                                        Offers.Insert(true);

                                    end;

                                end;
                            end;
                            //AlleRSN 150124 start

                            //AlleRSN 150124 end

                        end;

                        //Order Discount Array Iteration
                        JsonObj.Get('orderDiscounts', JsonTkn);
                        if JsonTkn.IsArray then begin
                            JsonArr := JsonTkn.AsArray();

                            for iterator := 0 to JsonArr.Count - 1 do begin
                                JsonArr.Get(iterator, JsonTkn);


                                if JsonTkn.IsObject then begin
                                    JsonObjOrd := JsonTkn.AsObject();

                                    rec_Offers.Reset();
                                    IF rec_Offers.FindLast() then;

                                    Offers.Init();
                                    Offers."Entry No." := rec_Offers."Entry No." + 1;
                                    Offers.UserId := json_Methods.GetJsonToken(JsonObj, 'userId').AsValue().AsText();
                                    Offers."Discount Id" := json_Methods.GetJsonToken(JsonObjOrd, 'discountId').AsValue().AsText();
                                    Offers.Code := json_Methods.GetJsonToken(JsonObjOrd, 'code').AsValue().AsText();
                                    Offers."Offer Type" := Offers."Offer Type"::orderDiscounts;
                                    Offers."Discount Type" := json_Methods.GetJsonToken(JsonObjOrd, 'type').AsValue().AsText();
                                    Offers."Token ID" := TokenID;
                                    Offers."Receipt No" := postrans."Receipt No."; //AlleRSN 301023
                                    Offers."Wallet Balance" := LSCPOSMenuLine4."Wallet Balance";//AJ_alle_01112023
                                    Offers."Wave Coin Balance" := LSCPOSMenuLine4."Wave Coin Balance";//AJ_alle_01112023
                                    Offers.Insert(true);
                                    CartDiscCount := CartDiscCount + 1; //AlleRSN 150124

                                end;
                            end;
                        end;

                        //Product Discount Array Iteration
                        JsonObj.Get('productDiscounts', JsonTkn);
                        if JsonTkn.IsArray then begin
                            JsonArr := JsonTkn.AsArray();

                            for iterator := 0 to JsonArr.Count - 1 do begin
                                JsonArr.Get(iterator, JsonTkn);

                                if JsonTkn.IsObject then begin
                                    JsonObjProd := JsonTkn.AsObject();

                                    JsonObjProd.Get('products', JsonTknProd);
                                    if JsonTknProd.IsArray then begin
                                        JsonArrProd := JsonTknProd.AsArray();
                                        for iterator1 := 0 to JsonArrProd.Count - 1 do begin
                                            JsonArrProd.Get(iterator1, JsonTknProd);
                                            If JsonTknProd.IsObject then begin
                                                JsonObjOrd := JsonTknProd.AsObject();


                                                rec_Offers.Reset();
                                                IF rec_Offers.FindLast() then;

                                                Offers.Init();
                                                Offers."Entry No." := rec_Offers."Entry No." + 1;
                                                Offers.UserId := json_Methods.GetJsonToken(JsonObj, 'userId').AsValue().AsText();
                                                Offers."Discount Id" := json_Methods.GetJsonToken(JsonObjProd, 'discountId').AsValue().AsText();
                                                Offers.Code := json_Methods.GetJsonToken(JsonObjProd, 'code').AsValue().AsText();
                                                Offers."Offer Type" := Offers."Offer Type"::productDiscounts;
                                                Offers."Discount Type" := json_Methods.GetJsonToken(JsonObjProd, 'type').AsValue().AsText();
                                                Offers.appProductId := json_Methods.GetJsonToken(JsonObjOrd, 'appProductId').AsValue().AsText();
                                                jsonvalue := json_Methods.GetJsonToken(JsonObjOrd, 'posItemId').AsValue();
                                                IF not jsonvalue.IsNull then
                                                    Offers.posItemId := json_Methods.GetJsonToken(JsonObjOrd, 'posItemId').AsValue().AsText();
                                                Offers.productName := json_Methods.GetJsonToken(JsonObjOrd, 'productName').AsValue().AsText();
                                                Offers."Token ID" := TokenID;
                                                Offers."Receipt No" := postrans."Receipt No."; //AlleRSN 301023
                                                Offers."Wallet Balance" := LSCPOSMenuLine4."Wallet Balance";//AJ_alle_01112023
                                                Offers."Wave Coin Balance" := LSCPOSMenuLine4."Wave Coin Balance";//AJ_alle_01112023
                                                Offers.Insert(true);
                                                ProdDiscCount := ProdDiscCount + 1; //AlleRSN 150124
                                            end;
                                        end;
                                    end;
                                end;
                            end;
                        end;
                        //AlleRSN 150124 start
                        LSCPOSMenuLine.Init();
                        LSCPOSMenuLine.Validate("Profile ID", '##DEFAULT');
                        LSCPOSMenuLine.Validate("Menu ID", '#TWCOFFER');
                        LSCPOSMenuLine.Validate("Key No.", 1);
                        LSCPOSMenuLine.Validate(CustAppUserId, userid);
                        LSCPOSMenuLine.Validate("Cust App Order", true);
                        LSCPOSMenuLine.Command := 'MENU2';
                        LSCPOSMenuLine.Parameter := '#LOYALTYDISC';
                        LSCPOSMenuLine.Description := 'Loyalty Discounts' + '\' + Format(LoyDiscCount);
                        LSCPOSMenuLine.Insert();

                        LSCPOSMenuLine.Init();
                        LSCPOSMenuLine.Validate("Profile ID", '##DEFAULT');
                        LSCPOSMenuLine.Validate("Menu ID", '#TWCOFFER');
                        LSCPOSMenuLine.Validate("Key No.", 2);
                        LSCPOSMenuLine.Validate(CustAppUserId, userid);
                        LSCPOSMenuLine.Validate("Cust App Order", true);
                        LSCPOSMenuLine.Command := 'MENU2';
                        LSCPOSMenuLine.Parameter := '#CARTDISC';
                        LSCPOSMenuLine.Description := 'Cart Discounts' + '\' + Format(CartDiscCount);
                        LSCPOSMenuLine.Insert();

                        LSCPOSMenuLine.Init();
                        LSCPOSMenuLine.Validate("Profile ID", '##DEFAULT');
                        LSCPOSMenuLine.Validate("Menu ID", '#TWCOFFER');
                        LSCPOSMenuLine.Validate("Key No.", 3);
                        LSCPOSMenuLine.Validate(CustAppUserId, userid);
                        LSCPOSMenuLine.Validate("Cust App Order", true);
                        LSCPOSMenuLine.Command := 'MENU2';
                        LSCPOSMenuLine.Parameter := '#PRODDISC';
                        LSCPOSMenuLine.Description := 'Product Discounts' + '\' + Format(ProdDiscCount);
                        LSCPOSMenuLine.Insert();

                        LSCPOSMenuLine.Init();
                        LSCPOSMenuLine.Validate("Profile ID", '##DEFAULT');
                        LSCPOSMenuLine.Validate("Menu ID", '#TWCOFFER');
                        LSCPOSMenuLine.Validate("Key No.", 4);
                        LSCPOSMenuLine.Validate(CustAppUserId, userid);
                        LSCPOSMenuLine.Validate("Cust App Order", true);
                        LSCPOSMenuLine.Command := 'MENU2';
                        LSCPOSMenuLine.Parameter := '#ADDONDISC';
                        LSCPOSMenuLine.Description := 'Add-On Discounts';
                        LSCPOSMenuLine.Insert();

                        LSCPOSMenuLine.Init();
                        LSCPOSMenuLine.Validate("Profile ID", '##DEFAULT');
                        LSCPOSMenuLine.Validate("Menu ID", '#TWCOFFER');
                        LSCPOSMenuLine.Validate("Key No.", 5);
                        LSCPOSMenuLine.Validate(CustAppUserId, userid);
                        LSCPOSMenuLine.Validate("Cust App Order", true);
                        LSCPOSMenuLine.Command := 'MENU2';
                        LSCPOSMenuLine.Parameter := '#BOGODISC';
                        LSCPOSMenuLine.Description := 'BOGO';
                        LSCPOSMenuLine.Insert();

                        POSCTRL.RefreshMenuButton('##DEFAULT', '#TWCOFFER', 1);
                        POSCTRL.RefreshMenuButton('##DEFAULT', '#TWCOFFER', 2);
                        POSCTRL.RefreshMenuButton('##DEFAULT', '#TWCOFFER', 3);


                        //AlleRSN 150124 end
                    end;

                end;
            end;
        end;
    end;



    var
        TokenID: Code[20];
        storeid: Code[20];
        APIURL: Text;
        RespText: Text;
        LSCPOSMenuLine: Record "LSC POS Menu Line";
        LSCPOSMenuLine2: Record "LSC POS Menu Line";
        LSCPOSMenuLine3: Record "LSC POS Menu Line";
        Id: Text;
        POSCTRL: Codeunit "LSC POS Control Interface";
        userID: Code[20];
        twcapisetup: Record TwcApiSetupUrl;
        Retailusersetup: Record "LSC Retail User";
        POSEvent: Codeunit "LSC POS Transaction";
        postrans1: Record "LSC POS Transaction"; //AlleRSN 101023
}
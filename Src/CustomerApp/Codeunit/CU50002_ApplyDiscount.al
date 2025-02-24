codeunit 50002 "Apply Discount"
{
    trigger OnRun()
    var
        POStrnsevent: Codeunit "LSC POS Transaction";
        POSTransaction: Record "LSC POS Transaction";
        test: Codeunit "LSC POS Transaction Events";
    begin

        /*
           POSTransaction.Reset();
           POSTransaction.SetRange("Receipt No.", POStrnsevent.GetReceiptNo());
           IF POSTransaction.FindFirst() then
               ReviewCart(POSTransaction);
               */
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Transaction Events", 'OnAfterRunCommand', '', false, false)]
    local procedure OnAfterRunCommand(var POSMenuLine: Record "LSC POS Menu Line"; var Command: Code[20]; var POSTransaction: Record "LSC POS Transaction"; var POSTransLine: Record "LSC POS Trans. Line"; var CurrInput: Text)
    var
        disid: List of [Text];
        posTransLine2: Record "LSC POS Trans. Line";
        pos: Integer;
        desc: List of [Text];
        offers: record Cust_App_Offers;
    begin
        IF POSMenuLine.Parameter = 'APPLYDISC' then begin
            //   IF POSMenuLine.Parameter = 'APPLYDISC' then begin

            // end;
            Clear(POSTransLine2);
            IF POSTransaction."Review Cart done" then
                Error('You cannot apply discount after review cart is done');


            IF POSTransLine."Entry Type" <> posTransLine."Entry Type"::Item then
                Error('Discount can only be applied to Item');

            disid := POSMenuLine.Description.Split('-');

            IF POSMenuLine."Menu ID" = '#CARTDISC' then begin

                posTransLine2.Reset();
                posTransLine2.SetRange("Receipt No.", POSTransLine."Receipt No.");
                posTransLine2.SetRange("Cart Offer ID", disid.Get(1));
                POSTransLine2.SetFilter("Entry Status", '<>%1', posTransLine2."Entry Status"::" ");
                IF posTransLine2.FindFirst() then
                    Error('Discount %1 is already applied', disid.Get(1));


                posTransLine2.Reset();
                posTransLine2.SetRange("Receipt No.", POSTransLine."Receipt No.");
                posTransLine2.SetFilter("Offer ID", '<>%1', '');
                IF posTransLine2.FindFirst() then begin
                    desc := posTransLine2.Description.Split(' - ');
                    posTransLine2."Offer ID" := '';
                    posTransLine2.Description := desc.Get(1);
                    posTransLine2.Modify();
                    Commit();
                end;

                posTransLine2.Reset();
                posTransLine2.SetRange("Receipt No.", POSTransLine."Receipt No.");
                posTransLine2.SetRange("Cart Offer ID", disid.Get(1));
                POSTransLine2.SetFilter("Entry Status", '<>%1', posTransLine2."Entry Status"::" ");
                IF posTransLine2.FindFirst() then
                    Error('Discount %1 is already applied', disid.Get(1));

                posTransLine2.Reset();
                posTransLine2.SetRange("Receipt No.", POSTransLine."Receipt No.");
                posTransLine2.SetFilter("Cart Offer ID", '<>%1', '');
                IF posTransLine2.FindFirst() then begin
                    desc := posTransLine2.Description.Split(' - ');
                    posTransLine2."Cart Offer ID" := '';
                    posTransLine2.Description := desc.Get(1);
                    posTransLine2.Modify();
                    Commit();
                end;

                IF (POSTransaction."Cart Offer ID" <> '') OR (POSTransaction."Offer ID" <> '') then begin
                    POSTransaction."Cart Offer ID" := disid.Get(1);
                    POSTransaction."App Discount Code" := disid.Get(2); //AlleRSN 131223
                    POSTransaction.Modify();
                    POSTransLine."Cart Offer ID" := disid.Get(1);

                    POSTransLine."Offer ID" := '';
                    desc := POSTransLine.Description.Split(' - ');
                    POSTransLine.Description := desc.Get(1) + ' - ' + disid.Get(1);
                    POSTransLine.Modify();
                end
                else begin
                    POSTransaction."Cart Offer ID" := disid.Get(1);
                    POSTransaction."App Discount Code" := disid.Get(2); //AlleRSN 131223
                    POSTransaction.Modify();
                    POSTransLine."Cart Offer ID" := disid.Get(1);
                    //     POSTransLine.Validate("Cart Offer ID");
                    POSTransLine."Offer ID" := '';
                    POSTransLine.Description := POSTransLine.Description + ' - ' + disid.Get(1);
                    POSTransLine.Modify();
                end;
                Message('%1 Offer applied successfully', disid.Get(1));
            end else begin

                posTransLine2.Reset();
                posTransLine2.SetRange("Receipt No.", POSTransLine."Receipt No.");
                posTransLine2.SetFilter("Offer ID", '<>%1', '');
                IF posTransLine2.FindFirst() then begin
                    desc := posTransLine2.Description.Split(' - ');
                    posTransLine2."Offer ID" := '';
                    posTransLine2.Description := desc.Get(1);
                    posTransLine2.Modify();
                    Commit();
                end;

                posTransLine2.Reset();
                posTransLine2.SetRange("Receipt No.", POSTransLine."Receipt No.");
                posTransLine2.SetFilter("Cart Offer ID", '<>%1', '');
                IF posTransLine2.FindFirst() then begin
                    desc := posTransLine2.Description.Split(' - ');
                    posTransLine2."Cart Offer ID" := '';
                    posTransLine2.Description := desc.Get(1);
                    posTransLine2.Modify();
                    Commit();
                end;

                offers.Reset();
                offers.SetRange(UserId, POSTransaction.CustAppUserId);
                offers.SetRange("Discount Id", disid.Get(1));
                offers.SetRange(posItemId, '');
                IF offers.FindFirst() then begin
                    POSTransaction."Cart Offer ID" := offers."Discount Id";
                    POSTransaction."App Discount Code" := disid.Get(2); //AlleRSN 131223
                end;

                posTransLine2.Reset();
                posTransLine2.SetRange("Receipt No.", POSTransLine."Receipt No.");
                posTransLine2.SetRange("Offer ID", disid.Get(1));
                POSTransLine2.SetFilter("Entry Status", '<>%1', posTransLine2."Entry Status"::" ");
                IF posTransLine2.FindFirst() then
                    Error('Discount %1 is already applied', disid.Get(1));

                IF (POSTransaction."Offer ID" <> '') OR (POSTransaction."Cart Offer ID" <> '') then begin
                    IF POSTransaction."Offer ID" <> '' then
                        POSTransaction."Offer ID" := disid.Get(1)
                    else
                        POSTransaction."Cart Offer ID" := disid.Get(1);
                    POSTransaction."App Discount Code" := disid.Get(2); //AlleRSN 131223
                    POSTransaction.Modify();
                    IF POSTransaction."Offer ID" <> '' then
                        POSTransLine."Offer ID" := disid.Get(1);
                    desc := POSTransLine.Description.Split(' - ');
                    //   POSTransLine.Validate("Offer ID");
                    POSTransLine."Cart Offer ID" := POSTransaction."Cart Offer ID";
                    POSTransLine.Description := desc.Get(1) + ' - ' + disid.Get(1);
                    POSTransLine.Modify();
                    Message('%1 Offer applied successfully', disid.Get(1));
                end
                else begin
                    POSTransaction."Offer ID" := disid.Get(1);
                    POSTransaction."App Discount Code" := disid.Get(2); //AlleRSN 131223
                    POSTransaction.Modify();
                    POSTransLine."Offer ID" := disid.Get(1);
                    // POSTransLine.Validate("Offer ID");
                    POSTransLine."Cart Offer ID" := '';
                    POSTransLine.Description := POSTransLine.Description + ' - ' + disid.Get(1);
                    POSTransLine.Modify();
                    Message('%1 Offer applied successfully', disid.Get(1));
                end;
            end;

        end;

        IF POSMenuLine.Parameter = 'WAVECOIN' then begin


        end;


    end;

    local procedure ReviewCart(TH: Record "LSC POS Transaction")
    var
        iterator: Integer;
        JArray: JsonArray;
        cartObject: JsonObject;
        JsonObject: JsonObject;
        productsObject: JsonObject;
        JsonData: Text;
        TRansLine: Record "LSC POS Trans. Line";
        RecItem: Record Item;
        cartleveldis: Code[30];
        ResponseText: Text;
        userid: Text;
        LSCPOSMenuLine1: Record "LSC POS Menu Line";
        responsemsg: HttpResponseMessage;
        JsonTkn: JsonToken;
        JsonObj: JsonObject;
        jsonarr: JsonArray;
        ErrorObj: JsonObject;
        ErrorJkn: JsonToken;
        TL: Record "LSC POS Trans. Line";

    begin
        TL.Reset();
        TL.SetRange("Receipt No.", TH."Receipt No.");
        TL.SetRange("Cust App Order", true);
        IF TL.FindFirst() then begin
            IF TH."Sales Type" = 'POS' then //AlleRSN 301123
                TH."Cust App Order" := true;
            TH.Modify(true);
        end;
        //AlleRSN 301123 start
        IF TH."Sales Type" <> 'POS' then
            IF TH."Cust App Order" then begin
                TH."Cust App Order" := false;
                TH.Modify(true);
            end;
        //AlleRSN 301123

        LSCPOSMenuLine1.Reset();
        LSCPOSMenuLine1.SetRange("Menu ID", '#APPCUSTOMER');
        // LSCPOSMenuLine1.SetRange("Key No.", 1);
        IF LSCPOSMenuLine1.FindLast() then begin

            Clear(cartObject);
            Clear(JsonObject);


            //IF TH."Cust App Order" then begin
            TH.CalcFields("Line TAX Amount");
            TH.CalcFields("Total Discount");
            TH.CalcFields("Net Amount");
            TH.CalcFields("LSCIN GST Amount");
            JsonObject.Add('POSStoreId', '11');
            JsonObject.Add('POSTerminalId', TH."POS Terminal No.");
            JsonObject.Add('POSTransactionRefNo', TH."Receipt No.");
            JsonObject.Add('TransactionInitiatedTime', TH."Trans. Date");
            //  cartObject.Add('userId', CopyStr(UserId, 17, StrLen(UserId)));


            JsonObject.Add('TotalQTY', TH."Line TAX Quantity");
            JsonObject.Add('TotalCartValue', TH."Net Amount");
            JsonObject.Add('TotalTaxAMT', TH."LSCIN GST Amount");

            TRansLine.Reset();
            TRansLine.SetRange("Receipt No.", TH."Receipt No.");
            IF TRansLine.FindFirst() then begin
                Clear(JArray);
                repeat
                    Clear(productsObject);
                    IF RecItem.Get(TRansLine.Number) then;
                    productsObject.Add('POSItemId', TRansLine.Number);
                    productsObject.Add('qty', TRansLine.Quantity);
                    productsObject.Add('subUserPlanId', TRansLine."User Plan Id");
                    productsObject.Add('prodDiscountId', TRansLine."Offer ID");
                    productsObject.Add('POSProductPrice', TRansLine.Price);
                    productsObject.Add('TaxPercentage', TRansLine."LSCIN GST Amount");
                    productsObject.Add('TaxAmt', TRansLine."LSCIN GST Amount");
                    // productsObject.Add('ParentItemno', TRansLine."Parent Item No.");
                    //ALLE-AS-18092023
                    if TRansLine."Kitchen Routing" = TRansLine."Kitchen Routing"::Yes then begin
                        //productsObject.Add('IndentNo', TRansLine."Indent No.");
                        productsObject.Add('IndentNo', 0);
                        if TRansLine."Deal Line No." <> 0 then
                            productsObject.Add('ParentLine', TRansLine."Deal Line No.")
                        else
                            productsObject.Add('ParentLine', TRansLine."Parent Line");
                    end else begin
                        productsObject.Add('IndentNo', 1);
                        //if TRansLine."Deal Line No." = 0 then
                        productsObject.Add('ParentLine', TRansLine."Parent Line");
                    end;
                    //ALLE-AS-18092023

                    JArray.Add(productsObject);
                until TRansLine.Next() = 0;

                LSCPOSMenuLine1.Reset();
                LSCPOSMenuLine1.SetRange("Menu ID", '#APPCUSTOMER');
                LSCPOSMenuLine1.SetRange("Key No.", 1);
                IF LSCPOSMenuLine1.FindLast() then;
                JsonObject.Add('userId', LSCPOSMenuLine1.CustAppUserId);
                TRansLine.Reset();
                TRansLine.SetRange("Receipt No.", TH."Receipt No.");
                IF TRansLine.FindFirst() then begin

                    IF TRansLine."Cart Offer ID" = '' then
                        cartleveldis := '-1'
                    else
                        cartleveldis := format(TRansLine."Cart Offer ID");

                    //cartleveldis := Text.LowerCase(cartleveldis);
                    //Message(cartleveldis);
                    JsonObject.Add('cartLevelDiscount', cartleveldis);
                end;
                cartObject.Add('products', JArray);
            end;

            JsonObject.Add('cart', cartObject);

            JsonObject.WriteTo(JsonData);
            Message(JsonData);

            APIURL := 'https://testing-api.thirdwavecoffee.in/pos-ls-central-integration-svc/api/cart/create';


            responsemsg := CallServiceStatus(APIURL, HTTPRequestTypeEnum::post, JsonData);

            IF responsemsg.IsSuccessStatusCode then begin
                responsemsg.Content().ReadAs(ResponseText);
                ReadReviewCartResponse(ResponseText, TH);
            end
            else begin
                responsemsg.Content().ReadAs(ResponseText);
                if JsonTkn.ReadFrom(ResponseText) then begin
                    if JsonTkn.IsObject then begin
                        JsonObj := JsonTkn.AsObject();
                    end;
                    if JsonObj.Get('message', JsonTkn) then begin
                        IF JsonTkn.IsArray then begin
                            JsonArr := JsonTkn.AsArray();
                            for iterator := 0 to JsonArr.Count - 1 do begin
                                JsonArr.Get(iterator, ErrorJkn);
                                // if ErrorJkn.IsObject then begin
                                //  ErrorObj := ErrorJkn.AsObject();
                                ResponseText := ErrorJkn.AsValue().AsText();
                                //end;
                            end;
                        end;
                    end;
                    Message(ResponseText);
                end;
            end;
        end;
    end;

    procedure CallServiceStatus(RequestUrl: Text; RequestType: Enum HTTPRequestTypeEnum; Body: Text): HttpResponseMessage
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
        RequestHeaders := httpWebClient.DefaultRequestHeaders();

        case RequestType of
            RequestType::Get:
                begin
                    // RequestContent.GetHeaders(contentHeaders);
                    //contentHeaders.Clear();

                    RequestMessage.GetHeaders(contentHeaders);
                    //contentHeaders.Remove('Content-Type');
                    //contentHeaders.Add('Content-Type', 'application/json');
                    contentHeaders.Add('X-API-VERSION', '1');
                    contentHeaders.Add('X-API-KEY', 'ebbafe94-2c62-4f00-a860-ea309faab250');
                    RequestMessage.SetRequestUri(RequestUrl);
                    RequestMessage.Method := 'GET';
                    httpWebClient.Send(RequestMessage, ResponseMessage);

                    //   httpWebClient.Get(RequestURL, ResponseMessage);
                end;
            RequestType::post:
                begin
                    RequestContent.WriteFrom(Body);
                    //  RequestMessage.GetHeaders(contentHeaders);


                    //RequestMessage.SetRequestUri(RequestUrl);
                    RequestContent.GetHeaders(contentHeaders);
                    contentHeaders.Clear();
                    contentHeaders.Add('Content-Type', 'application/json');
                    contentHeaders.Add('X-API-VERSION', '1');
                    contentHeaders.Add('X-API-KEY', 'ebbafe94-2c62-4f00-a860-ea309faab250');
                    //                    RequestMessage.SetRequestUri(RequestUrl);
                    httpWebClient.SetBaseAddress(RequestUrl);
                    // httpWebClient.DefaultRequestHeaders.Add('Content-Type', 'application/json');
                    httpWebClient.Post(RequestUrl, RequestContent, ResponseMessage);
                end;
        end;
        //  IF ResponseMessage.IsSuccessStatusCode then begin
        //ResponseMessage.Content().ReadAs(ResponseText);
        // Message(ResponseText);
        exit(ResponseMessage);

    end;

    procedure ReadReviewCartResponse(RespText: Text; TH: Record "LSC POS Transaction")
    var
        PosTransLine: Record "LSC POS Trans. Line";

        TypeHelper: Codeunit "Type Helper";
        CRLF: Text;
        JsonTkn: JsonToken;
        JsonObj: JsonObject;
        ReceiptNo: Code[50];
        CartProd: JsonToken;
        cartprodObj: JsonObject;
        json_Methods: Codeunit JSON_Methods;
        JsonArr: JsonArray;
        Itemno: Code[30];
        subprice: Decimal;
        iterator: Integer;
        disc: Decimal;
        SubID: Code[20];
        OfferID: Code[20];
        Jsnval: JsonValue;
        POSCTRL: Codeunit "LSC POS Control Interface";
    begin

        CRLF := TypeHelper.CRLFSeparator();

        if JsonTkn.ReadFrom(RespText) then begin
            if JsonTkn.IsObject then begin
                JsonObj := JsonTkn.AsObject();

                if JsonObj.Get('POSTransactionRefNo', JsonTkn) then begin
                    ReceiptNo := JsonTkn.AsValue().AsCode();
                end;

                IF JsonObj.Get('cartProducts', CartProd) then;
                If CartProd.IsArray then begin
                    JsonArr := CartProd.AsArray();
                    for iterator := 0 to JsonArr.Count - 1 do begin
                        JsonArr.Get(iterator, CartProd);
                        if CartProd.IsObject then begin
                            cartprodObj := CartProd.AsObject();
                            Itemno := json_Methods.GetJsonToken(cartprodObj, 'POSItemId').AsValue().AsText();
                            subprice := json_Methods.GetJsonToken(cartprodObj, 'perUnitSubscriptionPrice').AsValue().AsDecimal();
                            disc := json_Methods.GetJsonToken(cartprodObj, 'disAmount').AsValue().AsDecimal();
                            Jsnval := json_Methods.GetJsonToken(cartprodObj, 'subscriptionPlanId').AsValue();
                            IF not Jsnval.IsNull then
                                SubID := json_Methods.GetJsonToken(cartprodObj, 'subscriptionPlanId').AsValue().AsText();
                            //   OfferID := json_Methods.GetJsonToken(cartprodObj, 'POSItemId').AsValue().AsText();
                            PosTransLine.Reset();
                            PosTransLine.SetRange("Receipt No.", ReceiptNo);
                            PosTransLine.SetRange(Number, Itemno);
                            IF PosTransLine.FindFirst() then begin
                                IF subprice <> 0 then
                                    PosTransLine.Validate(Price, subprice);
                                IF disc <> 0 then begin
                                    PosTransLine.validate("Discount Amount", disc);
                                    PosTransLine.CalcPrices();
                                    PosTransLine.Validate("Net Price", PosTransLine."Net Price" - disc);
                                end;
                                PosTransLine.Validate("Subscription ID", SubID);
                                PosTransLine.Validate("Offer ID", TH."Offer ID");
                                // PosTransLine.Validate("LSCIN GST Group Type", );
                                IF SubID <> '' then
                                    PosTransLine.Validate("LSCIN Price Inclusive of Tax", true);
                                //   PosTransLine.Validate("LSCIN HSN/SAC Code", '');

                                //PosTransLine.Validate("LSCIN GST Amount", 0);
                                //PosTransLine.CalcPrices();
                                PosTransLine.Modify(true);
                            end;

                            // TH.
                        end;
                    end;
                end;
            end;
            IF PosTransLine."Offer ID" <> '' then
                Message('Validate Member done Successfully with Offer ID %1', TH."Offer ID");
            IF PosTransLine."Subscription ID" <> '' then
                Message('Validate Member done Successfully with Subscription ID %1 ', PosTransLine."Subscription ID")
            else
                Message('Validate Member done Successfully');
            TH."Review Cart done" := true;
            TH.Modify(true);

            //  POSCTRL.RefreshProfiles();



        end;
    end;


    var
        APIURL: Text;
}

page 50028 "TWC Wallet Redemption"
{
    PageType = Card;
    // SourceTable = "LSC POS Transaction";
    ApplicationArea = all;
    UsageCategory = Administration;
    InsertAllowed = false;
    ModifyAllowed = false;

    layout
    {
        area(Content)
        {
            group("Wallet Redemption")
            {
                field("Wallet Balance"; Wallet)
                {
                    ApplicationArea = All;
                    Editable = false;
                    Caption = 'Main Wallet';

                }
                field("Promo Balance"; Promo)
                {
                    ApplicationArea = all;
                    Editable = false;
                    Caption = 'Promo Wallet';
                    Visible = false;


                }
                field("Net Amount"; POSTransaction."Gross Amount" - POSTransaction.Payment)
                {
                    ApplicationArea = all;
                    Editable = false;
                    Caption = 'Amount Payable';
                }
                field(MaxRedemable; MaxRedemable)
                {
                    Caption = 'Redemable Amount';

                    trigger OnValidate()
                    var
                        lscposmenuline1: Record "LSC POS Menu Line";
                    begin
                        lscposmenuline1.Reset();
                        lscposmenuline1.SetRange("Menu ID", '#APPCUSTOMER');
                        IF LSCPOSMenuLine1.FindFirst() then;

                        IF POSTransaction."Cust App Order" then begin
                            //  Error('Please scan your App to continue');

                            IF MaxRedemable > Wallet then
                                Error('Redemable amount cannot be greater then wallet balance');

                            IF MaxRedemable > POSTransaction."Gross Amount" then
                                Error('Redemable amount cannot be greater than Amount payable');
                        end;
                    end;
                }

            }
        }

    }
    actions
    {
        area(Processing)
        {

            action(Submit)
            {
                ApplicationArea = all;
                Promoted = true;
                PromotedCategory = Process;
                ShortcutKey = 'Enter';


                trigger OnAction()
                var
                    PS: Record "LSC POS Transaction";
                    PSLine: Record "LSC POS Trans. Line";
                    PSLine1: Record "LSC POS Trans. Line";
                    Redem: Decimal;
                    respmsg: HttpResponseMessage;
                    JsonTkn: JsonToken;
                    JsonTkn1: JsonToken;
                    JsonObj: JsonObject;
                    jsonarr: JsonArray;
                    ErrorObj: JsonObject;
                    ErrorJkn: JsonToken;
                    ResponseText: Text;
                    json_Methods: Codeunit JSON_Methods;
                    jsnobj1: JsonObject;
                    //   LSCPOSMenuLine1: Record "LSC POS Menu Line";
                    postrans1: Record "LSC POS Transaction";
                    iterator: Integer;
                    jsonobject: JsonObject;
                    redepvalue: Decimal;
                    postransline: Record "LSC POS Trans. Line";

                    lscposmenuline1: Record "LSC POS Menu Line";
                    txnid: Text;
                    promotxnid: Text;
                    batchnumber: Text;

                begin

                    lscposmenuline1.Reset();
                    lscposmenuline1.SetRange("Menu ID", '#APPCUSTOMER');
                    IF LSCPOSMenuLine1.FindFirst() then;

                    IF not POSTransaction."Cust App Order" then
                        Error('Please scan your App to continue');

                    IF not POSTransaction."Review Cart done" then
                        Error('Please Validate the member');

                    /* respmsg := WalletRedemptioAPI(MaxRedemable);

                     Clear(redepvalue);
                     IF respmsg.IsSuccessStatusCode then begin
                         // IF ResponseText <> '' then begin
                         respmsg.Content().ReadAs(ResponseText);

                         if JsonTkn.ReadFrom(ResponseText) then begin
                             if JsonTkn.IsObject then begin
                                 JsonObj := JsonTkn.AsObject();
                             end;
                             if JsonObj.Get('redemptionData', JsonTkn) then begin
                                 IF JsonTkn.IsArray then begin
                                     JsonArr := JsonTkn.AsArray();
                                     for iterator := 0 to JsonArr.Count - 1 do begin
                                         jsonarr.Get(iterator, JsonTkn1);
                                         if JsonTkn1.IsObject then begin
                                             JsonObject := JsonTkn1.AsObject();
                                             redepvalue += json_Methods.GetJsonToken(JsonObject, 'redemptionValue').AsValue().AsDecimal();
                                             IF json_Methods.GetJsonToken(JsonObject, 'bucketType').AsValue().AsText() = 'PROMOTIONAL' then
                                                 promotxnid := json_Methods.GetJsonToken(JsonObject, 'txnId').AsValue().AsCode()
                                             else
                                                 txnid := json_Methods.GetJsonToken(JsonObject, 'txnId').AsValue().AsCode();


                                             batchnumber := json_Methods.GetJsonToken(JsonObject, 'batchNumber').AsValue().AsCode();
                                         end;
                                     end;
                                 end;
                             end;
                         end;
                    postransline.Reset();
                    postransline.SetRange("Receipt No.", POSTransaction."Receipt No.");
                    IF postransline.FindFirst() then
                        repeat
                            postransline.txnId := txnid;
                            postransline.PromoTxnId := promotxnid;
                            postransline.redemptionValue := MaxRedemable; //AlleRSN 111223//redepvalue;
                            postransline.batchNumber := batchnumber;
                            postransline.Modify();
                        until postransline.Next() = 0;
                    // end;
                end
                    else begin
                        //IF ResponseText <> '' then begin
                        respmsg.Content().ReadAs(ResponseText);

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
                                        Message(ResponseText);

                                    end;
                                end;
                            end;

                        end;
                    end; */ //AlleRSN 111223 
                    //AlleRSN 111223 start
                    postransline.Reset();
                    postransline.SetRange("Receipt No.", POSTransaction."Receipt No.");
                    IF postransline.FindFirst() then
                        repeat
                            postransline.txnId := txnid;
                            postransline.PromoTxnId := promotxnid;
                            postransline.redemptionValue := MaxRedemable; //AlleRSN 111223//redepvalue;
                            postransline.batchNumber := batchnumber;
                            postransline.Modify();
                        until postransline.Next() = 0;
                    //AlleRSN 111223 end

                    //Postrans.TenderKeyPressedEx('16', Format(redepvalue));

                    // POSTransaction.redemptionValue := redepvalue;
                    // POSTransaction.Modify();


                    CurrPage.Close();



                end;

            }
        }
    }


    trigger OnOpenPage()
    var

    begin
        POSTransaction.Reset();
        POSTransaction.SetRange("Receipt No.", Postrans.GetReceiptNo());
        IF POSTransaction.FindFirst() then begin
            IF POSTransaction."Wallet Balance" <> '' then
                Evaluate(Wallet, POSTransaction."Wallet Balance");

            IF evaluate(promo, POSTransaction."Promo Balance") then;

            POSTransaction.CalcFields("Gross Amount");
            POSTransaction.CalcFields(Payment);

            IF not POSTransaction."Review Cart done" then
                Error('Please void the transaction and start again');

        end;
    end;

    procedure WalletRedemptioAPI(Amt: Decimal): HttpResponseMessage
    var
        resp: Decimal;
        ReqUrl: Text;
        response: Boolean;
        jsondata: Text;
        iterator: Integer;
        JArray: JsonArray;
        PaymentObject: JsonObject;
        JsonObject: JsonObject;
        responsemsg: HttpResponseMessage;
        JsonTkn: JsonToken;
        JsonTkn1: JsonToken;
        JsonObj: JsonObject;
        jsonarr: JsonArray;
        ErrorObj: JsonObject;
        ErrorJkn: JsonToken;
        ResponseText: Text;
        //   json_Methods: Codeunit JSON_Methods;
        jsnobj1: JsonObject;
        LSCPOSMenuLine1: Record "LSC POS Menu Line";
        postrans1: Record "LSC POS Transaction";
    begin
        Clear(paymentObject);
        Clear(JsonObject);

        LSCPOSMenuLine1.Reset();
        LSCPOSMenuLine1.SetRange("Menu ID", '#APPCUSTOMER');
        LSCPOSMenuLine1.SetRange("Key No.", 1);
        IF LSCPOSMenuLine1.FindLast() then;

        JsonObject.Add('userId', POSTransaction.CustAppUserId);
        JsonObject.Add('transactionRefNo', POSTransaction."Receipt No.");
        JsonObject.Add('posStoreId', POSTransaction."Store No.");
        JsonObject.Add('posTerminalId', POSTransaction."POS Terminal No.");
        JsonObject.Add('method', 'WALLET');
        JsonObject.Add('waveCoinUsed', POSTransaction.WaveCoinApplied);

        Clear(JArray);
        paymentObject.Add('type', 'CUSTOMER');
        paymentObject.Add('amount', Amt);
        JArray.Add(paymentObject);
        JsonObject.Add('paymentOption', PaymentObject);

        JsonObject.WriteTo(JsonData);

        apisetup.Get();
        //  Message(JsonData);
        ReqUrl := apisetup.WalletRedempAPIUrl;
        responsemsg := CallServiceStatus(ReqUrl, HTTPRequestTypeEnum::post, JsonData);
        exit(responsemsg);

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
        apisetup.Get();
        RequestHeaders := httpWebClient.DefaultRequestHeaders();

        case RequestType of
            RequestType::post:
                begin
                    RequestContent.WriteFrom(Body);
                    RequestContent.GetHeaders(contentHeaders);
                    contentHeaders.Clear();
                    contentHeaders.Add('Content-Type', 'application/json');
                    contentHeaders.Add('X-API-VERSION', Format(apisetup."X-API-VERSION"));
                    contentHeaders.Add('X-API-KEY', apisetup."X-API-KEY");
                    httpWebClient.SetBaseAddress(RequestUrl);
                    httpWebClient.Post(RequestUrl, RequestContent, ResponseMessage);
                end;
        end;

        exit(ResponseMessage);
    end;

    var
        MaxRedemable: Decimal;
        Postrans: Codeunit "LSC POS Transaction";
        Wallet: Decimal;
        Promo: Decimal;
        POSTransaction: Record "LSC POS Transaction";

        apisetup: Record TwcApiSetupUrl;
}
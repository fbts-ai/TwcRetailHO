page 50100 "Promo Wallet Redemption"
{
    PageType = Card;
    // SourceTable = "LSC POS Transaction";
    ApplicationArea = all;
    UsageCategory = Administration;
    InsertAllowed = false;
    DeleteAllowed = false;
    ModifyAllowed = false;

    layout
    {
        area(Content)
        {
            group("Promo Wallet Redemption")
            {

                field("Promo Wallet Balance"; POSTransaction."Promo Balance")
                {
                    ApplicationArea = all;
                    Caption = 'Promo Wallet Available';
                    Editable = false;
                }

                field(Redeemable; Redeemable)
                {
                    ApplicationArea = all;
                    Caption = 'To be Redeemed';
                    trigger OnValidate()
                    begin
                        apisetup.Get();


                        POSTransaction.CalcFields("Gross Amount");
                        IF Redeemable > Promo then
                            Error('Redemable amount cannot be greater then Promo balance');

                        IF Redeemable > POSTransaction."Gross Amount" then
                            Error('Redemable amount cannot be greater than Amount payable');

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
                    taxcalc: Codeunit "LSCIN Calculate Tax";
                    batchnumber: Text;
                    posTransLine2: Record "LSC POS Trans. Line";

                begin

                    lscposmenuline1.Reset();
                    lscposmenuline1.SetRange("Menu ID", '#APPCUSTOMER');
                    IF LSCPOSMenuLine1.FindFirst() then;

                    IF not POSTransaction."Cust App Order" then
                        Error('Please scan your App to continue');


                    posTransLine2.Reset();
                    posTransLine2.SetRange("Receipt No.", POSTransaction."Receipt No.");
                    posTransLine2.SetFilter("Cart Offer ID", '<>%1', '');
                    POSTransLine2.SetFilter("Entry Status", '%1', posTransLine2."Entry Status"::" ");
                    IF posTransLine2.FindFirst() then
                        Error('Discount %1 is already applied', posTransLine2."Cart Offer ID");


                    posTransLine2.Reset();
                    posTransLine2.SetRange("Receipt No.", POSTransaction."Receipt No.");
                    posTransLine2.SetFilter("Offer ID", '<>%1', '');
                    POSTransLine2.SetFilter("Entry Status", '%1', posTransLine2."Entry Status"::" ");
                    IF posTransLine2.FindFirst() then
                        Error('Discount %1 is already applied', posTransLine2."Offer ID");

                    respmsg := WalletRedemptioAPI(Redeemable);

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
                                    postransline.Reset();
                                    postransline.SetRange("Receipt No.", POSTransaction."Receipt No.");
                                    IF postransline.FindFirst() then
                                        repeat
                                            postransline.txnId := txnid;
                                            postransline.PromoTxnId := promotxnid;
                                            postransline.redemptionValue := redepvalue;
                                            postransline.batchNumber := batchnumber;

                                            postransline.Modify();
                                            postransline.CalcTotalDiscAmt(true, Redeemable, true);
                                            //  taxcalc.CalculateTaxOnSelectedLineV2(POSTransaction, PSLine, true);
                                            taxcalc.RecalculateTaxForAllLinesV2(POSTransaction, PSLine);
                                        until postransline.Next() = 0;
                                end;
                            end;
                        end;
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
                    end;



                    CurrPage.Close();



                end;

            }
        }
    }

    trigger OnOpenPage()

    begin
        IF apisetup.Get() then;

        Clear(Promo);
        POSTransaction.Reset();
        POSTransaction.SetRange("Receipt No.", Postrans.GetReceiptNo());
        IF POSTransaction.FindFirst() then;

        IF POSTransaction."Wave Coin Balance" <> '' then
            Evaluate(Promo, POSTransaction."Promo Balance");


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
        paymentObject.Add('type', 'PROMOTION');
        paymentObject.Add('amount', Amt);
        //  JArray.Add(paymentObject);
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
        Redeemable: Decimal;
        //text001: Text[50];
        //  text1: TextConst ENU = 'Wave Coin Redemption - Min. %1 coins can be redeemed';

        Postrans: Codeunit "LSC POS Transaction";
        POSTransaction: Record "LSC POS Transaction";

        Promo: Decimal;
        apisetup: Record TwcApiSetupUrl;
}
codeunit 50010 "PinelabsIntegration"
{

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Transaction Events", 'OnBeforeInsertPaymentLine', '', false, false)]
    local procedure OnBeforeInsertPaymentLine(var POSTransaction: Record "LSC POS Transaction"; var POSTransLine: Record "LSC POS Trans. Line"; var CurrInput: Text;
    var TenderTypeCode: Code[10]; Balance: Decimal; PaymentAmount: Decimal; STATE: Code[10]; var isHandled: Boolean)
    var
        client: HttpClient;
        request: HttpRequestMessage;
        response: HttpResponseMessage;
        contentHeaders: HttpHeaders;
        content: HttpContent;
        responseText: Text;
        TempBlob: Codeunit "Temp Blob";
        ToFile: Variant;
        InStream: InStream;
        OutStream: OutStream;
        JobjToken: JsonToken;
        JobjectResponse: JsonObject;
        PlutusTransactionReferenceID: Integer;
        UseLineNo: Integer;
        POSTransLine1: Record "LSC POS Trans. Line";
        tempLSCTenderType: Record "LSC Tender type";
        tempTendertypesetup: Record "LSC Tender Type Setup";
        tempposterminal: Record "LSC Pos Terminal";
        merchid: Integer;
        TempPineLabTrannsDetails: Record PineLabTransactiondetails;
        JSONManagement: Codeunit "JSON Management";
        JSONTransactionDataArray: JsonArray;
        JSONTransdataObject: JsonObject;
        i: Integer;
        txnStatusJsonObject: JsonObject;
        ApprovedAmount: Decimal;
        tag: Text[50];
        requestCount: Integer;
        TempPLab: Record PineLabTransactiondetails;
        POSGUI: Codeunit "LSC POS GUI";
        RecPinelabstatuscheck: Record PineLabTransactiondetails;
        tempTendertypesetup1: Record "LSC Tender Type Setup";
        TempTwcApiSetup: Record TwcApiSetupUrl;
    begin

        //IF tempTendertypesetup.Get(,Store) then;
        IF tempTendertypesetup.Get(TenderTypeCode) then;
        ///validation to change tender
        IF ((tempTendertypesetup.PineLabPaymentTender) and (Not POSTransaction."Sale Is Return Sale")) then Begin
            RecPinelabstatuscheck.Reset();
            RecPinelabstatuscheck.SetRange("Receipt No.", POSTransaction."Receipt No.");
            RecPinelabstatuscheck.SetRange("Store No.", POSTransaction."Store No.");
            RecPinelabstatuscheck.SetRange("POS Terminal No.", POSTransaction."POS Terminal No.");
            RecPinelabstatuscheck.SetFilter(TransactionStatus, '=%1', 'TXN APPROVED');
            if RecPinelabstatuscheck.FindLast() then begin
                IF RecPinelabstatuscheck.AllowedPaymentMode = '1' then begin
                    //TenderTypeCode := '50';
                    tempTendertypesetup1.Reset();
                    tempTendertypesetup1.SetRange(tempTendertypesetup1.PinelabCard, true);
                    IF tempTendertypesetup1.FindFirst() then
                        TenderTypeCode := tempTendertypesetup1.Code;
                end;
                IF RecPinelabstatuscheck.AllowedPaymentMode = '10' then begin
                    tempTendertypesetup1.Reset();
                    tempTendertypesetup1.SetRange(tempTendertypesetup1.PineLabUPI, true);
                    IF tempTendertypesetup1.FindFirst() then
                        TenderTypeCode := tempTendertypesetup1.Code;
                end;
            end;
        End
        else begin
            IF ((tempTendertypesetup.PineLabPaymentTender) and (POSTransaction."Sale Is Return Sale")) then Begin

                RecPinelabstatuscheck.Reset();
                RecPinelabstatuscheck.SetRange(RecPinelabstatuscheck.SalesReturnReceiptNo, POSTransaction."Receipt No.");
                RecPinelabstatuscheck.SetRange("Store No.", POSTransaction."Store No.");
                RecPinelabstatuscheck.SetRange("POS Terminal No.", POSTransaction."POS Terminal No.");
                RecPinelabstatuscheck.SetFilter(TransactionStatus, '=%1', 'TXN APPROVED');
                RecPinelabstatuscheck.SetFilter(SalesReturnTransactionStatus, '=%1', 'TXN APPROVED');
                if RecPinelabstatuscheck.FindLast() then begin
                    IF RecPinelabstatuscheck.AllowedPaymentMode = '1' then begin
                        //TenderTypeCode := '50';
                        tempTendertypesetup1.Reset();
                        tempTendertypesetup1.SetRange(tempTendertypesetup1.PinelabCard, true);
                        IF tempTendertypesetup1.FindFirst() then
                            TenderTypeCode := tempTendertypesetup1.Code;
                    end;
                    IF RecPinelabstatuscheck.AllowedPaymentMode = '10' then begin
                        tempTendertypesetup1.Reset();
                        tempTendertypesetup1.SetRange(tempTendertypesetup1.PineLabUPI, true);
                        IF tempTendertypesetup1.FindFirst() then
                            TenderTypeCode := tempTendertypesetup1.Code;
                    end;
                end;
            End;
        end;
        //
        if (tempTendertypesetup.PinelabCard) or (tempTendertypesetup.PineLabUPI) or (tempTendertypesetup.PineLabGiftCard) then begin

            if (PaymentAmount = 0) then
                Error('Payment amount must be gretaer than 0');

            TempPLab.Reset();
            TempPLab.SetRange(TempPLab."Receipt No.", POSTransaction."Receipt No.");
            TempPLab.SetRange(TempPLab."POS Terminal No.", POSTransaction."POS Terminal No.");
            TempPLab.SetRange(TempPLab."Store No.", POSTransaction."Store No.");
            TempPLab.SetFilter(TempPLab.TransactionStatus, '=%1', '');
            IF TempPLab.FindFirst() then begin
                Error('Please update the status of open transaction for this receipt number');
            end;


            isHandled := true;
            //Message('Pine Labs payment process started');
            Initialize();
            tempposterminal.Reset();
            tempposterminal.SetRange("No.", POSTransaction."POS Terminal No.");
            if tempposterminal.FindFirst() then;

            tempposterminal.TestField(tempposterminal.MerchantID);
            tempposterminal.TestField(tempposterminal.MerchantStorePosCode);
            tempposterminal.TestField(tempposterminal.IMEI);
            tempposterminal.TestField(tempposterminal.SecurityToken);


            // WriteJsonFileHeader();
            JObject.Add('TransactionNumber', POSTransaction."Receipt No.");


            requestCount := 1;
            TempPLab.Reset();
            TempPLab.SetRange(TempPLab."Receipt No.", POSTransaction."Receipt No.");
            TempPLab.SetRange(TempPLab."POS Terminal No.", POSTransaction."POS Terminal No.");
            TempPLab.SetRange(TempPLab."Store No.", POSTransaction."Store No.");
            IF TempPLab.FindSet() then
                repeat
                    requestCount := requestCount + 1
                until TempPLab.Next() = 0;

            JObject.Add('SequenceNumber', requestCount);

            IF tempTendertypesetup.PinelabCard then
                JObject.Add('AllowedPaymentMode', '1');

            if tempTendertypesetup.PineLabUPI then
                JObject.Add('AllowedPaymentMode', '10');

            JObject.Add('MerchantStorePosCode', tempposterminal.MerchantStorePosCode);
            JObject.Add('Amount', (PaymentAmount * 100));
            JObject.Add('UserID', POSTransaction."Staff ID");
            Evaluate(merchid, tempposterminal.MerchantID);
            JObject.Add('MerchantID', merchid);
            JObject.Add('SecurityToken', tempposterminal.SecurityToken);
            JObject.Add('IMEI', tempposterminal.IMEI);
            JObject.Add('AutoCancelDurationInMinutes', 1);
            //Message(Format(merchid));
            //Message(JsonText);

            JObject.WriteTo(JsonText);
            /*
           JsonArrayData.Add(JObject);
           JsonArrayData.WriteTo(JsonText);
           */
            TempBlob.CreateOutStream(OutStream);
            OutStream.WriteText(JsonText);
            ToFile := 'pinelab.json';
            // TempBlob.CreateInStream(InStream);
            // DownloadFromStream(InStream, 'Pinelab', '', '', ToFile);
            // Sleep(1000);



            content.WriteFrom(JsonText);
            content.GetHeaders(contentHeaders);
            contentHeaders.Clear();
            contentHeaders.Add('Content-Type', 'application/json');

            request.Content := content;
            //https://www.plutuscloudserviceuat.in:8201/API/CloudBasedIntegration/V1/UploadBilledTransaction
            TempTwcApiSetup.Get();
            TempTwcApiSetup.TestField(TempTwcApiSetup.PineLabSalesUploadUrl);
            request.SetRequestUri(TempTwcApiSetup.PineLabSalesUploadUrl);
            request.Method := 'POST';

            client.Send(request, response);
            if response.IsSuccessStatusCode then begin
                response.Content().ReadAs(responseText);
                // Message(responseText);
                if JobjToken.ReadFrom(responseText) then begin
                    if JobjToken.IsObject then begin
                        JobjectResponse := JobjToken.AsObject();
                        JobjectResponse.Get('PlutusTransactionReferenceID', JobjToken);
                        PlutusTransactionReferenceID := JobjToken.AsValue().AsInteger();
                        if JobjectResponse.Get('ResponseMessage', JobjToken) then begin
                            if (JobjToken.AsValue().AsText() = 'APPROVED') then begin

                                TempPineLabTrannsDetails.Init();
                                TempPineLabTrannsDetails."Receipt No." := POSTransaction."Receipt No.";
                                TempPineLabTrannsDetails.PlutusRefID := PlutusTransactionReferenceID;
                                TempPineLabTrannsDetails."Store No." := POSTransaction."Store No.";
                                TempPineLabTrannsDetails."POS Terminal No." := POSTransaction."POS Terminal No.";
                                TempPineLabTrannsDetails.SequenceNumber := requestCount;
                                if tempTendertypesetup.PinelabCard then
                                    TempPineLabTrannsDetails.AllowedPaymentMode := '1';
                                if tempTendertypesetup.PineLabUPI then
                                    TempPineLabTrannsDetails.AllowedPaymentMode := '10';
                                TempPineLabTrannsDetails.UploaTransactionStatus := 'APPROVED';
                                TempPineLabTrannsDetails.TenderTypeCodeID := tempTendertypesetup.Code;
                                TempPineLabTrannsDetails."Line No." := POSTransLine."Line No.";
                                // TempPineLabTrannsDetails.CurrentTransaction := True;
                                TempPineLabTrannsDetails.UploadTransactionRequest := responseText;
                                TempPineLabTrannsDetails."Trans. Date" := POSTransaction."Trans. Date";

                                TempPineLabTrannsDetails."Trans Time" := POSTransaction."Trans Time";
                                TempPineLabTrannsDetails.Insert(true);
                                Commit();
                                Message('Txn is uploaded to pinelab ,please check the status after bill is done on pinelabs');
                                /*
                                if POSGUI.PosMessage('Request send to Pinelab , Click on Okay buttuon once traction on pine lab machine completed') then begin
                                    message('Status strted');
                                    checkPinelabStatus(PlutusTransactionReferenceID, tempposterminal."No.", POSTransaction, TempPineLabTrannsDetails, isHandled);
                                    // isHandled := false;
                                end;
                                */
                            end
                            Else
                                Error(JobjToken.AsValue().AsText());
                        End;
                    end;
                end;
            end
            Else
                Error('Resposnse errore from Pinelab Side');
        End;

    end;
    /*
        Local procedure checkPinelabStatus(var PlutusTransactionReferenceID: Integer; var postermibnalcode: code[10];
        var POSTransaction: Record "LSC POS Transaction"; var TempPineLabTrannsDetails: Record PineLabTransactiondetails;
        var isHandled: Boolean)
        var
            tempposterminal1: Record "LSC POS Terminal";
            merchid1: Integer;
            client1: HttpClient;
            request1: HttpRequestMessage;
            response1: HttpResponseMessage;
            contentHeaders1: HttpHeaders;
            content1: HttpContent;
            responseText1: Text;
            JobjToken1: JsonToken;
            JobjectResponse1: JsonObject;
            responseStatus1: text[50];
            PlutusTransactionReferenceID1: integer;
            JsonArrayDataPinelabStatus1: JsonArray;
            i: Integer;
            txnStatusJsonObject1: JsonObject;
            tag1: text[30];
            AcquirerId: Text[20];
            AcquirerName: Text[50];
            TransactionDate: Date;
            TransactionTime: Time;
            AmountInPaisa: Decimal;
            OriginalAmount: Decimal;
            FinalAmount: Decimal;
            tempTendertypesetup1: Record "LSC Tender Type Setup";
            CardHolderName: Text[100];
            CardNumber: Text[30];
            InvoiceNumber: Text[20];
            CardType: Text[10];
            PaymentMode: Text[20];
            TransactionLogId: Integer;
            TID: Integer;
            txnstatusresponse: Text[2048];
            responseStatus: text[100];
            ApprovedAmount: Decimal;
            plabdetailsTrans: Record PineLabTransactiondetails;
            BatchNumber: text[10];
            RRN: text[10];
            dateText: Text[20];

        Begin
            Initialize1();

            tempposterminal1.Reset();
            tempposterminal1.SetRange("No.", postermibnalcode);
            if tempposterminal1.FindFirst() then;

            // WriteJsonFileHeader();
            Evaluate(merchid1, tempposterminal1.MerchantID);
            JObject1.Add('MerchantID', merchid1);
            JObject1.Add('SecurityToken', tempposterminal1.SecurityToken);
            JObject1.Add('IMEI', tempposterminal1.IMEI);
            JObject1.Add('MerchantStorePosCode', tempposterminal1.MerchantStorePosCode);
            JObject1.Add('PlutusTransactionReferenceID', PlutusTransactionReferenceID);
            JObject1.WriteTo(JsonText1);

            content1.WriteFrom(JsonText1);
            content1.GetHeaders(contentHeaders1);
            contentHeaders1.Clear();
            contentHeaders1.Add('Content-Type', 'application/json');

            request1.Content := content1;

            request1.SetRequestUri('https://www.plutuscloudserviceuat.in:8201/API/CloudBasedIntegration/V1/GetCloudBasedTxnStatus');
            request1.Method := 'POST';

            client1.Send(request1, response1);
            if response1.IsSuccessStatusCode then begin

                response1.Content().ReadAs(responseText1);
                //  Message(responseText);
                if JobjToken1.ReadFrom(responseText1) then begin
                    if JobjToken1.IsObject then begin
                        JobjectResponse1 := JobjToken1.AsObject();
                        JobjectResponse1.Get('PlutusTransactionReferenceID', JobjToken1);
                        PlutusTransactionReferenceID1 := JobjToken1.AsValue().AsInteger();
                        if JobjectResponse1.Get('ResponseMessage', JobjToken1) then begin
                            responseStatus1 := JobjToken1.AsValue().AsText();
                            Message('Response status %1', responseStatus1);
                            if (responseStatus1 = 'TXN APPROVED') then begin

                                //Create JSONArray String
                                JobjectResponse1.Get('TransactionData', JobjToken1);
                                if JobjToken1.IsArray then
                                    JsonArrayDataPinelabStatus1 := JobjToken1.AsArray();

                                for i := 0 to JsonArrayDataPinelabStatus1.Count() - 1 do begin

                                    JsonArrayDataPinelabStatus1.Get(i, JobjToken1);
                                    if JobjToken1.IsObject then begin
                                        txnStatusJsonObject1 := JobjToken1.AsObject();
                                        txnStatusJsonObject1.Get('Tag', JobjToken1);
                                        tag1 := JobjToken1.AsValue().AsText();

                                        IF tag1 = 'Amount' then begin
                                            txnStatusJsonObject1.Get('Value', JobjToken1);
                                            ApprovedAmount := JobjToken1.AsValue().AsDecimal();
                                            // Message('Approved amount %1', ApprovedAmount);
                                        end;


                                        IF tag1 = 'Invoice Number' then begin
                                            txnStatusJsonObject1.Get('Value', JobjToken1);
                                            InvoiceNumber := JobjToken1.AsValue().AsText();
                                        end;

                                        IF tag1 = 'Card Number' then begin
                                            txnStatusJsonObject1.Get('Value', JobjToken1);
                                            CardNumber := JobjToken1.AsValue().AsText();
                                        end;

                                        IF tag1 = 'Card Holder Name' then begin
                                            txnStatusJsonObject1.Get('Value', JobjToken1);
                                            CardHolderName := JobjToken1.AsValue().AsText();
                                        end;

                                        IF tag1 = 'PaymentMode' then begin
                                            txnStatusJsonObject1.Get('Value', JobjToken1);
                                            PaymentMode := JobjToken1.AsValue().AsText();
                                        end;
                                        IF tag1 = 'Card Type' then begin
                                            txnStatusJsonObject1.Get('Value', JobjToken1);
                                            CardType := JobjToken1.AsValue().AsText();
                                        end;

                                        IF tag1 = 'TID' then begin
                                            txnStatusJsonObject1.Get('Value', JobjToken1);
                                            TID := JobjToken1.AsValue().AsInteger();
                                        end;

                                        IF tag1 = 'Acquirer Id' then begin
                                            txnStatusJsonObject1.Get('Value', JobjToken1);
                                            AcquirerId := JobjToken1.AsValue().AsText();
                                        end;
                                        IF tag1 = 'Acquirer Name' then begin
                                            txnStatusJsonObject1.Get('Value', JobjToken1);
                                            AcquirerName := JobjToken1.AsValue().AsText();
                                        end;
                                        /*
                                                                            IF tag1 = 'Transaction Date' then begin
                                                                                txnStatusJsonObject1.Get('Value', JobjToken1);
                                                                                // Evaluate(TransactionDate, JobjToken1.AsValue().AsText());
                                                                                dateText := FORMAT(JobjToken1.AsValue().AsText(), 10, '<Day,2>/<Month,2>/<Year,4>');
                                                                                Evaluate(TransactionDate, dateText);

                                                                            end;

                                                                            IF tag1 = 'Transaction Time' then begin
                                                                                txnStatusJsonObject1.Get('Value', JobjToken1);
                                                                                Evaluate(Transactiontime, JobjToken1.AsValue().AsText())

                                                                            end;


                                        IF tag1 = 'AmountInPaisa' then begin
                                            txnStatusJsonObject1.Get('Value', JobjToken1);
                                            AmountInPaisa := JobjToken1.AsValue().AsDecimal();
                                        end;
                                        IF tag1 = 'OriginalAmount' then begin
                                            txnStatusJsonObject1.Get('Value', JobjToken1);
                                            OriginalAmount := JobjToken1.AsValue().AsDecimal();
                                        end;
                                        IF tag1 = 'FinalAmount' then begin
                                            txnStatusJsonObject1.Get('Value', JobjToken1);
                                            FinalAmount := JobjToken1.AsValue().AsDecimal();
                                        end;

                                        IF tag1 = 'BatchNumber' Then Begin
                                            txnStatusJsonObject1.Get('Value', JobjToken1);
                                            BatchNumber := JobjToken1.AsValue().AsText();

                                        End;
                                        IF tag1 = 'RRN' Then Begin
                                            txnStatusJsonObject1.Get('Value', JobjToken1);
                                            RRN := JobjToken1.AsValue().AsText();

                                        End;


                                    end;
                                End;
                                Message(Format(JsonArrayDataPinelabStatus1));
                                IF ApprovedAmount > 0 then begin
                                    isHandled := False;

                                    TempPineLabTrannsDetails.CardType := CardType;
                                    TempPineLabTrannsDetails.CardNumber := CardNumber;
                                    TempPineLabTrannsDetails.cardholdername := CardHolderName;
                                    TempPineLabTrannsDetails.InvoiceNumber := InvoiceNumber;
                                    TempPineLabTrannsDetails.PaymentMode := PaymentMode;
                                    TempPineLabTrannsDetails.TID := TID;
                                    TempPineLabTrannsDetails.TransactionStatusRequest := JsonText;
                                    TempPineLabTrannsDetails.txnstatusresponse := responseText1;
                                    TempPineLabTrannsDetails.TransactionStatus := 'TXN APPROVED';
                                    TempPineLabTrannsDetails.AcquirerId := AcquirerId;
                                    TempPineLabTrannsDetails.TransactionDate := TransactionDate;
                                    TempPineLabTrannsDetails.Transactiontime := TransactionTime;

                                    TempPineLabTrannsDetails.AcquirerName := AcquirerName;
                                    TempPineLabTrannsDetails.AmountInPaisa := AmountInPaisa;
                                    TempPineLabTrannsDetails.FinalAmount := FinalAmount;
                                    TempPineLabTrannsDetails.OriginalAmount := OriginalAmount;
                                    TempPineLabTrannsDetails.BatchNumber := BatchNumber;
                                    TempPineLabTrannsDetails.RRN := RRn;

                                    //TempPineLabTrannsDetails.

                                    TempPineLabTrannsDetails.Modify();

                                end
                                else
                                    Error('Approve amount should be grater than 0');

                            End Else begin
                                IF not (responseStatus1 = 'TXN UPLOADED') then Begin
                                    // TempPineLabTrannsDetails.CurrentTransaction := false;
                                    //TempPineLabTrannsDetails.TransactionStatus := responseStatus;
                                    // TempPineLabTrannsDetails.Modify();
                                    //IsHandled := true;
                                    // Commit();
                                    plabdetailsTrans.Reset();
                                    plabdetailsTrans.SetRange(plabdetailsTrans."POS Terminal No.", POSTransaction."POS Terminal No.");
                                    plabdetailsTrans.SetRange(plabdetailsTrans.CurrentTransaction, true);
                                    plabdetailsTrans.SetRange(plabdetailsTrans."Receipt No.", POSTransaction."Receipt No.");
                                    plabdetailsTrans.SetRange(plabdetailsTrans."Store No.", POSTransaction."Store No.");
                                    plabdetailsTrans.SetFilter(plabdetailsTrans.TransactionStatus, '<>%1', 'TXN APPROVED');
                                    if plabdetailsTrans.FindLast() then begin
                                        plabdetailsTrans.TransactionStatus := responseStatus1;
                                        plabdetailsTrans.Modify();
                                        Commit();
                                        //  Message('Response Status %1', responseStatus);
                                    End;
                                End;
                                Error('Transaction is declined with Error %1 , please try to send a request again', responseStatus1);

                            end;


                        End;


                    end;


                End;

            End
            Else
                Error('Resposnse error from pine lab');



        End;
    */


    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Transaction Events", 'OnAfterInsertPaymentLine', '', false, false)]
    local procedure OnAfterInsertPaymentLine(var POSTransaction: Record "LSC POS Transaction"; var POSTransLine: Record "LSC POS Trans. Line";
    var CurrInput: Text; var TenderTypeCode: Code[10])
    var
        tempint: Integer;
        tempLSCTenderType: Record "LSC tender type";
        tempTendertypesetup: Record "LSC Tender Type Setup";
    begin
        /*
        if TenderTypeCode = '50' then begin
            Evaluate(tempint, CurrInput);
            //  POSTransLine.PlutusTransactionReferenceID := tempint;
            //   Message(Format(POSTransLine.PlutusTransactionReferenceID));
            Clear(CurrInput);
        end;
        */
        IF tempTendertypesetup.Get(TenderTypeCode) then;
        if (tempTendertypesetup.PinelabCard) or (tempTendertypesetup.PineLabUPI) or (tempTendertypesetup.PineLabGiftCard) then begin
            //Message(format(plutusRefID));
            IF CurrInput <> '' Then
                POSTransLine.PlutusTransaction := Format(CurrInput);
            POSTransLine.Modify();
            Clear(CurrInput);

        End;


    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Post Utility", 'OnBeforeInsertPaymentEntryV2', '', true, true)]
    local procedure OnBeforeInsertPaymentEntryV2(var POSTransaction: Record "LSC POS Transaction"; var POSTransLineTemp: Record "LSC POS Trans. Line" temporary; var TransPaymentEntry: Record "LSC Trans. Payment Entry")
    begin
        TransPaymentEntry.PlutusTransaction := POSTransLineTemp.PlutusTransaction;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Transaction Events", 'OnAfterTenderKeyPressedEx', '', false, false)]
    local procedure OnAfterTenderKeyPressedEx(var POSTransaction: Record "LSC POS Transaction"; var POSTransLine: Record "LSC POS Trans. Line";
      var TenderAmountText: Text; var TenderTypeCode: Code[10]; var CurrInput: Text; var IsHandled: Boolean)
    var
        client: HttpClient;
        request: HttpRequestMessage;
        response: HttpResponseMessage;
        contentHeaders: HttpHeaders;
        content: HttpContent;
        responseText: Text;
        TempBlob: Codeunit "Temp Blob";
        ToFile: Variant;
        InStream: InStream;
        OutStream: OutStream;
        JobjToken: JsonToken;
        JobjectResponse: JsonObject;
        PlutusTransactionReferenceID: Integer;
        UseLineNo: Integer;
        POSTransLine1: Record "LSC POS Trans. Line";
        tempLSCTenderType: Record "LSC Tender type";
        tempTendertypesetup: Record "LSC Tender Type Setup";
        tempposterminal: Record "LSC Pos Terminal";
        merchid: Integer;
        TempPineLabTrannsDetails: Record PineLabTransactiondetails;
        JSONManagement: Codeunit "JSON Management";
        JSONTransactionDataArray: JsonArray;
        JSONTransdataObject: JsonObject;
        i: Integer;
        txnStatusJsonObject: JsonObject;
        ApprovedAmount: Decimal;
        tag: Text[50];
        CardHolderName: Text[100];
        CardNumber: Text[30];
        InvoiceNumber: Text[20];
        CardType: Text[10];
        PaymentMode: Text[20];
        TransactionLogId: Integer;
        TID: Integer;
        txnstatusresponse: Text[2048];
        responseStatus: text[100];
        plabdetailsTrans: Record PineLabTransactiondetails;

        AcquirerId: Text[20];
        AcquirerName: Text[50];
        TransactionDate: Date;
        TransactionTime: Time;
        AmountInPaisa: Decimal;
        OriginalAmount: Decimal;
        FinalAmount: Decimal;
        tempTendertypesetup1: Record "LSC Tender Type Setup";
        BatchNumber: text[20];
        RRN: text[20];
        JsonArrayDataPinelabStatus: JsonArray;

        SalesReturnPaymentMode: Text[10];
        ReturnAmount: Decimal;

        TemptwcApiSetup: Record TwcApiSetupUrl;

    begin
        // Message(format(PaymentAmount));
        // CurrInput := '10';
        // Message(CurrInput);
        //for pinelab get status
        Initialize();

        IF tempTendertypesetup.Get(TenderTypeCode) then;
        tempposterminal.Reset();
        tempposterminal.SetRange("No.", POSTransaction."POS Terminal No.");
        if tempposterminal.FindFirst() then;
        //for processing Normal sales transaction.
        IF ((tempTendertypesetup.PineLabPaymentTender) and (Not POSTransaction."Sale Is Return Sale")) then begin
            IsHandled := true;
            TempPineLabTrannsDetails.Reset();
            TempPineLabTrannsDetails.SetRange(TempPineLabTrannsDetails."POS Terminal No.", POSTransaction."POS Terminal No.");
            //TempPineLabTrannsDetails.SetRange(TempPineLabTrannsDetails.CurrentTransaction, true);
            TempPineLabTrannsDetails.SetRange(TempPineLabTrannsDetails."Receipt No.", POSTransaction."Receipt No.");
            TempPineLabTrannsDetails.SetRange(TempPineLabTrannsDetails."Store No.", POSTransaction."Store No.");
            TempPineLabTrannsDetails.SetFilter(TempPineLabTrannsDetails.TransactionStatus, '<>%1', 'TXN APPROVED');
            if TempPineLabTrannsDetails.FindLast() then begin
                Initialize();

                //tender type Code
                IF TempPineLabTrannsDetails.AllowedPaymentMode = '1' then begin
                    //TenderTypeCode := '50';
                    //  tempTendertypesetup1.Reset();
                    //   tempTendertypesetup1.SetRange(tempTendertypesetup1.PinelabCard, true);
                    //IF tempTendertypesetup1.FindFirst() then
                    // TenderTypeCode := tempTendertypesetup1.Code;
                end;


                IF TempPineLabTrannsDetails.AllowedPaymentMode = '10' then begin
                    // tempTendertypesetup1.Reset();
                    //   tempTendertypesetup1.SetRange(tempTendertypesetup1.PineLabUPI, true);
                    // IF tempTendertypesetup1.FindFirst() then
                    //   TenderTypeCode := tempTendertypesetup1.Code;
                end;


                tempposterminal.Reset();
                tempposterminal.SetRange("No.", POSTransaction."POS Terminal No.");
                if tempposterminal.FindFirst() then;

                // WriteJsonFileHeader();
                Evaluate(merchid, tempposterminal.MerchantID);
                JObject.Add('MerchantID', merchid);
                JObject.Add('SecurityToken', tempposterminal.SecurityToken);
                JObject.Add('IMEI', tempposterminal.IMEI);
                JObject.Add('MerchantStorePosCode', tempposterminal.MerchantStorePosCode);
                JObject.Add('PlutusTransactionReferenceID', TempPineLabTrannsDetails.PlutusRefID);
                JObject.WriteTo(JsonText);

                TempBlob.CreateOutStream(OutStream);
                OutStream.WriteText(JsonText);
                ToFile := 'pinelab.json';
                //  TempBlob.CreateInStream(InStream);
                //  DownloadFromStream(InStream, 'Pinelab', '', '', ToFile);
                // Sleep(1000);

                content.WriteFrom(JsonText);
                content.GetHeaders(contentHeaders);
                contentHeaders.Clear();
                contentHeaders.Add('Content-Type', 'application/json');

                request.Content := content;
                //https://www.plutuscloudserviceuat.in:8201/API/CloudBasedIntegration/V1/GetCloudBasedTxnStatus
                TemptwcApiSetup.Get();
                TemptwcApiSetup.TestField(TemptwcApiSetup.PineLabGetStatusUrl);
                request.SetRequestUri(TemptwcApiSetup.PineLabGetStatusUrl);
                request.Method := 'POST';

                client.Send(request, response);
                if response.IsSuccessStatusCode then begin
                    response.Content().ReadAs(responseText);
                    //  Message(responseText);
                    if JobjToken.ReadFrom(responseText) then begin
                        if JobjToken.IsObject then begin
                            JobjectResponse := JobjToken.AsObject();
                            JobjectResponse.Get('PlutusTransactionReferenceID', JobjToken);
                            PlutusTransactionReferenceID := JobjToken.AsValue().AsInteger();
                            if JobjectResponse.Get('ResponseMessage', JobjToken) then begin
                                responseStatus := JobjToken.AsValue().AsText();
                                // Message(responseStatus);
                                if (JobjToken.AsValue().AsText() = 'TXN APPROVED') then begin

                                    //Create JSONArray String
                                    JobjectResponse.Get('TransactionData', JobjToken);
                                    if JobjToken.IsArray then
                                        JsonArrayDataPinelabStatus := JobjToken.AsArray();

                                    for i := 0 to JsonArrayDataPinelabStatus.Count() - 1 do begin

                                        JsonArrayDataPinelabStatus.Get(i, JobjToken);
                                        if JobjToken.IsObject then begin
                                            txnStatusJsonObject := JobjToken.AsObject();
                                            txnStatusJsonObject.Get('Tag', JobjToken);
                                            tag := JobjToken.AsValue().AsText();

                                            IF tag = 'Amount' then begin
                                                txnStatusJsonObject.Get('Value', JobjToken);
                                                ApprovedAmount := JobjToken.AsValue().AsDecimal();
                                                // Message('Approved amount %1', ApprovedAmount);
                                            end;


                                            IF tag = 'Invoice Number' then begin
                                                txnStatusJsonObject.Get('Value', JobjToken);
                                                InvoiceNumber := JobjToken.AsValue().AsText();
                                            end;

                                            IF tag = 'Card Number' then begin
                                                txnStatusJsonObject.Get('Value', JobjToken);
                                                CardNumber := JobjToken.AsValue().AsText();
                                            end;

                                            IF tag = 'Card Holder Name' then begin
                                                txnStatusJsonObject.Get('Value', JobjToken);
                                                CardHolderName := JobjToken.AsValue().AsText();
                                            end;

                                            IF tag = 'PaymentMode' then begin
                                                txnStatusJsonObject.Get('Value', JobjToken);
                                                PaymentMode := JobjToken.AsValue().AsText();
                                            end;
                                            IF tag = 'Card Type' then begin
                                                txnStatusJsonObject.Get('Value', JobjToken);
                                                CardType := JobjToken.AsValue().AsText();
                                            end;

                                            IF tag = 'TID' then begin
                                                txnStatusJsonObject.Get('Value', JobjToken);
                                                TID := JobjToken.AsValue().AsInteger();
                                            end;

                                            IF tag = 'Acquirer Id' then begin
                                                txnStatusJsonObject.Get('Value', JobjToken);
                                                AcquirerId := JobjToken.AsValue().AsText();
                                            end;
                                            IF tag = 'Acquirer Name' then begin
                                                txnStatusJsonObject.Get('Value', JobjToken);
                                                AcquirerName := JobjToken.AsValue().AsText();
                                            end;
                                            /*
                                            IF tag = 'Transaction Date' then begin
                                                txnStatusJsonObject.Get('Value', JobjToken);
                                                Evaluate(TransactionDate, JobjToken.AsValue().AsText());

                                            end;
                                            IF tag = 'Transaction Time' then begin
                                                txnStatusJsonObject.Get('Value', JobjToken);
                                                Evaluate(Transactiontime, JobjToken.AsValue().AsText())

                                            end;
                                            */
                                            IF tag = 'AmountInPaisa' then begin
                                                txnStatusJsonObject.Get('Value', JobjToken);
                                                AmountInPaisa := JobjToken.AsValue().AsDecimal();
                                            end;
                                            IF tag = 'OriginalAmount' then begin
                                                txnStatusJsonObject.Get('Value', JobjToken);
                                                OriginalAmount := JobjToken.AsValue().AsDecimal();
                                            end;
                                            IF tag = 'FinalAmount' then begin
                                                txnStatusJsonObject.Get('Value', JobjToken);
                                                FinalAmount := JobjToken.AsValue().AsDecimal();
                                            end;

                                            IF tag = 'BatchNumber' Then Begin
                                                txnStatusJsonObject.Get('Value', JobjToken);
                                                BatchNumber := JobjToken.AsValue().AsText();

                                            End;
                                            IF tag = 'RRN' Then Begin
                                                txnStatusJsonObject.Get('Value', JobjToken);
                                                RRN := JobjToken.AsValue().AsText();

                                            End;


                                        end;
                                    end;
                                    //   Message(Format(JsonArrayDataPinelabStatus));
                                    IF ApprovedAmount > 0 then begin
                                        CurrInput := Format(ApprovedAmount);
                                        IsHandled := false;
                                        TempPineLabTrannsDetails.CurrentTransaction := True;
                                        TempPineLabTrannsDetails.CardType := CardType;
                                        TempPineLabTrannsDetails.CardNumber := CardNumber;
                                        TempPineLabTrannsDetails.Amount := ApprovedAmount;
                                        TempPineLabTrannsDetails.cardholdername := CardHolderName;
                                        TempPineLabTrannsDetails.InvoiceNumber := InvoiceNumber;
                                        TempPineLabTrannsDetails.PaymentMode := PaymentMode;
                                        TempPineLabTrannsDetails.TID := TID;
                                        TempPineLabTrannsDetails.TransactionStatusRequest := JsonText;
                                        TempPineLabTrannsDetails.txnstatusresponse := responseText;
                                        TempPineLabTrannsDetails.TransactionStatus := 'TXN APPROVED';
                                        TempPineLabTrannsDetails.AcquirerId := AcquirerId;
                                        TempPineLabTrannsDetails.AcquirerName := AcquirerName;
                                        TempPineLabTrannsDetails.AmountInPaisa := AmountInPaisa;
                                        TempPineLabTrannsDetails.FinalAmount := FinalAmount;
                                        TempPineLabTrannsDetails.OriginalAmount := OriginalAmount;
                                        //TempPineLabTrannsDetails.
                                        TempPineLabTrannsDetails.BatchNumber := BatchNumber;
                                        TempPineLabTrannsDetails.RRN := RRN;
                                        //TempPineLabTrannsDetails.TransactionDate := POSTransaction.tra;
                                        //TempPineLabTrannsDetails.Transactiontime := TransactionTime;

                                        TempPineLabTrannsDetails.Modify(true);

                                    end
                                    else
                                        Error('Approve amount should be grater than 0');

                                end
                                Else begin
                                    IF not (responseStatus = 'TXN UPLOADED') then Begin
                                        // TempPineLabTrannsDetails.CurrentTransaction := false;
                                        //TempPineLabTrannsDetails.TransactionStatus := responseStatus;
                                        // TempPineLabTrannsDetails.Modify();
                                        //IsHandled := true;
                                        // Commit();
                                        plabdetailsTrans.Reset();
                                        plabdetailsTrans.SetRange(plabdetailsTrans."POS Terminal No.", POSTransaction."POS Terminal No.");
                                        plabdetailsTrans.SetRange(plabdetailsTrans."Receipt No.", POSTransaction."Receipt No.");
                                        plabdetailsTrans.SetRange(plabdetailsTrans."Store No.", POSTransaction."Store No.");
                                        plabdetailsTrans.SetFilter(plabdetailsTrans.TransactionStatus, '<>%1', 'TXN APPROVED');
                                        if plabdetailsTrans.FindLast() then begin
                                            plabdetailsTrans.TransactionStatus := responseStatus;
                                            plabdetailsTrans.Modify(true);
                                            Commit();
                                            //  Message('Response Status %1', responseStatus);
                                        End;
                                    End;
                                    Error('Transaction is declined , please try to send a request again');

                                end;
                            end;
                        end
                        Else
                            Error(JobjToken.AsValue().AsText());
                    End;
                end;
            end
            else
                Error('No open request found for this transaction');
        end
        Else begin   ///sales return transaction processing
            IF ((tempTendertypesetup.PineLabPaymentTender) and POSTransaction."Sale Is Return Sale") then begin
                ///Sales Return Processing start
                IsHandled := true;
                TempPineLabTrannsDetails.Reset();
                TempPineLabTrannsDetails.SetRange(TempPineLabTrannsDetails."POS Terminal No.", POSTransaction."POS Terminal No.");
                TempPineLabTrannsDetails.SetRange(TempPineLabTrannsDetails.SalesReturnReceiptNo, POSTransaction."Receipt No.");
                TempPineLabTrannsDetails.SetRange(TempPineLabTrannsDetails."Store No.", POSTransaction."Store No.");
                TempPineLabTrannsDetails.SetFilter(TempPineLabTrannsDetails.SalesReturnUploaTransStatus, '=%1', 'APPROVED');
                TempPineLabTrannsDetails.SetFilter(TempPineLabTrannsDetails.SalesReturnTransactionStatus, '<>%1', 'TXN APPROVED');
                if TempPineLabTrannsDetails.FindLast() then begin
                    Initialize();

                    tempposterminal.Reset();
                    tempposterminal.SetRange("No.", POSTransaction."POS Terminal No.");
                    if tempposterminal.FindFirst() then;

                    // WriteJsonFileHeader();
                    Evaluate(merchid, tempposterminal.MerchantID);
                    JObject.Add('MerchantID', merchid);
                    JObject.Add('SecurityToken', tempposterminal.SecurityToken);
                    JObject.Add('IMEI', tempposterminal.IMEI);
                    JObject.Add('MerchantStorePosCode', tempposterminal.MerchantStorePosCode);
                    JObject.Add('PlutusTransactionReferenceID', TempPineLabTrannsDetails.SaleReturnPlutusRefNo);
                    JObject.WriteTo(JsonText);

                    TempBlob.CreateOutStream(OutStream);
                    OutStream.WriteText(JsonText);
                    ToFile := 'pinelab.json';
                    //  TempBlob.CreateInStream(InStream);
                    // DownloadFromStream(InStream, 'Pinelab', '', '', ToFile);
                    // Sleep(1000);

                    content.WriteFrom(JsonText);
                    content.GetHeaders(contentHeaders);
                    contentHeaders.Clear();
                    contentHeaders.Add('Content-Type', 'application/json');

                    request.Content := content;
                    TemptwcApiSetup.Get();
                    TemptwcApiSetup.TestField(TemptwcApiSetup.PineLabGetStatusUrl);
                    //https://www.plutuscloudserviceuat.in:8201/API/CloudBasedIntegration/V1/GetCloudBasedTxnStatus
                    request.SetRequestUri(TemptwcApiSetup.PineLabGetStatusUrl);
                    request.Method := 'POST';

                    client.Send(request, response);
                    if response.IsSuccessStatusCode then begin
                        response.Content().ReadAs(responseText);
                        //  Message(responseText);
                        if JobjToken.ReadFrom(responseText) then begin
                            if JobjToken.IsObject then begin
                                JobjectResponse := JobjToken.AsObject();
                                JobjectResponse.Get('PlutusTransactionReferenceID', JobjToken);
                                PlutusTransactionReferenceID := JobjToken.AsValue().AsInteger();
                                if JobjectResponse.Get('ResponseMessage', JobjToken) then begin
                                    responseStatus := JobjToken.AsValue().AsText();
                                    // Message(responseStatus);
                                    if (JobjToken.AsValue().AsText() = 'TXN APPROVED') then begin

                                        //Create JSONArray String
                                        JobjectResponse.Get('TransactionData', JobjToken);
                                        if JobjToken.IsArray then
                                            JsonArrayDataPinelabStatus := JobjToken.AsArray();

                                        for i := 0 to JsonArrayDataPinelabStatus.Count() - 1 do begin

                                            JsonArrayDataPinelabStatus.Get(i, JobjToken);
                                            if JobjToken.IsObject then begin
                                                txnStatusJsonObject := JobjToken.AsObject();
                                                txnStatusJsonObject.Get('Tag', JobjToken);
                                                tag := JobjToken.AsValue().AsText();

                                                IF tag = 'PaymentMode' then begin
                                                    txnStatusJsonObject.Get('Value', JobjToken);
                                                    SalesReturnPaymentMode := JobjToken.AsValue().AsText();
                                                    // Message('Approved amount %1', ApprovedAmount);
                                                end;
                                            end;

                                        End;

                                        IF SalesReturnPaymentMode = 'VOID' then begin
                                            CurrInput := Format(TempPineLabTrannsDetails.Amount);
                                            IsHandled := false;
                                            TempPineLabTrannsDetails.SalesReturnPaymentMode := 'VOID';
                                            TempPineLabTrannsDetails.SalesReturnTransactionStatus := 'TXN APPROVED';

                                            TempPineLabTrannsDetails.Modify(true);
                                        end;

                                    end
                                    Else
                                        Error('Transaction is not successful');
                                end
                                Else
                                    Error(JobjToken.AsValue().AsText());
                            End;
                        end;
                    end
                    else
                        Error('No open sales return request found for this transaction');

                    //Sales Return Processing end
                end
                Else
                    error('No ransaction found for return');

            end;
        End;
        ///for Uploading Sales return transaction.
        IF tempTendertypesetup.PineLabReturn then begin
            IsHandled := true;

            IF NOT POSTransaction."Sale Is Return Sale" then
                Error('Pinelab Return Tender only work in case of Return transaction.');

            TempPineLabTrannsDetails.Reset();
            TempPineLabTrannsDetails.SetRange(TempPineLabTrannsDetails."POS Terminal No.", POSTransaction."Retrieved from POS Term. No.");
            //TempPineLabTrannsDetails.SetRange(TempPineLabTrannsDetails.CurrentTransaction, true);
            TempPineLabTrannsDetails.SetRange(TempPineLabTrannsDetails."Receipt No.", POSTransaction."Retrieved from Receipt No.");
            TempPineLabTrannsDetails.SetRange(TempPineLabTrannsDetails."Store No.", POSTransaction."Retrieved from Store No.");
            TempPineLabTrannsDetails.SetFilter(TempPineLabTrannsDetails.TransactionStatus, '=%1', 'TXN APPROVED');
            TempPineLabTrannsDetails.SetFilter(TempPineLabTrannsDetails.SalesReturnTransactionStatus, '=%1', '');
            if TempPineLabTrannsDetails.FindFirst() then Begin


                Initialize();

                tempposterminal.Reset();
                tempposterminal.SetRange("No.", POSTransaction."POS Terminal No.");
                if tempposterminal.FindFirst() then;

                Evaluate(merchid, tempposterminal.MerchantID);
                JObject.Add('TransactionNumber', TempPineLabTrannsDetails."Receipt No.");


                JObject.Add('SequenceNumber', TempPineLabTrannsDetails.SequenceNumber);

                JObject.Add('AllowedPaymentMode', TempPineLabTrannsDetails.AllowedPaymentMode);
                /// return amount                 
               /*
                ReturnAmount := POSTransaction."Gross Amount" - POSTransaction.Payment;
                IF ReturnAmount >= TempPineLabTrannsDetails.Amount then
                    JObject.Add('Amount', TempPineLabTrannsDetails.AmountInPaisa)
                Else
                    JObject.Add('Amount', (ReturnAmount * 100));
                    */

                //
                JObject.Add('Amount', TempPineLabTrannsDetails.AmountInPaisa);
                JObject.Add('MerchantStorePosCode', tempposterminal.MerchantStorePosCode);

                JObject.Add('MerchantID', merchid);
                JObject.Add('SecurityToken', tempposterminal.SecurityToken);
                JObject.Add('IMEI', tempposterminal.IMEI);
                JObject.Add('TxnType', 1);

                JObject.Add('OriginalPlutusTransactionReferenceID', TempPineLabTrannsDetails.PlutusRefID);
                JObject.WriteTo(JsonText);

                TempBlob.CreateOutStream(OutStream);
                OutStream.WriteText(JsonText);
                ToFile := 'pinelab.json';
                //TempBlob.CreateInStream(InStream);
                //DownloadFromStream(InStream, 'Pinelab', '', '', ToFile);
                //Sleep(1000);

                content.WriteFrom(JsonText);
                content.GetHeaders(contentHeaders);
                contentHeaders.Clear();
                contentHeaders.Add('Content-Type', 'application/json');

                request.Content := content;
                //https://www.plutuscloudserviceuat.in:8201/API/CloudBasedIntegration/V1/UploadBilledTransaction
                TemptwcApiSetup.Get();
                TemptwcApiSetup.TestField(TemptwcApiSetup.PineLabCancelUrl);
                request.SetRequestUri(TemptwcApiSetup.PineLabCancelUrl);
                request.Method := 'POST';

                client.Send(request, response);
                if response.IsSuccessStatusCode then begin

                    response.Content().ReadAs(responseText);
                    //  Message(responseText);
                    if JobjToken.ReadFrom(responseText) then begin
                        if JobjToken.IsObject then begin
                            JobjectResponse := JobjToken.AsObject();
                            JobjectResponse.Get('PlutusTransactionReferenceID', JobjToken);
                            PlutusTransactionReferenceID := JobjToken.AsValue().AsInteger();
                            if JobjectResponse.Get('ResponseMessage', JobjToken) then begin
                                responseStatus := JobjToken.AsValue().AsText();
                                // Message(responseStatus);
                                if (responseStatus = 'APPROVED') then begin
                                    //Create JSONArray String
                                    TempPineLabTrannsDetails.SalesReturnUploaTransStatus := 'APPROVED';
                                    TempPineLabTrannsDetails.SaleReturnPlutusRefNo := PlutusTransactionReferenceID;
                                    TempPineLabTrannsDetails.SalesReturnReceiptNo := POSTransaction."Receipt No.";
                                    TempPineLabTrannsDetails.Modify(true);
                                    Message('Transaction Uploaded to pinelab for return , please process return on pinelab');

                                End
                                Else
                                    Error('Invalid Response');

                            End;
                        End;

                    End;
                end;

            end
            Else
                Error('No plutus transaction id is find against this receipt Number');

        End;

    end;

    //For pinelab status check
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Transaction Events", 'OnBeforeRunCommand', '', true, true)]
    local procedure OnBeforeRunCommand(var POSTransaction: Record "LSC POS Transaction"; var POSTransLine: Record "LSC POS Trans. Line";
    var POSMenuLine: Record "LSC POS Menu Line"; var isHandled: Boolean; var CusomterOrCardNo: Code[20];
    var CurrInput: Text; TenderType: Record "LSC Tender Type")
    var
        TempPOSTransactionEvents: Codeunit "LSC POS Transaction Events";
        TenderAmountText: Text;
        TenderTypeCode: Code[10];

    begin
        if POSMenuLine.Command = 'PINELABSTATUS' then begin
            Message('New Pinelab Command');
            CurrInput := 'PineLab';
            // RunOnAfterTenderKeyPressedEx(POSTransaction, POSTransLine, TenderAmountText, TenderTypeCode, CurrInput, IsHandled);

        end;
    end;
    /*
        //to call on pos command tender press
        [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Transaction Events", 'OnAfterTenderKeyPressedEx', '', false, false)]
        local procedure RunOnAfterTenderKeyPressedEx(var POSTransaction: Record "LSC POS Transaction"; var POSTransLine: Record "LSC POS Trans. Line";
          var TenderAmountText: Text; var TenderTypeCode: Code[10]; var CurrInput: Text; var IsHandled: Boolean)
        var
            client: HttpClient;
            request: HttpRequestMessage;
            response: HttpResponseMessage;
            contentHeaders: HttpHeaders;
            content: HttpContent;
            responseText: Text;
            TempBlob: Codeunit "Temp Blob";
            ToFile: Variant;
            InStream: InStream;
            OutStream: OutStream;
            JobjToken: JsonToken;
            JobjectResponse: JsonObject;
            PlutusTransactionReferenceID: Integer;
            UseLineNo: Integer;
            POSTransLine1: Record "LSC POS Trans. Line";
            tempLSCTenderType: Record "LSC Tender type";
            tempTendertypesetup: Record "LSC Tender Type Setup";
            tempposterminal: Record "LSC Pos Terminal";
            merchid: Integer;
            TempPineLabTrannsDetails: Record PineLabTransactiondetails;
            JSONManagement: Codeunit "JSON Management";
            JSONTransactionDataArray: JsonArray;
            JSONTransdataObject: JsonObject;
            i: Integer;
            txnStatusJsonObject: JsonObject;
            ApprovedAmount: Decimal;
            tag: Text[50];
            CardHolderName: Text[100];
            CardNumber: Text[30];
            InvoiceNumber: Text[20];
            CardType: Text[10];
            PaymentMode: Text[20];
            TransactionLogId: Integer;
            TID: Integer;
            txnstatusresponse: Text[2048];
            responseStatus: text[100];
            plabdetailsTrans: Record PineLabTransactiondetails;

            AcquirerId: Text[20];
            AcquirerName: Text[50];
            TransactionDate: Date;
            TransactionTime: Time;
            AmountInPaisa: Decimal;
            OriginalAmount: Decimal;
            FinalAmount: Decimal;
            tempTendertypesetup1: Record "LSC Tender Type Setup";
            BatchNumber: text[10];
            RRN: text[10];
            JsonArrayDataPinelabStatus: JsonArray;
            dateText: Text[20];

        begin
            IF CurrInput = 'PineLab' Then begin
                Clear(CurrInput);
                IsHandled := true;
                Message('Pinelab Fucntion call from POS cooamnd');
                //for pinelab get status
                Initialize();
                //IF tempTendertypesetup.Get(TenderTypeCode) then;
                tempposterminal.Reset();
                tempposterminal.SetRange("No.", POSTransaction."POS Terminal No.");
                if tempposterminal.FindFirst() then;


                TempPineLabTrannsDetails.Reset();
                TempPineLabTrannsDetails.SetRange(TempPineLabTrannsDetails."POS Terminal No.", POSTransaction."POS Terminal No.");
                TempPineLabTrannsDetails.SetRange(TempPineLabTrannsDetails.CurrentTransaction, true);
                TempPineLabTrannsDetails.SetRange(TempPineLabTrannsDetails."Receipt No.", POSTransaction."Receipt No.");
                TempPineLabTrannsDetails.SetRange(TempPineLabTrannsDetails."Store No.", POSTransaction."Store No.");
                TempPineLabTrannsDetails.SetFilter(TempPineLabTrannsDetails.TransactionStatus, '<>%1', 'TXN APPROVED');
                if TempPineLabTrannsDetails.FindLast() then begin
                    Initialize();

                    //tender type Code
                    IF TempPineLabTrannsDetails.AllowedPaymentMode = '1' then begin
                        //TenderTypeCode := '50';
                        tempTendertypesetup1.Reset();
                        tempTendertypesetup1.SetRange(tempTendertypesetup1.PinelabCard, true);
                        IF tempTendertypesetup1.FindFirst() then
                            TenderTypeCode := tempTendertypesetup1.Code;
                    end;


                    IF TempPineLabTrannsDetails.AllowedPaymentMode = '10' then begin
                        tempTendertypesetup1.Reset();
                        tempTendertypesetup1.SetRange(tempTendertypesetup1.PineLabUPI, true);
                        IF tempTendertypesetup1.FindFirst() then
                            TenderTypeCode := tempTendertypesetup1.Code;
                    end;

                    tempposterminal.Reset();
                    tempposterminal.SetRange("No.", POSTransaction."POS Terminal No.");
                    if tempposterminal.FindFirst() then;

                    // WriteJsonFileHeader();
                    Evaluate(merchid, tempposterminal.MerchantID);
                    JObject.Add('MerchantID', merchid);
                    JObject.Add('SecurityToken', tempposterminal.SecurityToken);
                    JObject.Add('IMEI', tempposterminal.IMEI);
                    JObject.Add('MerchantStorePosCode', tempposterminal.MerchantStorePosCode);
                    JObject.Add('PlutusTransactionReferenceID', TempPineLabTrannsDetails.PlutusRefID);
                    JObject.WriteTo(JsonText);

                    TempBlob.CreateOutStream(OutStream);
                    OutStream.WriteText(JsonText);
                    ToFile := 'pinelab.json';
                    TempBlob.CreateInStream(InStream);
                    DownloadFromStream(InStream, 'Pinelab', '', '', ToFile);
                    Sleep(1000);

                    content.WriteFrom(JsonText);
                    content.GetHeaders(contentHeaders);
                    contentHeaders.Clear();
                    contentHeaders.Add('Content-Type', 'application/json');

                    request.Content := content;

                    request.SetRequestUri('https://www.plutuscloudserviceuat.in:8201/API/CloudBasedIntegration/V1/GetCloudBasedTxnStatus');
                    request.Method := 'POST';

                    client.Send(request, response);
                    if response.IsSuccessStatusCode then begin
                        response.Content().ReadAs(responseText);
                        //  Message(responseText);
                        if JobjToken.ReadFrom(responseText) then begin
                            if JobjToken.IsObject then begin
                                JobjectResponse := JobjToken.AsObject();
                                JobjectResponse.Get('PlutusTransactionReferenceID', JobjToken);
                                PlutusTransactionReferenceID := JobjToken.AsValue().AsInteger();
                                if JobjectResponse.Get('ResponseMessage', JobjToken) then begin
                                    responseStatus := JobjToken.AsValue().AsText();
                                    if (responseStatus = 'TXN APPROVED') then begin

                                        //Create JSONArray String
                                        JobjectResponse.Get('TransactionData', JobjToken);
                                        if JobjToken.IsArray then
                                            JsonArrayDataPinelabStatus := JobjToken.AsArray();

                                        for i := 0 to JsonArrayDataPinelabStatus.Count() - 1 do begin

                                            JsonArrayDataPinelabStatus.Get(i, JobjToken);
                                            if JobjToken.IsObject then begin
                                                txnStatusJsonObject := JobjToken.AsObject();
                                                txnStatusJsonObject.Get('Tag', JobjToken);
                                                tag := JobjToken.AsValue().AsText();

                                                IF tag = 'Amount' then begin
                                                    txnStatusJsonObject.Get('Value', JobjToken);
                                                    ApprovedAmount := JobjToken.AsValue().AsDecimal();
                                                    // Message('Approved amount %1', ApprovedAmount);
                                                end;


                                                IF tag = 'Invoice Number' then begin
                                                    txnStatusJsonObject.Get('Value', JobjToken);
                                                    InvoiceNumber := JobjToken.AsValue().AsText();
                                                end;

                                                IF tag = 'Card Number' then begin
                                                    txnStatusJsonObject.Get('Value', JobjToken);
                                                    CardNumber := JobjToken.AsValue().AsText();
                                                end;

                                                IF tag = 'Card Holder Name' then begin
                                                    txnStatusJsonObject.Get('Value', JobjToken);
                                                    CardHolderName := JobjToken.AsValue().AsText();
                                                end;

                                                IF tag = 'PaymentMode' then begin
                                                    txnStatusJsonObject.Get('Value', JobjToken);
                                                    PaymentMode := JobjToken.AsValue().AsText();
                                                end;
                                                IF tag = 'Card Type' then begin
                                                    txnStatusJsonObject.Get('Value', JobjToken);
                                                    CardType := JobjToken.AsValue().AsText();
                                                end;

                                                IF tag = 'TID' then begin
                                                    txnStatusJsonObject.Get('Value', JobjToken);
                                                    TID := JobjToken.AsValue().AsInteger();
                                                end;

                                                IF tag = 'Acquirer Id' then begin
                                                    txnStatusJsonObject.Get('Value', JobjToken);
                                                    AcquirerId := JobjToken.AsValue().AsText();
                                                end;
                                                IF tag = 'Acquirer Name' then begin
                                                    txnStatusJsonObject.Get('Value', JobjToken);
                                                    AcquirerName := JobjToken.AsValue().AsText();
                                                end;
                                                /*
                                               IF tag = 'Transaction Date' then begin
                                                   txnStatusJsonObject.Get('Value', JobjToken);
                                                   // Evaluate(TransactionDate, JobjToken1.AsValue().AsText());
                                                   //dateText := FORMAT(JobjToken.AsValue().AsDate(), 10, '<Day,2>/<Month,2>/<Year4>');
                                                   TransactionDate := JobjToken.AsValue().AsDate();

                                               End;

                                               IF tag = 'Transaction Time' then begin
                                                   txnStatusJsonObject.Get('Value', JobjToken);
                                                   //Evaluate(Transactiontime, JobjToken.AsValue().AsTime())
                                                   Transactiontime := JobjToken.AsValue().AsTime();
                                               end; 


                                                IF tag = 'AmountInPaisa' then begin
                                                    txnStatusJsonObject.Get('Value', JobjToken);
                                                    AmountInPaisa := JobjToken.AsValue().AsDecimal();
                                                end;
                                                IF tag = 'OriginalAmount' then begin
                                                    txnStatusJsonObject.Get('Value', JobjToken);
                                                    OriginalAmount := JobjToken.AsValue().AsDecimal();
                                                end;
                                                IF tag = 'FinalAmount' then begin
                                                    txnStatusJsonObject.Get('Value', JobjToken);
                                                    FinalAmount := JobjToken.AsValue().AsDecimal();
                                                end;

                                                IF tag = 'BatchNumber' Then Begin
                                                    txnStatusJsonObject.Get('Value', JobjToken);
                                                    BatchNumber := JobjToken.AsValue().AsText();

                                                End;
                                                IF tag = 'RRN' Then Begin
                                                    txnStatusJsonObject.Get('Value', JobjToken);
                                                    RRN := JobjToken.AsValue().AsText();

                                                End;


                                            end;
                                        end;
                                        Message(Format(JsonArrayDataPinelabStatus));
                                        IF ApprovedAmount > 0 then begin
                                            CurrInput := Format(ApprovedAmount);
                                            IsHandled := false;
                                            TempPineLabTrannsDetails.CardType := CardType;
                                            TempPineLabTrannsDetails.CardNumber := CardNumber;
                                            TempPineLabTrannsDetails.cardholdername := CardHolderName;
                                            TempPineLabTrannsDetails.InvoiceNumber := InvoiceNumber;
                                            TempPineLabTrannsDetails.PaymentMode := PaymentMode;
                                            TempPineLabTrannsDetails.TID := TID;
                                            TempPineLabTrannsDetails.TransactionStatusRequest := JsonText;
                                            TempPineLabTrannsDetails.txnstatusresponse := responseText;
                                            TempPineLabTrannsDetails.TransactionStatus := 'TXN APPROVED';
                                            TempPineLabTrannsDetails.AcquirerId := AcquirerId;
                                            TempPineLabTrannsDetails.AcquirerName := AcquirerName;
                                            TempPineLabTrannsDetails.AmountInPaisa := AmountInPaisa;
                                            TempPineLabTrannsDetails.FinalAmount := FinalAmount;
                                            TempPineLabTrannsDetails.OriginalAmount := OriginalAmount;
                                            //TempPineLabTrannsDetails.
                                            TempPineLabTrannsDetails.BatchNumber := BatchNumber;
                                            TempPineLabTrannsDetails.RRN := RRN;
                                            TempPineLabTrannsDetails.TransactionDate := TransactionDate;
                                            TempPineLabTrannsDetails.Transactiontime := TransactionTime;

                                            TempPineLabTrannsDetails.Modify();

                                        end
                                        else
                                            Error('Approve amount should be grater than 0');

                                    end
                                    Else begin
                                        IF not (responseStatus = 'TXN UPLOADED') then Begin
                                            // TempPineLabTrannsDetails.CurrentTransaction := false;
                                            //TempPineLabTrannsDetails.TransactionStatus := responseStatus;
                                            // TempPineLabTrannsDetails.Modify();
                                            //IsHandled := true;
                                            // Commit();
                                            plabdetailsTrans.Reset();
                                            plabdetailsTrans.SetRange(plabdetailsTrans."POS Terminal No.", POSTransaction."POS Terminal No.");
                                            plabdetailsTrans.SetRange(plabdetailsTrans.CurrentTransaction, true);
                                            plabdetailsTrans.SetRange(plabdetailsTrans."Receipt No.", POSTransaction."Receipt No.");
                                            plabdetailsTrans.SetRange(plabdetailsTrans."Store No.", POSTransaction."Store No.");
                                            plabdetailsTrans.SetFilter(plabdetailsTrans.TransactionStatus, '<>%1', 'TXN APPROVED');
                                            if plabdetailsTrans.FindLast() then begin
                                                plabdetailsTrans.TransactionStatus := responseStatus;
                                                plabdetailsTrans.Modify();
                                                Commit();
                                                //  Message('Response Status %1', responseStatus);
                                            End;
                                        End;
                                        // Error('Transaction is declined , please try to send a request again');

                                    end;
                                end;
                            end
                            Else
                                Error(JobjToken.AsValue().AsText());
                        End;
                    end;
                end
                else
                    Error('No open request found for this transaction');

            end;
        end;
    */


    local procedure Initialize()
    begin
        Clear(JObject);
        Clear(JsonArrayData);
        Clear(JsonText);
    end;

    local procedure Initialize1()
    begin
        Clear(JObject1);
        Clear(JsonArrayData1);
        Clear(JsonText1);
    end;





    var
        //global
        JObject: JsonObject;
        JsonArrayData: JsonArray;
        JsonText: Text;

        JObject1: JsonObject;
        JsonArrayData1: JsonArray;
        JsonText1: Text;

        plutusRefID: Integer;
        test: Codeunit "LSC POS Transaction";
    /*
            JObjectPinelabStatus: JsonObject;
            JsonArrayDataPinelabStatus: JsonArray;
            JsonTextPinelabStatus: Text;
            */


}
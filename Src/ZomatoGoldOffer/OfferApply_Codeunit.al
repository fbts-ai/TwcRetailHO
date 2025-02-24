// codeunit 50210 "OfferApply_FreeItem"
// {
//     var
//         PopupFunc: Codeunit "LSC Pop-up Functions";
//         POSPayloadUtil: Codeunit "LSC POS Payload Util";

//     trigger OnRun()
//     begin

//     end;

//     local procedure InsertFreeOfferItem(OfferNo: Code[20]; DiscvalPeriod: Code[10]; OfferDesc: Text; lvoidLine: Boolean)
//     var
//         InsertTransLine: Record "LSC POS Trans. Line";
//         LineNoLast: Record "LSC POS Trans. Line";
//         FreeItemOfferLine: Record "Free Item Offer Line";
//         DealPOSTransLine: Record "LSC POS Trans. Line";
//         PosTransCU: Codeunit "LSC POS Transaction";
//         PosTrans: Record "LSC POS Transaction";
//         FromLineNo: Integer;
//         POSLINES: Codeunit "LSC POS Trans. Lines";
//         PosPriceUtil: Codeunit "LSC POS Price Utility";
//         AmDec: Decimal;
//         AmountToDisc: Decimal;
//         FreeItemFlag: Boolean;
//         FreeItemCounter: Boolean;
//         I: Integer;//Insert
//         J: Integer;//Modify
//         FreeItemHeader: Record "FreeItem Offer Header";
//         SalesType: Record "LSC Sales Type";
//         SalesTypeFound: Boolean;
//     begin
//         PosTransCU.GetPOSTransaction(PosTrans);
//         FreeItemHeader.reset;
//         FreeItemHeader.SetRange("Offer No.", OfferNo);
//         FreeItemHeader.SetRange(Status, FreeItemHeader.Status::Enabled);
//         if FreeItemHeader.FindFirst() then begin
//             SalesType.Reset();
//             SalesType.SetFilter(Code, FreeItemHeader."Sales Type filter");
//             if SalesType.FindFirst() then
//                 repeat
//                     if PosTrans."Sales Type" = SalesType.Code then
//                         SalesTypeFound := true;
//                 until (SalesType.next = 0) or (SalesTypeFound);
//         end;

//         if not SalesTypeFound then
//             Exit;

//         FreeItemOfferLine.RESET;
//         FreeItemOfferLine.SETRANGE("Offer No.", OfferNo);
//         FreeItemOfferLine.SETRANGE("Free Item", TRUE);
//         IF FreeItemOfferLine.FINDFIRST THEN
//             REPEAT
//                 IF NOT lvoidLine THEN BEGIN
//                     InsertTransLine.RESET;
//                     InsertTransLine.SETRANGE("Receipt No.", PosTrans."Receipt No.");
//                     InsertTransLine.SETRANGE(Number, FreeItemOfferLine."No.");
//                     InsertTransLine.SETRANGE("Entry Status", InsertTransLine."Entry Status"::" ");
//                     IF InsertTransLine.FINDFIRST THEN BEGIN
//                         FreeItemFlag := true;
//                     End else
//                         FreeItemCounter := true;
//                 End;
//             until FreeItemOfferLine.next = 0;

//         FreeItemOfferLine.RESET;
//         FreeItemOfferLine.SETRANGE("Offer No.", OfferNo);
//         FreeItemOfferLine.SETRANGE("Free Item", TRUE);
//         IF FreeItemOfferLine.FINDFIRST THEN
//             REPEAT
//                 IF NOT lvoidLine THEN BEGIN
//                     InsertTransLine.RESET;
//                     InsertTransLine.SETRANGE("Receipt No.", PosTrans."Receipt No.");
//                     InsertTransLine.SETRANGE(Number, FreeItemOfferLine."No.");
//                     InsertTransLine.SETRANGE("Entry Status", InsertTransLine."Entry Status"::" ");
//                     // InsertTransLine.SETRANGE("Free Offer Item", TRUE);
//                     IF NOT InsertTransLine.FINDFIRST THEN BEGIN
//                         if (not FreeItemFlag) then begin
//                             InsertTransLine.INIT;
//                             InsertTransLine."Receipt No." := PosTrans."Receipt No.";
//                             InsertTransLine."Store No." := PosTrans."Store No.";
//                             InsertTransLine."POS Terminal No." := PosTrans."POS Terminal No.";
//                             InsertTransLine.VALIDATE(Number, FreeItemOfferLine."No.");

//                             LineNoLast.RESET;
//                             LineNoLast.SETRANGE("Receipt No.", PosTrans."Receipt No.");
//                             IF LineNoLast.FINDLAST THEN
//                                 InsertTransLine."Line No." := LineNoLast."Line No." + 1000
//                             ELSE
//                                 InsertTransLine."Line No." := 10000;

//                             InsertTransLine.VALIDATE(Quantity, 1);
//                             InsertTransLine."Free Offer Item" := TRUE;
//                             InsertTransLine."Free Offer No." := OfferNo;
//                             InsertTransLine.CalcPrices;
//                             InsertTransLine.InsertLine;
//                             POSLINES.SetCurrentLine(InsertTransLine);
//                             PosTransCU.DiscAmPressedEx(100);
//                             I += 1;
//                         End;
//                     END else begin
//                         InsertTransLine."Free Offer Item" := TRUE;
//                         InsertTransLine."Free Offer No." := OfferNo;
//                         InsertTransLine.Modify();

//                         AmDec := InsertTransLine.Price;
//                         AmountToDisc := InsertTransLine.Price * InsertTransLine.Quantity;

//                         POSLINES.SetCurrentLine(InsertTransLine);
//                         PosTransCU.DiscAmPressedEx(PosPriceUtil.DiscAmountGetPercentage(AmDec, AmountToDisc));
//                         J += 1;
//                     end;
//                 END;
//             UNTIL (FreeItemOfferLine.NEXT = 0) or (I >= 1) or (j >= 1);

//         IF NOT lvoidLine THEN BEGIN
//             PosTrans."Free Item Offer" := OfferNo;
//             PosTrans."Free Offer Validation Period" := DiscvalPeriod;
//             IF PosTrans.MODIFY THEN BEGIN
//                 DealPOSTransLine.SETRANGE("Receipt No.", PosTrans."Receipt No.");
//                 IF NOT DealPOSTransLine.FINDLAST THEN
//                     FromLineNo := 150
//                 ELSE
//                     FromLineNo := DealPOSTransLine."Line No." + 350;

//                 DealPOSTransLine.reset;
//                 DealPOSTransLine.SetRange("Receipt No.", PosTrans."Receipt No.");
//                 DealPOSTransLine.SetRange("Entry Status", DealPOSTransLine."Entry Status"::" ");
//                 DealPOSTransLine.SetRange("Entry Type", DealPOSTransLine."Entry Type"::FreeText);
//                 DealPOSTransLine.SetRange("Free Offer Item", true);
//                 if not DealPOSTransLine.FindFirst() then begin
//                     DealPOSTransLine.INIT;
//                     DealPOSTransLine."Receipt No." := PosTrans."Receipt No.";
//                     DealPOSTransLine."Store No." := PosTrans."Store No.";
//                     DealPOSTransLine."POS Terminal No." := PosTrans."POS Terminal No.";
//                     DealPOSTransLine."Line No." := FromLineNo;
//                     DealPOSTransLine."Entry Type" := DealPOSTransLine."Entry Type"::FreeText;
//                     DealPOSTransLine."Text Type" := DealPOSTransLine."Text Type"::"Freetext Input";
//                     DealPOSTransLine.Description := OfferDesc;
//                     DealPOSTransLine."Sales Type" := PosTrans."Sales Type";
//                     DealPOSTransLine."Free Offer Item" := TRUE;
//                     DealPOSTransLine."Free Offer No." := OfferNo;
//                     DealPOSTransLine.Quantity := 1;
//                     DealPOSTransLine.INSERT;
//                 end;
//             END;
//         END ELSE BEGIN
//             PosTrans."Free Item Offer" := '';
//             PosTrans."Free Offer Validation Period" := '';
//             PosTrans.MODIFY;

//             InsertTransLine.RESET;
//             InsertTransLine.SETRANGE("Receipt No.", PosTrans."Receipt No.");
//             InsertTransLine.SETRANGE("Entry Status", InsertTransLine."Entry Status"::" ");
//             InsertTransLine.SETRANGE("Free Offer Item", TRUE);
//             IF InsertTransLine.FINDFIRST THEN
//                 REPEAT
//                     InsertTransLine."Entry Status" := InsertTransLine."Entry Status"::Voided;
//                     InsertTransLine.MODIFY;
//                 UNTIL InsertTransLine.NEXT = 0;
//         END;
//     end;

//     local procedure ApplyOffer(lVoidPressed: Boolean; lVoidLineNo: Integer; lVoidItemCode: Code[20])
//     var
//         FreeItemOfferLine: Record "Free Item Offer Line";
//         AllNA: Decimal;
//         AllGA: Decimal;
//         ItemNA: Decimal;
//         ItemGA: Decimal;
//         FreeItemApply: Boolean;
//         ValidationPeriod: Record "LSC Validation Period";
//         RetailPriceUtils: Codeunit "LSC Retail Price Utils";
//         FreeItemOfferHeader: Record "FreeItem Offer Header";
//         OfferStorewiseDist: Record "Offer Store wise Dist.";
//         PosLine: Record "LSC POS Trans. Line";
//         POSTransaction: Record "LSC POS Transaction";
//         PosTransCU: Codeunit "LSC POS Transaction";
//     begin
//         //FBTS YM
//         PosTransCU.GetPOSTransaction(POSTransaction);
//         FreeItemOfferHeader.RESET;
//         FreeItemOfferHeader.SETRANGE(Status, FreeItemOfferHeader.Status::Enabled);
//         FreeItemOfferHeader.SetRange(DiscountOffer, false);
//         IF FreeItemOfferHeader.FINDFIRST THEN
//             REPEAT//Get All Enable Offer
//                 IF ValidationPeriod.GET(FreeItemOfferHeader."Validation Period ID") THEN
//                     IF RetailPriceUtils.DiscValPerValid(ValidationPeriod.ID, TODAY, TIME) THEN BEGIN
//                         IF OfferStorewiseDist.GET(FreeItemOfferHeader."Offer No.", POSTransaction."Store No.") THEN BEGIN//Get All Enable offer for particular Store
//                             FreeItemOfferLine.RESET;
//                             FreeItemOfferLine.SETRANGE("Offer No.", FreeItemOfferHeader."Offer No.");
//                             IF FreeItemOfferLine.FINDFIRST THEN
//                                 REPEAT
//                                     IF FreeItemOfferLine.Type IN [FreeItemOfferLine.Type::All] THEN BEGIN
//                                         PosLine.RESET;
//                                         PosLine.SETRANGE("Receipt No.", POSTransaction."Receipt No.");
//                                         PosLine.SETRANGE("Entry Type", PosLine."Entry Type"::Item);
//                                         PosLine.SETRANGE("Entry Status", PosLine."Entry Status"::" ");
//                                         IF PosLine.FINDFIRST THEN
//                                             REPEAT
//                                                 AllNA += PosLine."Net Amount";
//                                                 AllGA += PosLine.Amount;
//                                             UNTIL PosLine.NEXT = 0;
//                                     END;
//                                     IF FreeItemOfferLine.Type IN [FreeItemOfferLine.Type::Item] THEN BEGIN
//                                         PosLine.RESET;
//                                         PosLine.SETRANGE("Receipt No.", POSTransaction."Receipt No.");
//                                         PosLine.SETRANGE("Entry Type", PosLine."Entry Type"::Item);
//                                         PosLine.SETRANGE("Entry Status", PosLine."Entry Status"::" ");
//                                         PosLine.SETRANGE(Number, FreeItemOfferLine."No.");
//                                         IF PosLine.FINDFIRST THEN
//                                             REPEAT
//                                                 if PosLine."Line No." <> lVoidLineNo then begin
//                                                     ItemNA += PosLine."Net Amount";
//                                                     ItemGA += PosLine.Amount;
//                                                 end;
//                                             UNTIL PosLine.NEXT = 0;
//                                     END;
//                                 UNTIL FreeItemOfferLine.NEXT = 0;
//                         END;

//                         if not lVoidPressed then begin
//                             IF FreeItemOfferHeader."Offer Applicable of N/G" = FreeItemOfferHeader."Offer Applicable of N/G"::"Net Amount" THEN BEGIN
//                                 IF AllNA <> 0 THEN BEGIN
//                                     IF AllNA > FreeItemOfferHeader."Amount to Trigger" THEN
//                                         InsertFreeOfferItem(FreeItemOfferHeader."Offer No.", FreeItemOfferHeader."Validation Period ID",
//                                                             FreeItemOfferHeader."Offer Description", FALSE)
//                                 END ELSE BEGIN
//                                     IF ItemNA > FreeItemOfferHeader."Amount to Trigger" THEN
//                                         InsertFreeOfferItem(FreeItemOfferHeader."Offer No.", FreeItemOfferHeader."Validation Period ID",
//                                                             FreeItemOfferHeader."Offer Description", FALSE)
//                                 END;
//                             END ELSE BEGIN
//                                 IF AllGA <> 0 THEN BEGIN
//                                     IF AllGA > FreeItemOfferHeader."Amount to Trigger" THEN
//                                         InsertFreeOfferItem(FreeItemOfferHeader."Offer No.", FreeItemOfferHeader."Validation Period ID",
//                                                             FreeItemOfferHeader."Offer Description", FALSE)
//                                 END ELSE BEGIN
//                                     IF ItemGA > FreeItemOfferHeader."Amount to Trigger" THEN
//                                         InsertFreeOfferItem(FreeItemOfferHeader."Offer No.", FreeItemOfferHeader."Validation Period ID",
//                                                             FreeItemOfferHeader."Offer Description", FALSE)
//                                 END;
//                             END;
//                         End else begin
//                             IF FreeItemOfferHeader."Offer Applicable of N/G" = FreeItemOfferHeader."Offer Applicable of N/G"::"Net Amount" THEN BEGIN
//                                 IF AllNA <> 0 THEN BEGIN
//                                     IF AllNA < FreeItemOfferHeader."Amount to Trigger" THEN
//                                         InsertFreeOfferItem(FreeItemOfferHeader."Offer No.", FreeItemOfferHeader."Validation Period ID",
//                                                 FreeItemOfferHeader."Offer Description", TRUE);
//                                 END ELSE BEGIN
//                                     IF ItemNA < FreeItemOfferHeader."Amount to Trigger" THEN
//                                         InsertFreeOfferItem(FreeItemOfferHeader."Offer No.", FreeItemOfferHeader."Validation Period ID",
//                                                 FreeItemOfferHeader."Offer Description", TRUE);
//                                 END;
//                             END ELSE BEGIN
//                                 IF AllGA <> 0 THEN BEGIN
//                                     IF AllGA < FreeItemOfferHeader."Amount to Trigger" THEN
//                                         InsertFreeOfferItem(FreeItemOfferHeader."Offer No.", FreeItemOfferHeader."Validation Period ID",
//                                                             FreeItemOfferHeader."Offer Description", TRUE);

//                                 END ELSE BEGIN
//                                     IF ItemGA < FreeItemOfferHeader."Amount to Trigger" THEN
//                                         InsertFreeOfferItem(FreeItemOfferHeader."Offer No.", FreeItemOfferHeader."Validation Period ID",
//                                                 FreeItemOfferHeader."Offer Description", TRUE);
//                                 END;
//                             END;

//                         end;
//                     END;//
//             UNTIL FreeItemOfferHeader.NEXT = 0;
//         //FBTS YM

//     end;

//     [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Transaction Events", 'OnBeforeVoidLine', '', false, false)]
//     local procedure OnBeforeVoidLine(var POSTransaction: Record "LSC POS Transaction";
//     var POSTransLine: Record "LSC POS Trans. Line"; var Handled: Boolean; var HandledErrorText: Text;
//     var ReturnValue: Boolean);
//     begin
//         ApplyOffer(true, POSTransLine."Line No.", POSTransLine.Number);
//     end;

//     [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Transaction Events", 'OnBeforeTotalExecuted', '', false, false)]
//     local procedure OnBeforeTotalExecuted(var POSTransaction: Record "LSC POS Transaction"; var IsHandled: Boolean);
//     begin

//         ApplyOffer(false, 0, '');
//     end;

//     [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Post Utility", 'OnAfterInsertTransHeader', '', false, false)]
//     local procedure OnAfterInsertTransHeader(var Transaction: Record "LSC Transaction Header"; var POSTrans: Record "LSC POS Transaction");
//     begin
//         Transaction."Free Item Offer" := POSTrans."Free Item Offer";
//         Transaction."Free Offer Validation Period" := POSTrans."Free Offer Validation Period";
//     end;

//     [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Transaction Events", 'OnAfterTenderKeyPressed', '', false, false)]
//     local procedure "LSC POS Transaction Events_OnAfterTenderKeyPressed"(
//         var POSTransaction: Record "LSC POS Transaction";
//         var POSTransLine: Record "LSC POS Trans. Line";
//         var CurrInput: Text;
//         var TenderTypeCode: Code[10])
//     var
//         FreeItemOffer: Record "FreeItem Offer Header";
//         ValidationPeriod: Record "LSC Validation Period";
//         RetailPriceUtils: Codeunit "LSC Retail Price Utils";
//         OfferStorewiseDist: Record "Offer Store wise Dist.";
//         FreeItemOfferLine: Record "Free Item Offer Line";
//         PosLine: Record "LSC POS Trans. Line";
//         PosTrans: Codeunit "LSC POS Transaction";
//         TaxCalc: Codeunit "LSCIN Calculate Tax";
//         CUPosLine: Codeunit "LSC POS Trans. Lines";
//         OfferApplicable: Boolean;
//         l_OfferNo: Code[20];
//         l_OfferDesc: Text;
//         POSGUI: Codeunit "LSC POS GUI";
//         ZomatoGoldTxt: label 'Zomato Gold Ref. ID:';
//         payload: text;
//     begin
//         l_OfferNo := '';
//         l_OfferDesc := '';
//         // if POSTransaction.CustAppUserId <> '' then
//         //     if TenderTypeCode = '56' then
//         //         Error('Zomato Gold is not allowed for APP-SCAN Users');

//         FreeItemOffer.Reset();
//         FreeItemOffer.SetRange(Status, FreeItemOffer.Status::Enabled);
//         FreeItemOffer.SetRange(DiscountOffer, true);
//         FreeItemOffer.SetRange(CustomerNo, POSTransaction."Customer No.");
//         FreeItemOffer.SetRange("Tender Type", TenderTypeCode);
//         if FreeItemOffer.FindFirst() then
//             repeat
//                 if FreeItemOffer."Sales Type filter" = POSTransaction."Sales Type" then
//                     IF ValidationPeriod.GET(FreeItemOffer."Validation Period ID") THEN
//                         IF RetailPriceUtils.DiscValPerValid(ValidationPeriod.ID, TODAY, TIME) THEN BEGIN
//                             IF OfferStorewiseDist.GET(FreeItemOffer."Offer No.", POSTransaction."Store No.") THEN BEGIN//Get All Enable offer for particular Store
//                                 FreeItemOfferLine.RESET;
//                                 FreeItemOfferLine.SETRANGE("Offer No.", FreeItemOffer."Offer No.");
//                                 IF FreeItemOfferLine.FINDFIRST THEN
//                                     REPEAT
//                                         IF FreeItemOfferLine.Type IN [FreeItemOfferLine.Type::All] THEN BEGIN
//                                             PosTrans.TotDiscPrPressed(Format(FreeItemOffer."Discount %"), false);
//                                             //  TaxCalc.RecalculateTaxForAllLinesV2(POSTransaction, PosLine);
//                                             POSTransaction."Free Item Offer" := FreeItemOffer."Offer No.";
//                                             POSTransaction."Free Offer Validation Period" := FreeItemOffer."Validation Period ID";
//                                             POSTransaction.Modify();
//                                             POSTransaction.CalcFields("Gross Amount");
//                                             PosTrans.PosMessage('Zomato Gold Discount has been Applied:\ Discount Amt: ' + format(POSTransaction."Total Discount") + '\' +
//                                             'Payment Received: ' + Format(POSTransaction."Gross Amount"));
//                                             OfferApplicable := true;
//                                             l_OfferNo := FreeItemOffer."Offer No.";
//                                             l_OfferDesc := FreeItemOffer."Offer Description";
//                                         END;
//                                         IF FreeItemOfferLine.Type IN [FreeItemOfferLine.Type::Item] THEN BEGIN
//                                             l_OfferNo := FreeItemOffer."Offer No.";
//                                             l_OfferDesc := FreeItemOffer."Offer Description";
//                                             PosLine.RESET;
//                                             PosLine.SETRANGE("Receipt No.", POSTransaction."Receipt No.");
//                                             PosLine.SETRANGE("Entry Type", PosLine."Entry Type"::Item);
//                                             PosLine.SETRANGE("Entry Status", PosLine."Entry Status"::" ");
//                                             PosLine.SETRANGE(Number, FreeItemOfferLine."No.");
//                                             IF PosLine.FINDFIRST THEN
//                                                 REPEAT
//                                                     CUPosLine.SetCurrentLine(PosLine);
//                                                     // PosLine.CalcTotalDiscAmt(true, FreeItemOffer."Disocunt %", true);
//                                                     PosTrans.DiscPrPressedEx(FreeItemOffer."Discount %");
//                                                     TaxCalc.RecalculateTaxForAllLinesV2(POSTransaction, PosLine);
//                                                     POSTransaction."Free Item Offer" := FreeItemOffer."Offer No.";
//                                                     POSTransaction."Free Offer Validation Period" := FreeItemOffer."Validation Period ID";
//                                                     POSTransaction.Modify();
//                                                     POSTransaction.CalcFields("Gross Amount");
//                                                     PosTrans.PosMessage('Zomato Gold Discount has been Applied:\ Discount Amt: ' + format(POSTransaction."Total Discount") + '\' +
//                                                     'Payment Received: ' + Format(POSTransaction."Gross Amount"));
//                                                     OfferApplicable := true;
//                                                 UNTIL PosLine.NEXT = 0;

//                                         END;

//                                     until FreeItemOfferLine.next = 0;
//                             end;
//                         end;
//             until FreeItemOffer.next = 0;

//         if OfferApplicable then
//             InsertFreeText(POSTransaction, l_OfferNo, l_OfferDesc);
//     end;

//     local procedure InsertFreeText(POSTrans: Record "LSC POS Transaction"; OfferNo: Code[20]; OfferDesc: Text)
//     var
//         DealPOSTransLine: Record "LSC POS Trans. Line";
//         FromLineNo: Integer;

//     begin
//         DealPOSTransLine.SETRANGE("Receipt No.", POSTrans."Receipt No.");
//         IF NOT DealPOSTransLine.FINDLAST THEN
//             FromLineNo := 150
//         ELSE
//             FromLineNo := DealPOSTransLine."Line No." + 350;

//         DealPOSTransLine.reset;
//         DealPOSTransLine.SetRange("Receipt No.", POSTrans."Receipt No.");
//         DealPOSTransLine.SetRange("Entry Status", DealPOSTransLine."Entry Status"::" ");
//         DealPOSTransLine.SetRange("Entry Type", DealPOSTransLine."Entry Type"::FreeText);
//         DealPOSTransLine.SetRange("Free Offer Item", true);
//         if not DealPOSTransLine.FindFirst() then begin
//             DealPOSTransLine.INIT;
//             DealPOSTransLine."Receipt No." := POSTrans."Receipt No.";
//             DealPOSTransLine."Store No." := POSTrans."Store No.";
//             DealPOSTransLine."POS Terminal No." := POSTrans."POS Terminal No.";
//             DealPOSTransLine."Line No." := FromLineNo;
//             DealPOSTransLine."Entry Type" := DealPOSTransLine."Entry Type"::FreeText;
//             DealPOSTransLine."Text Type" := DealPOSTransLine."Text Type"::"Freetext Input";
//             DealPOSTransLine.Description := OfferDesc;
//             DealPOSTransLine."Sales Type" := POSTrans."Sales Type";
//             DealPOSTransLine."Free Offer Item" := TRUE;
//             DealPOSTransLine."Free Offer No." := OfferNo;
//             DealPOSTransLine.Quantity := 1;
//             DealPOSTransLine.INSERT;
//         end;
//     end;

// }

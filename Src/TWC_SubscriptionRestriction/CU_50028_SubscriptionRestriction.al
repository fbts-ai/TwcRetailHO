codeunit 50028 "Subscription Restriction"
{

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Transaction Events", 'OnInitInsertItemLine', '', false, false)]
    procedure OnInitInsertItemLine(PosTrans: Record "LSC POS Transaction"; PosTransLine: Record "LSC POS Trans. Line"; Customer: Record Customer; var IsHandled: Boolean);
    var
        count: Integer;
        posline: Record "LSC POS Trans. Line";
        posline1: Record "LSC POS Trans. Line";
        POSTransactionLine: Record "LSC POS Trans. Line";
    begin

        posline.Reset();
        posline.SetRange("Receipt No.", POSTransLine."Receipt No.");
        posline.SetRange("Line No.", POSTransLine."Line No.");
        IF posline.FindFirst() then;
        IF PosTrans.IsSubscriptionTransaction then begin

            posline."Subscription ID" := PosTrans."Subscription ID";
            posline."Subscription Qty" := PosTrans."Subscription Qty";
            posline."User Plan Id" := PosTrans."User Plan Id";
        end;

        posline1.Reset();
        posline1.SetRange("Receipt No.", POSTransLine."Receipt No.");
        posline1.SetRange("User Plan Id", posline."User Plan Id");
        posline1.SetFilter("Entry Status", '0');
        //posline1.SetRange("Line No.", POSTransLine."Line No.");
        IF posline1.FindSet() then begin
            count := 1;
            repeat
                if (posline."User Plan Id" <> '') then begin
                    count += 1;
                    if (count > posline."Subscription Qty") then begin
                        isHandled := true;
                        Message('Cannot add more items as you have added maximum amount of subscription items');
                    end
                    else begin

                    end;
                end;
            until posline1.Next = 0;
        end;

    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Transaction Events", 'OnBeforeRunCommand', '', false, false)]
    procedure OnBeforeRunCommand(var POSTransaction: Record "LSC POS Transaction"; var POSTransLine: Record "LSC POS Trans. Line"; var CurrInput: Text; var POSMenuLine: Record "LSC POS Menu Line"; var isHandled: Boolean; TenderType: Record "LSC Tender Type"; var CusomterOrCardNo: Code[20])
    var
        POSTransactions: Record "LSC POS Trans. Line";
        count: Integer;
        POSTransactionLine: Record "LSC POS Trans. Line";

    begin
        if ((POSMenuLine.Command = 'TOTDISCAM') or (POSMenuLine.Command = 'TOTDISCPR'))
        or (POSMenuLine.Command = 'DISCPR') or (POSMenuLine.Command = 'DISCAM')
         then begin
            if (IsASubscriptionTransaction(POSTransaction."Receipt No.") or ISACouponTransaction(POSTransaction."Receipt No.")
             or ISAWaveCoinTransaction(POSTransaction."Receipt No.") or IsAOfferTransaction(POSTransaction."Receipt No.")) or ISAPromoDiscountTransaction(POSTransaction."Receipt No.")
             then begin
                Error('Discounts cannot be applied on this transaction');
            end;
        end;

        if (POSMenuLine.Parameter = 'APPLYDISC') then begin
            if (IsASubscriptionTransaction(POSTransaction."Receipt No.") or ISACouponTransaction(POSTransaction."Receipt No.")
              or ISAWaveCoinTransaction(POSTransaction."Receipt No.")) or IsAOfferTransaction(POSTransaction."Receipt No.") or ISAPromoDiscountTransaction(POSTransaction."Receipt No.")
                  then begin
                Error('Offers cannot be applied on this transaction');
            end;
        end;

        if (POSMenuLine.Description = 'Wave Coin') then begin
            if (IsASubscriptionTransaction(POSTransaction."Receipt No.") or IsAOfferTransaction(POSTransaction."Receipt No.")
             or ISACouponTransaction(POSTransaction."Receipt No.")) or ISAPromoDiscountTransaction(POSTransaction."Receipt No.") then begin
                Error('Wave Coin cannot be applied on this transaction');
            end;
        end;

        if (POSMenuLine.Description = 'Promo Discount') then begin
            if (IsASubscriptionTransaction(POSTransaction."Receipt No.") or IsAOfferTransaction(POSTransaction."Receipt No.")
             or ISACouponTransaction(POSTransaction."Receipt No.")) then begin
                Error('Promo Discount cannot be applied on this transaction');
            end;
        end;



        if (POSMenuLine.Command = 'COUPON') then begin
            if (IsASubscriptionTransaction(POSTransaction."Receipt No.") or IsAOfferTransaction(POSTransaction."Receipt No.")
            or ISAWaveCoinTransaction(POSTransaction."Receipt No.") or ISAPromoDiscountTransaction(POSTransaction."Receipt No.")) then begin
                Error('Coupon cannot be applied on this transaction');
            end;
        end;

    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Transaction Events", 'OnAfterTotalExecuted', '', false, false)]
    procedure OnAfterTotalExecuted(var POSTransaction: Record "LSC POS Transaction")
    var
        POSTransactionLine: Record "LSC POS Trans. Line";
        POSTransactionLine1: Record "LSC POS Trans. Line";
        totalTWCAPPAmount: Decimal;
        lineNo: Integer;
        paymentLine: Record "LSC POS Trans. Line";
        twcConfiguration: Record "TWC Configuration";
        subscriptionTenderName: Text[100];
        subscriptionTenderID: Text[100];
        pos: Codeunit "LSC POS Transaction";
    begin

        if IsASubscriptionTransaction(POSTransaction."Receipt No.") then begin
            twcConfiguration.SetFilter(twcConfiguration.Key_, 'Subscription Tender');
            twcConfiguration.Init();
            if twcConfiguration.FindFirst() then begin
                subscriptionTenderName := twcConfiguration.Name;
                subscriptionTenderID := twcConfiguration.Value_;
            end;

            POSTransactionLine.Reset();
            POSTransactionLine.Init();
            POSTransactionLine.SetFilter(POSTransactionLine."Indent No.", '0');
            POSTransactionLine.SetFilter(POSTransactionLine."Entry Status", '0');
            POSTransactionLine.SetFilter(POSTransactionLine."Entry Type", '0');
            POSTransactionLine.SetFilter(POSTransactionLine."Receipt No.", POSTransaction."Receipt No.");
            if POSTransactionLine.FindSet() then begin
                repeat
                    if not (POSTransactionLine."User Plan Id" = '') then begin
                        totalTWCAPPAmount += POSTransactionLine."Net Price";
                    end;
                until POSTransactionLine.Next = 0;
            end;

            POSTransactionLine1.Reset();
            POSTransactionLine1.Init();
            POSTransactionLine1.SetFilter("Entry Status", '0');
            POSTransactionLine1.SetFilter("Entry Type", '1');
            POSTransactionLine1.SetFilter("Receipt No.", POSTransaction."Receipt No.");
            POSTransactionLine1.SetFilter(Number, subscriptionTenderID);
            if POSTransactionLine1.FindFirst() then begin
                POSTransactionLine1.Delete();
                Commit();
            end;

            //pos.TotalPressed(true);
            pos.TenderKeyPressedEx(subscriptionTenderID, Format(totalTWCAPPAmount));
        end;
    end;

    //AlleRSN 121223 start
    /*[EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Transaction Events", 'OnAfterProcessInfoCode', '', false, false)]
    local procedure OnAfterProcessInfoCode(var Infocode: Record "LSC Infocode"; var POSTransaction: Record "LSC POS Transaction")
    begin
        IF Infocode.Code = 'MANDISC' THEN begin
            IF (POSTransaction."Sales Type" = 'POS') AND (POSTransaction.CustAppUserId <> '') then
                Error('For App Scan Order You Can not Apply Mannual Discount');
        end;
    end;
    //AlleRSN 121223 end
    */
    procedure IsASubscriptionTransaction(receiptNumber: Text) subscriptionTransaction: Boolean
    var
        POSTransactionLine: Record "LSC POS Trans. Line";
    //text1 : Text;

    begin
        POSTransactionLine.Init();
        POSTransactionLine.SetFilter(POSTransactionLine."Indent No.", '0');
        POSTransactionLine.SetFilter(POSTransactionLine."Entry Status", '0');
        POSTransactionLine.SetFilter(POSTransactionLine."Receipt No.", receiptNumber);
        POSTransactionLine.SetFilter(POSTransactionLine."User Plan Id", '<>%1', '');

        if POSTransactionLine.FindLast() then begin
            subscriptionTransaction := true;
        end;

    end;

    procedure IsAOfferTransaction(receiptNumber: Text) offerTransaction: Boolean
    var
        POSTransactionLine: Record "LSC POS Trans. Line";
    begin
        POSTransactionLine.Init();
        POSTransactionLine.SetFilter(POSTransactionLine."Indent No.", '0');
        POSTransactionLine.SetFilter(POSTransactionLine."Entry Status", '0');
        POSTransactionLine.SetFilter(POSTransactionLine."Receipt No.", receiptNumber);
        POSTransactionLine.SetFilter(POSTransactionLine."Offer ID", '<>%1', '');

        if POSTransactionLine.FindLast() then begin
            offerTransaction := true;
        end;

    end;

    procedure ISAWaveCoinTransaction(receiptNumber: Text) wavecoinTransaction: Boolean
    var
        POSTransactionLine: Record "LSC POS Trans. Line";
    begin
        POSTransactionLine.Init();
        POSTransactionLine.SetFilter(POSTransactionLine."Indent No.", '0');
        POSTransactionLine.SetFilter(POSTransactionLine."Entry Status", '0');
        POSTransactionLine.SetFilter(POSTransactionLine."Receipt No.", receiptNumber);
        POSTransactionLine.SetFilter(POSTransactionLine.WaveCoinApplied, '1');

        if POSTransactionLine.FindLast() then begin
            wavecoinTransaction := true;
        end;
    end;

    procedure ISACouponTransaction(receiptNumber: Text) couponCodeTransaction: Boolean
    var
        POSTransactionLine: Record "LSC POS Trans. Line";
    begin
        POSTransactionLine.Init();
        POSTransactionLine.SetFilter(POSTransactionLine."Indent No.", '0');
        POSTransactionLine.SetFilter(POSTransactionLine."Entry Status", '0');
        POSTransactionLine.SetFilter(POSTransactionLine."Receipt No.", receiptNumber);
        POSTransactionLine.SetFilter(POSTransactionLine."Coupon Code", '<>%1', '');

        if POSTransactionLine.FindLast() then begin
            couponCodeTransaction := true;
        end;
    end;

    procedure ISAPromoDiscountTransaction(receiptNumber: Text) PromoDiscountTransaction: Boolean
    var
        POSTransactionLine: Record "LSC POS Trans. Line";
    begin
        POSTransactionLine.Init();
        // POSTransactionLine.SetFilter(POSTransactionLine."Indent No.", '0');
        POSTransactionLine.SetFilter(POSTransactionLine."Entry Status", '0');
        POSTransactionLine.SetFilter(POSTransactionLine."Receipt No.", receiptNumber);
        POSTransactionLine.SetRange("Entry Status", POSTransactionLine."Entry Status"::" ");
        POSTransactionLine.SetFilter(POSTransactionLine.PromoTxnId, '<>%1', '');

        if POSTransactionLine.FindLast() then begin
            PromoDiscountTransaction := true;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Price Utility", 'OnAfterCalcTransDiscPercent', '', true, true)]
    local procedure OnAfterCalcTransDiscPercent(var POSTransLine: Record "LSC POS Trans. Line")
    var
        POSTransaction: Record "LSC POS Transaction";
        UpLineRec: Record "UP Line";  //AlleRSN 231023
        UpHeadRec: Record "UP Header"; //AlleRSN 231023
        ItemrecLoc: Record Item;  //AlleRSN 091123
        ICatRec: Record "Item Category";  //AlleRSN 091123
    begin

        if (POSTransLine."Indent No." = 0) and not (POSTransLine."User Plan Id" = '') then begin
            POSTransLine."Discount Amount" := 0;
            POSTransLine."Discount %" := 0;
            POSTransLine."Line Disc. %" := 0;
            POSTransLine."Total Disc. %" := 0;
            POSTransLine."Total Disc. Amount" := 0;
            POSTransLine."Coupon Discount %" := 0;
            POSTransLine."Coupon Discount Amount" := 0;
        end;

        //AlleRSN 231023 start
        UpHeadRec.Reset();
        UpHeadRec.SetRange(receiptNo, POSTransLine."Receipt No.");
        IF UpHeadRec.FindFirst() THEN begin
            UpLineRec.Reset();
            UpLineRec.SetRange(order_id, UpHeadRec.order_details_id);
            UpLineRec.SetRange(order_items_merchant_id, POSTransLine.Number); //AlleRSN 141123
            UpLineRec.SetFilter(UpLineRec.order_items_price, '<>%1', 0);  //AlleRSN 141123
            //UpLineRec.SetRange(line_no, POSTransLine."Line No.");
            IF UpLineRec.FindLast() then begin
                //if POSTransLine."Parent BOM Line No" <> 0 THEN begin //AlleRSN 091123
                //AlleRSN 091123 start
                IF ItemrecLoc.Get(POSTransLine.Number) then begin
                    IF ICatRec.Get(ItemrecLoc."Item Category Code") then begin
                        if not ICatRec."Packaging Bom" then begin
                            //AlleRSN 091123 end
                            //IF (UpLineRec.order_items_price * UpLineRec.order_items_quantity) - (UpLineRec.order_items_discount * UpLineRec.order_items_quantity) = 0 THEN begin
                            IF (UpLineRec.order_items_price * UpLineRec.order_items_quantity) - (UpLineRec.order_items_discount) = 0 THEN begin
                                POSTransLine."Discount %" := 100;
                                POSTransLine."Discount Amount" := UpLineRec.order_items_discount;
                            end else
                                if UpLineRec.order_items_discount <> 0 then begin
                                    //if POSTransLine."Parent BOM Line No" <> 0 THEN begin
                                    //POSTransLine."Discount Amount" := UpLineRec.order_items_discount * UpLineRec.order_items_quantity;
                                    POSTransLine."Discount Amount" := UpLineRec.order_items_discount;
                                    //POSTransLine."Discount %" := (UpLineRec.order_items_discount * 100) / (UpLineRec.order_items_price + UpHeadRec.order_details_total_taxes);  //AlleRSN 071123                                                                                                                                                                    
                                    POSTransLine."Discount %" := ((UpLineRec.order_items_discount / UpLineRec.order_items_quantity) * 100) / (UpLineRec.order_items_price + UpHeadRec.order_details_total_taxes);  //AlleRSN 221123
                                end;
                        end; //AlleRSN 091123
                    end; //AlleRSN 091123
                end; //AlleRSN 091123

            end;
        end;

        //AlleRSN 231023 end
        //AlleRSN 141123 uncomment
    end;


    //AlleRSN 071123 start
    [EventSubscriber(ObjectType::Table, Database::"LSC POS Trans. Line", 'OnAfterCalcPrices', '', false, false)]
    local procedure OnAfterCalcPrices(var Rec: Record "LSC POS Trans. Line")
    var
        POSTransaction: Record "LSC POS Transaction";
        UpLineRec: Record "UP Line";
        UpHeadRec: Record "UP Header";
        ItemrecLoc: Record Item;
        ICatRec: Record "Item Category";
    begin

        UpHeadRec.Reset();
        UpHeadRec.SetRange(receiptNo, Rec."Receipt No.");
        IF UpHeadRec.FindFirst() THEN begin
            UpLineRec.Reset();
            UpLineRec.SetRange(order_id, UpHeadRec.order_details_id);
            UpLineRec.SetRange(order_items_merchant_id, Rec.Number); //AlleRSN 141123
            UpLineRec.SetFilter(UpLineRec.order_items_price, '<>%1', 0);  //AlleRSN 141123
            //UpLineRec.SetRange(line_no, POSTransLine."Line No.");
            IF UpLineRec.FindLast() then begin
                //if Rec."Parent BOM Line No" <> 0 THEN begin //AlleRSN 091123
                //IF Rec."Item Category Code" = 'PACKAGING' then
                //AlleRSN 091123 start
                IF ItemrecLoc.Get(Rec.Number) then begin
                    IF ICatRec.Get(ItemrecLoc."Item Category Code") then begin
                        if not ICatRec."Packaging Bom" then begin
                            //AlleRSN 091123 end
                            //IF (UpLineRec.order_items_price * UpLineRec.order_items_quantity) - (UpLineRec.order_items_discount * UpLineRec.order_items_quantity) = 0 THEN begin
                            IF (UpLineRec.order_items_price * UpLineRec.order_items_quantity) - (UpLineRec.order_items_discount) = 0 THEN begin
                                Rec."Discount %" := 100;
                                Rec."Discount Amount" := UpLineRec.order_items_discount;
                            end else
                                if UpLineRec.order_items_discount <> 0 then begin
                                    //Rec."Discount Amount" := UpLineRec.order_items_discount * UpLineRec.order_items_quantity;
                                    //Rec."Discount %" := (UpLineRec.order_items_discount * 100) / (UpLineRec.order_items_price + UpHeadRec.order_details_total_taxes);  //AlleRSN 071123
                                    Rec."Discount Amount" := UpLineRec.order_items_discount;
                                    //POSTransLine."Discount %" := (UpLineRec.order_items_discount * 100) / (UpLineRec.order_items_price + UpHeadRec.order_details_total_taxes);  //AlleRSN 071123                                                                                                                                                                    
                                    Rec."Discount %" := ((UpLineRec.order_items_discount / UpLineRec.order_items_quantity) * 100) / (UpLineRec.order_items_price + UpHeadRec.order_details_total_taxes);  //AlleRSN 221123
                                    Rec."Net Amount" := (UpLineRec.order_items_price * UpLineRec.order_items_quantity) - UpLineRec.order_items_discount;
                                    Rec.Amount := ((UpLineRec.order_items_price * UpLineRec.order_items_quantity) - UpLineRec.order_items_discount) +
                                                    ((UpLineRec.order_items_sgst_value + UpLineRec.order_items_cgst_value)); //AlleRSN 221123 //* UpLineRec.order_items_quantity);
                                end;
                        end; //AlleRSN 091123
                    end; //AlleRSN 091123
                end; //AlleRSN 091123
            end;
        end;

    end;
    //AlleRSN 071123 end
    //AlleRSN 141123 uncomment

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Price Utility", 'OnAfterCalcPeriodicDisc', '', true, true)]
    local procedure OnAfterCalcPeriodicDisc(var POSTransLine: Record "LSC POS Trans. Line")

    var
        POSTransaction: Record "LSC POS Transaction";
    begin

        if (POSTransLine."Indent No." = 0) and not (POSTransLine."User Plan Id" = '') then begin
            POSTransLine."Discount %" := 0;
            POSTransLine."Discount Amount" := 0;
            POSTransLine."Periodic Disc. %" := 0;
        end;
    end;
}
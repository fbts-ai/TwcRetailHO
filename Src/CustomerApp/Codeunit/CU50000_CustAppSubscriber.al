codeunit 50000 "Cust App Subscribers"
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Transaction Events", 'OnBeforeRunCommand', '', false, false)]
    local procedure OnBeforeRunCommand(var POSMenuLine: Record "LSC POS Menu Line"; var POSTransaction: Record "LSC POS Transaction"; var POSTransLine: Record "LSC POS Trans. Line"; var CurrInput: Text)
    var
        subs: Code[30];
        posTransLine2: Record "LSC POS Trans. Line";
        lscposmenuline1: Record "LSC POS Menu Line";
        Custappoffers: Record Cust_App_Offers; //AJ_ Alle 30102023
    begin

        //If POSMenuLine."Menu ID" = '#SUBS' then begin
        Clear(POSTransaction.IsSubscriptionTransaction);
        IF POSMenuLine.IsSubscription then begin
            POSTransaction."Subscription ID" := POSMenuLine."Subscription ID";
            POSTransaction."Subscription Qty" := POSMenuLine."Subscription Qty";
            POSTransaction."User Plan Id" := POSMenuLine."User Plan Id";
            POSTransaction.IsSubscriptionTransaction := POSMenuLine.IsSubscription;
            POSTransaction.Modify();

        end;


        lscposmenuline1.Reset();
        lscposmenuline1.SetRange("Menu ID", '#APPCUSTOMER');
        IF LSCPOSMenuLine1.FindFirst() then;

        //AJ_Alle_30102023+
        IF (POSTransaction."Receipt No." <> '') AND (POSTransaction."Sales Type" = 'POS') THEN begin //AlleRSN 091123 //AlleRSN 281123
            Custappoffers.Reset();
            Custappoffers.SetRange("Receipt No", POSTransaction."Receipt No.");
            Custappoffers.SetFilter("Token ID", '<>%1', '');//ALLENICK_171123
            if Custappoffers.FindFirst() then begin
                IF POSTransaction.CustAppUserId = '' THEN begin
                    POSTransaction.CustAppUserId := Custappoffers.UserId;
                    POSTransaction."Wallet Balance" := Custappoffers."Wallet Balance"; //AlleRSN 311023
                    POSTransaction."Wave Coin Balance" := Custappoffers."Wave Coin Balance";  //AlleRSN 311023
                                                                                              //Message(Format(Custappoffers.UserId));
                    POSTransaction.Modify();
                end;
            end;
        end; //AlleRSN 091123
        //AJ_Alle_30102023-

        IF LSCPOSMenuLine1.CustAppUserId <> '' then begin
            if (POSTransaction."Receipt No." <> '') AND (POSTransaction."Sales Type" = 'POS') then begin  //Allersn 281123
                //POSTransaction.CustAppUserId := lscposmenuline1.CustAppUserId; //AlleRSN 301023 commented 
                IF POSTransaction.CustAppUserId <> '' THEN  //AlleRSN 301123
                    POSTransaction.CustAppUserId := POSTransaction.CustAppUserId; //AlleRSN 301023
                //Message('%1 is cust id & %2 is recppt no ', POSTransaction.CustAppUserId, POSTransaction."Receipt No.");//TO be remove
                //POSTransaction."Wallet Balance" := lscposmenuline1."Wallet Balance"; //AlleRSN 311023 commented
                // POSTransaction."Wave Coin Balance" := POSMenuLine."Wave Coin Balance";
                POSTransaction."Promo Balance" := lscposmenuline1."Promo Balance";
                POSTransaction.Modify();
            end;
        end;
        //AlleRSN 110124 start 
        if (POSTransaction."Receipt No." <> '') AND (POSTransaction."Sales Type" = 'POS') then begin
            IF (POSTransaction.CustAppUserId <> '') AND (POSMenuLine.Command = 'SELECTCUST') AND (POSMenuLine.Parameter = 'C00080') THEN
                Error('Not Allowed to select Zomato Gold Customer for App Scan user');
        end;
        IF (POSTransaction."Receipt No." <> '') Then begin
            IF (POSTransaction."Sales Type" = 'TAKEAWAY') OR (POSTransaction."Sales Type" = 'PRE-ORDER') then begin
                if (POSMenuLine.Command = 'SELECTCUST') AND (POSMenuLine.Parameter = 'C00080') then
                    Error('Not Allowed to select Zomato Gold Customer for online customer');
            end;
        end;

        //AlleRSN 110124 end
        //AlleRSN 190124 start
        IF POSMenuLine.Command = 'KITCHEN_SENDTOKDS' THEN begin
            IF (POSTransaction."Sales Type" = 'POS') THen
                Error('Not Allowed to Print KOT on In-Store Transaction');
        end;
        //AlleRSN 190124 end
    end;



    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Transaction Events", 'OnBeforeInsertItemLine', '', false, false)]
    local procedure OnBeforeInsertItemLine(var CurrInput: Text; var POSTransaction: Record "LSC POS Transaction")
    var
        Item: Record Item;
        foodlock: Record FoodLock;
        Transline: Record "LSC POS Trans. Line";
        lscposmenuline1: Record "LSC POS Menu Line";
    begin
        Transline.Reset();
        Transline.SetRange("Receipt No.", POSTransaction."Receipt No.");
        Transline.SetRange("Entry Status", Transline."Entry Status"::" ");
        Transline.SetRange(Number, Format(1));
        IF Transline.FindFirst() then begin
            IF CurrInput <> Format(1) then
                Error('Normal Items cannot be added with wallet load');
        end;

        Transline.Reset();
        Transline.SetRange("Receipt No.", POSTransaction."Receipt No.");
        Transline.SetRange("Entry Status", Transline."Entry Status"::" ");
        Transline.SetFilter(Number, '<>%1', '1');
        IF Transline.FindFirst() then begin
            IF CurrInput = Format(1) then
                Error('Load wallet cannot be added with normal items');
        end;



    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Transaction Events", 'OnAfterItemLine', '', false, false)]
    local procedure OnAfterItemLine(var POSTransLine: Record "LSC POS Trans. Line"; var POSTransaction: Record "LSC POS Transaction"; var CurrInput: Text)
    var
        subs: Code[30];
        item: Record Item;
        lscposmenuline1: Record "LSC POS Menu Line";
        transline: Record "LSC POS Trans. Line";
        Custappoffers: Record Cust_App_Offers; //AJ_Alle_30102023

    //pos: Codeunit lsc pos
    begin
        Transline.Reset();
        Transline.SetRange("Receipt No.", POSTransaction."Receipt No.");
        Transline.SetRange("Entry Status", Transline."Entry Status"::" ");
        Transline.SetRange(Number, Format(1));
        IF Transline.FindFirst() then begin
            IF CurrInput <> Format(1) then
                Error('Normal Items cannot be added with wallet load');
        end;

        Transline.Reset();
        Transline.SetRange("Receipt No.", POSTransaction."Receipt No.");
        Transline.SetRange("Entry Status", Transline."Entry Status"::" ");
        IF Transline.FindFirst() then begin
            IF CurrInput = Format(1) then
                Error('Load wallet cannot be added with normal items');
        end;


        IF item.Get(POSTransLine.Number) then;



        lscposmenuline1.Reset();
        lscposmenuline1.SetRange("Menu ID", '#APPCUSTOMER');
        IF LSCPOSMenuLine1.FindFirst() then;


        POSTransLine."Cust App Order" := lscposmenuline1."Cust App Order";
        //POSTransLine."Wallet Balance" := lscposmenuline1."Wallet Balance"; //AlleRSN 311023 commented
        IF POSTransaction."Cust App Order" = false then begin
            POSTransaction."Promo Balance" := lscposmenuline1."Promo Balance";
            //POSTransaction."Wave Coin Balance" := lscposmenuline1."Wave Coin Balance";  //AlleRSN 311023 commented
            //POSTransaction.CustAppUserId := lscposmenuline1.CustAppUserId;  //AlleRSN 301023
            IF POSTransaction.CustAppUserId <> '' THEN  //AlleRSN 301123
                POSTransaction.CustAppUserId := POSTransaction.CustAppUserId; //AlleRSN 301023
            POSTransaction.Modify();
        end;
        // //AJ_Alle_30102023+
        // Custappoffers.Reset();
        // Custappoffers.SetRange("Receipt No", POSTransaction."Receipt No.");
        // if Custappoffers.FindFirst() then begin
        //     POSTransaction.CustAppUserId := Custappoffers.UserId;
        //     POSTransaction.Modify();
        // end;
        // //AJ_Alle_30102023-
        IF POSTransLine.CustAppUserId = '' then begin
            IF POSTransaction.CustAppUserId <> '' THEN  //AlleRSN 301123
                POSTransLine.CustAppUserId := POSTransaction.CustAppUserId;
            POSTransLine."Wallet Balance" := POSTransaction."Wallet Balance"; //AlleRSN 311023 
            POSTransLine."Wave Coin Balance" := POSTransaction."Wave Coin Balance"; //AlleRSN 011123
        end;


    end;
    //AlleRSN 240124 start
    // [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Transaction Events", 'OnBeforeCheckInfoCodeV2', '', false, false)]
    // local procedure OnBeforeCheckInfoCodeV2(var POSTransaction: Record "LSC POS Transaction"; var Infocode: Record "LSC Infocode"; Module: Code[10]; var IsHandled: Boolean; var ReturnValue: Boolean)
    // begin

    //     CASE
    //     Module of
    //         'WCDISC':
    //             IF POSTransaction."Cart Offer ID" <> '' then
    //                 IsHandled := true;
    //     //ReturnValue:=False;
    //     END;
    // end;

    //AlleRSN 240124 end
    //AlleRSN 091223 start
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Transaction Events", 'OnBeforeLogoff', '', false, false)]
    local procedure OnBeforeLogoff(var POSTransaction: Record "LSC POS Transaction")
    var
        Custappoffers: Record Cust_App_Offers;
    begin
        Custappoffers.Reset();
        Custappoffers.SetRange("Receipt No", POSTransaction."Receipt No.");
        if Custappoffers.FindSet() then
            Custappoffers.DeleteAll();
    end;
    //AlleRSN 091223 end

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSCIN POS Refund Mgt", 'LSCINOnProcessRefundSelection', '', false, false)]
    local procedure LSCINOnProcessRefundSelection(OriginalTransaction: Record "LSC Transaction Header"; var POSTransaction: Record "LSC POS Transaction")

    begin

        POSTransaction."Subscription ID" := OriginalTransaction."Subscription ID";
        POSTransaction."Offer ID" := OriginalTransaction."Offer ID";
        POSTransaction."Subscription Qty" := OriginalTransaction."Subscription Qty";
        POSTransaction.IsSubscriptionTransaction := OriginalTransaction.IsSubscriptionTransaction;
        POSTransaction."User Plan Id" := OriginalTransaction."User Plan Id";
        POSTransaction."Cust App Order" := OriginalTransaction."Cust App Order";
        POSTransaction.CustAppUserId := OriginalTransaction.CustAppUserId;
        POSTransaction."Review Cart done" := OriginalTransaction."Review Cart done";
        POSTransaction."Check out done" := OriginalTransaction."Check out done";
        POSTransaction."Cart Offer ID" := OriginalTransaction."Cart Offer ID";
        POSTransaction."Wave Coin Balance" := OriginalTransaction."Wave Coin Balance";
        POSTransaction."Wallet Balance" := OriginalTransaction."Wallet Balance";
        POSTransaction."Promo Balance" := OriginalTransaction."Promo Balance";
        POSTransaction.WaveCoinApplied := OriginalTransaction.WaveCoinApplied;

    end;



    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Transaction Events", 'OnAfterRunCommand', '', false, false)]
    local procedure OnAfterRunCommand(var POSMenuLine: Record "LSC POS Menu Line"; var Command: Code[20]; var POSTransaction: Record "LSC POS Transaction"; var POSTransLine: Record "LSC POS Trans. Line"; var CurrInput: Text)
    var
        postrnsline: Record "LSC POS Trans. Line";
        lscposmenuline1: Record "LSC POS Menu Line";
        hardwareProfile: Record "LSC POS Hardware Profile";
    begin

        hardwareProfile.SetRange("Profile ID", '##DEFAULT');
        IF hardwareProfile.FindFirst() then begin
            hardwareProfile."Tone1 Duration" := 0;
            hardwareProfile.Validate("Tone1 Duration");
            hardwareProfile."Tone1 Pitch" := 0;
            hardwareProfile.Validate("Tone1 Pitch");
            hardwareProfile."Tone1 Volume" := 0;
            hardwareProfile.Validate("Tone1 Volume");
            hardwareProfile.Modify(true);
            Commit();
        end;


        Clear(POSTransaction.IsSubscriptionTransaction);
        IF POSTransaction.IsSubscriptionTransaction then begin
            POSTransaction."Subscription ID" := POSMenuLine."Subscription ID";
            POSTransaction."Subscription Qty" := POSMenuLine."Subscription Qty";
            POSTransaction."User Plan Id" := POSMenuLine."User Plan Id";
            POSTransaction.IsSubscriptionTransaction := POSMenuLine.IsSubscription;


        end;



        lscposmenuline1.Reset();
        lscposmenuline1.SetRange("Menu ID", '#APPCUSTOMER');
        IF LSCPOSMenuLine1.FindFirst() then;

        IF LSCPOSMenuLine1.CustAppUserId <> '' then begin
            if (POSTransaction."Receipt No." <> '') AND (POSTransaction."Sales Type" = 'POS') then begin //AlleRSN 281123
                // POSTransaction.CustAppUserId := lscposmenuline1.CustAppUserId;  //AlleRSN 301023 commented
                IF POSTransaction.CustAppUserId <> '' THEN  //AlleRSN 301123
                    POSTransaction.CustAppUserId := POSTransaction.CustAppUserId; //AlleRSN 301023
                //POSTransaction."Wallet Balance" := lscposmenuline1."Wallet Balance";  //AlleRSN 311023 commented
                // POSTransaction."Wave Coin Balance" := POSMenuLine."Wave Coin Balance";
                POSTransaction."Promo Balance" := lscposmenuline1."Promo Balance";
                POSTransaction.Modify();
            end;
        end;

    end;

    // end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Post Utility", 'SalesEntryOnBeforeInsertV2', '', false, false)]
    local procedure SalesEntryOnBeforeInsert(var pPOSTransLineTemp: Record "LSC POS Trans. Line" temporary; var pTransSalesEntry: Record "LSC Trans. Sales Entry")
    begin
        pTransSalesEntry."User Plan Id" := pPOSTransLineTemp."User Plan Id";
        pTransSalesEntry."Subscription ID" := pPOSTransLineTemp."Subscription ID";
        pTransSalesEntry."Offer ID" := pPOSTransLineTemp."Offer ID";
        pTransSalesEntry."Subscription Qty" := pPOSTransLineTemp."Subscription Qty";
        pTransSalesEntry."Cust App Order" := pPOSTransLineTemp."Cust App Order";
        pTransSalesEntry.CustAppUserId := pPOSTransLineTemp.CustAppUserId;
        pTransSalesEntry."Cart Offer ID" := pPOSTransLineTemp."Cart Offer ID";
        pTransSalesEntry."Wallet Balance" := pPOSTransLineTemp."Wallet Balance";
        pTransSalesEntry."Promo Balance" := pPOSTransLineTemp."Promo Balance";
        pTransSalesEntry."Wave Coin Balance" := pPOSTransLineTemp."Wave Coin Balance";
        pTransSalesEntry.txnId := pPOSTransLineTemp.txnId;
        pTransSalesEntry.PromoTxnId := pPOSTransLineTemp.PromoTxnId;
        pTransSalesEntry.batchNumber := pPOSTransLineTemp.batchNumber;
        pTransSalesEntry.redemptionValue := pPOSTransLineTemp.redemptionValue;


    end;



    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Post Utility", 'OnAfterInsertTransHeader', '', false, false)]
    local procedure OnAfterInsertTransHeader(var POSTrans: Record "LSC POS Transaction"; var Transaction: Record "LSC Transaction Header")
    var
        UpHeadRec: Record "UP Header"; //AlleRSN 201223    
    begin
        Transaction."Cust App Order" := POSTrans."Cust App Order";
        Transaction."Offer ID" := POSTrans."Offer ID";
        Transaction.CustAppUserId := POSTrans.CustAppUserId;
        Transaction."Review Cart done" := POSTrans."Review Cart done";
        Transaction."Check out done" := POSTrans."Check out done";
        Transaction."Cart Offer ID" := POSTrans."Cart Offer ID";
        Transaction."Wallet Balance" := POSTrans."Wallet Balance";
        Transaction."Wave Coin Balance" := POSTrans."Wave Coin Balance";
        Transaction."Promo Balance" := POSTrans."Promo Balance";
        Transaction.WaveCoinApplied := POSTrans.WaveCoinApplied;
        Transaction.txnId := POSTrans.txnId;
        Transaction.batchNumber := POSTrans.batchNumber;
        Transaction.redemptionValue := POSTrans.redemptionValue;
        Transaction.PromoTxnId := POSTrans.PromoTxnId;
        Transaction."Tax Area Code" := POSTrans."App Discount ID"; //AlleRSN 131223
        Transaction."Tax Exemption No." := POSTrans."App Discount Code"; //AlleRSN 131223


        IF UpHeadRec.Get(POSTrans.OrderId) then begin
            UpHeadRec.StoreNo := Transaction."Store No.";
            UpHeadRec.PosTerminalNo := Transaction."POS Terminal No.";
            UpHeadRec.Modify();
        end;
    end;


    //AlleRSN 201223 start

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Post Utility", 'OnAfterPostTransaction', '', false, false)]
    local procedure OnAfterPostTransaction(var TransactionHeader_p: Record "LSC Transaction Header")
    var
        UpHeadRec: Record "UP Header"; //AlleRSN 201223
        UpLineRec: Record "UP Line";
    begin
        UpHeadRec.RESET();
        UpHeadRec.SetRange(UpHeadRec.StoreNo, TransactionHeader_p."Store No.");
        UpHeadRec.SetRange(PosTerminalNo, TransactionHeader_p."POS Terminal No.");
        UpHeadRec.SetRange(UpHeadRec.receiptNo, TransactionHeader_p."Receipt No.");
        IF UpHeadRec.FINDLAST() then begin
            UpHeadRec.TransactionNo := TransactionHeader_p."Transaction No.";
            UpHeadRec.Modify();

            UpLineRec.Reset();
            UpLineRec.SetRange(order_id, UpHeadRec.order_details_id);
            IF UpLineRec.FindSet() then
                repeat
                    UpLineRec.StoreNo := TransactionHeader_p."Store No.";
                    UpLineRec.PosTerminalNo := TransactionHeader_p."POS Terminal No.";
                    UpLineRec.TransactionNo := TransactionHeader_p."Transaction No.";
                    UpLineRec.Modify();
                until UpLineRec.next = 0;
        end;
    end;
    //AlleRSN 201223 end

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Transaction Events", 'OnBeforeStartNewTransaction', '', false, false)]
    local procedure OnBeforeStartNewTransaction(var POSTransaction: Record "LSC POS Transaction")
    var
        POSCTRL: Codeunit "LSC POS Control Interface";
        LSCPOSMenuLine: Record "LSC POS Menu Line";
        LSCPOSMenuLine1: Record "LSC POS Menu Line";
        LSCPOSMenuLine2: Record "LSC POS Menu Line";
        i: integer;
        hardwareprofile: Record "LSC POS Hardware Profile";
        taxtable: Record 10044509;
    begin

        LSCPOSMenuLine.Reset();
        LSCPOSMenuLine.SetRange("Menu ID", '#APPCUSTOMER');
        IF LSCPOSMenuLine.FindFirst() then
            LSCPOSMenuLine.DeleteAll();


        LSCPOSMenuLine.Init();
        LSCPOSMenuLine.Validate("Profile ID", '##DEFAULT');
        LSCPOSMenuLine.Validate("Menu ID", '#APPCUSTOMER');
        LSCPOSMenuLine.Validate("Key No.", 1);
        LSCPOSMenuLine.Validate(RowSpan, 2);
        LSCPOSMenuLine.Description := 'Customer Information';
        LSCPOSMenuLine.Insert();

        LSCPOSMenuLine.Init();
        LSCPOSMenuLine.Validate("Profile ID", '##DEFAULT');
        LSCPOSMenuLine.Validate("Menu ID", '#APPCUSTOMER');
        LSCPOSMenuLine.Validate("Key No.", 2);
        LSCPOSMenuLine.Description := 'Customer Level';
        LSCPOSMenuLine.Insert();
        LSCPOSMenuLine.Init();
        LSCPOSMenuLine.Validate("Profile ID", '##DEFAULT');
        LSCPOSMenuLine.Validate("Menu ID", '#APPCUSTOMER');
        LSCPOSMenuLine.Validate("Key No.", 3);
        LSCPOSMenuLine.Description := 'Wave-Coins';
        LSCPOSMenuLine.Insert();
        LSCPOSMenuLine.Init();
        LSCPOSMenuLine.Validate("Profile ID", '##DEFAULT');
        LSCPOSMenuLine.Validate("Menu ID", '#APPCUSTOMER');
        LSCPOSMenuLine.Validate("Key No.", 5);
        LSCPOSMenuLine.Description := 'Promo Wallet';
        LSCPOSMenuLine.Insert();
        LSCPOSMenuLine.Init();
        LSCPOSMenuLine.Validate("Profile ID", '##DEFAULT');
        LSCPOSMenuLine.Validate("Menu ID", '#APPCUSTOMER');
        LSCPOSMenuLine.Validate("Key No.", 6);
        LSCPOSMenuLine.Description := 'Main Wallet';
        LSCPOSMenuLine.Insert();



        LSCPOSMenuLine.Reset();
        LSCPOSMenuLine.SetRange("Menu ID", '#FVRTS');
        IF LSCPOSMenuLine.FindFirst() then
            LSCPOSMenuLine.DeleteAll();

        For i := 1 to 6 do begin
            LSCPOSMenuLine.Reset();
            LSCPOSMenuLine.Init();
            LSCPOSMenuLine.Validate("Profile ID", '##DEFAULT');
            LSCPOSMenuLine.Validate("Menu ID", '#FVRTS');
            LSCPOSMenuLine.Validate("Key No.", i);
            LSCPOSMenuLine.Description := '';
            LSCPOSMenuLine.Insert();
        end;

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


        LSCPOSMenuLine2.Reset();
        LSCPOSMenuLine2.SetRange("Menu ID", '#LOYALTYDISC');
        IF LSCPOSMenuLine2.FindSet() then
            LSCPOSMenuLine2.DeleteAll();


        For i := 1 to 27 do begin
            LSCPOSMenuLine.Reset();
            LSCPOSMenuLine.Init();
            LSCPOSMenuLine.Validate("Profile ID", '##DEFAULT');
            LSCPOSMenuLine.Validate("Menu ID", '#LOYALTYDISC');
            LSCPOSMenuLine.Validate("Key No.", i);
            LSCPOSMenuLine.Description := '';
            LSCPOSMenuLine.Insert();
        end;
        LSCPOSMenuLine2.Reset();
        LSCPOSMenuLine2.SetRange("Menu ID", '#CARTDISC');
        IF LSCPOSMenuLine2.FindSet() then
            LSCPOSMenuLine2.DeleteAll();
        For i := 1 to 27 do begin
            LSCPOSMenuLine.Reset();
            LSCPOSMenuLine.Init();
            LSCPOSMenuLine.Validate("Profile ID", '##DEFAULT');
            LSCPOSMenuLine.Validate("Menu ID", '#CARTDISC');
            LSCPOSMenuLine.Validate("Key No.", i);
            LSCPOSMenuLine.Description := '';
            LSCPOSMenuLine.Insert();
        end;


        LSCPOSMenuLine2.Reset();
        LSCPOSMenuLine2.SetRange("Menu ID", '#PRODDISC');
        IF LSCPOSMenuLine2.FindSet() then
            LSCPOSMenuLine2.DeleteAll();

        For i := 1 to 27 do begin
            LSCPOSMenuLine.Reset();
            LSCPOSMenuLine.Init();
            LSCPOSMenuLine.Validate("Profile ID", '##DEFAULT');
            LSCPOSMenuLine.Validate("Menu ID", '#PRODDISC');
            LSCPOSMenuLine.Validate("Key No.", i);
            LSCPOSMenuLine.Description := '';
            LSCPOSMenuLine.Insert();
        end;

        POSCTRL.RefreshMenu('##DEFAULT', '#PRODDISC');
        POSCTRL.RefreshMenu('##DEFAULT', '#CARTDISC');
        POSCTRL.RefreshMenu('##DEFAULT', '#LOYALTYDISC');
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Transaction Events", 'OnAfterLogin', '', false, false)]
    local procedure OnAfterLogin(var POSTransaction: Record "LSC POS Transaction")
    var
        POSCTRL: Codeunit "LSC POS Control Interface";
        LSCPOSMenuLine: Record "LSC POS Menu Line";
        LSCPOSMenuLine1: Record "LSC POS Menu Line";
        LSCPOSMenuLine2: Record "LSC POS Menu Line";
        i: integer;
    begin

        LSCPOSMenuLine.Reset();
        LSCPOSMenuLine.SetRange("Menu ID", '#APPCUSTOMER');
        IF LSCPOSMenuLine.FindFirst() then
            LSCPOSMenuLine.DeleteAll();


        LSCPOSMenuLine.Init();
        LSCPOSMenuLine.Validate("Profile ID", '##DEFAULT');
        LSCPOSMenuLine.Validate("Menu ID", '#APPCUSTOMER');
        LSCPOSMenuLine.Validate("Key No.", 1);
        LSCPOSMenuLine.Validate(RowSpan, 2);
        LSCPOSMenuLine.Description := 'Customer Information';
        LSCPOSMenuLine.Insert();

        LSCPOSMenuLine.Init();
        LSCPOSMenuLine.Validate("Profile ID", '##DEFAULT');
        LSCPOSMenuLine.Validate("Menu ID", '#APPCUSTOMER');
        LSCPOSMenuLine.Validate("Key No.", 2);
        LSCPOSMenuLine.Description := 'Customer Level';
        LSCPOSMenuLine.Insert();

        LSCPOSMenuLine.Init();
        LSCPOSMenuLine.Validate("Profile ID", '##DEFAULT');
        LSCPOSMenuLine.Validate("Menu ID", '#APPCUSTOMER');
        LSCPOSMenuLine.Validate("Key No.", 3);
        LSCPOSMenuLine.Description := 'Wave-Coins';
        LSCPOSMenuLine.Insert();
        LSCPOSMenuLine.Init();
        LSCPOSMenuLine.Validate("Profile ID", '##DEFAULT');
        LSCPOSMenuLine.Validate("Menu ID", '#APPCUSTOMER');
        LSCPOSMenuLine.Validate("Key No.", 5);
        LSCPOSMenuLine.Description := 'Promo Wallet';
        LSCPOSMenuLine.Insert();
        LSCPOSMenuLine.Init();
        LSCPOSMenuLine.Validate("Profile ID", '##DEFAULT');
        LSCPOSMenuLine.Validate("Menu ID", '#APPCUSTOMER');
        LSCPOSMenuLine.Validate("Key No.", 6);
        LSCPOSMenuLine.Description := 'Main Wallet';
        LSCPOSMenuLine.Insert();



        LSCPOSMenuLine.Reset();
        LSCPOSMenuLine.SetRange("Menu ID", '#FVRTS');
        IF LSCPOSMenuLine.FindFirst() then
            LSCPOSMenuLine.DeleteAll();

        For i := 1 to 6 do begin
            LSCPOSMenuLine.Reset();
            LSCPOSMenuLine.Init();
            LSCPOSMenuLine.Validate("Profile ID", '##DEFAULT');
            LSCPOSMenuLine.Validate("Menu ID", '#FVRTS');
            LSCPOSMenuLine.Validate("Key No.", i);
            LSCPOSMenuLine.Description := '';
            LSCPOSMenuLine.Insert();
        end;

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


        LSCPOSMenuLine2.Reset();
        LSCPOSMenuLine2.SetRange("Menu ID", '#LOYALTYDISC');
        IF LSCPOSMenuLine2.FindSet() then
            LSCPOSMenuLine2.DeleteAll();


        For i := 1 to 27 do begin
            LSCPOSMenuLine.Reset();
            LSCPOSMenuLine.Init();
            LSCPOSMenuLine.Validate("Profile ID", '##DEFAULT');
            LSCPOSMenuLine.Validate("Menu ID", '#LOYALTYDISC');
            LSCPOSMenuLine.Validate("Key No.", i);
            LSCPOSMenuLine.Description := '';
            LSCPOSMenuLine.Insert();
        end;
        LSCPOSMenuLine2.Reset();
        LSCPOSMenuLine2.SetRange("Menu ID", '#CARTDISC');
        IF LSCPOSMenuLine2.FindSet() then
            LSCPOSMenuLine2.DeleteAll();
        For i := 1 to 27 do begin
            LSCPOSMenuLine.Reset();
            LSCPOSMenuLine.Init();
            LSCPOSMenuLine.Validate("Profile ID", '##DEFAULT');
            LSCPOSMenuLine.Validate("Menu ID", '#CARTDISC');
            LSCPOSMenuLine.Validate("Key No.", i);
            LSCPOSMenuLine.Description := '';
            LSCPOSMenuLine.Insert();
        end;


        LSCPOSMenuLine2.Reset();
        LSCPOSMenuLine2.SetRange("Menu ID", '#PRODDISC');
        IF LSCPOSMenuLine2.FindSet() then
            LSCPOSMenuLine2.DeleteAll();

        For i := 1 to 27 do begin
            LSCPOSMenuLine.Reset();
            LSCPOSMenuLine.Init();
            LSCPOSMenuLine.Validate("Profile ID", '##DEFAULT');
            LSCPOSMenuLine.Validate("Menu ID", '#PRODDISC');
            LSCPOSMenuLine.Validate("Key No.", i);
            LSCPOSMenuLine.Description := '';
            LSCPOSMenuLine.Insert();
        end;

        POSCTRL.RefreshMenu('##DEFAULT', '#PRODDISC');
        POSCTRL.RefreshMenu('##DEFAULT', '#CARTDISC');
        POSCTRL.RefreshMenu('##DEFAULT', '#LOYALTYDISC');
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Transaction Events", 'OnAfterClose', '', false, false)]
    local procedure OnAfterClose(var POSTransaction: Record "LSC POS Transaction")
    var
        POSCTRL: Codeunit "LSC POS Control Interface";
        LSCPOSMenuLine: Record "LSC POS Menu Line";
        LSCPOSMenuLine1: Record "LSC POS Menu Line";
        LSCPOSMenuLine2: Record "LSC POS Menu Line";
        i: Integer;
    begin

        LSCPOSMenuLine.Reset();
        LSCPOSMenuLine.SetRange("Menu ID", '#APPCUSTOMER');
        IF LSCPOSMenuLine.FindFirst() then
            LSCPOSMenuLine.DeleteAll();


        LSCPOSMenuLine.Init();
        LSCPOSMenuLine.Validate("Profile ID", '##DEFAULT');
        LSCPOSMenuLine.Validate("Menu ID", '#APPCUSTOMER');
        LSCPOSMenuLine.Validate("Key No.", 1);
        LSCPOSMenuLine.Validate(RowSpan, 2);
        LSCPOSMenuLine.Description := 'Customer Information';
        LSCPOSMenuLine.Insert();

        LSCPOSMenuLine.Init();
        LSCPOSMenuLine.Validate("Profile ID", '##DEFAULT');
        LSCPOSMenuLine.Validate("Menu ID", '#APPCUSTOMER');
        LSCPOSMenuLine.Validate("Key No.", 2);
        LSCPOSMenuLine.Description := 'Customer Level';
        LSCPOSMenuLine.Insert();

        LSCPOSMenuLine.Init();
        LSCPOSMenuLine.Validate("Profile ID", '##DEFAULT');
        LSCPOSMenuLine.Validate("Menu ID", '#APPCUSTOMER');
        LSCPOSMenuLine.Validate("Key No.", 3);
        LSCPOSMenuLine.Description := 'Wave-Coins';
        LSCPOSMenuLine.Insert();
        LSCPOSMenuLine.Init();
        LSCPOSMenuLine.Validate("Profile ID", '##DEFAULT');
        LSCPOSMenuLine.Validate("Menu ID", '#APPCUSTOMER');
        LSCPOSMenuLine.Validate("Key No.", 5);
        LSCPOSMenuLine.Description := 'Promo Wallet';
        LSCPOSMenuLine.Insert();
        LSCPOSMenuLine.Init();
        LSCPOSMenuLine.Validate("Profile ID", '##DEFAULT');
        LSCPOSMenuLine.Validate("Menu ID", '#APPCUSTOMER');
        LSCPOSMenuLine.Validate("Key No.", 6);
        LSCPOSMenuLine.Description := 'Main Wallet';
        LSCPOSMenuLine.Insert();

        LSCPOSMenuLine.Reset();
        LSCPOSMenuLine.SetRange("Menu ID", '#FVRTS');
        IF LSCPOSMenuLine.FindFirst() then
            LSCPOSMenuLine.DeleteAll();

        For i := 1 to 6 do begin
            LSCPOSMenuLine.Reset();
            LSCPOSMenuLine.Init();
            LSCPOSMenuLine.Validate("Profile ID", '##DEFAULT');
            LSCPOSMenuLine.Validate("Menu ID", '#FVRTS');
            LSCPOSMenuLine.Validate("Key No.", i);
            LSCPOSMenuLine.Description := '';
            LSCPOSMenuLine.Insert();
        end;

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
        POSCTRL.RefreshMenu('##DEFAULT', '#APPCUSTOMER');
        POSCTRL.RefreshMenu('##DEFAULT', '#FVRTS');

        LSCPOSMenuLine2.Reset();
        LSCPOSMenuLine2.SetRange("Menu ID", '#LOYALTYDISC');
        IF LSCPOSMenuLine2.FindSet() then
            LSCPOSMenuLine2.DeleteAll();


        For i := 1 to 27 do begin
            LSCPOSMenuLine.Reset();
            LSCPOSMenuLine.Init();
            LSCPOSMenuLine.Validate("Profile ID", '##DEFAULT');
            LSCPOSMenuLine.Validate("Menu ID", '#LOYALTYDISC');
            LSCPOSMenuLine.Validate("Key No.", i);
            LSCPOSMenuLine.Description := '';
            LSCPOSMenuLine.Insert();
        end;
        LSCPOSMenuLine2.Reset();
        LSCPOSMenuLine2.SetRange("Menu ID", '#CARTDISC');
        IF LSCPOSMenuLine2.FindSet() then
            LSCPOSMenuLine2.DeleteAll();
        For i := 1 to 27 do begin
            LSCPOSMenuLine.Reset();
            LSCPOSMenuLine.Init();
            LSCPOSMenuLine.Validate("Profile ID", '##DEFAULT');
            LSCPOSMenuLine.Validate("Menu ID", '#CARTDISC');
            LSCPOSMenuLine.Validate("Key No.", i);
            LSCPOSMenuLine.Description := '';
            LSCPOSMenuLine.Insert();
        end;


        LSCPOSMenuLine2.Reset();
        LSCPOSMenuLine2.SetRange("Menu ID", '#PRODDISC');
        IF LSCPOSMenuLine2.FindSet() then
            LSCPOSMenuLine2.DeleteAll();

        For i := 1 to 27 do begin
            LSCPOSMenuLine.Reset();
            LSCPOSMenuLine.Init();
            LSCPOSMenuLine.Validate("Profile ID", '##DEFAULT');
            LSCPOSMenuLine.Validate("Menu ID", '#PRODDISC');
            LSCPOSMenuLine.Validate("Key No.", i);
            LSCPOSMenuLine.Description := '';
            LSCPOSMenuLine.Insert();
        end;
        POSCTRL.RefreshMenu('##DEFAULT', '#PRODDISC');
        POSCTRL.RefreshMenu('##DEFAULT', '#CARTDISC');
        POSCTRL.RefreshMenu('##DEFAULT', '#LOYALTYDISC');
        POSCTRL.RefreshMenu('##DEFAULT', '#APPCUSTOMER');

    end;
    //Alle-Commented
    // [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Transaction Events", 'OnAfterTotalExecuted', '', false, false)]
    // local procedure WalletLoadAPICall(var POSTransaction: Record "LSC POS Transaction")
    // var
    //     transsalesentry: Record "LSC Trans. Sales Entry";
    //     Jsonobject: JsonObject;
    //     jsondata: Text;
    //     ReqUrl: Text;
    //     responsemsg: HttpResponseMessage;
    //     POstransLine: Record "LSC POS Trans. Line";
    //     // posmenu: Codeunit lsc pos co
    //     POstransLine1: Record "LSC POS Trans. Line";
    //     posmenuline: Record "LSC POS Menu Line";

    // begin
    //     IF POSTransaction."Is wallet loaded" then begin
    //         Message('Wallet is already loaded.Please continue');
    //         // exit;
    //     end
    //     else begin


    //         //   IF POSTransaction."Is wallet Error" then begin
    //         POstransLine.Reset();
    //         POstransLine.SetRange("Receipt No.", POSTransaction."Receipt No.");
    //         POstransLine.SetRange("Entry Status", POstransLine."Entry Status"::" ");
    //         POstransLine.SetRange(Number, Format(1));
    //         IF POstransLine.FindFirst() then begin
    //             //   IF not POstransLine."Is wallet Error" then begin
    //             Clear(JsonObject);

    //             JsonObject.Add('userId', POSTransaction.CustAppUserId);
    //             JsonObject.Add('amount', abs(POstransLine."Net Amount"));
    //             JsonObject.Add('posStoreId', POstransLine."Store No.");

    //             Jsonobject.WriteTo(jsondata);

    //             apisetup.Get();
    //             // Message(jsondata);

    //             ReqUrl := apisetup.WalletLoadAPIUrl;
    //             if not POSTransaction."Is wallet loaded" then //ALLE-AS-06102023
    //                 responsemsg := CallServiceStatusReviewCart(ReqUrl, HTTPRequestTypeEnum::post, JsonData);
    //             IF responsemsg.IsSuccessStatusCode then begin
    //                 POstransLine."Is wallet Error" := false;
    //                 POstransLine.Modify(true);
    //                 POSTransaction."Is wallet Error" := false;
    //                 POSTransaction."Is wallet loaded" := true;
    //                 POSTransaction.Modify(true);


    //             end;
    //             IF not responsemsg.IsSuccessStatusCode then begin
    //                 POstransLine."Is wallet Error" := true;
    //                 POSTransaction."Is wallet loaded" := false;
    //                 POstransLine.Modify(true);

    //                 POSTransaction."Is wallet Error" := true;
    //                 POSTransaction.Modify(true);

    //                 Error('Unable to proceed with the transaction due to server error. Please void the transaction and start again.');

    //             end;
    //         end;
    //     end;
    // end;
    //Alle-Commented

    // //ALLE-ONBeforeTotal
    // [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Transaction Events", 'OnAfterTotalExecuted', '', false, false)]
    // local procedure OnAfterTotalExecuted(var POSTransaction: Record "LSC POS Transaction")
    // var
    //     transsalesentry: Record "LSC Trans. Sales Entry";
    //     Jsonobject: JsonObject;
    //     jsondata: Text;
    //     ReqUrl: Text;
    //     responsemsg: HttpResponseMessage;
    //     POstransLine: Record "LSC POS Trans. Line";
    //     // posmenu: Codeunit lsc pos co
    //     POstransLine1: Record "LSC POS Trans. Line";
    //     posmenuline: Record "LSC POS Menu Line";
    //     GSTGrpCode: Text;
    // begin
    //     //ALLE-AS-17102023--commented
    //     POstransLine.Reset();
    //     POstransLine.SetRange("Receipt No.", POSTransaction."Receipt No.");
    //     POstransLine.SetRange("Entry Type", POstransLine."Entry Type"::Item);
    //     POstransLine.SetRange("Entry Status", POstransLine."Entry Status"::" ");
    //     IF POstransLine.FindFirst() then begin
    //         //Clear(GSTGrpCode);
    //         //if ((POstransLine."Net Amount" - POstransLine."Discount Amount") <> 0) then
    //         //GSTGrpCode := Evaluate(POstransLine."LSCIN GST Group Code")
    //         if POstransLine."Net Amount" <> 0 then
    //             if (POstransLine."LSCIN GST Group Code" <> '0') or (POstransLine."LSCIN GST Group Code" = '') then
    //                 if (POstransLine."LSCIN GST Amount" = 0) then
    //                     if (POstransLine."User Plan Id" = '') then
    //                         if POSTransaction."Sales Type" = 'POS' then
    //                             Error('GST amount cannot be zero.So check once gst amount for that item');
    //     end;
    //     //ALLE-AS-17102023--commented
    // end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Transaction Events", 'OnAfterPostPOSTransaction', '', false, false)]
    local procedure OnAfterPostPOSTransaction(var POSTransaction: Record "LSC POS Transaction")
    var
        POSCTRL: Codeunit "LSC POS Control Interface";
        LSCPOSMenuLine: Record "LSC POS Menu Line";
        LSCPOSMenuLine1: Record "LSC POS Menu Line";
        LSCPOSMenuLine2: Record "LSC POS Menu Line";
        i: Integer;
        item: Record Item;
        transsalesentry: Record "LSC Trans. Sales Entry";
        Jsonobjjsonarrtendeect: JsonObject;
        jsondata: Text;
        ReqUrl: Text;
        responsemsg: HttpResponseMessage;
        TransactionHeader: Record "LSC Transaction Header";

    begin

        item.ModifyAll("Subscription Item", false);
        //ALLENICK_START
        // TransactionHeader.SetRange("Store No.", POSTransaction."Store No.");
        // TransactionHeader.SetRange("Receipt No.", POSTransaction."Receipt No.");
        // if TransactionHeader.FindFirst() then begin
        //     BillMe(TransactionHeader);
        // end;
        //ALLENICK_END
        LSCPOSMenuLine.Reset();
        LSCPOSMenuLine.SetRange("Menu ID", '#APPCUSTOMER');
        IF LSCPOSMenuLine.FindFirst() then
            LSCPOSMenuLine.DeleteAll();

        LSCPOSMenuLine.Init();
        LSCPOSMenuLine.Validate("Profile ID", '##DEFAULT');
        LSCPOSMenuLine.Validate("Menu ID", '#APPCUSTOMER');
        LSCPOSMenuLine.Validate("Key No.", 1);
        LSCPOSMenuLine.Validate(RowSpan, 2);
        LSCPOSMenuLine.Description := 'Customer Information';
        LSCPOSMenuLine.Insert();

        LSCPOSMenuLine.Init();
        LSCPOSMenuLine.Validate("Profile ID", '##DEFAULT');
        LSCPOSMenuLine.Validate("Menu ID", '#APPCUSTOMER');
        LSCPOSMenuLine.Validate("Key No.", 2);
        LSCPOSMenuLine.Description := 'Customer Level';
        LSCPOSMenuLine.Insert();

        LSCPOSMenuLine.Init();
        LSCPOSMenuLine.Validate("Profile ID", '##DEFAULT');
        LSCPOSMenuLine.Validate("Menu ID", '#APPCUSTOMER');
        LSCPOSMenuLine.Validate("Key No.", 3);
        LSCPOSMenuLine.Description := 'Wave-Coins';
        LSCPOSMenuLine.Insert();
        LSCPOSMenuLine.Init();
        LSCPOSMenuLine.Validate("Profile ID", '##DEFAULT');
        LSCPOSMenuLine.Validate("Menu ID", '#APPCUSTOMER');
        LSCPOSMenuLine.Validate("Key No.", 5);
        LSCPOSMenuLine.Description := 'Promo Wallet';
        LSCPOSMenuLine.Insert();
        LSCPOSMenuLine.Init();
        LSCPOSMenuLine.Validate("Profile ID", '##DEFAULT');
        LSCPOSMenuLine.Validate("Menu ID", '#APPCUSTOMER');
        LSCPOSMenuLine.Validate("Key No.", 6);
        LSCPOSMenuLine.Description := 'Main Wallet';
        LSCPOSMenuLine.Insert();


        LSCPOSMenuLine.Reset();
        LSCPOSMenuLine.SetRange("Menu ID", '#FVRTS');
        IF LSCPOSMenuLine.FindFirst() then
            LSCPOSMenuLine.DeleteAll();

        For i := 1 to 6 do begin
            LSCPOSMenuLine.Reset();
            LSCPOSMenuLine.Init();
            LSCPOSMenuLine.Validate("Profile ID", '##DEFAULT');
            LSCPOSMenuLine.Validate("Menu ID", '#FVRTS');
            LSCPOSMenuLine.Validate("Key No.", i);
            LSCPOSMenuLine.Description := '';
            LSCPOSMenuLine.Insert();
        end;

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

        For i := 1 to 27 do begin
            LSCPOSMenuLine.Reset();
            LSCPOSMenuLine.Init();
            LSCPOSMenuLine.Validate("Profile ID", '##DEFAULT');
            LSCPOSMenuLine.Validate("Menu ID", '#SUBS');
            LSCPOSMenuLine.Validate("Key No.", i);
            LSCPOSMenuLine.Description := '';
            LSCPOSMenuLine.Insert();
        end;
        POSCTRL.RefreshMenu('##DEFAULT', '#SUBS');


        POSCTRL.RefreshMenu('##DEFAULT', '#FVRTS');
        POSCTRL.RefreshMenu('##DEFAULT', '#APPCUSTOMER');

        LSCPOSMenuLine2.Reset();
        LSCPOSMenuLine2.SetRange("Menu ID", '#LOYALTYDISC');
        IF LSCPOSMenuLine2.FindSet() then
            LSCPOSMenuLine2.DeleteAll();


        For i := 1 to 27 do begin
            LSCPOSMenuLine.Reset();
            LSCPOSMenuLine.Init();
            LSCPOSMenuLine.Validate("Profile ID", '##DEFAULT');
            LSCPOSMenuLine.Validate("Menu ID", '#LOYALTYDISC');
            LSCPOSMenuLine.Validate("Key No.", i);
            LSCPOSMenuLine.Description := '';
            LSCPOSMenuLine.Insert();
        end;
        LSCPOSMenuLine2.Reset();
        LSCPOSMenuLine2.SetRange("Menu ID", '#CARTDISC');
        IF LSCPOSMenuLine2.FindSet() then
            LSCPOSMenuLine2.DeleteAll();
        For i := 1 to 27 do begin
            LSCPOSMenuLine.Reset();
            LSCPOSMenuLine.Init();
            LSCPOSMenuLine.Validate("Profile ID", '##DEFAULT');
            LSCPOSMenuLine.Validate("Menu ID", '#CARTDISC');
            LSCPOSMenuLine.Validate("Key No.", i);
            LSCPOSMenuLine.Description := '';
            LSCPOSMenuLine.Insert();
        end;


        LSCPOSMenuLine2.Reset();
        LSCPOSMenuLine2.SetRange("Menu ID", '#PRODDISC');
        IF LSCPOSMenuLine2.FindSet() then
            LSCPOSMenuLine2.DeleteAll();

        For i := 1 to 27 do begin
            LSCPOSMenuLine.Reset();
            LSCPOSMenuLine.Init();
            LSCPOSMenuLine.Validate("Profile ID", '##DEFAULT');
            LSCPOSMenuLine.Validate("Menu ID", '#PRODDISC');
            LSCPOSMenuLine.Validate("Key No.", i);
            LSCPOSMenuLine.Description := '';
            LSCPOSMenuLine.Insert();
        end;
        POSCTRL.RefreshMenu('##DEFAULT', '#PRODDISC');
        POSCTRL.RefreshMenu('##DEFAULT', '#CARTDISC');
        POSCTRL.RefreshMenu('##DEFAULT', '#LOYALTYDISC');

        /*
          transsalesentry.Reset();
          transsalesentry.SetRange("Receipt No.", POSTransaction."Receipt No.");
          transsalesentry.SetRange("Item No.", Format(1));
          IF transsalesentry.FindFirst() then begin
              Clear(JsonObject);

              JsonObject.Add('userId', POSTransaction.CustAppUserId);
              JsonObject.Add('amount', abs(transsalesentry."Net Amount"));
              JsonObject.Add('posStoreId', transsalesentry."Store No.");

              Jsonobject.WriteTo(jsondata);

              apisetup.Get();
              // Message(jsondata);

              ReqUrl := apisetup.WalletLoadAPIUrl;
              CallServiceStatus(ReqUrl, HTTPRequestTypeEnum::post, JsonData);

          end;
          */



    end;
    //AlleRSN 051023
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Transaction Events", 'OnBeforeItemLine', '', false, false)]
    local procedure OnBeforeItemLine(var CurrInput: Text; var POSTransaction: Record "LSC POS Transaction")
    var
        ItemrecLoc: Record Item;
        ICatRec: Record "Item Category";
    begin

        IF (POSTransaction."Sales Type" = 'TAKEAWAY') OR (POSTransaction."Sales Type" = 'PRE-ORDER') then begin
            IF CurrInput <> '' then begin
                IF ItemrecLoc.Get(CurrInput) then begin
                    //IF ItemrecLoc."Item Category Code" = 'PACKAGING' then begin
                    IF ICatRec.Get(ItemrecLoc."Item Category Code") then begin
                        if not ICatRec."Packaging Bom" then
                            Error('Not Allowed to Add Items');
                    end;
                    // end;
                end;


            end;
        end;


    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Transaction Events", 'OnBeforeChangeQty', '', false, false)]
    local procedure OnBeforeChangeQty(var POSTransaction: Record "LSC POS Transaction"; var POSTransLine: Record "LSC POS Trans. Line")
    begin
        IF (POSTransaction."Sales Type" = 'TAKEAWAY') OR (POSTransaction."Sales Type" = 'PRE-ORDER') then begin
            Error('Not Allowed to Change Quantity');
        end;

    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Transaction Events", 'OnBeforeVoidLine', '', false, false)]
    local procedure OnBeforeVoidLine(var POSTransaction: Record "LSC POS Transaction"; var POSTransLine: Record "LSC POS Trans. Line")
    var
        ItemrecLoc: Record Item;
        ICatRec: Record "Item Category";
        InfocodeRec: Record "LSC Infocode";  //AlleRSN 091223
    begin
        IF POSTransLine."Parent BOM Line No" <> 0 THEN begin
            Error('You cannot void Production BOM items');

        end;
        IF (POSTransaction."Sales Type" = 'TAKEAWAY') OR (POSTransaction."Sales Type" = 'PRE-ORDER') then begin
            Error('Not Allowed to void lines');
            /* IF POSTransLine."Entry Type" = POSTransLine."Entry Type"::Item then begin
                 IF ItemrecLoc.Get(POSTransLine.Number) then begin
                     IF ItemrecLoc."Item Category Code" = 'PACKAGING' then begin
                         IF ICatRec.Get(ItemrecLoc."Item Category Code") then begin
                             if ICatRec."Packaging Bom" then
                                 Error('Not Allowed to void lines');
                         end;
                     end;
                 end;


             end;*/
        end;
        //AlleRSN 091223 start
        IF InfocodeRec.Get(POSTransLine."Orig. from Infocode") then
            if InfocodeRec."Min. Selection" > 0 then begin
                Error('Mandatory Item Modifiers cannot be voided');
            end;

        //AlleRSN 091223 end
    end;
    //AlleRSN 051023
    //AlleRSN 101023 start
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Transaction Events", 'OnBeforeTotDiscPr', '', false, false)]
    local procedure OnBeforeTotDiscPr(var CurrInput: Text; var POSTransaction: Record "LSC POS Transaction")
    begin
        IF (POSTransaction."Sales Type" = 'TAKEAWAY') OR (POSTransaction."Sales Type" = 'PRE-ORDER') then begin
            Error('Not Allowed!');
        end;
        //AlleRSN 111223 start
        IF (POSTransaction."Sales Type" = 'POS') AND (POSTransaction.CustAppUserId <> '') then begin
            Error('For App Scan Order You Can not Apply Mannual Discount');
        end;
        //AlleRSN 111223 End
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Transaction Events", 'OnBeforeTotDiscAm', '', false, false)]
    local procedure OnBeforeTotDiscAm(var CurrInput: Text; var POSTransaction: Record "LSC POS Transaction")
    begin
        IF (POSTransaction."Sales Type" = 'TAKEAWAY') OR (POSTransaction."Sales Type" = 'PRE-ORDER') then begin
            Error('Not Allowed!');
        end;
        //AJ_ALLE_11122023

        IF (POSTransaction."Sales Type" = 'POS') AND (POSTransaction.CustAppUserId <> '') then begin

            IF POSTransaction."Cart Offer ID" = '' then
                Error('For App Scan Order You Can not Apply Mannual Discount');
        end;
        //AJ_ALLE_11122023
    end;



    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Transaction", 'OnDiscAmtPressed', '', false, false)]
    local procedure OnDiscAmtPressed(var Sender: Codeunit "LSC POS Transaction"; var LineRec: Record "LSC POS Trans. Line"; var IsHandled: Boolean);
    var
        POSTransCu: Record "LSC POS Transaction";
    begin
        IF POSTransCu.Get(LineRec."Receipt No.") then begin
            IF (POSTransCu."Sales Type" = 'TAKEAWAY') OR (POSTransCu."Sales Type" = 'PRE-ORDER') then begin
                Error('Not Allowed!');
            end;
            //AJ_ALLE_11122023
            IF (POSTransCu."Sales Type" = 'POS') AND (POSTransCu.CustAppUserId <> '') then begin
                Error('For App Scan Order You Can not Apply Mannual Discount');
            end;
            //AJ_ALLE_11122023
        end;
    end;


    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Transaction Events", 'OnAfterDiscPrDiscountLine', '', false, false)]
    local procedure OnAfterDiscPrDiscountLine(var POSTransaction: Record "LSC POS Transaction")
    begin
        IF (POSTransaction."Sales Type" = 'TAKEAWAY') OR (POSTransaction."Sales Type" = 'PRE-ORDER') then begin
            Error('Not Allowed!');
        end;
        //AJ_ALLE_11122023
        IF (POSTransaction."Sales Type" = 'POS') AND (POSTransaction.CustAppUserId <> '') then begin
            Error('For App Scan Order You Can not Apply Mannual Discount');
        end;
        //AJ_ALLE_11122023  
    end;
    //AlleRSN 101023 end
    //AlleRSN 300124 start
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Transaction", 'OnBeforeRefundLookup', '', false, false)]
    local procedure OnBeforeRefundLookup(var RefundTransaction: Record "LSC Transaction Header"; var IsHandled: Boolean)
    begin
        IF RefundTransaction."Sales Type" <> 'POS' then
            Error('Cannot refund HD/APP orders');

    end;
    //AlleRSN 

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Transaction Events", 'OnAfterVoidLine', '', false, false)]
    local procedure OnAfterVoidLine(var POSTransaction: Record "LSC POS Transaction"; var POSTransLine: Record "LSC POS Trans. Line")
    var
        i: Integer;
        apiurl: Text;
        jsondata: Text;
        PaymentObject: JsonObject;
        JsonObject: JsonObject;
        responsemsg: HttpResponseMessage;
        JsonTkn: JsonToken;
        JsonTkn1: JsonToken;
        JsonObj: JsonObject;
        jsonarr: JsonArray;
        POSTRans: Record "LSC POS Trans. Line";
        POSTRans1: Record "LSC POS Trans. Line";
        POSTRans2: Record "LSC POS Trans. Line";

    begin
        //  IF POSTransLine.Description = 'TWC Wallet' then begin

        IF POSTransLine."Entry Type" = POSTransLine."Entry Type"::TotalDiscount then begin
            POSTransLine.ModifyAll(WaveCoinApplied, false);
        end;

        //AlleRSN 041023 start
        IF POSTransLine."Packaging BOM Applied" then begin
            POSTRans2.Reset();
            POSTRans2.SetRange("Parent BOM Line No", POSTransLine."Line No.");
            IF POSTRans2.FindSet() THEN
                repeat
                    POSTRans2.VoidLine();
                until POSTRans2.next = 0;
        end;
        //AlleRSN 041023 end

        POSTRans.Reset();
        POSTRans.SetRange("Receipt No.", POSTransaction."Receipt No.");
        POSTRans.SetRange("Entry Status", POSTRans."Entry Status"::" ");
        IF POSTRans.FindFirst() then
            IF (POSTRans.txnId <> '') OR (POSTRans.PromoTxnId <> '') then begin
                Clear(JsonObject);


                JsonObject.Add('userId', POSTransaction.CustAppUserId);
                Clear(jsonarr);
                IF POSTRans.PromoTxnId <> '' then begin
                    paymentObject.Add('txnId', POSTRans.PromoTxnId);
                    paymentObject.Add('batchNumber', POSTRans.batchNumber);
                    jsonarr.Add(paymentObject);

                end;

                //  Clear(jsonarr);
                Clear(PaymentObject);
                IF POSTRans.txnId <> '' then begin
                    paymentObject.Add('txnId', POSTRans.txnId);
                    paymentObject.Add('batchNumber', POSTRans.batchNumber);
                    jsonarr.Add(paymentObject);
                    //   JsonObject.Add('referenceList', jsonarr);
                end;
                JsonObject.Add('referenceList', jsonarr);
                JsonObject.WriteTo(JsonData);


                //  Message(JsonData);
                apisetup.Get();
                apiurl := apisetup.CancellationAPIUrl;
                responsemsg := CallServiceStatusReviewCart(apiurl, HTTPRequestTypeEnum::post, jsondata);
                //  IF not responsemsg.IsSuccessStatusCode then

                //    end;
                POSTransaction.batchNumber := '';
                POSTransaction.txnId := '';
                POSTransaction.PromoTxnId := '';

            end;
        POSTransaction."Review Cart done" := false;
        POSTransaction."Cart Offer ID" := '';
        POSTransaction.Modify();

        POSTRans1.Reset();
        POSTRans1.SetRange("Receipt No.", POSTransaction."Receipt No.");
        IF POSTRans1.FindSet() then begin
            POSTRans1.ModifyAll("Cart Offer ID", '');
            POSTRans1.ModifyAll(PromoTxnId, '');

        end;
    end;


    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Transaction Events", 'OnVoidTransaction', '', false, false)]
    local procedure OnVoidTransaction(var POSTrans: Record "LSC POS Transaction"; var POSTransLine: Record "LSC POS Trans. Line")
    var
        posline: Record "LSC POS Trans. Line";

    begin
        posline.Reset();
        posline.SetRange("Receipt No.", POSTrans."Receipt No.");
        posline.SetRange("Entry Status", posline."Entry Status"::" ");
        IF posline.FindFirst() then begin
            POSTrans.txnId := posline.txnId;
            POSTrans.batchNumber := posline.batchNumber;
            POSTrans.PromoTxnId := posline.PromoTxnId;
            POSTrans.redemptionValue := posline.redemptionValue;
            POSTrans.Modify();
        end;
    end;




    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Transaction Events", 'OnAfterVoidTransaction', '', false, false)]
    local procedure OnAfterVoidTransaction(var POSTransaction: Record "LSC POS Transaction")
    var
        POSCTRL: Codeunit "LSC POS Control Interface";
        LSCPOSMenuLine: Record "LSC POS Menu Line";
        LSCPOSMenuLine1: Record "LSC POS Menu Line";
        LSCPOSMenuLine2: Record "LSC POS Menu Line";
        i: Integer;
        apiurl: Text;
        jsondata: Text;
        PaymentObject: JsonObject;
        JsonObject: JsonObject;
        responsemsg: HttpResponseMessage;
        JsonTkn: JsonToken;
        JsonTkn1: JsonToken;
        JsonObj: JsonObject;
        jsonarr: JsonArray;
        postrans: Record "LSC POS Trans. Line";

    begin

        LSCPOSMenuLine.Reset();
        LSCPOSMenuLine.SetRange("Menu ID", '#APPCUSTOMER');
        IF LSCPOSMenuLine.FindFirst() then
            LSCPOSMenuLine.DeleteAll();


        LSCPOSMenuLine.Init();
        LSCPOSMenuLine.Validate("Profile ID", '##DEFAULT');
        LSCPOSMenuLine.Validate("Menu ID", '#APPCUSTOMER');
        LSCPOSMenuLine.Validate("Key No.", 1);
        LSCPOSMenuLine.Validate(RowSpan, 2);
        LSCPOSMenuLine.Description := 'Customer Information';
        LSCPOSMenuLine.Insert();

        LSCPOSMenuLine.Init();
        LSCPOSMenuLine.Validate("Profile ID", '##DEFAULT');
        LSCPOSMenuLine.Validate("Menu ID", '#APPCUSTOMER');
        LSCPOSMenuLine.Validate("Key No.", 2);
        LSCPOSMenuLine.Description := 'Customer Level';
        LSCPOSMenuLine.Insert();

        LSCPOSMenuLine.Init();
        LSCPOSMenuLine.Validate("Profile ID", '##DEFAULT');
        LSCPOSMenuLine.Validate("Menu ID", '#APPCUSTOMER');
        LSCPOSMenuLine.Validate("Key No.", 3);
        LSCPOSMenuLine.Description := 'Wave-Coins';
        LSCPOSMenuLine.Insert();
        LSCPOSMenuLine.Init();
        LSCPOSMenuLine.Validate("Profile ID", '##DEFAULT');
        LSCPOSMenuLine.Validate("Menu ID", '#APPCUSTOMER');
        LSCPOSMenuLine.Validate("Key No.", 5);
        LSCPOSMenuLine.Description := 'Promo Wallet';
        LSCPOSMenuLine.Insert();
        LSCPOSMenuLine.Init();
        LSCPOSMenuLine.Validate("Profile ID", '##DEFAULT');
        LSCPOSMenuLine.Validate("Menu ID", '#APPCUSTOMER');
        LSCPOSMenuLine.Validate("Key No.", 6);
        LSCPOSMenuLine.Description := 'Main Wallet';
        LSCPOSMenuLine.Insert();


        LSCPOSMenuLine.Reset();
        LSCPOSMenuLine.SetRange("Menu ID", '#FVRTS');
        IF LSCPOSMenuLine.FindFirst() then
            LSCPOSMenuLine.DeleteAll();

        For i := 1 to 6 do begin
            LSCPOSMenuLine.Reset();
            LSCPOSMenuLine.Init();
            LSCPOSMenuLine.Validate("Profile ID", '##DEFAULT');
            LSCPOSMenuLine.Validate("Menu ID", '#FVRTS');
            LSCPOSMenuLine.Validate("Key No.", i);
            LSCPOSMenuLine.Description := '';
            LSCPOSMenuLine.Insert();
        end;

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

        LSCPOSMenuLine2.Reset();
        LSCPOSMenuLine2.SetRange("Menu ID", '#LOYALTYDISC');
        IF LSCPOSMenuLine2.FindSet() then
            LSCPOSMenuLine2.DeleteAll();


        For i := 1 to 27 do begin
            LSCPOSMenuLine.Reset();
            LSCPOSMenuLine.Init();
            LSCPOSMenuLine.Validate("Profile ID", '##DEFAULT');
            LSCPOSMenuLine.Validate("Menu ID", '#LOYALTYDISC');
            LSCPOSMenuLine.Validate("Key No.", i);
            LSCPOSMenuLine.Description := '';
            LSCPOSMenuLine.Insert();
        end;
        LSCPOSMenuLine2.Reset();
        LSCPOSMenuLine2.SetRange("Menu ID", '#CARTDISC');
        IF LSCPOSMenuLine2.FindSet() then
            LSCPOSMenuLine2.DeleteAll();
        For i := 1 to 7 do begin
            LSCPOSMenuLine.Reset();
            LSCPOSMenuLine.Init();
            LSCPOSMenuLine.Validate("Profile ID", '##DEFAULT');
            LSCPOSMenuLine.Validate("Menu ID", '#CARTDISC');
            LSCPOSMenuLine.Validate("Key No.", i);
            LSCPOSMenuLine.Description := '';
            LSCPOSMenuLine.Insert();
        end;


        LSCPOSMenuLine2.Reset();
        LSCPOSMenuLine2.SetRange("Menu ID", '#PRODDISC');
        IF LSCPOSMenuLine2.FindSet() then
            LSCPOSMenuLine2.DeleteAll();

        For i := 1 to 27 do begin
            LSCPOSMenuLine.Reset();
            LSCPOSMenuLine.Init();
            LSCPOSMenuLine.Validate("Profile ID", '##DEFAULT');
            LSCPOSMenuLine.Validate("Menu ID", '#PRODDISC');
            LSCPOSMenuLine.Validate("Key No.", i);
            LSCPOSMenuLine.Description := '';
            LSCPOSMenuLine.Insert();
        end;

        POSCTRL.RefreshMenu('##DEFAULT', '#PRODDISC');
        POSCTRL.RefreshMenu('##DEFAULT', '#CARTDISC');
        POSCTRL.RefreshMenu('##DEFAULT', '#LOYALTYDISC');
        POSCTRL.RefreshMenu('##DEFAULT', '#APPCUSTOMER');
        POSCTRL.RefreshMenu('#HOSP-QS', 'CONTROL');


        IF (POSTransaction.txnId <> '') OR (POSTransaction.PromoTxnId <> '') then begin
            Clear(JsonObject);


            JsonObject.Add('userId', POSTransaction.CustAppUserId);
            Clear(jsonarr);
            IF POSTransaction.PromoTxnId <> '' then begin
                paymentObject.Add('txnId', POSTransaction.PromoTxnId);
                paymentObject.Add('batchNumber', POSTransaction.batchNumber);
                jsonarr.Add(paymentObject);

            end;

            //  Clear(jsonarr);
            Clear(PaymentObject);
            IF POSTransaction.txnId <> '' then begin
                paymentObject.Add('txnId', POSTransaction.txnId);
                paymentObject.Add('batchNumber', POSTransaction.batchNumber);
                jsonarr.Add(paymentObject);
                //   JsonObject.Add('referenceList', jsonarr);
            end;
            JsonObject.Add('referenceList', jsonarr);
            JsonObject.WriteTo(JsonData);


            //  Message(JsonData);
            apisetup.Get();

            apiurl := apisetup.CancellationAPIUrl;
            responsemsg := CallServiceStatusReviewCart(apiurl, HTTPRequestTypeEnum::post, jsondata);
            //  IF not responsemsg.IsSuccessStatusCode then

            //    end;

        end;

    end;


    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Transaction Events", 'OnAfterPostPOSTransaction', '', false, false)]
    local procedure CheckOutAPI(var POSTransaction: Record "LSC POS Transaction")
    var
        transsalesentry: Record "LSC Trans. Sales Entry";
        postransline: Record "LSC POS Trans. Line";
        TransPaymentEntry: Record "LSC Trans. Payment Entry";
        TransHdr: Record "LSC Transaction Header";
        JArray: JsonArray;
        cartObject: JsonObject;
        JsonObject: JsonObject;
        productsObject: JsonObject;
        JsonData: Text;
        TaxJsonObject: JsonObject;
        TaxJsonTkn: JsonToken;
        PaymentJsonObject: JsonObject;
        PaymentJsonTkn: JsonToken;
        paymentTender: JsonObject;
        ReqUrl: Text;
        response: Boolean;
        wavecoin: Decimal;
        posdataentry: Record "LSC POS Data Entry";
        KOTHeader: Record "LSC KOT Header";
        voidtrans: Record "LSC POS Voided Transaction";
        responsemsg: HttpResponseMessage;
    begin

        //    IF POSTransaction."Cust App Order" then begin
        voidtrans.Reset();
        voidtrans.SetRange("Receipt No.", POSTransaction."Receipt No.");
        IF not voidtrans.FindFirst() then begin
            IF (POSTransaction."Review Cart done") OR ((POSTransaction."Sale Is Return Sale") AND (POSTransaction."Cust App Order")) then begin
                //IF ((POSTransaction."Review Cart done") AND (POSTransaction."Sales Type" = 'POS')) OR ((POSTransaction."Sale Is Return Sale") AND (POSTransaction."Cust App Order") AND (POSTransaction."Sales Type" = 'POS')) then begin //AlleRSN 
                TransHdr.Reset();
                TransHdr.SetRange("Receipt No.", POSTransaction."Receipt No.");
                IF TransHdr.FindFirst() then;


                Clear(cartObject);
                Clear(JsonObject);

                POSTransaction.CalcFields("Line TAX Amount");
                POSTransaction.CalcFields("Net Amount");
                // TransHdr.CalcFields("LSCIN GST Amount");
                // TransHdr.CalcFields("Net Amount");

                Clear(wavecoin);
                IF TransHdr.WaveCoinApplied then begin
                    // POSTransaction.CalcFields("Total Discount");
                    wavecoin := TransHdr."Total Discount";
                end;

                posdataentry.Reset();
                posdataentry.SetRange("Created by Receipt No.", TransHdr."Receipt No.");
                IF posdataentry.FindFirst() then;

                KOTHeader.Reset();
                KOTHeader.SetRange("Receipt No.", TransHdr."Receipt No.");
                IF KOTHeader.FindFirst() then;

                IF TransHdr."Sale Is Return Sale" then
                    JsonObject.Add('invoiceType', 'Refund')
                else
                    JsonObject.Add('invoiceType', TransHdr."Transaction Type");
                JsonObject.Add('channelType', 'APP_SCAN');
                JsonObject.Add('posStoreId', TransHdr."Store No.");
                JsonObject.Add('posTerminalId', TransHdr."POS Terminal No.");
                JsonObject.Add('posTransactionRefNo', TransHdr."Receipt No.");
                JsonObject.Add('mobileNo', '');
                JsonObject.Add('transactionDate', TransHdr.Date);
                JsonObject.Add('tableNo', TransHdr."Table No.");
                JsonObject.Add('orderNumber', KOTHeader."KOT No.");
                JsonObject.Add('orderDate', TransHdr.Date);
                JsonObject.Add('staffId', TransHdr."Staff ID");
                JsonObject.Add('totalTaxes', TransHdr."LSCIN GST Amount");
                JsonObject.Add('totalCharges', POSTransaction."Service Charge");
                JsonObject.Add('invoiceAmount', TransHdr."Net Amount");
                JsonObject.Add('originalReceiptNo', TransHdr."Retrieved from Receipt No.");
                JsonObject.Add('creditNoteNo', posdataentry."Entry Code");
                JsonObject.Add('creditNoteAmount', posdataentry.Amount);
                JsonObject.Add('salesReturnReason', '');
                JsonObject.Add('billDiscount', TransHdr."Discount Amount");
                JsonObject.Add('waveCoinDiscount', wavecoin);
                JsonObject.Add('voucherCode', 'null');
                JsonObject.Add('roundOffDiff', TransHdr.Rounded);


                transsalesentry.Reset();
                transsalesentry.SetRange("Receipt No.", TransHdr."Receipt No.");
                IF transsalesentry.FindFirst() then
                    Clear(JArray);
                repeat
                    Clear(productsObject);
                    productsObject.Add('ItemType', transsalesentry."Line Type");
                    productsObject.Add('ItemSeqNo', transsalesentry."Line No.");
                    productsObject.Add('posItemId', transsalesentry."Item No.");
                    productsObject.Add('unitPrice', transsalesentry.Price);
                    productsObject.Add('quantity', transsalesentry.Quantity);
                    productsObject.Add('discountValue', transsalesentry."Discount Amount");
                    productsObject.Add('totalItemPrice', transsalesentry."Net Price");
                    productsObject.Add('subscriptionPlanId', transsalesentry."User Plan Id");
                    productsObject.Add('ConsumerOfferId', transsalesentry."Offer ID");
                    productsObject.Add('HSN_SAC', transsalesentry."LSCIN HSN/SAC Code");
                    JArray.Add(productsObject);
                //Clear(TaxJsonObject);
                until transsalesentry.Next() = 0;

                JsonObject.Add('items', JArray);
                Clear(JArray);
                productsObject.Add('taxes', JArray);
                productsObject.Add('charges', JArray);

                //        Clear(PaymentJsonObject);

                TransPaymentEntry.Reset();
                TransPaymentEntry.SetRange("Receipt No.", TransHdr."Receipt No.");
                IF TransPaymentEntry.FindFirst() then
                    Clear(JArray);
                repeat
                    Clear(paymentTender);
                    paymentTender.Add('paymentSeqNo', TransPaymentEntry."Line No.");
                    paymentTender.Add('paymentType', TransPaymentEntry."Tender Type");
                    paymentTender.Add('tenderedAmount', TransPaymentEntry."Amount Tendered");
                    paymentTender.Add('paymentRefNo', TransPaymentEntry."Transaction No.");
                    JArray.Add(paymentTender);

                until TransPaymentEntry.Next() = 0;


                PaymentJsonObject.Add('paymentTenderDetails', JArray);
                //  Clear(JArray);
                JsonObject.Add('paymentDetails', PaymentJsonObject);
                JsonObject.WriteTo(JsonData);
                //  Message(JsonData);
                apisetup.Get();
                ReqUrl := apisetup.CheckOutAPIUrl;
                response := CallServiceStatus(ReqUrl, HTTPRequestTypeEnum::post, JsonData);


                IF response = true then begin
                    transsalesentry."Check out done" := true;
                    transsalesentry.Modify();
                    Message('Checkout successfully done');
                end;
            end else
                //Alle-AS-06102023
                IF POSTransaction."Is wallet loaded" then begin
                    Message('Wallet is already loaded.Please continue');
                    // exit;
                end
                else begin
                    TransHdr.Reset();
                    TransHdr.SetRange("Receipt No.", POSTransaction."Receipt No.");
                    IF TransHdr.FindFirst() then;
                    //   IF POSTransaction."Is wallet Error" then begin
                    transsalesentry.Reset();
                    transsalesentry.SetRange("Receipt No.", TransHdr."Receipt No.");
                    //POstransLine.SetRange("Entry Status", POstransLine."Entry Status"::" "); //Alle-Commented
                    transsalesentry.SetRange("Item No.", Format(1));
                    IF transsalesentry.FindFirst() then begin
                        //   IF not POstransLine."Is wallet Error" then begin
                        Clear(JsonObject);

                        JsonObject.Add('userId', TransHdr.CustAppUserId);
                        JsonObject.Add('amount', abs(transsalesentry."Net Amount"));
                        JsonObject.Add('posStoreId', transsalesentry."Store No.");

                        Jsonobject.WriteTo(jsondata);

                        apisetup.Get();
                        // Message(jsondata);

                        ReqUrl := apisetup.WalletLoadAPIUrl;
                        if not POSTransaction."Is wallet loaded" then //ALLE-AS-06102023
                            responsemsg := CallServiceStatusReviewCart(ReqUrl, HTTPRequestTypeEnum::post, JsonData);

                        IF responsemsg.IsSuccessStatusCode then begin
                            //POstransLine."Is wallet Error" := false; //Alle-Commented
                            //POstransLine.Modify(true);//Alle-Commented
                            POSTransaction."Is wallet Error" := false;
                            POSTransaction."Is wallet loaded" := true;
                            //POSTransaction.Modify(true);
                            Message('Wallet is loaded succesfully');
                        end;
                        IF not responsemsg.IsSuccessStatusCode then begin
                            //POstransLine."Is wallet Error" := true;//Alle-Commented
                            POSTransaction."Is wallet loaded" := false;
                            //POstransLine.Modify(true); //Alle-Commented
                            POSTransaction."Is wallet Error" := true;
                            //POSTransaction.Modify(true);
                            Error('Unable to proceed with the transaction due to server error. Please void the transaction and start again.');
                        end;
                    end;
                end;
            //Alle-AS-06102023
        end;
    end;


    procedure CallServiceStatus(RequestUrl: Text; RequestType: Enum HTTPRequestTypeEnum; Body: Text): Boolean
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

        ResponseMessage.Content().ReadAs(ResponseText);
        // Message(ResponseText);
        IF ResponseMessage.IsSuccessStatusCode then
            exit(true)
        else
            exit(false);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Transaction Events", 'OnAfterInsertItemLine', '', false, false)]
    local procedure OnAfterInsertItemLine(var POSTransLine: Record "LSC POS Trans. Line"; var POSTransaction: Record "LSC POS Transaction")
    var
        custappoffer: Record Cust_App_Offers;
        lscposmenuline: Record "LSC POS Menu Line";
        LSCPOSMenuLine2: Record "LSC POS Menu Line";
        LSCPOSMenuLine3: Record "LSC POS Menu Line";
        LSCPOSMenuLine4: Record "LSC POS Menu Line";
        LSCPOSMenuLine5: Record "LSC POS Menu Line";
        LSCPOSMenuLine1: Record "LSC POS Menu Line";
        POSCTRL: Codeunit "LSC POS Control Interface";
        i: Integer;
        posline: Record "LSC POS Trans. Line";
        posline1: Record "LSC POS Trans. Line";
        count: Integer;


    begin
        LSCPOSMenuLine2.Reset();
        LSCPOSMenuLine2.SetRange("Menu ID", '#LOYALTYDISC');
        LSCPOSMenuLine2.SetRange(Description, '');
        IF LSCPOSMenuLine2.FindSet() then
            LSCPOSMenuLine2.DeleteAll();


        LSCPOSMenuLine2.Reset();
        LSCPOSMenuLine2.SetRange("Menu ID", '#CARTDISC');
        //  LSCPOSMenuLine2.SetRange(Description, '');
        IF LSCPOSMenuLine2.FindSet() then
            LSCPOSMenuLine2.DeleteAll();

        LSCPOSMenuLine2.Reset();
        LSCPOSMenuLine2.SetRange("Menu ID", '#PRODDISC');
        LSCPOSMenuLine2.SetRange(Description, '');
        IF LSCPOSMenuLine2.FindSet() then
            LSCPOSMenuLine2.DeleteAll();



        POSCTRL.RefreshMenu('##DEFAULT', '#PRODDISC');
        POSCTRL.RefreshMenu('##DEFAULT', '#CARTDISC');
        POSCTRL.RefreshMenu('##DEFAULT', '#LOYALTYDISC');

        lscposmenuline1.Reset();
        lscposmenuline1.SetRange("Menu ID", '#APPCUSTOMER');
        IF LSCPOSMenuLine1.FindFirst() then;



        custappoffer.Reset();
        custappoffer.SetRange(posItemId, POSTransLine.Number);
        custappoffer.SetRange(UserId, LSCPOSMenuLine1.CustAppUserId);
        //   custappoffer.SetRange("Offer Type", custappoffer."Offer Type"::loyaltyDiscounts);
        IF custappoffer.FindFirst() then
            repeat
                IF custappoffer."Offer Type" = custappoffer."Offer Type"::loyaltyDiscounts then begin
                    LSCPOSMenuLine5.Reset();
                    LSCPOSMenuLine5.SetRange("Profile ID", '##DEFAULT');
                    LSCPOSMenuLine5.SetRange("Menu ID", '#LOYALTYDISC');
                    LSCPOSMenuLine5.SetRange(Description, custappoffer."Discount Id" + '-' + custappoffer.Code);
                    IF not LSCPOSMenuLine5.FindFirst() then begin
                        lscposmenuline.Reset();
                        lscposmenuline.Init();
                        lscposmenuline.Validate("Profile ID", '##DEFAULT');
                        lscposmenuline.Validate("Menu ID", '#LOYALTYDISC');

                        LSCPOSMenuLine2.Reset();
                        LSCPOSMenuLine2.SetRange("Menu ID", '#LOYALTYDISC');
                        IF LSCPOSMenuLine2.FindLast() then
                            lscposmenuline.Validate("Key No.", LSCPOSMenuLine2."Key No." + 1)
                        else
                            lscposmenuline.Validate("Key No.", 1);

                        // lscposmenuline.Validate("Key No.", LSCPOSMenuLine2."Key No.");
                        lscposmenuline.Validate(Description, custappoffer."Discount Id" + '-' + custappoffer.Code);
                        lscposmenuline.Validate(Command, 'RUNOBJ');
                        lscposmenuline.Validate(Parameter, 'APPLYDISC');
                        lscposmenuline.Insert(true);
                    end;
                end;
            until custappoffer.Next() = 0;
        //  end;
        Clear(lscposmenuline);
        Clear(LSCPOSMenuLine2);
        Clear(LSCPOSMenuLine3);
        Clear(LSCPOSMenuLine4);
        i := 1;


        custappoffer.Reset();
        custappoffer.SetRange(UserId, LSCPOSMenuLine1.CustAppUserId);
        custappoffer.SetRange(posItemId, POSTransLine.Number);
        custappoffer.SetRange("Offer Type", custappoffer."Offer Type"::productDiscounts);
        IF custappoffer.FindFirst() then
            repeat
                LSCPOSMenuLine5.Reset();
                LSCPOSMenuLine5.SetRange("Profile ID", '##DEFAULT');
                LSCPOSMenuLine5.SetRange("Menu ID", '#PRODDISC');
                LSCPOSMenuLine5.SetRange(Description, custappoffer."Discount Id" + '-' + custappoffer.Code);
                IF not LSCPOSMenuLine5.FindFirst() then begin
                    lscposmenuline.Reset();
                    lscposmenuline.Init();
                    lscposmenuline.Validate("Profile ID", '##DEFAULT');
                    lscposmenuline.Validate("Menu ID", '#PRODDISC');

                    LSCPOSMenuLine2.Reset();
                    LSCPOSMenuLine2.SetRange("Menu ID", '#PRODDISC');
                    IF LSCPOSMenuLine2.FindLast() then
                        lscposmenuline.Validate("Key No.", LSCPOSMenuLine2."Key No." + 1)
                    else
                        lscposmenuline.Validate("Key No.", 1);

                    lscposmenuline.Validate(Description, custappoffer."Discount Id" + '-' + custappoffer.Code);
                    lscposmenuline.Validate(Command, 'RUNOBJ');
                    lscposmenuline.Validate(Parameter, 'APPLYDISC');
                    lscposmenuline.Insert(true);

                end;
            until custappoffer.Next() = 0;


        custappoffer.Reset();
        //        custappoffer.SetRange(posItemId, POSTransLine.Number);
        custappoffer.SetRange(UserId, LSCPOSMenuLine1.CustAppUserId);
        custappoffer.SetRange("Offer Type", custappoffer."Offer Type"::orderDiscounts);
        IF custappoffer.FindFirst() then
            repeat
                lscposmenuline.Reset();
                lscposmenuline.Init();
                lscposmenuline.Validate("Profile ID", '##DEFAULT');
                lscposmenuline.Validate("Menu ID", '#CARTDISC');

                LSCPOSMenuLine3.Reset();
                LSCPOSMenuLine3.SetRange("Menu ID", '#CARTDISC');
                IF LSCPOSMenuLine3.FindLast() then
                    lscposmenuline.Validate("Key No.", LSCPOSMenuLine3."Key No." + 1)
                else
                    lscposmenuline.Validate("Key No.", 1);

                // lscposmenuline.Validate("Key No.", LSCPOSMenuLine2."Key No." + 1);

                lscposmenuline.Validate(Description, custappoffer."Discount Id" + '-' + custappoffer.Code);
                lscposmenuline.Validate(Command, 'RUNOBJ');
                lscposmenuline.Validate(Parameter, 'APPLYDISC');
                lscposmenuline.Insert(true);

            until custappoffer.next = 0;
        custappoffer.Reset();
        custappoffer.SetRange(posItemId, '');
        custappoffer.SetRange(UserId, LSCPOSMenuLine1.CustAppUserId);
        custappoffer.SetRange("Offer Type", custappoffer."Offer Type"::loyaltyDiscounts);
        IF custappoffer.FindFirst() then
            repeat
                LSCPOSMenuLine5.Reset();
                LSCPOSMenuLine5.SetRange("Profile ID", '##DEFAULT');
                LSCPOSMenuLine5.SetRange("Menu ID", '#LOYALTYDISC');
                LSCPOSMenuLine5.SetRange(Description, custappoffer."Discount Id" + '-' + custappoffer.Code);
                IF not LSCPOSMenuLine5.FindFirst() then begin
                    lscposmenuline.Reset();
                    lscposmenuline.Init();
                    lscposmenuline.Validate("Profile ID", '##DEFAULT');
                    lscposmenuline.Validate("Menu ID", '#LOYALTYDISC');

                    LSCPOSMenuLine2.Reset();
                    LSCPOSMenuLine2.SetRange("Menu ID", '#LOYALTYDISC');
                    IF LSCPOSMenuLine2.FindLast() then
                        lscposmenuline.Validate("Key No.", LSCPOSMenuLine2."Key No." + 1)
                    else
                        lscposmenuline.Validate("Key No.", 1);

                    // lscposmenuline.Validate("Key No.", LSCPOSMenuLine2."Key No.");
                    lscposmenuline.Validate(Description, custappoffer."Discount Id" + '-' + custappoffer.Code);
                    lscposmenuline.Validate(Command, 'RUNOBJ');
                    lscposmenuline.Validate(Parameter, 'APPLYDISC');
                    lscposmenuline.Insert(true);
                end;
            until custappoffer.Next() = 0;



        POSCTRL.RefreshMenu('##DEFAULT', '#TWCOFFER');
        POSCTRL.RefreshMenu('##DEFAULT', '#PRODDISC');
        POSCTRL.RefreshMenu('##DEFAULT', '#CARTDISC');
        POSCTRL.RefreshMenu('##DEFAULT', '#LOYALTYDISC');


        /*
                posline.Reset();
                posline.SetRange("Receipt No.", POSTransLine."Receipt No.");
                posline.SetRange("Line No.", POSTransLine."Line No.");
                IF posline.FindFirst() then;
                IF POSTransaction.IsSubscriptionTransaction then begin

                    posline."Subscription ID" := POSTransaction."Subscription ID";
                    posline."Subscription Qty" := POSTransaction."Subscription Qty";
                    // POSTransLine."Offer ID" := POSTransaction."Offer ID";
                    posline."User Plan Id" := POSTransaction."User Plan Id";
                end;
                IF posline."User Plan Id" <> '' then begin
                    posline.Description := posline.Description + '-' + posline."User Plan Id";

                    posline.Modify();

                end;
        */
        POSTransaction."Cust App Order" := LSCPOSMenuLine1."Cust App Order";
        //POSTransaction.CustAppUserId := LSCPOSMenuLine1.CustAppUserId;  //AlleRSN 301023 commented
        // POSTransaction."Wallet Balance" := LSCPOSMenuLine1."Wallet Balance";//AJ_Alle_31102023 Cmnted
        //POSTransaction."Wave Coin Balance" := LSCPOSMenuLine1."Wave Coin Balance";//AJ_Alle_31102023 cmnted
        POSTransaction."Promo Balance" := LSCPOSMenuLine1."Promo Balance";
        POSTransaction.IsSubscriptionTransaction := false;
        POSTransaction.Modify(true);





    end;


    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Transaction Events", 'OnBeforeTotalExecuted', '', false, false)]
    local procedure OnBeforeTotalExecuted(var POSTransaction: Record "LSC POS Transaction")
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
        //wavecoin: Integer; Alle-comment
        wavecoin: Decimal; //ALLE-AS-09102023
        promo: Decimal;
        TransLine1: Record "LSC POS Trans. Line";
    begin
        //   IF not POSTransaction."Review Cart done" then begin
        IF (POSTransaction."Cust App Order") AND (POSTransaction."Sales Type" = 'POS') then begin //AlleRSN 301123
            IF not POSTransaction."Sale Is Return Sale" then begin
                TL.Reset();
                TL.SetRange("Receipt No.", POSTransaction."Receipt No.");
                TL.SetRange("Cust App Order", true);
                IF TL.FindFirst() then begin
                    POSTransaction."Cust App Order" := true;
                    POSTransaction.Modify(true);
                end;
                LSCPOSMenuLine1.Reset();
                LSCPOSMenuLine1.SetRange("Menu ID", '#APPCUSTOMER');
                // LSCPOSMenuLine1.SetRange("Key No.", 1);
                IF LSCPOSMenuLine1.FindLast() then begin

                    Clear(cartObject);
                    Clear(JsonObject);
                    Clear(wavecoin);
                    TransLine1.Reset();
                    TransLine1.SetRange("Receipt No.", POSTransaction."Receipt No.");
                    TransLine1.SetRange("Entry Type", TransLine1."Entry Type"::TotalDiscount);
                    TransLine1.SetRange(WaveCoinApplied, true);
                    IF TransLine1.FindFirst() then;
                    //  IF POSTransaction.WaveCoinApplied then begin
                    // POSTransaction.CalcFields("Total Discount");
                    wavecoin := ABS(TransLine1.Amount);

                    TransLine1.Reset();
                    TransLine1.SetRange("Receipt No.", POSTransaction."Receipt No.");
                    TransLine1.SetRange("Entry Type", TransLine1."Entry Type"::TotalDiscount);
                    TransLine1.SetFilter(PromoTxnId, '<>%1', '');
                    IF TransLine1.FindFirst() then;

                    promo := abs(TransLine1.redemptionValue);
                    //  end;

                    //IF TH."Cust App Order" then begin
                    POSTransaction.CalcFields("Line TAX Amount");
                    POSTransaction.CalcFields("Total Discount");
                    POSTransaction.CalcFields("Net Amount");
                    POSTransaction.CalcFields("LSCIN GST Amount");
                    POSTransaction.CalcFields("Line TAX Quantity");
                    JsonObject.Add('POSStoreId', POSTransaction."Store No.");
                    JsonObject.Add('POSTerminalId', POSTransaction."POS Terminal No.");
                    JsonObject.Add('POSTransactionRefNo', POSTransaction."Receipt No.");
                    JsonObject.Add('TransactionInitiatedTime', POSTransaction."Trans. Date");
                    //  cartObject.Add('userId', CopyStr(UserId, 17, StrLen(UserId)));


                    JsonObject.Add('TotalQTY', POSTransaction."Line TAX Quantity");
                    JsonObject.Add('TotalCartValue', POSTransaction."Net Amount" + POSTransaction."Total Discount");
                    JsonObject.Add('TotalTaxAMT', POSTransaction."LSCIN GST Amount");

                    TRansLine.Reset();
                    TRansLine.SetRange("Receipt No.", POSTransaction."Receipt No.");
                    TRansLine.SetRange("Entry Status", TRansLine."Entry Status"::" ");
                    TRansLine.SetRange("Entry Type", TRansLine."Entry Type"::Item);
                    TRansLine.Setfilter(Number, '<>%1', '');
                    IF TRansLine.FindFirst() then begin
                        Clear(JArray);
                        repeat
                            Clear(productsObject);
                            IF RecItem.Get(TRansLine.Number) then;
                            productsObject.Add('POSItemId', TRansLine.Number);
                            productsObject.Add('POSLineNo', TRansLine."Line No.");
                            productsObject.Add('qty', TRansLine.Quantity);
                            productsObject.Add('subUserPlanId', TRansLine."User Plan Id");
                            productsObject.Add('prodDiscountId', TRansLine."Offer ID");
                            productsObject.Add('POSProductPrice', TRansLine.Price);
                            productsObject.Add('TaxPercentage', TRansLine."LSCIN GST Group Code");
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
                        JsonObject.Add('userId', POSTransaction.CustAppUserId);
                        TRansLine.Reset();
                        TRansLine.SetRange("Receipt No.", POSTransaction."Receipt No.");
                        TRansLine.SetFilter("Cart Offer ID", '<>%1', '');
                        IF TRansLine.FindFirst() then begin
                            cartleveldis := format(TRansLine."Cart Offer ID");

                        end;
                        IF cartleveldis = '' then
                            cartleveldis := '-1';
                        JsonObject.Add('cartLevelDiscount', cartleveldis);
                        JsonObject.Add('waveCoins', Round(wavecoin, 0.01, '<'));//ALLE-AS-09102023
                        JsonObject.Add('promoAmount', promo);
                        cartObject.Add('products', JArray);
                    end;

                    JsonObject.Add('cart', cartObject);

                    JsonObject.WriteTo(JsonData);
                    //  Message(JsonData);

                    apisetup.Get();

                    APIURL := apisetup.ReviewCartAPIUrl;


                    responsemsg := CallServiceStatusReviewCart(APIURL, HTTPRequestTypeEnum::post, JsonData);

                    IF responsemsg.IsSuccessStatusCode then begin
                        responsemsg.Content().ReadAs(ResponseText);
                        ReadReviewCartResponse(ResponseText, POSTransaction);
                        POSTransaction."Review Cart done" := true;
                        POSTransaction.Modify();
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
                                Message(ResponseText);
                            end;

                        end;
                    end;
                end;
            end;
        end;
        //ALLE_NICK_011223_START
        if (POSTransaction."Sales Type" <> 'POS') And (POSTransaction."Cust App Order" = true) then
            POSTransaction."Cust App Order" := false;
        POSTransaction.Modify();
        //ALLE_NICK_011223_END
    end;
    //   end;

    procedure CallServiceStatusReviewCart(RequestUrl: Text; RequestType: Enum HTTPRequestTypeEnum; Body: Text): HttpResponseMessage
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
            RequestType::Get:
                begin
                    // RequestContent.GetHeaders(contentHeaders);
                    //contentHeaders.Clear();

                    RequestMessage.GetHeaders(contentHeaders);
                    //contentHeaders.Remove('Content-Type');
                    //contentHeaders.Add('Content-Type', 'application/json');
                    contentHeaders.Add('X-API-VERSION', Format(apisetup."X-API-VERSION"));
                    contentHeaders.Add('X-API-KEY', apisetup."X-API-KEY");
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
                    contentHeaders.Add('X-API-VERSION', Format(apisetup."X-API-VERSION"));
                    contentHeaders.Add('X-API-KEY', apisetup."X-API-KEY");
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
        postran: Codeunit "LSC POS Transaction";
        totdisc: Decimal;
        lineno: Integer;
        postras: Record "LSC POS Transaction";
        postranslineCU: Codeunit "LSC POS Trans. Lines";
    begin

        CRLF := TypeHelper.CRLFSeparator();

        if JsonTkn.ReadFrom(RespText) then begin
            if JsonTkn.IsObject then begin
                JsonObj := JsonTkn.AsObject();

                if JsonObj.Get('POSTransactionRefNo', JsonTkn) then begin
                    ReceiptNo := JsonTkn.AsValue().AsCode();
                end;
                if JsonObj.Get('totalDiscountAmount', JsonTkn) then begin
                    totdisc := JsonTkn.AsValue().AsDecimal();
                end;

                IF JsonObj.Get('cartProducts', CartProd) then;
                If CartProd.IsArray then begin
                    JsonArr := CartProd.AsArray();
                    for iterator := 0 to JsonArr.Count - 1 do begin
                        JsonArr.Get(iterator, CartProd);
                        if CartProd.IsObject then begin
                            cartprodObj := CartProd.AsObject();
                            Itemno := json_Methods.GetJsonToken(cartprodObj, 'POSItemId').AsValue().AsText();
                            lineno := json_Methods.GetJsonToken(cartprodObj, 'POSLineno').AsValue().AsInteger();
                            subprice := json_Methods.GetJsonToken(cartprodObj, 'perUnitSubscriptionPrice').AsValue().AsDecimal();
                            disc := json_Methods.GetJsonToken(cartprodObj, 'disAmount').AsValue().AsDecimal();
                            Jsnval := json_Methods.GetJsonToken(cartprodObj, 'subscriptionPlanId').AsValue();
                            Clear(SubID);
                            IF not Jsnval.IsNull then
                                SubID := json_Methods.GetJsonToken(cartprodObj, 'subscriptionPlanId').AsValue().AsText();
                            //   OfferID := json_Methods.GetJsonToken(cartprodObj, 'POSItemId').AsValue().AsText();
                            postras.Reset();
                            postras.SetRange("Receipt No.", ReceiptNo);
                            postras.SetFilter("Cart Offer ID", '<>%1', '');
                            IF postras.FindFirst() then begin
                                //    PosTransLine.CalcTotalDiscAmt(true, totdisc, true);
                                //   Ashish  postran.TotDiscAmPressed(Format(totdisc), false, false);
                            end
                            else begin
                                PosTransLine.Reset();
                                PosTransLine.SetRange("Receipt No.", ReceiptNo);
                                PosTransLine.SetRange(Number, Itemno);
                                PosTransLine.SetRange("Line No.", lineno);
                                IF PosTransLine.FindFirst() then begin
                                    //   IF subprice <> 0 then
                                    //     PosTransLine.Validate(Price, subprice);
                                    IF disc <> 0 then begin
                                        PosTransLine.validate("Discount Amount", disc);
                                        IF PosTransLine."Net Price" <> 0 then
                                            PosTransLine."Discount %" := Round((disc / PosTransLine."Net Price") * 100, 0.01, '=');
                                        PosTransLine.Validate("Discount %");
                                        //postran.DiscAmPressedEx(PosTransLine."Discount %");


                                        //     IF PosTransLine."Cart Offer ID" <> '' then
                                        //       PosTransLine.CalcTotalDiscAmt(true, totdisc, true)
                                        // else
                                        postranslineCU.SetCurrentLine(PosTransLine);
                                        postran.DiscAmPressedEx(PosTransLine."Discount %");


                                    end;
                                    IF SubID <> '' then begin
                                        //  PosTransLine.Validate("LSCIN Price Inclusive of Tax", true);
                                        PosTransLine.Validate("User Plan Id", SubID);
                                        PosTransLine.Validate("LSCIN Unit Price Incl. of Tax", subprice);
                                        //  PosTransLine.Validate("Net Amount", subprice);
                                        PosTransLine.Validate("Net Price", subprice);

                                        PosTransLine.Modify();
                                    end;
                                end;

                            end;

                            // TH.
                        end;
                    end;
                end;
            end;
            Message('Validate Member done Successfully');


        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSCIN POS Sales Validations", 'OBLSCINOnAfterInsertItemLine', '', false, false)]
    local procedure OBLSCINOnAfterInsertItemLine(var IsHandled: Boolean; var POSTransaction: Record "LSC POS Transaction"; var POSTransLine: Record "LSC POS Trans. Line")
    var
        posline: Record "LSC POS Trans. Line";
    begin
        posline.Reset();
        posline.SetRange("Receipt No.", POSTransLine."Receipt No.");
        posline.SetRange("Line No.", POSTransLine."Line No.");
        IF posline.FindFirst() then;
        IF POSTransaction.IsSubscriptionTransaction then begin

            posline."Subscription ID" := POSTransaction."Subscription ID";
            posline."Subscription Qty" := POSTransaction."Subscription Qty";
            // POSTransLine."Offer ID" := POSTransaction."Offer ID";
            posline."User Plan Id" := POSTransaction."User Plan Id";
        end;
        IF posline."User Plan Id" <> '' then begin
            posline.Description := posline.Description + '-' + posline."User Plan Id";

            posline.Modify();

        end;

        IF posline."User Plan Id" <> '' then
            IsHandled := true;
    end;


    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSCIN Calculate Tax", 'OnBeforeCalculateTaxOnSelectedLine', '', false, false)]
    local procedure OnBeforeCalculateTaxOnSelectedLine(var POSTransLine: Record "LSC POS Trans. Line"; var Ishandled: Boolean)
    var
        TL: Record "LSC POS Trans. Line";
    begin
        if POSTransLine."User Plan Id" <> '' then
            Ishandled := true;

    end;

    [EventSubscriber(ObjectType::Page, Page::"TWC Wallet Redemption", 'OnAfterActionEvent', 'Submit', false, false)]
    local procedure OnAfterActionEvent()
    var
        postrans: Codeunit "LSC POS Transaction";
        postransline: Record "LSC POS Trans. Line";
        postransaction: Record "LSC POS Transaction";
        postransaction1: Record "LSC POS Transaction";
        txnid: Code[20];
        promotxnid: Code[20];
        walletredep: Decimal;
        batchid: Code[20];
        tranhdr: Record "LSC Transaction Header";
    begin
        Clear(promotxnid);
        Clear(batchid);
        Clear(txnid);
        Clear(walletredep);
        postransline.Reset();
        postransline.SetRange("Receipt No.", postrans.GetReceiptNo());
        IF postransline.FindFirst() then begin
            txnid := postransline.txnId;
            batchid := postransline.batchNumber;
            walletredep := postransline.redemptionValue;
            promotxnid := postransline.PromoTxnId;
            Postrans.TenderKeyPressedEx('16', Format(postransline.redemptionValue));


            tranhdr.Reset();
            tranhdr.SetRange("Receipt No.", postransline."Receipt No.");
            IF tranhdr.FindFirst() then begin
                tranhdr.txnId := txnId;
                tranhdr.batchNumber := batchid;
                tranhdr.redemptionValue := walletredep;
                tranhdr.PromoTxnId := promotxnid;
                tranhdr.Modify();
            end;

            /*
                        postransaction1.Reset();
                        postransaction1.SetRange("Receipt No.", postrans.GetReceiptNo());
                        IF postransaction1.FindFirst() then begin
                            postransaction1.txnId := txnId;
                            postransaction1.batchNumber := batchid;
                            postransaction1.redemptionValue := walletredep;
                            postransaction1.PromoTxnId := promotxnid;
                            postransaction1.Modify();
                        end;
            */

        end;
    end;

    [EventSubscriber(ObjectType::Page, Page::"Promo Wallet Redemption", 'OnAfterActionEvent', 'Submit', false, false)]
    local procedure OnAfterActionEvent1()
    var
        postrans: Codeunit "LSC POS Transaction";
        postransline: Record "LSC POS Trans. Line";
        postransaction: Record "LSC POS Transaction";
        postransaction1: Record "LSC POS Transaction";
        txnid: Code[20];
        promotxnid: Code[20];
        walletredep: Decimal;
        batchid: Code[20];
        tranhdr: Record "LSC Transaction Header";
    begin
        Clear(promotxnid);
        Clear(batchid);
        Clear(txnid);
        Clear(walletredep);

        postransline.Reset();
        postransline.SetRange("Receipt No.", postrans.GetReceiptNo());
        IF postransline.FindFirst() then begin
            txnid := postransline.txnId;
            batchid := postransline.batchNumber;
            walletredep := postransline.redemptionValue;
            promotxnid := postransline.PromoTxnId;
            //Postrans.TenderKeyPressedEx('16', Format(postransline.redemptionValue));
            IF postransaction.Get(postrans.GetReceiptNo()) then;
            POSTransaction.CalcFields("Gross Amount");

            IF POSTransaction."Gross Amount" = 0 then begin
                postrans.SetPOSState('PAYMENT');
                postrans.TenderKeyPressedEx('1', '0');
            end;


            tranhdr.Reset();
            tranhdr.SetRange("Receipt No.", postransline."Receipt No.");
            IF tranhdr.FindFirst() then begin
                tranhdr.txnId := txnId;
                tranhdr.batchNumber := batchid;
                tranhdr.redemptionValue := walletredep;
                tranhdr.PromoTxnId := promotxnid;
                tranhdr.Modify();
            end;
        end;
    end;



    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Transaction Events", 'OnAfterTenderKeyExecuted', '', false, false)]
    local procedure OnAfterTenderKeyExecuted(var POSTransaction: Record "LSC POS Transaction"; var POSTransLine: Record "LSC POS Trans. Line")
    var
        TL: Record "LSC POS Trans. Line";
    begin
        TL.Reset();
        TL.SetRange("Receipt No.", POSTransaction."Receipt No.");
        IF TL.FindFirst() then;

        POSTransaction.txnId := TL.txnId;
        POSTransaction.PromoTxnId := TL.PromoTxnId;
        POSTransaction.batchNumber := tl.batchNumber;
        POSTransaction.redemptionValue := tl.redemptionValue;


        IF TL.WaveCoinApplied then begin
            POSTransaction.WaveCoinApplied := true;
            POSTransaction."Review Cart done" := true;
            POSTransaction.Modify();
        end;

    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Transaction Events", 'OnAfterTenderKeyPressed', '', false, false)]
    local procedure OnAfterTenderKeyPressed(var CurrInput: Text; var POSTransaction: Record "LSC POS Transaction"; var POSTransLine: Record "LSC POS Trans. Line"; var TenderTypeCode: Code[10])
    // var
    //     respmsg: HttpResponseMessage;
    //     JsonTkn: JsonToken;
    //     JsonTkn1: JsonToken;
    //     JsonObj: JsonObject;
    //     jsonarr: JsonArray;
    //     ErrorObj: JsonObject;
    //     ErrorJkn: JsonToken;
    //     ResponseText: Text;
    //     json_Methods: Codeunit JSON_Methods;
    //     jsnobj1: JsonObject;
    //     postrans1: Record "LSC POS Transaction";
    //     iterator: Integer;
    //     jsonobject: JsonObject;
    //     redepvalue: Decimal;
    //     promotxnid: Text;
    //     batchnumber: Text;
    //     //postransline: Record "LSC POS Trans. Line";

    //     lscposmenuline1: Record "LSC POS Menu Line";
    //     txnid: Text;
    begin
        IF POSTransaction."Is wallet Error" then
            Error('Currently unable to load wallet. Please try after sometime');

        IF POSTransaction."Cust App Order" then
            IF not POSTransaction."Review Cart done" then
                Error('Please void the transaction and start again');

        //AlleRSN 061023 start
        //IF (POSTransaction.Channel = 'ConsumerApp') OR (POSTransaction.Channel = 'Zomato') OR (POSTransaction.Channel = 'Swiggy') then
        if POSTransaction."Sales Type" <> 'POS' then begin
            IF (POSTransaction.Channel = 'ConsumerApp') AND (TenderTypeCode <> '21') then
                Error('Not Allowed')
            ELSE
                IF (POSTransaction.Channel = 'zomato') AND (TenderTypeCode <> '23') then
                    Error('Not Allowed')
                ELSE
                    IF (POSTransaction.Channel = 'swiggy') AND (TenderTypeCode <> '22') then
                        Error('Not Allowed')
                    ELSE
                        IF TenderTypeCode = '56' then  //AlleRSN 110124
                            Error('Not Allowed');
            //AlleRSN 061023 end
            //Alle-AS-25102023
        END else
            if POSTransaction."Sales Type" = 'POS' then begin
                if (TenderTypeCode = '23') OR (TenderTypeCode = '22') OR (TenderTypeCode = '21') then
                    Error('Not Allowed');

                if not POSTransaction."Sale Is Return Sale" then begin
                    if (TenderTypeCode = '56') AND (POSTransaction."Customer No." <> 'C00080') then
                        Error('Only Zomato Gold Customer Allowed!'); //AlleRSN 110124
                    if (TenderTypeCode <> '56') AND (POSTransaction."Customer No." = 'C00080') then
                        Error('Only Zomato Gold payment is Allowed for Zomato customers!'); //AlleRSN 110124
                end;
            end;
        //Alle-AS-25102023


        //ALLE-AS-17102023
        POstransLine.Reset();
        POstransLine.SetRange("Receipt No.", POSTransaction."Receipt No.");
        POstransLine.SetRange("Entry Type", POstransLine."Entry Type"::Item);
        POstransLine.SetRange("Entry Status", POstransLine."Entry Status"::" ");
        IF POstransLine.findset then
            repeat
                //Clear(GSTGrpCode);
                //if ((POstransLine."Net Amount" - PO.stransLine."Discount Amount") <> 0) then
                //GSTGrpCode := Evaluate(POstransLine."LSCIN GST Group Code")
                if POstransLine."Net Amount" <> 0 then
                    if (POstransLine."LSCIN GST Group Code" <> '0') or (POstransLine."LSCIN GST Group Code" = '') then
                        if (POstransLine."LSCIN GST Amount" = 0) then
                            if (POstransLine."User Plan Id" = '') then
                                if POSTransaction."Sales Type" = 'POS' then
                                    Error('GST amount cannot be zero.So check once gst amount for that item');
            until POstransLine.next = 0;
        //ALLE-AS-17102023
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Transaction Events", 'OnBeforeInsertPayment_TenderKeyExecutedEx', '', false, false)]
    local procedure OnBeforeInsertPayment_TenderKeyExecutedEx(var POSTransaction: Record "LSC POS Transaction"; var POSTransLine: Record "LSC POS Trans. Line")
    var
        TL: Record "LSC POS Trans. Line";
    begin


        TL.Reset();
        TL.SetRange("Receipt No.", POSTransaction."Receipt No.");
        IF TL.FindFirst() then;




        IF TL.WaveCoinApplied then begin
            POSTransaction.WaveCoinApplied := true;
            POSTransaction."Review Cart done" := true;
            POSTransaction.Modify();
        end;


    end;

    //Alle-AS-13112023-commented
    // [EventSubscriber(ObjectType::Table, Database::"Job Queue Entry", 'OnBeforeModifyLogEntry', '', false, false)]

    // local procedure OnBeforeModifyLogEntry(var JobQueueLogEntry: Record "Job Queue Log Entry"; var JobQueueEntry: Record "Job Queue Entry")
    // var
    //     JsonO: JsonObject;
    //     payload: Text;
    //     ResponseText: Text;
    //     RetailSetup: Record "LSC Retail Setup";
    //     StartDateTxt: text;
    //     EndDateTxt: text;
    //     StartDate: DateTime;
    //     EndDate: DateTime;
    //     Recstatus: text;
    //     ObjectType: Text;
    //     lenstart: Integer;
    //     lenEnd: Integer;
    //     TwcApiSetupUrl: record TwcApiSetupUrl;
    //     Body: Text;
    //     EmailItem: Record "Email Item" temporary;
    // begin
    //     Clear(Recstatus);
    //     Clear(ObjectType);
    //     if (JobQueueLogEntry."Object ID to Run" = 50014) then begin
    //         RetailSetup.Get();
    //         JobQueueLogEntry."Store Code" := RetailSetup."Local Store No.";
    //         JsonO.Add('EntryNo', JobQueueLogEntry."Entry No.");
    //         JsonO.Add('StoreCode', JobQueueLogEntry."Store Code");
    //         JsonO.Add('UserId', JobQueueLogEntry."User ID");
    //         StartDateTxt := FORMAT(JobQueueLogEntry."Start Date/Time", 30, '<Year4>-<Month,2>-<Day,2> <Hours24,2>:<Minutes,2>:<Seconds,2>');
    //         StartDateTxt := StartDateTxt.Replace('T', ' ');
    //         lenstart := StrLen(StartDateTxt);
    //         if lenstart = 19 then begin
    //             lenstart := lenstart - 3;
    //             StartDateTxt := CopyStr(StartDateTxt, 16, lenstart);
    //         end;
    //         // StartDateTxt := Format(JobQueueLogEntry."Start Date/Time").Replace('/', '-');
    //         JsonO.Add('StartDateTime', StartDateTxt);
    //         EndDateTxt := FORMAT(JobQueueLogEntry."End Date/Time", 30, '<Year4>-<Month,2>-<Day,2> <Hours24,2>:<Minutes,2>:<Seconds,2>');
    //         EndDateTxt := EndDateTxt.Replace('T', ' ');
    //         lenEnd := StrLen(EndDateTxt);
    //         if lenEnd = 19 then begin
    //             lenEnd := lenEnd - 3;
    //             EndDateTxt := CopyStr(EndDateTxt, 16, lenEnd);
    //         end;
    //         JsonO.Add('EndDateTime', EndDateTxt);
    //         if JobQueueLogEntry."Object Type to Run" = 3 then
    //             ObjectType := 'Report';
    //         if JobQueueLogEntry."Object Type to Run" = 5 then
    //             ObjectType := 'Codeunit';
    //         JsonO.Add('ObjectType', ObjectType);
    //         JsonO.Add('ObjectId', JobQueueLogEntry."Object ID to Run");
    //         if JobQueueLogEntry.Status = 0 then
    //             Recstatus := 'Success';
    //         if JobQueueLogEntry.Status = 1 then
    //             Recstatus := 'In Process';
    //         if JobQueueLogEntry.Status = 2 then
    //             Recstatus := 'Error';
    //         JsonO.Add('status', Recstatus);
    //         JsonO.Add('Description', JobQueueLogEntry.Description);
    //         JsonO.Add('ErrorMessage', JobQueueLogEntry."Error Message");
    //         JsonO.Add('Duration', JobQueueLogEntry.Duration());
    //         JsonO.Add('UserSessionId', JobQueueLogEntry."User Session ID");
    //         JsonO.WriteTo(payload);
    //         //Message(payload);

    //         // Body := payload + ' Job Failed.' + 'Dear User,<br><br>Responce : <b>' + ResponseText +
    //         //                                  '<br><br>Thanks & Regards';
    //         // EmailItem."Send to" := 'nchauhan@alletec.com';
    //         // EmailItem."Send CC" := 'akswar@alletec.com';
    //         // EmailItem.Subject := 'JOb Success';
    //         // EmailItem.Validate("Plaintext Formatted", false);
    //         // EmailItem.SetBodyText(Body);
    //         // EmailItem.Send(true, Enum::"Email Scenario"::Default);

    //         ResponseText := MakeRequestForJobQueueStatus('https://bce-apimanagement.azure-api.net/api/v1/posjobdetails', payload);//ADD URL


    //     end;                                                                                                                      // JobQueueLogEntry.Modify();
    // end;

    // [EventSubscriber(ObjectType::Codeunit, Codeunit::"Job Queue Error Handler", 'OnAfterLogError', '', false, false)]
    // local procedure OnAfterLogError(var JobQueueEntry: Record "Job Queue Entry")
    // var
    //     JsonO: JsonObject;
    //     payload: Text;
    //     ResponseText: Text;
    //     RetailSetup: Record "LSC Retail Setup";
    //     StartDateTxt: text;
    //     EndDateTxt: text;
    //     StartDate: DateTime;
    //     EndDate: DateTime;
    //     Recstatus: text;
    //     ObjectType: Text;
    //     lenstart: Integer;
    //     lenEnd: Integer;
    //     TwcApiSetupUrl: record TwcApiSetupUrl;
    //     JobQueueLogEntry: Record "Job Queue Log Entry";
    //     Body: Text;
    //     EmailItem: Record "Email Item" temporary;
    // begin
    //     Clear(Recstatus);
    //     Clear(ObjectType);

    //     if (JobQueueEntry."Object ID to Run" = 50014) then begin
    //         JobQueueLogEntry.SetRange(ID, JobQueueEntry.ID);
    //         JobQueueLogEntry.SetRange("User Session ID", JobQueueEntry."User Session ID");
    //         JobQueueLogEntry.setfilter(status, '%1', JobQueueLogEntry.Status::Error);
    //         if JobQueueLogEntry.FindFirst() then
    //             RetailSetup.Get();
    //         JobQueueLogEntry."Store Code" := RetailSetup."Local Store No.";
    //         JsonO.Add('EntryNo', JobQueueLogEntry."Entry No.");
    //         JsonO.Add('StoreCode', JobQueueLogEntry."Store Code");
    //         JsonO.Add('UserId', JobQueueEntry."User ID");
    //         StartDateTxt := FORMAT(JobQueueLogEntry."Start Date/Time", 30, '<Year4>-<Month,2>-<Day,2> <Hours24,2>:<Minutes,2>:<Seconds,2>');
    //         StartDateTxt := StartDateTxt.Replace('T', ' ');
    //         lenstart := StrLen(StartDateTxt);
    //         if lenstart = 19 then begin
    //             lenstart := lenstart - 3;
    //             StartDateTxt := CopyStr(StartDateTxt, 16, lenstart);
    //         end;
    //         // StartDateTxt := Format(JobQueueEntry."Start Date/Time").Replace('/', '-');
    //         JsonO.Add('StartDateTime', StartDateTxt);
    //         EndDateTxt := FORMAT(JobQueueLogEntry."End Date/Time", 30, '<Year4>-<Month,2>-<Day,2> <Hours24,2>:<Minutes,2>:<Seconds,2>');
    //         EndDateTxt := EndDateTxt.Replace('T', ' ');
    //         lenEnd := StrLen(EndDateTxt);

    //         if lenEnd = 19 then begin
    //             lenEnd := lenEnd - 3;
    //             EndDateTxt := CopyStr(EndDateTxt, 16, lenEnd);
    //         end;
    //         JsonO.Add('EndDateTime', EndDateTxt);
    //         if JobQueueEntry."Object Type to Run" = 3 then
    //             ObjectType := 'Report';
    //         if JobQueueEntry."Object Type to Run" = 5 then
    //             ObjectType := 'Codeunit';
    //         JsonO.Add('ObjectType', ObjectType);
    //         JsonO.Add('ObjectId', JobQueueEntry."Object ID to Run");
    //         if JobQueueEntry.Status = 0 then
    //             Recstatus := 'Success';
    //         if JobQueueEntry.Status = 1 then
    //             Recstatus := 'In Process';
    //         if JobQueueEntry.Status = 2 then
    //             Recstatus := 'Error';
    //         JsonO.Add('status', Recstatus);
    //         JsonO.Add('Description', JobQueueEntry.Description);
    //         JsonO.Add('ErrorMessage', JobQueueEntry."Error Message");
    //         JsonO.Add('Duration', JobQueueLogEntry.Duration());
    //         JsonO.Add('UserSessionId', JobQueueEntry."User Session ID");
    //         JsonO.WriteTo(payload);
    //         //Message(payload);

    //         // Body := payload + ' Job Failed.' + 'Dear User,<br><br>Responce : <b>' + ResponseText +
    //         //                             '<br><br>Thanks & Regards';
    //         // EmailItem."Send to" := 'nchauhan@alletec.com';
    //         // EmailItem."Send CC" := 'akswar@alletec.com';
    //         // EmailItem.Subject := 'JOb Error';
    //         // EmailItem.Validate("Plaintext Formatted", false);
    //         // EmailItem.SetBodyText(Body);
    //         // EmailItem.Send(true, Enum::"Email Scenario"::Default);
    //         TwcApiSetupUrl.Get();
    //         TwcApiSetupUrl.Modify();
    //         ResponseText := MakeRequestForJobQueueStatus('https://bce-apimanagement.azure-api.net/api/v1/posjobdetails', payload);//ADD URL


    //     end;                                                                                                                      // JobQueueLogEntry.Modify();
    // end;
    // end;
    //Alle-AS-13112023-commented
    procedure MakeRequestForJobQueueStatus(URL: Text; payload: Text) responseText: Text;
    var
        client: HttpClient;
        request: HttpRequestMessage;
        response: HttpResponseMessage;
        contentHeaders: HttpHeaders;
        content: HttpContent;
        IsSuccessful: Boolean;
        TwcApiSetupUrl: record TwcApiSetupUrl;
    begin
        // EInvIntegrationSetup.get();
        // Add the payload to the content
        TwcApiSetupUrl.Get();
        content.WriteFrom(payload);
        // Replace the default content type header with a header associated with this request
        content.GetHeaders(contentHeaders);
        contentHeaders.Clear();
        contentHeaders.Add('Content-Type', 'application/json');
        // client.DefaultRequestHeaders.Add('storeCode', storeNo);//ADD store Code
        client.DefaultRequestHeaders.Add('Ocp-Apim-Subscription-Key', '05788ebc0db44e1d83fc45bf3e14159d');//ADD Token
        request.Content := content;
        request.SetRequestUri(URL);
        request.Method := 'POST';
        IsSuccessful := client.Send(request, response);
        if not IsSuccessful then begin
            // handle the error
        end;
        if not response.IsSuccessStatusCode() then begin
            // handle the error
        end;
        // Read the response content as json.
        response.Content().ReadAs(responseText);
    end;

    //ALLE_NICK_START
    //BILLME_INTEGRATION
    procedure BillMe(var TransactionHeader: Record "LSC Transaction Header")
    var
        JsonO: JsonObject;
        JsonO1: JsonObject;
        customerData: JsonObject;
        storeData: JsonObject;
        transactionalData: JsonObject;
        paymentData: JsonObject;
        RequestType: Option Get,Patch,Post,Delete,Put;
        JArray: JsonArray;
        payload: Text;
        paymentMethodsarray: JsonArray;
        paymentMethods: JsonObject;
        billAmountData: JsonObject;
        taxesData: JsonObject;
        distributedTax: JsonArray;
        distributed: JsonObject;
        other: JsonObject;
        ResponseText: Text;
        JsonText: Text;
        UserSetup: Record "User Setup";
        TIE: Record "LSC Trans. Infocode Entry";
        TableNo: Text;
        UpHeader: Record "UP Header";
        InvoiceTxt: text;
        Item: Record Item;
        Store: Record "LSC Store";
        TransPaymentEntry: Record "LSC Trans. Payment Entry";
        TenderType: Record "LSC Tender Type";
        ChannelType: Text;
        Date1: Datetime;
        TwcApiSetupUrl: Record TwcApiSetupUrl;
        ReceiptNoString: Text;
        JObject: JsonObject;
        JToken: JsonToken;
        PosDataEntry: Record "LSC POS Data Entry";
        CreditNoteNo: Code[20];
        CreditNoteNoString: Text;
        PaymentEntry: Record 99001474;
        LSCPOSMenuLine1: Record "LSC POS Menu Line";
        NO: Text;

    begin
        with TransactionHeader do begin
            // JArray.Add(JsonO);
            if TransactionHeader."Entry Status" <> TransactionHeader."Entry Status"::Voided then begin
                JsonO.Add('sms', 'true');
                //  JsonO.Add('email', '0');
                // JsonO.Add('whatsapp', '0');
                UpHeader.Reset();
                UpHeader.SetRange(receiptNo, "Receipt No.");
                IF UpHeader.FindFirst() Then;
                JsonO.add('customerData', customerData.AsToken());
                if UpHeader.customer_phone <> '' then begin
                    customerData.Add('phone', UpHeader.customer_phone);
                    customerData.Add('email', UpHeader.customer_email);
                end;
                LSCPOSMenuLine1.Reset();
                LSCPOSMenuLine1.SetRange("Profile ID", '##DEFAULT');
                LSCPOSMenuLine1.SetRange("Menu ID", '#APPCUSTOMER');
                LSCPOSMenuLine1.SetRange("Key No.", 1);
                LSCPOSMenuLine1.SetRange(CustAppUserId, TransactionHeader.CustAppUserId);
                LSCPOSMenuLine1.SetFilter("Mobile NO.", '<>%1', '');
                if LSCPOSMenuLine1.FindFirst() then begin
                    NO := DelChr(LSCPOSMenuLine1."Mobile NO.", '=', '+');
                    No := CopyStr(No, 3, 10);
                    customerData.Add('phone', NO);

                end;
                //customerData.Add('phone', '9805794009');
                JsonO.Add('storeData', storeData.AsToken());
                Store.Reset();
                IF Store.Get("Store No.") THEN;
                storeData.Add('storeName', Store.Name);
                storeData.Add('storeOrderId', "Store No.");
                JsonO.Add('transactionalData', transactionalData.AsToken());
                //InvoiceType
                IF TransactionHeader."Sale Is Return Sale" then begin
                    InvoiceTxt := 'return tax invoice';
                    TableNo := '';
                end
                Else
                    //Wallet Balance Criteria
                    IF Item."No." = '1' Then begin
                        // IF TransactionHeader."Wallet Balance" <> '' Then
                        //     IF Evaluate(WalletBal, TransactionHeader."Wallet Balance") Then;
                        // WalletBal += ABS("Net Amount" - "Discount Amount");
                        InvoiceTxt := 'advance receipt';
                        TableNo := '';
                        TransactionHeader.Rounded := 0;
                        TransactionHeader."Gross Amount" := ("Net Amount" - "Discount Amount");
                    end
                    else
                        InvoiceTxt := 'tax invoice';
                transactionalData.Add('invoiceType', Format(InvoiceTxt));
                transactionalData.Add('invoiceNumber', Format("Receipt No."));
                //  Date:=DelChr(FORMAT(Date),'=','/')
                Date1 := CreateDateTime(Date, TransactionHeader."Time when Trans. Closed");
                transactionalData.Add('invoiceDate', Date1);
                //OrderNo.
                if UpHeader.order_details_ext_platforms_id <> '' then begin
                    transactionalData.Add('orderNumber', UpHeader.order_details_ext_platforms_id);
                end;
                if UpHeader.order_details_channel <> '' then begin
                    transactionalData.Add('orderType', UpHeader.order_details_channel);
                end;
                if InvoiceTxt <> 'return tax invoice' then begin
                    // ReceiptNoString := getBarcode("Receipt No.");
                    transactionalData.Add('barCodeNum', Format("Receipt No."));
                end;

                JsonO.Add('paymentData', paymentData.AsToken());
                paymentData.Add('paymentMethods', paymentMethodsarray);
                //PaymentMethods
                TransPaymentEntry.SETRANGE("Store No.", TransactionHeader."Store No.");
                TransPaymentEntry.SETRANGE("POS Terminal No.", TransactionHeader."POS Terminal No.");
                TransPaymentEntry.SETRANGE("Transaction No.", TransactionHeader."Transaction No.");
                IF TransPaymentEntry.FINDSET() THEN
                    TenderType.Reset();
                TenderType.SetRange(Code, TransPaymentEntry."Tender Type");
                TenderType.SetFilter("Store No.", '=%1', TransactionHeader."Store No.");
                IF TenderType.FindFirst() then
                    paymentMethodsarray.Add(paymentMethods);
                paymentMethods.Add('name', TenderType.Description);
                paymentMethods.Add('amount', ABS(TransPaymentEntry."Amount Tendered"));
                // paymentMethods.Add('productsData', productsData(SalesInvHeader));
                JsonO.Add('productsData', productsData(TransactionHeader));
                JsonO.Add('billAmountData', billAmountData.AsToken());
                billAmountData.Add('totalQty', TotalQty);
                billAmountData.Add('subTotal', abs("Net Amount"));
                billAmountData.Add('saleCurrency', Format('INR'));
                billAmountData.Add('totalDiscount', ABS("Discount Amount"));
                billAmountData.Add('netPayableAmount', ABS("Gross Amount"));
                PaymentEntry.SetRange("Receipt No.", TransactionHeader."Receipt No.");
                PaymentEntry.SetFilter("Change Line", '%1', true);
                if PaymentEntry.FindFirst() then;
                if PaymentEntry."Amount Tendered" <> 0 then begin
                    billAmountData.Add('changeAmount', ABS(PaymentEntry."Amount Tendered"));
                end;
                billAmountData.Add('roundupAmount', ABS(Rounded));
                JsonO.Add('taxesData', taxesData.AsToken());
                taxesData.Add('distributedTax', distributedTax.AsToken());
                distributedTax.Add(distributed);
                GetGSt(TransactionHeader);
                distributed.Add('cgstPercent', GstCode);
                distributed.Add('sgstPercent', GstCode);
                distributed.Add('cgst', ABS(CGST));
                distributed.Add('sgst', ABS(SGST));
                JsonO.Add('other', other.AsToken());

                //TABlENo.
                TIE.Reset();
                TIE.SetRange("Transaction No.", "Transaction No.");
                TIE.SetRange("Store No.", "Store No.");
                TIE.SetRange("POS Terminal No.", "POS Terminal No.");
                TIE.SetRange(Infocode, 'SELECTTABLE');
                IF TIE.FindFirst() then
                    TableNo := TIE.Information
                Else begin
                    TIE.SetRange(Infocode, 'TABLE NO.');
                    IF TIE.FindFirst() then
                        TableNo := TIE.Information;
                end;
                if TableNo <> '' then begin
                    other.Add('tableNumber', TableNo);
                end;

                other.Add('staffId', "Staff ID");
                PosDataEntry.Reset();
                PosDataEntry.SetRange("Created by Receipt No.", TransactionHeader."Receipt No.");
                IF PosDataEntry.FindFirst() then
                    CreditNoteNo := PosDataEntry."Entry Code";

                IF CreditNoteNo <> '' Then begin
                    //  CreditNoteNoString := getBarcode(CreditNoteNo);
                    other.Add('creditNoteBarCode', CreditNoteNo);
                end;

                JsonO.WriteTo(payload);
                Message(payload);
                TwcApiSetupUrl.Get();
                ResponseText := MakeRequest(TwcApiSetupUrl."Bill ME URL", payload, "Store No.");//ADD URL
                Message(ResponseText);
                JObject.ReadFrom(ResponseText);
                JObject.Get('data', JToken);//need to change
                ReadTable2(JToken.AsObject(), TransactionHeader);
            end;
        end;
    end;

    local procedure ReadTable2(JObject: JsonObject; TransactionHeader: Record "LSC Transaction Header")
    var
        OuterNode: Text;
        RecRef: RecordRef;
        JToken2: JsonToken;
        Entryno: Guid;
        Bill: text;
        Msg: text;
    begin
        foreach OuterNode in JObject.Keys() do begin
            JObject.Get(OuterNode, JToken2);
            if OuterNode = 'bill' then
                Bill := JToken2.AsValue().AsText();
            if OuterNode = 'msg' then
                Msg := JToken2.AsValue().AsText();
        end;
        //TransactionHeader."BILL ME URL" := Bill;

        //Hyperlink(TransactionHeader."BILL ME URL");

        If Msg <> '' then begin
            //TransactionHeader.Msg := Msg;
            Message(Msg);
        end;
        TransactionHeader.Modify();

    end;





    local procedure productsData(TransactionHeader: Record "LSC Transaction Header"): JsonArray
    var
        TransSalesEntry: Record "LSC Trans. Sales Entry";
        JTransSalesEntry: JsonArray;
        SNo: Integer;
    begin
        TransSalesEntry.SETRANGE("Store No.", TransactionHeader."Store No.");
        TransSalesEntry.SETRANGE("POS Terminal No.", TransactionHeader."POS Terminal No.");
        TransSalesEntry.SETRANGE("Transaction No.", TransactionHeader."Transaction No.");
        IF TransSalesEntry.FINDSET() THEN begin
            REPEAT
                //SNo += 1;
                AddSalesInvoiceLineToJson(TransSalesEntry, JTransSalesEntry, SNo);
            until TransSalesEntry.NEXT() = 0;
            exit(JTransSalesEntry);
        end;

    end;

    local procedure AddSalesInvoiceLineToJson(TransSalesEntry: Record "LSC Trans. Sales Entry"; JTransSalesEntry: JsonArray; SNo: Integer)
    // local procedure AddSalesInvoiceLineToJson(JTransSalesEntry: JsonArray)
    var
        JOBJTransSalesEntry: JsonObject;
        TotalItemValue: Decimal;
        ValueEntryRelation: Record "Value Entry Relation";
        ValueEntry: Record "Value Entry";
        ILERec: Record "Item Ledger Entry";
        batch_details: JsonObject;
        RowID: Text[250];
        subItemsArr: JsonArray;
        subItemsOBJ: JsonObject;
        Item: Record Item;
        TransSalesEntry2: Record "LSC Trans. Sales Entry";
    begin
        Item.Reset();
        IF Item.Get(TransSalesEntry."Item No.") THEN;
        if (TransSalesEntry."Parent Line No." = 0) and (TransSalesEntry."Infocode Selected Qty." = 0) then begin
            JOBJTransSalesEntry.Add('name', Item.Description);
            JOBJTransSalesEntry.Add('quantity', ABS(TransSalesEntry.Quantity));
            JOBJTransSalesEntry.Add('unitAmount', Abs(TransSalesEntry.Price));
            JOBJTransSalesEntry.Add('totalAmount', Round((ABS(TransSalesEntry.Quantity) * Abs(TransSalesEntry.Price)), 0.01, '='));
            JOBJTransSalesEntry.Add('hsnCode', TransSalesEntry."LSCIN HSN/SAC Code");
            ParentQty += Abs(TransSalesEntry.Quantity);
            TransSalesEntry2.SetRange("Receipt No.", TransSalesEntry."Receipt No.");
            TransSalesEntry2.SetRange("Parent Line No.", TransSalesEntry."Line No.");
            TransSalesEntry2.SetFilter("Infocode Selected Qty.", '<>%1', 0);
            if TransSalesEntry2.FindSet() then begin
                JOBJTransSalesEntry.Add('subItems', subItemsArr);
                repeat
                    Item.Reset();
                    IF Item.Get(TransSalesEntry2."Item No.") THEN;
                    subItemsArr.Add(subItemsOBJ);
                    subItemsOBJ.Add('name', Item.Description);
                    subItemsOBJ.Add('quantity', ABS(TransSalesEntry2."UOM Quantity"));
                    subItemsOBJ.Add('unitAmount', abs(TransSalesEntry2."UOM Price"));//NEEDTOCHECK
                    subItemsOBJ.Add('totalAmount', Round((ABS(TransSalesEntry2."UOM Quantity") * Abs(TransSalesEntry2."UOM Price")), 0.01, '='));
                    subItemsOBJ.Add('hsnCode', TransSalesEntry2."LSCIN HSN/SAC Code");
                until TransSalesEntry2.Next() = 0;
                childQty += ABS(TransSalesEntry2."UOM Quantity");
            end;
            JTransSalesEntry.Add(JOBJTransSalesEntry);
            TotalQty := childQty + ParentQty;
        end;
    end;

    procedure MakeRequest(URL: Text; payload: Text; storeNo: code[10]) responseText: Text;
    var
        client: HttpClient;
        request: HttpRequestMessage;
        response: HttpResponseMessage;
        contentHeaders: HttpHeaders;
        content: HttpContent;
        IsSuccessful: Boolean;
        TwcApiSetupUrl: record TwcApiSetupUrl;
    // EInvIntegrationSetup: Record "E-Inv Integration Setup";
    begin
        // EInvIntegrationSetup.get();
        // Add the payload to the content
        TwcApiSetupUrl.Get();
        content.WriteFrom(payload);
        // Replace the default content type header with a header associated with this request
        content.GetHeaders(contentHeaders);
        contentHeaders.Clear();
        contentHeaders.Add('Content-Type', 'application/json');
        client.DefaultRequestHeaders.Add('storeCode', storeNo);//ADD store Code
        client.DefaultRequestHeaders.Add('Authorization', 'Bearer ' + TwcApiSetupUrl."Bill ME Token");//ADD Token
        request.Content := content;
        request.SetRequestUri(URL);
        request.Method := 'POST';
        IsSuccessful := client.Send(request, response);
        if not IsSuccessful then begin
            // handle the error
        end;
        if not response.IsSuccessStatusCode() then begin
            // handle the error
        end;
        // Read the response content as json.
        response.Content().ReadAs(responseText);
    end;

    local procedure GetGSt(TransactionHeader: Record "LSC Transaction Header")
    var
        TransSalesEntry: Record "LSC Trans. Sales Entry";
    begin
        TransSalesEntry.SETRANGE("Store No.", TransactionHeader."Store No.");
        TransSalesEntry.SETRANGE("POS Terminal No.", TransactionHeader."POS Terminal No.");
        TransSalesEntry.SETRANGE("Transaction No.", TransactionHeader."Transaction No.");
        IF TransSalesEntry.FINDSET() THEN BEGIN
            //GSTVALUE
            Clear(GstCode);
            Clear(GstValue);
            Clear(CGST);
            Clear(SGST);
            IF (TransSalesEntry."LSCIN GST Group Code" <> '') AND (StrLen(Format(TransSalesEntry."LSCIN GST Group Code")) <= 2) THEN begin
                Evaluate(GstCode, TransSalesEntry."LSCIN GST Group Code");
                GstCode /= 2;
                GstValue := TransSalesEntry."LSCIN GST Amount";
                SGST := GstValue / 2;
                CGST := GstValue / 2;
            end;

        end;
    end;

    local procedure getBarcode("No.": Code[20]): Text
    var
        Base64Convert: Codeunit "Base64 Convert";
        TempBlob: Codeunit "Temp Blob";
        Client: HttpClient;
        Response: HttpResponseMessage;
        Instr: InStream;
        BarcodeString: Text;
    begin
        Clear(BarcodeString);
        IF Client.Get('https://barcode.tec-it.com/barcode.ashx?data=' + "No." + '&code=Code128', Response) Then Begin
            TempBlob.CreateInStream(Instr);
            Response.Content.ReadAs(Instr);

            BarcodeString := Base64Convert.ToBase64(Instr);

            exit(BarcodeString);
        End;
    end;



    //ALLE_NICK_END
    //BILLME_INTEGRATION

    //AlleRSN 111223 start
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Transaction Events", 'OnBeforePostPOSTransaction', '', false, false)]
    local procedure OnBeforePostPOSTransaction(var POSTransaction: Record "LSC POS Transaction")
    var
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
        postrans1: Record "LSC POS Transaction";
        iterator: Integer;
        jsonobject: JsonObject;
        redepvalue: Decimal;
        promotxnid: Text;
        batchnumber: Text;
        POSTransLine: Record "LSC POS Trans. Line";
        lscposmenuline1: Record "LSC POS Menu Line";
        txnid: Text;
    begin
        //AlleRSN 111223 start
        //if TenderTypeCode = '16' then begin
        POSTransLine.Reset();
        POSTransLine.SetRange("Receipt No.", POSTransaction."Receipt No.");
        POSTransLine.SetFilter(Number, '%1', '16');
        if POSTransLine.FindFirst() then begin
            respmsg := WalletRedemptioAPI(POSTransLine.Amount, POSTransaction);
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
                        postransline.redemptionValue := redepvalue;
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
            end;
        end;
        //end;
        //AlleRSN 111223 end

    end;
    //AlleRSN 111223 end
    //AJ_ALLE_11122023
    procedure WalletRedemptioAPI(Amt: Decimal; POSTransaction: Record "LSC POS Transaction"): HttpResponseMessage
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
        responsemsg := CallServiceStatus_WR(ReqUrl, HTTPRequestTypeEnum::post, JsonData);
        exit(responsemsg);

    end;

    procedure CallServiceStatus_WR(RequestUrl: Text; RequestType: Enum HTTPRequestTypeEnum; Body: Text): HttpResponseMessage
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
    //AJ_ALLE_11122023

    var
        EmailScenario: Enum "Email Scenario";
        POSCTRL: Codeunit "LSC POS Control Interface";
        LSCPOSMenuLine: Record "LSC POS Menu Line";
        APIURL: Text;
        apisetup: Record TwcApiSetupUrl;
        TotalQty: Decimal;
        ParentQty: Decimal;
        childQty: Decimal;
        GstCode: Decimal;
        GstValue: Decimal;
        SGST: Decimal;
        CGST: Decimal;








    //        VoidCommand: Boolean;
}

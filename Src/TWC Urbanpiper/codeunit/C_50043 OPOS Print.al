codeunit 50043 OPOSPrint_2
{
    var
        Currency: Record Currency;
        Store: Record "LSC Store";
        HospitalityType: Record "LSC Hospitality Type";
        glTrans: Record "LSC Transaction Header";
        GenPOSFunc: Record "LSC POS Func. Profile";
        tmpDeal: Record "LSC Offer" temporary;
        TmpPrintedSalesEntry: Record "LSC Trans. Sales Entry" temporary;
        TmpPrintedDealPOSTransLine: Record "LSC POS Trans. Line" temporary;
        TempSalesLine: Record "Sales Line" temporary;
        TempGSTRateGroup: Record "LSC POS Trans. Line" temporary;
        TempTaxComponent: Record "Sales Invoice Line" temporary; //Use to calculate GST component
        TempTaxComponentGroup: Record "Sales Invoice Line" temporary; //Use to group GST component with same %
        PeriodicDiscountInfoTEMP: Record "LSC Periodic Discount" temporary;
        Globals: Codeunit "LSC POS Session";
        POSFunctions: Codeunit "LSC POS Functions";
        LocalizationExt: Codeunit "LSC Retail Localization Ext.";
        LocalizationUtility: Codeunit "LSC Localization Utility";
        POSDisplayMgt: Codeunit "LSCIN POS Display Management";
        TipsText1: Text;
        TipsText2: Text;
        FieldValue: array[10] of Text[80];
        NodeName: array[32] of Text[50];
        BreakdownLabel: array[4] of Text[30];
        Subtotal: Decimal;
        TotalAmt: Decimal;
        TipsAmount1: Decimal;
        TipsAmount2: Decimal;
        totSPOAmount: Decimal;
        BreakdownAmt: array[4] of Decimal;
        TempTaxComponentLineNo: Integer;
        TempTaxComponentGroupLineNo: Integer;
        LineLen: Integer;
        bSecondPrintActive: Boolean;
        Text024: Label 'Total Discount';
        Text232: Label 'Points';
        Text046: Label '** COPY **';
        Text071: Label 'Description';
        Text004: Label 'Amount';
        Text321: Label 'Tips';
        Text131: Label 'pcs';
        Text063: Label 'VAT';
        Text063_2: Label 'Net.Amt';
        Text133: Label 'VAT RegNo.:';
        Text084: Label 'Line Discount';
        Text074: Label 'Item No.: ';
        Text075: Label 'Barcode: ';
        Text003: Label 'RETURN';
        Text042: Label 'Subtotal';
        Text005: Label 'Total ';
        Text093: Label 'Rounding';
        Text501: Label 'Code';
        Text502: Label 'Base Amt';
        Text503: Label 'GST%';
        Text504: Label 'GST Amt';
        Text506: Label 'GST Details';
        Text507: Label 'VAT Details';
        Text508: Label 'VAT %';
        Text50000: Label '#';
        Text50001: Label 'Item';
        Text50002: Label 'HSN';
        Text50003: Label 'Qty';
        Text50004: Label 'Rate';

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSCIN POS Print Utility", 'OnBeforePrintSalesINInfo', '', false, false)]
    local procedure OnBeforePrintSalesINInfo(var IsHandled: Boolean)
    begin
        IsHandled := TRUE;
        exit;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Print Utility", 'OnBeforePrintSalesInfo', '', false, false)]
    local procedure OnBeforePrintSalesInfo(var Sender: Codeunit "LSC POS Print Utility"; var Transaction: Record "LSC Transaction Header"; var PrintBuffer: Record "LSC POS Print Buffer"; var PrintBufferIndex: Integer; var LinesPrinted: Integer; Tray: Integer; var IsHandled: Boolean)
    var
        TransInfoCode: Record "LSC Trans. Infocode Entry";
        Customer: Record Customer;
        SalesEntry: Record "LSC Trans. Sales Entry";
        Item: Record Item;
        VATSetup: Record "LSC POS VAT Code";
        MixMatchEntry: Record "LSC Trans. Mix & Match Entry";
        PeriodicDiscount: Record "LSC Periodic Discount";
        TransInfoEntry: Record "LSC Trans. Infocode Entry";
        POSTerminal: Record "LSC POS Terminal";
        IncExpEntry: Record "LSC Trans. Inc./Exp. Entry";
        IncExpAcc: Record "LSC Income/Expense Account";
        CompInfo: Record "Company Information";
        ItemVariant: Record "Item Variant";
        Contact: Record Contact;
        ItemUnitOfMeasure: Record "Item Unit of Measure";
        SalesEntry2: Record "LSC Trans. Sales Entry";
        LinkedItems: Record "LSC Linked Item";
        TransactionOrderEntry: Record "LSC Transaction Order Entry";
        OptTypeValueEntry: Record "LSC Option Type Value Entry";
        TransDiscountEntry: Record "LSC Trans. Discount Entry";
        CouponHeader: Record "LSC Coupon Header";
        ParentItemLine: Record "LSC Trans. Sales Entry";
        ParentItem: Record Item;
        IncomeExpenseAccount: Record "LSC Income/Expense Account";
        VATPostingSetup: Record "VAT Posting Setup";
        RetailSetup: Record "LSC Retail Setup";
        TipsStaff_l: Record "LSC Staff";
        RecipeBufferTEMP: Record "LSC Trans. Sales Entry" temporary;
        RecipeBufferTEMP2: Record "LSC Trans. Sales Entry" temporary;
        RecipeBufferDetailTEMP_l: Record "LSC Trans. Discount Entry" temporary;
        RecipeBufferTransInfoTEMP: Record "LSC Trans. Infocode Entry" temporary;
        RecipeBufferTransInfoTextTEMP: Record "LSC Trans. Infocode Entry" temporary;
        ClientSessionUtility: Codeunit "LSC Client Session Utility";
        FormatAddress: Codeunit "Format Address";
        //ItemName: Text[30];
        ItemName: Text[40];
        discText: Text[30];
        DSTR1: Text[100];
        QtyTxt: Text[15];
        DSTR2: Text[100];
        DiscountText: Text[80];
        TmpValue: Text[100];
        LineArr: array[10] of Text[50];
        CustAddr: array[8] of Text[100];
        LastDepartment: Code[10];
        OfferCode: Code[20];
        VATExtraCharacters: Code[10];
        VATCode: array[5] of Code[10];
        PerDiscOffArr: array[250] of Code[20];
        totalCustItemDisc: Decimal;
        SalesLineAmount: Decimal;
        TotalNumberOfItems: Decimal;
        TotalSavings: Decimal;
        TotalAmtForSummary: Decimal;
        DiscountOnBlockPrintOffers: Decimal;
        DiscountOnLine: Decimal;
        LastQuantity: Decimal;
        ItemSoldUOMFactor: Decimal;
        TmpVATPerc: Decimal;
        SalesAmountVAT: array[5] of Decimal;
        VATPerc: array[5] of Decimal;
        VATAmount: array[5] of Decimal;
        PerDiscOffAmtArr: array[250] of Decimal;
        i: Integer;
        j: Integer;
        PrintItemNo: Integer;
        maxCounter: Integer;
        PerDiscOffArrCount: Integer;
        LineCount: Integer;
        StringLenBeforeSplitLine: Integer;
        NegativeQty: Integer;
        TotalAddrLine: Integer;
        ZALineCount: Integer;
        CheckCopyCount: Integer;
        VATPrinted: Boolean;
        discountSection: Boolean;
        OrderByDepartment: Boolean;
        PrintItem: Boolean;
        CountItemOk: Boolean;
        ThisIsAHospTipsLine: Boolean;
        CompressItemOK: Boolean;
        VATNotSet: Boolean;
        SkipCollectDiscountInfo: Boolean;
        PrintReturnText: Boolean;
        IncomeExpenseLinePrinted: Boolean;
        IsInvoice: Boolean;
        LineAmt: Decimal;
        NoOfItem: Integer;
        GSTCode: Code[20];
        SGST: Decimal;
        CGST: Decimal;
        Text085: Label 'Customer Discount';
        Text086: Label 'Infocode Discount';
        Text088: Label 'Discount Details';
        Text_DelNot: Label 'DELIVERY';
        Text151: Label 'Number of Items:';
        Text152: Label 'Total Savings:';
    begin
        StringLenBeforeSplitLine := 11;

        //OnBeforePrintSalesINInfo(Transaction, PrintBuffer, PrintBufferIndex, LinesPrinted, Tray, IsHandled, bSecondPrintActive);
        IsHandled := true; //AlleRSN
        //if IsHandled then
        //  exit;

        TransInfoCode.Reset();
        TransInfoCode.SetRange("Store No.", Transaction."Store No.");
        TransInfoCode.SetRange("POS Terminal No.", Transaction."POS Terminal No.");
        TransInfoCode.SetRange("Transaction No.", Transaction."Transaction No.");
        TransInfoCode.SetRange("Transaction Type", TransInfoCode."Transaction Type"::Header);
        Sender.PrintTransInfoCode(TransInfoCode, Tray, true);

        Clear(Customer);

        DSTR1 := '#T######################################';
        LineLen := Sender.GetLineLen();

        if Transaction."Customer No." <> '' then begin
            RetailSetup.Get();
            if (RetailSetup."W1 for Country  Code" = RetailSetup."W1 for Country  Code"::ZA) and ((-1 * Transaction."Gross Amount") >= 5000) then begin
                if Customer.Get(Transaction."Customer No.") then begin
                    FormatAddress.Customer(CustAddr, Customer);
                    TotalAddrLine := CompressArray(CustAddr);

                    DSTR1 := CopyStr('#L################################################', 1, LineLen);
                    for ZALineCount := 1 to TotalAddrLine do begin
                        FieldValue[1] := CopyStr(CustAddr[ZALineCount], 1, 80);
                        NodeName[1] := StrSubstNo('Customer Address %1', i);
                        Sender.PrintLine(Tray, Sender.FormatLine(FormatStr(Sender, FieldValue, DSTR1), false, false, false, false));
                        Sender.AddPrintLine(200, 1, NodeName, FieldValue, DSTR1, false, false, false, false, Tray);
                    end;
                    FieldValue[1] := Customer."VAT Registration No.";
                    NodeName[1] := 'VAT Registration No.';
                    Sender.PrintLine(Tray, Sender.FormatLine(FormatStr(Sender, FieldValue, DSTR1), false, false, false, false));
                    Sender.AddPrintLine(200, 1, NodeName, FieldValue, DSTR1, false, false, false, false, Tray);
                    Sender.PrintSeperator(Tray);
                end;
            end else begin
                if Transaction."Post as Shipment" then begin
                    FieldValue[1] := Text_DelNot;
                    NodeName[1] := 'Print Info';
                    Sender.PrintLine(Tray, Sender.FormatLine(FormatStr(Sender, FieldValue, '#C##################'), true, true, true, false));
                    Sender.AddPrintLine(250, 1, NodeName, FieldValue, '#C##################', true, true, true, false, Tray);
                    Sender.PrintLine(Tray, '');
                end;
                if Customer.Get(Transaction."Customer No.") then begin
                    FieldValue[1] := CopyStr(Customer."No." + ' ' + Customer.Name, 1, MaxStrLen(FieldValue[1]));
                    NodeName[1] := 'x';
                    FieldValue[2] := Customer."No.";
                    NodeName[2] := 'Customer No.';
                    FieldValue[3] := Customer.Name;
                    NodeName[3] := 'Customer Name';
                    Sender.PrintLine(Tray, Sender.FormatLine(FormatStr(Sender, FieldValue, DSTR1), false, false, false, false));
                    Sender.AddPrintLine(200, 3, NodeName, FieldValue, DSTR1, false, false, false, false, Tray);
                    Sender.PrintSeperator(Tray);
                end;
            end;
        end;
        if Transaction."Sell-to Contact No." <> '' then begin
            if Contact.Get(Transaction."Sell-to Contact No.") then begin
                FieldValue[1] := CopyStr(Contact."No." + ' ' + Contact.Name, 1, MaxStrLen(FieldValue[1]));
                NodeName[1] := 'x';
                FieldValue[2] := Contact."No.";
                NodeName[2] := 'Contact No.';
                FieldValue[3] := Contact.Name;
                NodeName[3] := 'Contact Name';
                Sender.PrintLine(Tray, Sender.FormatLine(FormatStr(Sender, FieldValue, DSTR1), false, false, false, false));
                Sender.AddPrintLine(200, 3, NodeName, FieldValue, DSTR1, false, false, false, false, Tray);
                Sender.PrintSeperator(Tray);
            end;
        end;

        PrintReturnText := true;

        if not LocalizationUtility.FiscalPOSCommandsIsNOLocalizationEnabled() then begin
            if PrintReturnText then begin
                if Transaction."Sale Is Return Sale" then begin
                    FieldValue[1] := Text003;
                    NodeName[1] := 'Description';
                    Sender.PrintLine(Tray, Sender.FormatLine(FormatStr(Sender, FieldValue, '#C##################'), true, true, true, false));
                    Sender.AddPrintLine(200, 1, NodeName, FieldValue, DSTR1, false, false, false, false, Tray);
                    Sender.PrintSeperator(Tray);
                end;
            end;
        end;

        IsInvoice := Sender.GetIsInvoice();

        if not IsInvoice then begin
            CheckCopyCount := 0;
            IF Transaction."Sale Is Return Sale" then
                CheckCopyCount := 1;
            if Transaction.GetPrintedCounter(1) > CheckCopyCount then
                Sender.PrintCopyText(Tray)
            else
                if bSecondPrintActive then begin
                    DSTR1 := '#C##################';
                    FieldValue[1] := Text046;
                    DSTR1 := '#C' + Sender.StringPad('#', LineLen - 2);
                    FieldValue[1] := Sender.StringPad('-', LineLen);
                end;
        end;

        if Transaction."Entry Status" = Transaction."Entry Status"::Training then
            Sender.PrintTrainingText(Tray);

        PerDiscOffArrCount := 0;
        totalCustItemDisc := 0;

        Clear(TotalNumberOfItems);
        Clear(TotalSavings);

        LineCount := 0;
        Clear(VATCode);
        Clear(VATPerc);
        Clear(VATAmount);
        Clear(SalesAmountVAT);
        Clear(SalesEntry);
        Clear(FieldValue);
        clear(tmpDeal);
        clear(GSTCode);
        clear(SGST);
        Clear(CGST);
        tmpDeal.DeleteAll;
        TmpPrintedSalesEntry.DeleteAll;
        TmpPrintedDealPOSTransLine.DeleteAll;
        if GenPOSFunc."Print Disc/Cpn Info on Slip" in
         [GenPOSFunc."Print Disc/Cpn Info on Slip"::"Detail for each line and Sub-total",
          GenPOSFunc."Print Disc/Cpn Info on Slip"::"Summary information below Sub-total"] then begin
            PeriodicDiscountInfoTEMP.Reset;
            PeriodicDiscountInfoTEMP.DeleteAll;
            Subtotal := 0;
        end;
        TotalAmt := 0;
        TipsAmount1 := 0;
        TipsText1 := '';
        TipsAmount2 := 0;
        TipsText2 := '';
        if LocalizationExt.IsNALocalizationEnabled then begin
            Clear(BreakdownLabel);
            Clear(BreakdownAmt);
            TempSalesLine.Reset;
            TempSalesLine.DeleteAll;
        end;
        glTrans := Transaction;
        SalesEntry.SetRange("Store No.", Transaction."Store No.");
        SalesEntry.SetRange("POS Terminal No.", Transaction."POS Terminal No.");
        SalesEntry.SetRange("Transaction No.", Transaction."Transaction No.");
        OrderByDepartment := GenPOSFunc."Receipt Printing by Category";
        if OrderByDepartment then
            SalesEntry.SetCurrentKey("Item Category Code");
        if SalesEntry.FindSet() then begin
            if GenPOSFunc."Print Free Text on Receipt" then begin
                Sender.PrintFreeTextLinesBeginning(SalesEntry, Tray, false);
            end;
            //DSTR1 := '#L################## #R#################';
            DSTR1 := '#L #L########## #L#### #R# #R#### #R####';
            FieldValue[1] := Text50000;
            FieldValue[2] := Text50001;
            FieldValue[3] := Text50002;
            FieldValue[4] := Text50003;
            FieldValue[5] := Text50004;
            FieldValue[6] := Text005;
            Sender.PrintLine(Tray, Sender.FormatLine(FormatStr(Sender, FieldValue, DSTR1), false, true, false, false));
            Sender.PrintSeperator(Tray);

            /*FieldValue[1] := Text071;
            FieldValue[2] := Text004;
            FieldValue[3] := 'HSN';
            Sender.PrintLine(Tray, Sender.FormatLine(FormatStr(Sender, FieldValue, DSTR1), false, true, false, false));
            Sender.PrintSeperator(Tray);
            */

            PrintItemNo := 0;
            if POSTerminal.Get(SalesEntry."POS Terminal No.") then
                if POSTerminal."Receipt Setup Location" = POSTerminal."Receipt Setup Location"::Store then begin
                    Store.Get(SalesEntry."Store No.");
                    case Store."Item No. on Receipt" of
                        Store."Item No. on Receipt"::"Item Number":
                            PrintItemNo := 1;
                        Store."Item No. on Receipt"::"Barcode/Item Number":
                            PrintItemNo := 2;
                    end;
                end else begin
                    case POSTerminal."Item No. on Receipt" of
                        POSTerminal."Item No. on Receipt"::"Item Number":
                            PrintItemNo := 1;
                        POSTerminal."Item No. on Receipt"::"Barcode/Item Number":
                            PrintItemNo := 2;
                    end;
                end;

            LastDepartment := '';
            RecipeBufferTEMP.Reset;
            RecipeBufferTEMP.DeleteAll;
            RecipeBufferDetailTEMP_l.Reset;
            RecipeBufferDetailTEMP_l.DeleteAll;
            RecipeBufferTEMP2.Reset;
            RecipeBufferTEMP2.DeleteAll;
            RecipeBufferTransInfoTEMP.Reset;
            RecipeBufferTransInfoTEMP.DeleteAll;
            RecipeBufferTransInfoTextTEMP.Reset;
            RecipeBufferTransInfoTextTEMP.DeleteAll;
            repeat
                if not SalesEntry."System-Exclude From Print" then begin

                    Clear(Item);
                    if Item.Get(SalesEntry."Item No.") then;

                    if SalesEntry."Parent Line No." = 0 then begin
                        ParentItem := Item;
                        ParentItemLine := SalesEntry;
                    end;

                    SkipCollectDiscountInfo := false;

                    //All lines except deal lines are put into recipe-item buffer. For cases where lines must not be compressed, CompresItemOK is set as false
                    CompressItemOK := true;
                    if ParentItem."LSC Skip Compr. When Printed" then
                        CompressItemOK := false;
                    if not (SalesEntry."Orig. from Infocode" <> '') and (SalesEntry."Parent Line No." <> 0) then begin
                        if SalesEntry."Price Change" then
                            CompressItemOK := false;
                        if SalesEntry."Scale Item" then
                            CompressItemOK := false;
                        if SalesEntry."Price in Barcode" then
                            CompressItemOK := false;
                        if SalesEntry.Quantity > 0 then begin
                            CompressItemOK := false;
                            NegativeQty += 1;
                        end;
                        if LastQuantity = 0 then
                            LastQuantity := SalesEntry.Quantity;
                        if (LastQuantity <> 0) and ((LastQuantity < 0) or (SalesEntry.Quantity < 0)) and (NegativeQty <> 0) then begin
                            CompressItemOK := false;
                            LastQuantity := 0;
                        end;
                    end;
                    if (not SalesEntry."Deal Line") then
                        Sender.InsertIntoRecipeBuffer(
                          SalesEntry, RecipeBufferTEMP, RecipeBufferTEMP2, ParentItemLine, RecipeBufferDetailTEMP_l,
                          RecipeBufferTransInfoTEMP, RecipeBufferTransInfoTextTEMP, CompressItemOK);

                    if POSTerminal."Print Total Savings" then begin
                        TotalSavings := TotalSavings + SalesEntry."Discount Amount";
                    end;

                    if POSTerminal."Print Number of Items" then begin
                        if (SalesEntry.Quantity < 0) then begin
                            CountItemOk := true;
                            if SalesEntry."Linked No. not Orig." then begin
                                SalesEntry2.Reset;
                                SalesEntry2.CopyFilters(SalesEntry);
                                if SalesEntry2.FindSet() then begin
                                    repeat
                                        if (SalesEntry2."Item No." <> SalesEntry."Item No.") and SalesEntry2."Orig. of a Linked Item List" then begin
                                            LinkedItems.Reset;
                                            LinkedItems.SetRange("Item No.", SalesEntry2."Item No.");
                                            LinkedItems.SetRange("Linked Item No.", SalesEntry."Item No.");
                                            LinkedItems.SetFilter("Sales Type", '%1|%2', '', Transaction."Sales Type");
                                            if LinkedItems.FindFirst then begin
                                                if LinkedItems."Deposit Item" then
                                                    CountItemOk := false;
                                            end;
                                        end;
                                    until (SalesEntry2.Next = 0) or not CountItemOk;
                                end;
                            end;

                            if CountItemOk then begin
                                if ItemUnitOfMeasure.Get(SalesEntry."Item No.", SalesEntry."Unit of Measure") then begin
                                    if ItemUnitOfMeasure."LSC Count as 1 on Receipt" then
                                        TotalNumberOfItems := TotalNumberOfItems + 1
                                    else
                                        TotalNumberOfItems := TotalNumberOfItems + Abs(SalesEntry.Quantity);
                                end else
                                    TotalNumberOfItems := TotalNumberOfItems + Abs(SalesEntry.Quantity);
                            end;

                        end;
                    end;
                    if SalesEntry."Deal Line" then begin
                        Sender.PrintDeal(SalesEntry, Tray, PrintItemNo);
                        CollectDiscInfo(SalesEntry, Tray, TotalAmt, Subtotal, PeriodicDiscountInfoTEMP);
                        if GenPOSFunc."Print Disc/Cpn Info on Slip" = GenPOSFunc."Print Disc/Cpn Info on Slip"::"No printing" then
                            if Globals.UseSalesTax and LocalizationExt.IsNALocalizationEnabled then
                                SalesLineAmount := SalesEntry."Net Amount"
                            else
                                SalesLineAmount := SalesEntry."Net Amount" + SalesEntry."LSCIN GST Amount" + SalesEntry."VAT Amount"
                        else
                            if Globals.UseSalesTax and LocalizationExt.IsNALocalizationEnabled then
                                SalesLineAmount := SalesEntry."Net Amount" - SalesEntry."Discount Amount"
                            else
                                SalesLineAmount := SalesEntry."Net Amount" + SalesEntry."LSCIN GST Amount" - SalesEntry."Discount Amount" + SalesEntry."VAT Amount";
                        if GenPOSFunc."Print Disc/Cpn Info on Slip" = GenPOSFunc."Print Disc/Cpn Info on Slip"::"Detail information for each line" then
                            TotalAmt := TotalAmt + SalesLineAmount
                        else
                            if GenPOSFunc."Print Disc/Cpn Info on Slip" = GenPOSFunc."Print Disc/Cpn Info on Slip"::"No printing" then
                                TotalAmt := TotalAmt + SalesLineAmount;
                        //***************************************** normal line, not deal line printed with recipe-item buffer
                    end else begin
                        if not SkipCollectDiscountInfo then
                            CollectDiscInfo(SalesEntry, Tray, TotalAmt, Subtotal, PeriodicDiscountInfoTEMP);
                    end;

                    totalCustItemDisc := totalCustItemDisc + SalesEntry."Infocode Discount";

                    if not SkipCollectDiscountInfo then begin
                        i := 0;
                        j := 0;
                        VATNotSet := true;
                        if SalesEntry."Net Amount" > 0 then begin
                            if (SalesEntry."VAT Bus. Posting Group" <> '') and (SalesEntry."VAT Prod. Posting Group" <> '') then
                                if VATPostingSetup.Get(SalesEntry."VAT Bus. Posting Group", SalesEntry."VAT Prod. Posting Group") then
                                    if VATSetup.Get(VATPostingSetup."LSC POS Terminal VAT Code") then
                                        VATNotSet := false;
                            if not VATNotSet and Item.Get(SalesEntry."Item No.") then
                                if VATPostingSetup.Get(Item."VAT Bus. Posting Gr. (Price)", Item."VAT Prod. Posting Group") then
                                    if VATSetup.Get(VATPostingSetup."LSC POS Terminal VAT Code") then
                                        VATNotSet := false;
                        end;
                        if VATNotSet then
                            if VATSetup.Get(SalesEntry."VAT Code") then
                                VATNotSet := false;
                        if (VATSetup."VAT Code" <> '') and not VATNotSet then begin
                            repeat
                                i := i + 1;
                                if j = 0 then
                                    if VATCode[i] = '' then
                                        j := i;
                            until (VATCode[i] = VATSetup."VAT Code") or (i >= 5);
                            if VATCode[i] <> VATSetup."VAT Code" then begin
                                i := j;
                                VATPerc[i] := VATSetup."VAT %";
                                VATCode[i] := VATSetup."VAT Code";
                            end;
                            VATAmount[i] := VATAmount[i] + SalesEntry."VAT Amount";
                            SalesAmountVAT[i] := SalesAmountVAT[i] + SalesEntry."Net Amount" + SalesEntry."VAT Amount";
                        end;
                        LineCount := LineCount + 1;
                    end;
                end;
            until SalesEntry.Next = 0;
        end;

        RecipeBufferTEMP.Reset;
        RecipeBufferTEMP2.Reset;
        RecipeBufferTEMP.SetRange("Parent Line No.", 0);
        if OrderByDepartment then
            RecipeBufferTEMP.SetCurrentKey("Item Category Code");
        if RecipeBufferTEMP.FindSet() then
            repeat
                VATExtraCharacters := '';
                if OrderByDepartment and (RecipeBufferTEMP."Item Category Code" <> LastDepartment) then begin
                    DSTR1 := '#L######################################';
                    FieldValue[1] := RecipeBufferTEMP."Item Category Code";
                    Sender.PrintLine(Tray, Sender.FormatLine(FormatStr(Sender, FieldValue, DSTR1), false, true, false, false));
                    LastDepartment := RecipeBufferTEMP."Item Category Code";
                end;

                DiscountOnLine := 0;
                if GenPOSFunc."Print Disc/Cpn Info on Slip" in
                  [GenPOSFunc."Print Disc/Cpn Info on Slip"::"Detail information for each line",
                  GenPOSFunc."Print Disc/Cpn Info on Slip"::"Detail for each line and Sub-total",
                  GenPOSFunc."Print Disc/Cpn Info on Slip"::"Summary information below Sub-total"]
                then begin
                    DiscountOnLine := -RecipeBufferTEMP."Discount Amount";
                end;

                ItemName := GetItemName(RecipeBufferTEMP."Item No.", RecipeBufferTEMP."Variant Code", Customer."Language Code", Store."Language Code");

                DSTR1 := '#L######### #L###################';
                if PrintItemNo <> 0 then begin
                    if PrintItemNo = 1 then begin
                        FieldValue[1] := Text074;
                        NodeName[1] := 'x';
                        FieldValue[2] := RecipeBufferTEMP."Item No.";
                        NodeName[2] := 'Item No.';
                    end
                    else begin
                        if RecipeBufferTEMP."Barcode No." <> '' then begin
                            FieldValue[1] := Text075;
                            NodeName[1] := 'x';
                            FieldValue[2] := RecipeBufferTEMP."Barcode No.";
                            NodeName[2] := 'Barcode';
                        end
                        else begin
                            FieldValue[1] := Text074;
                            NodeName[1] := 'x';
                            FieldValue[2] := RecipeBufferTEMP."Item No.";
                            NodeName[2] := 'Item No.';
                        end;
                    end;
                    FieldValue[3] := Format(RecipeBufferTEMP."Line No.");
                    NodeName[3] := 'Line No.';
                    Sender.PrintLine(Tray, Sender.FormatLine(FormatStr(Sender, FieldValue, DSTR1), false, false, false, false));
                    Sender.AddPrintLine(300, 3, NodeName, FieldValue, DSTR1, false, false, false, false, Tray);
                end;


                if (Abs(RecipeBufferTEMP.Quantity) <> 1) or
                  ((RecipeBufferTEMP."UOM Quantity" <> 0) and (Abs(RecipeBufferTEMP."UOM Quantity") <> 1)) or
                  RecipeBufferTEMP."Scale Item" or               //details always printed.
                  RecipeBufferTEMP."Price in Barcode"
                then begin
                    //DSTR1 := '#L######################################'; //AlleRSN
                    DSTR1 := '#L #L###################################'; //AlleRSN   
                    NoOfItem += 1;
                    FieldValue[1] := Format(NoOfItem);
                    NodeName[1] := 'x';
                    FieldValue[2] := ItemName;
                    NodeName[2] := 'Item Description';
                    // FieldValue[1] := ItemName;
                    // NodeName[1] := 'Item Description';
                    // FieldValue[2] := Format(RecipeBufferTEMP."Line No.");
                    // NodeName[2] := 'Line No.';
                    // FieldValue[3] := RecipeBufferTEMP."Item No.";
                    // NodeName[3] := 'Item No.';
                    // FieldValue[4] := RecipeBufferTEMP."Variant Code";
                    // NodeName[4] := 'Variant Code';
                    Sender.PrintLine(Tray, Sender.FormatLine(FormatStr(Sender, FieldValue, DSTR1), false, false, false, false));
                    Sender.AddPrintLine(300, 3, NodeName, FieldValue, DSTR1, false, false, false, false, Tray);


                    DSTR1 := '   #L###################### #N##########';
                    if RecipeBufferTEMP."Scale Item" or RecipeBufferTEMP."Price in Barcode" then begin
                        if RecipeBufferTEMP."Weight Manually Entered" then
                            DSTR1 := 'MAN #L################## #N########## #R';
                        if ClientSessionUtility.FindLocalizedVersion = 'AU' then
                            FieldValue[1] := 'Net' + ' ';
                        FieldValue[1] :=
                        FieldValue[1] + LocalizationUtility.POSFunctionsFormatWeight(-RecipeBufferTEMP.Quantity, RecipeBufferTEMP."Unit of Measure")
                                 + GenPOSFunc.GetMultipleItemsSymbol();
                        TmpValue := LocalizationUtility.POSFunctionsFormatPricePrUnit(RecipeBufferTEMP.Price, RecipeBufferTEMP."Unit of Measure");
                        if Item.Get(RecipeBufferTEMP."Item No.") then
                            if RecipeBufferTEMP."Unit of Measure" <> Item."Base Unit of Measure" then begin
                                ItemSoldUOMFactor := 0;
                                if ItemUnitOfMeasure.Get(RecipeBufferTEMP."Item No.", RecipeBufferTEMP."Unit of Measure") then
                                    ItemSoldUOMFactor := ItemUnitOfMeasure."Qty. per Unit of Measure";
                                if (ItemSoldUOMFactor <> 1) and (ItemSoldUOMFactor <> 0) then begin
                                    FieldValue[1] := LocalizationUtility.POSFunctionsFormatWeight(-RecipeBufferTEMP.Quantity / ItemSoldUOMFactor, RecipeBufferTEMP."Unit of Measure")
                                    + GenPOSFunc.GetMultipleItemsSymbol();
                                    TmpValue := LocalizationUtility.POSFunctionsFormatPricePrUnit(RecipeBufferTEMP.Price * ItemSoldUOMFactor, RecipeBufferTEMP."Unit of Measure");
                                end;
                            end;
                        if StrLen(TmpValue) > StringLenBeforeSplitLine then begin
                            Sender.PrintLine(Tray, Sender.FormatLine(FormatStr(Sender, FieldValue, DSTR1), false, (RecipeBufferTEMP."Periodic Discount" <> 0), false, false));
                            FieldValue[1] := TmpValue;
                        end else
                            FieldValue[1] := FieldValue[1] + TmpValue;
                    end else begin
                        if RecipeBufferTEMP."Unit of Measure" = '' then
                            RecipeBufferTEMP."Unit of Measure" := Text131;
                        if RecipeBufferTEMP."UOM Quantity" <> 0 then begin
                            RecipeBufferTEMP.Quantity := RecipeBufferTEMP."UOM Quantity";
                            RecipeBufferTEMP.Price := RecipeBufferTEMP."UOM Price";
                        end;
                        FieldValue[1] :=
                        LocalizationUtility.POSFunctionsFormatQty(-RecipeBufferTEMP.Quantity) + ' ' + LowerCase(RecipeBufferTEMP."Unit of Measure") + GenPOSFunc.GetMultipleItemsSymbol();
                        FieldValue[1] := FieldValue[1] + LocalizationUtility.POSFunctionsFormatPrice(RecipeBufferTEMP.Price);
                    end;

                    //AlleRSN start
                    If (RecipeBufferTEMP."LSCIN GST Group Code" <> '') AND (StrLen(Format(RecipeBufferTEMP."LSCIN GST Group Code")) <= 2) THEN begin
                        GSTCode := RecipeBufferTEMP."LSCIN GST Group Code";
                        If RecipeBufferTEMP."Sales Type" = 'POS' then begin
                            SGST += ABS(RecipeBufferTEMP."LSCIN GST Amount" / 2);
                            CGST += ABS(RecipeBufferTEMP."LSCIN GST Amount" / 2);
                        end;
                    end;
                    Clear(FieldValue);
                    DSTR1 := '#L #L########## #L#### #R# #R#### #R####'; //AlleRSN
                    FieldValue[1] := '';
                    NodeName[1] := 'x';
                    FieldValue[2] := '';
                    NodeName[2] := 'Item No';
                    FieldValue[3] := RecipeBufferTEMP."LSCIN HSN/SAC Code";
                    NodeName[3] := 'HSN';
                    FieldValue[4] := LocalizationUtility.POSFunctionsFormatQty(-RecipeBufferTEMP.Quantity);
                    NodeName[4] := 'Quantity';
                    FieldValue[5] := LocalizationUtility.POSFunctionsFormatPrice(RecipeBufferTEMP.Price);
                    NodeName[5] := 'Price';
                    Clear(LineAmt);
                    LineAmt := (RecipeBufferTEMP.Price * (-RecipeBufferTEMP.Quantity));
                    FieldValue[6] := POSFunctions.FormatAmount(LineAmt);
                    NodeName[6] := 'Amount';

                    //AlleRSN end

                    // NodeName[1] := 'x';
                    // if Globals.UseSalesTax and LocalizationExt.IsNALocalizationEnabled then
                    //     FieldValue[2] := POSFunctions.FormatAmount(-(RecipeBufferTEMP."Net Amount" + DiscountOnLine))
                    // else
                    //     FieldValue[2] := POSFunctions.FormatAmount(-(RecipeBufferTEMP."Net Amount" + RecipeBufferTEMP."LSCIN GST Amount" + DiscountOnLine + RecipeBufferTEMP."VAT Amount"));
                    // NodeName[2] := 'Amount';
                    // if Globals.UseSalesTax and LocalizationExt.IsNALocalizationEnabled then begin
                    //     if RecipeBufferTEMP."VAT Amount" <> 0 then begin
                    //         FieldValue[3] := 'T';
                    //         NodeName[3] := 'VAT Code';
                    //     end else begin
                    //         FieldValue[3] := 'N';
                    //         NodeName[3] := 'VAT Code';
                    //     end;
                    // end else begin
                    //     FieldValue[3] := RecipeBufferTEMP."VAT Code";
                    //     NodeName[3] := 'VAT Code';
                    //     if (StrLen(RecipeBufferTEMP."VAT Code") > 2) then
                    //         VATExtraCharacters := CopyStr(RecipeBufferTEMP."VAT Code", 3, 8);
                    // end;
                    // FieldValue[4] := Format(RecipeBufferTEMP."Line No.");
                    // NodeName[4] := 'Line No.';
                    // FieldValue[5] := RecipeBufferTEMP."Unit of Measure";
                    // NodeName[5] := 'UOM ID';
                    // FieldValue[6] := LocalizationUtility.POSFunctionsFormatQty(-RecipeBufferTEMP.Quantity);
                    // NodeName[6] := 'Quantity';
                    // FieldValue[7] := LocalizationUtility.POSFunctionsFormatPrice(RecipeBufferTEMP.Price);
                    // NodeName[7] := 'Price';

                    Sender.PrintLine(Tray, Sender.FormatLine(FormatStr(Sender, FieldValue, DSTR1), false, (RecipeBufferTEMP."Periodic Discount" <> 0), false, false));
                    Sender.AddPrintLine(300, 7, NodeName, FieldValue, DSTR1, false, (RecipeBufferTEMP."Periodic Discount" <> 0), false, false, Tray);
                    if VATExtraCharacters <> '' then begin
                        DSTR1 := '                              #R########';
                        Clear(FieldValue);
                        FieldValue[1] := VATExtraCharacters;
                        NodeName[1] := 'VAT Code';
                        Sender.PrintLine(Tray, Sender.FormatLine(FormatStr(Sender, FieldValue, DSTR1), false, (RecipeBufferTEMP."Periodic Discount" <> 0), false, false));
                    end;
                end
                else begin
                    //DSTR1 := '#L######################### #N##########';
                    //DSTR1 := '#L #L########## #L#### #R# #R#### #R####'; //AlleRSN
                    DSTR1 := '#L #L###################################'; //AlleRSN                    
                    NoOfItem += 1;
                    FieldValue[1] := Format(NoOfItem);
                    NodeName[1] := 'x';
                    FieldValue[2] := ItemName;
                    NodeName[2] := 'Item No';
                    Sender.PrintLine(Tray, Sender.FormatLine(FormatStr(Sender, FieldValue, DSTR1), false, (RecipeBufferTEMP."Periodic Discount" <> 0), false, false));
                    Sender.AddPrintLine(300, 3, NodeName, FieldValue, DSTR1, false, (RecipeBufferTEMP."Periodic Discount" <> 0), false, false, Tray);
                    If (RecipeBufferTEMP."LSCIN GST Group Code" <> '') AND (StrLen(Format(RecipeBufferTEMP."LSCIN GST Group Code")) <= 2) THEN begin
                        GSTCode := RecipeBufferTEMP."LSCIN GST Group Code";
                        If RecipeBufferTEMP."Sales Type" = 'POS' then begin
                            SGST += ABS(RecipeBufferTEMP."LSCIN GST Amount" / 2);
                            CGST += ABS(RecipeBufferTEMP."LSCIN GST Amount" / 2);
                        end;
                    end;
                    Clear(FieldValue);
                    DSTR1 := '#L #L########## #L#### #R# #R#### #R####'; //AlleRSN
                    FieldValue[1] := '';
                    NodeName[1] := 'x';
                    FieldValue[2] := '';
                    NodeName[2] := 'Item No';
                    FieldValue[3] := RecipeBufferTEMP."LSCIN HSN/SAC Code";
                    NodeName[3] := 'HSN';
                    FieldValue[4] := LocalizationUtility.POSFunctionsFormatQty(-RecipeBufferTEMP.Quantity);
                    NodeName[4] := 'Quantity';
                    FieldValue[5] := LocalizationUtility.POSFunctionsFormatPrice(RecipeBufferTEMP.Price);
                    NodeName[5] := 'Price';
                    Clear(LineAmt);
                    LineAmt := (RecipeBufferTEMP.Price * (-RecipeBufferTEMP.Quantity));
                    FieldValue[6] := POSFunctions.FormatAmount(LineAmt);
                    NodeName[6] := 'Amount';

                    /*FieldValue[1] := ItemName;
                    if RecipeBufferTEMP."Unit of Measure" <> '' then
                        FieldValue[1] := FieldValue[1] + ' ' + LowerCase(RecipeBufferTEMP."Unit of Measure");
                    NodeName[1] := 'x';
                    if Globals.UseSalesTax and LocalizationExt.IsNALocalizationEnabled then
                        FieldValue[2] := POSFunctions.FormatAmount(-(RecipeBufferTEMP."Net Amount" + DiscountOnLine))
                    else
                        FieldValue[2] := POSFunctions.FormatAmount(-(RecipeBufferTEMP."Net Amount" + RecipeBufferTEMP."LSCIN GST Amount" + DiscountOnLine + RecipeBufferTEMP."VAT Amount"));
                    NodeName[2] := 'Amount';
                    FieldValue[3] := Format(RecipeBufferTEMP."Line No.");
                    NodeName[3] := 'Line No.';
                    FieldValue[4] := ItemName;
                    NodeName[4] := 'Item Description';
                    FieldValue[5] := RecipeBufferTEMP."Unit of Measure";
                    NodeName[5] := 'UOM ID';
                    FieldValue[6] := LocalizationUtility.POSFunctionsFormatQty(-RecipeBufferTEMP.Quantity);
                    NodeName[6] := 'Quantity';
                    FieldValue[7] := LocalizationUtility.POSFunctionsFormatPrice(RecipeBufferTEMP.Price);
                    NodeName[7] := 'Price';
                    FieldValue[8] := RecipeBufferTEMP."Item No.";
                    NodeName[8] := 'Item No.';
                    FieldValue[9] := RecipeBufferTEMP."Variant Code";
                    NodeName[9] := 'Variant Code';
                    */
                    Sender.PrintLine(Tray, Sender.FormatLine(FormatStr(Sender, FieldValue, DSTR1), false, (RecipeBufferTEMP."Periodic Discount" <> 0), false, false));
                    //Sender.AddPrintLine(300, 10, NodeName, FieldValue, DSTR1, false, (RecipeBufferTEMP."Periodic Discount" <> 0), false, false, Tray);
                    Sender.AddPrintLine(300, 7, NodeName, FieldValue, DSTR1, false, (RecipeBufferTEMP."Periodic Discount" <> 0), false, false, Tray);
                    if VATExtraCharacters <> '' then begin
                        DSTR1 := '                              #R########';
                        Clear(FieldValue);
                        FieldValue[1] := VATExtraCharacters;
                        NodeName[1] := 'VAT Code';
                        Sender.PrintLine(Tray, Sender.FormatLine(FormatStr(Sender, FieldValue, DSTR1), false, (RecipeBufferTEMP."Periodic Discount" <> 0), false, false));
                    end;
                end;
                if GenPOSFunc."Print Free Text on Receipt" then
                    Sender.PrintFreeTextLinesFromBuffer(RecipeBufferTEMP, RecipeBufferTransInfoTextTEMP, Tray, false);

                PrintItemPOSText(Sender, RecipeBufferTEMP."Item No.", Customer."Language Code", Store."Language Code", RecipeBufferTEMP."Line No.", Tray);

                RecipeBufferTransInfoTEMP.SetRange("Store No.", Transaction."Store No.");
                RecipeBufferTransInfoTEMP.SetRange("POS Terminal No.", Transaction."POS Terminal No.");
                RecipeBufferTransInfoTEMP.SetRange("Transaction No.", Transaction."Transaction No.");
                RecipeBufferTransInfoTEMP.SetRange("Transaction Type", RecipeBufferTransInfoTEMP."Transaction Type"::"Sales Entry");
                RecipeBufferTransInfoTEMP.SetRange("Line No.", RecipeBufferTEMP."Line No.");
                Sender.PrintTransInfoCode(RecipeBufferTransInfoTEMP, Tray, false);
                PrintSalesDiscountInfo(Sender, RecipeBufferTEMP, RecipeBufferDetailTEMP_l, Tray);
                RecipeBufferTEMP2.SetRange("Parent Line No.", RecipeBufferTEMP."Line No.");
                if RecipeBufferTEMP2.FindSet then
                    repeat
                        DiscountOnLine := 0;
                        if GenPOSFunc."Print Disc/Cpn Info on Slip" in
                          [GenPOSFunc."Print Disc/Cpn Info on Slip"::"Detail information for each line",
                          GenPOSFunc."Print Disc/Cpn Info on Slip"::"Detail for each line and Sub-total",
                          GenPOSFunc."Print Disc/Cpn Info on Slip"::"Summary information below Sub-total"]
                        then begin
                            DiscountOnLine := -RecipeBufferTEMP2."Discount Amount";
                        end;
                        ItemName := GetItemName(RecipeBufferTEMP2."Item No.", RecipeBufferTEMP2."Variant Code", Customer."Language Code", Store."Language Code");

                        // DSTR1 := '#L######################################';
                        // FieldValue[1] := ItemName;
                        // NodeName[1] := 'Item Description';
                        // FieldValue[2] := Format(RecipeBufferTEMP2."Line No.");
                        // NodeName[2] := 'Line No.';
                        // FieldValue[3] := RecipeBufferTEMP2."Item No.";
                        // NodeName[3] := 'Item No.';
                        // FieldValue[4] := RecipeBufferTEMP2."Variant Code";
                        // NodeName[4] := 'Variant Code';
                        DSTR1 := '#L #L###################################'; //AlleRSN   
                        FieldValue[1] := '';
                        NodeName[1] := 'x';
                        FieldValue[2] := '+' + ItemName;
                        NodeName[2] := 'Item Description';
                        Sender.PrintLine(Tray, Sender.FormatLine(FormatStr(Sender, FieldValue, DSTR1), false, false, false, false));
                        Sender.AddPrintLine(300, 3, NodeName, FieldValue, DSTR1, false, false, false, false, Tray);
                        Clear(FieldValue); //AlleRSN
                        if RecipeBufferTEMP2."Unit of Measure" = '' then
                            RecipeBufferTEMP2."Unit of Measure" := Text131;
                        if RecipeBufferTEMP2."UOM Quantity" <> 0 then begin
                            RecipeBufferTEMP2.Quantity := RecipeBufferTEMP2."UOM Quantity";
                            RecipeBufferTEMP2.Price := RecipeBufferTEMP2."UOM Price";
                        end;
                        If (RecipeBufferTEMP2."LSCIN GST Group Code" <> '') AND (StrLen(Format(RecipeBufferTEMP2."LSCIN GST Group Code")) <= 2) THEN begin
                            GSTCode := RecipeBufferTEMP2."LSCIN GST Group Code";
                            If RecipeBufferTEMP2."Sales Type" = 'POS' then begin
                                SGST += ABS(RecipeBufferTEMP2."LSCIN GST Amount" / 2);
                                CGST += ABS(RecipeBufferTEMP2."LSCIN GST Amount" / 2);
                            end;
                        end;
                        //DSTR1 := '#L###################### #N########## #R';
                        DSTR1 := '#L #L########## #L#### #R# #R#### #R####';  //AlleRSN
                        FieldValue[1] := '';
                        //LocalizationUtility.POSFunctionsFormatQty(-RecipeBufferTEMP2.Quantity) + ' ' + LowerCase(RecipeBufferTEMP2."Unit of Measure") + GenPOSFunc.GetMultipleItemsSymbol();
                        //FieldValue[1] := FieldValue[1] + LocalizationUtility.POSFunctionsFormatPrice(RecipeBufferTEMP2.Price);
                        NodeName[1] := 'x';
                        // if Globals.UseSalesTax and LocalizationExt.IsNALocalizationEnabled then
                        //     FieldValue[2] := POSFunctions.FormatAmount(-(RecipeBufferTEMP2."Net Amount" + DiscountOnLine))
                        // else
                        //    FieldValue[2] := POSFunctions.FormatAmount(-(RecipeBufferTEMP2."Net Amount" + RecipeBufferTEMP2."LSCIN GST Amount" + DiscountOnLine + RecipeBufferTEMP2."VAT Amount"));
                        //FieldValue[2] := ItemName;
                        FieldValue[2] := '';
                        NodeName[2] := 'Item Description';
                        FieldValue[3] := RecipeBufferTEMP2."LSCIN HSN/SAC Code";
                        NodeName[3] := 'HSN';
                        FieldValue[4] := LocalizationUtility.POSFunctionsFormatQty(-RecipeBufferTEMP2.Quantity);
                        NodeName[4] := 'Quantity';
                        FieldValue[5] := LocalizationUtility.POSFunctionsFormatPrice(RecipeBufferTEMP2.Price);
                        NodeName[5] := 'Price';
                        Clear(LineAmt);
                        LineAmt := (RecipeBufferTEMP2.Price * (-RecipeBufferTEMP2.Quantity));
                        FieldValue[6] := POSFunctions.FormatAmount(LineAmt);
                        NodeName[6] := 'Amount';
                        // NodeName[2] := 'Amount';
                        // FieldValue[3] := RecipeBufferTEMP2."VAT Code";
                        // NodeName[3] := 'VAT Code';
                        // FieldValue[4] := Format(RecipeBufferTEMP2."Line No.");
                        // NodeName[4] := 'Line No.';
                        // FieldValue[5] := RecipeBufferTEMP2."Unit of Measure";
                        // NodeName[5] := 'UOM ID';
                        // FieldValue[6] := LocalizationUtility.POSFunctionsFormatQty(-RecipeBufferTEMP2.Quantity);
                        // NodeName[6] := 'Quantity';
                        // FieldValue[7] := LocalizationUtility.POSFunctionsFormatPrice(RecipeBufferTEMP2.Price);
                        // NodeName[7] := 'Price';
                        Sender.PrintLine(Tray, Sender.FormatLine(FormatStr(Sender, FieldValue, DSTR1), false, (RecipeBufferTEMP2."Periodic Discount" <> 0), false, false));
                        Sender.AddPrintLine(300, 7, NodeName, FieldValue, DSTR1, false, false, false, false, Tray);

                        PrintSalesDiscountInfo(Sender, RecipeBufferTEMP2, RecipeBufferDetailTEMP_l, Tray);

                    until RecipeBufferTEMP2.Next = 0;
            until RecipeBufferTEMP.Next = 0;

        if LineCount > 0 then
            Sender.PrintSeperator(Tray);

        if (not Globals.UseSalesTax) or (not LocalizationExt.IsNALocalizationEnabled) then begin
            if totalCustItemDisc <> 0 then begin
                DSTR1 := '#L################# #R###############   ';
                FieldValue[1] := Text086;
                NodeName[1] := 'Total Text';
                FieldValue[2] := POSFunctions.FormatAmount(totalCustItemDisc);
                NodeName[2] := 'Total Amount';
                Sender.PrintLine(Tray, Sender.FormatLine(FormatStr(Sender, FieldValue, DSTR1), false, false, false, false));
                Sender.AddPrintLine(600, 2, NodeName, FieldValue, DSTR1, false, false, false, false, Tray);
            end;

            if Transaction."Customer Discount" <> 0 then begin
                DSTR1 := '#L#################### #R###############';
                FieldValue[1] := Text085;
                NodeName[1] := 'Total Text';
                FieldValue[2] := POSFunctions.FormatAmount(-Transaction."Customer Discount");
                NodeName[2] := 'Total Amount';
                Sender.PrintLine(Tray, Sender.FormatLine(FormatStr(Sender, FieldValue, DSTR1), false, false, false, false));
                Sender.AddPrintLine(600, 2, NodeName, FieldValue, DSTR1, false, false, false, false, Tray);
            end;

            if (totalCustItemDisc <> 0) or (Transaction."Customer Discount" <> 0) then
                Sender.PrintSeperator(Tray);
        end;

        IncExpEntry.SetRange("Store No.", Transaction."Store No.");
        IncExpEntry.SetRange("POS Terminal No.", Transaction."POS Terminal No.");
        IncExpEntry.SetRange("Transaction No.", Transaction."Transaction No.");
        if IncExpEntry.FindSet() then begin
            repeat
                if not IncExpEntry."System-Exclude From Print" then begin

                    IncomeExpenseLinePrinted := true;

                    IncExpAcc.Get(IncExpEntry."Store No.", IncExpEntry."No.");
                    if (IncExpAcc."Gratuity Type" = IncExpAcc."Gratuity Type"::Tips) and
                    (IncExpAcc."Account Type" = IncExpAcc."Account Type"::Expense)
                    then begin
                        if not (TipsStaff_l.Get(IncExpEntry."Staff ID")) then
                            TipsStaff_l."Name on Receipt" := IncExpEntry."Staff ID";
                        IncExpAcc.Description :=
                        CopyStr(IncExpAcc.Description + ' ' + TipsStaff_l."Name on Receipt", 1, MaxStrLen(IncExpAcc.Description));
                    end;

                    DSTR1 := '#L#################### #N############';
                    FieldValue[1] := IncExpAcc.Description;
                    NodeName[1] := 'Inc./Exp. Description';
                    if Globals.UseSalesTax and LocalizationExt.IsNALocalizationEnabled then
                        FieldValue[2] := POSFunctions.FormatAmount(-IncExpEntry."Net Amount")
                    else
                        FieldValue[2] := POSFunctions.FormatAmount(-IncExpEntry.Amount);
                    NodeName[2] := 'Amount';
                    FieldValue[3] := IncExpEntry."VAT Code";
                    NodeName[3] := 'VAT Code';
                    FieldValue[4] := Format(IncExpEntry."Line No.");
                    NodeName[4] := 'Line No.';
                    FieldValue[5] := IncExpEntry."No.";
                    NodeName[5] := 'Income/Expense No.';
                    DSTR1 := '#L#################### #N############ #R';
                    if IncExpEntry."VAT Code" <> '' then begin
                        i := 0;
                        j := 0;
                        if VATSetup.Get(IncExpEntry."VAT Code") then begin
                            repeat
                                i := i + 1;
                                if j = 0 then
                                    if VATCode[i] = '' then
                                        j := i;
                            until (VATCode[i] = VATSetup."VAT Code") or (i >= 5);
                            if VATCode[i] <> VATSetup."VAT Code" then begin
                                i := j;
                                VATPerc[i] := VATSetup."VAT %";
                                VATCode[i] := VATSetup."VAT Code";
                            end;
                            VATAmount[i] := VATAmount[i] + IncExpEntry."VAT Amount";
                            if Globals.UseSalesTax and LocalizationExt.IsNALocalizationEnabled then
                                SalesAmountVAT[i] := SalesAmountVAT[i] + IncExpEntry."Net Amount"
                            else
                                SalesAmountVAT[i] := SalesAmountVAT[i] + IncExpEntry.Amount;
                        end;
                    end;
                    if Globals.UseSalesTax and LocalizationExt.IsNALocalizationEnabled then
                        TotalAmt := TotalAmt + IncExpEntry."Net Amount"
                    else
                        TotalAmt := TotalAmt + IncExpEntry.Amount;

                    if Globals.UseSalesTax and LocalizationExt.IsNALocalizationEnabled then
                        Subtotal := Subtotal + IncExpEntry."Net Amount"
                    else
                        Subtotal := Subtotal + IncExpEntry.Amount;
                    ThisIsAHospTipsLine := false;
                    if IncExpEntry."No." <> '' then begin
                        if IncExpEntry."No." = HospitalityType."Tips Income Acc. 1" then begin
                            ThisIsAHospTipsLine := true;
                            TipsAmount1 := TipsAmount1 + IncExpEntry.Amount;
                            if TipsText1 = '' then begin
                                IncomeExpenseAccount.Reset;
                                IncomeExpenseAccount.SetRange("Store No.", Transaction."Store No.");
                                IncomeExpenseAccount.SetRange("No.", IncExpEntry."No.");
                                if IncomeExpenseAccount.FindFirst then
                                    TipsText1 := IncomeExpenseAccount.Description
                                else
                                    TipsText1 := Text321;
                            end
                        end
                        else
                            if IncExpEntry."No." = HospitalityType."Tips Income Acc. 2" then begin
                                ThisIsAHospTipsLine := true;
                                TipsAmount2 := TipsAmount2 + IncExpEntry.Amount;
                                if TipsText2 = '' then begin
                                    IncomeExpenseAccount.Reset;
                                    IncomeExpenseAccount.SetRange("Store No.", Transaction."Store No.");
                                    IncomeExpenseAccount.SetRange("No.", IncExpEntry."No.");
                                    if IncomeExpenseAccount.FindFirst then
                                        TipsText2 := IncomeExpenseAccount.Description
                                    else
                                        TipsText2 := Text321;
                                end;
                            end;
                    end;

                    if not ThisIsAHospTipsLine then begin
                        Sender.PrintLine(Tray, Sender.FormatLine(FormatStr(Sender, FieldValue, DSTR1), false, false, false, false));
                        Sender.AddPrintLine(340, 5, NodeName, FieldValue, DSTR1, false, false, false, false, Tray);
                        if Transaction."Customer Order ID" <> '' then begin
                            Clear(FieldValue);
                            FieldValue[1] := 'ID: ' + Transaction."Customer Order ID";
                            NodeName[1] := 'Customer Order ID';
                            Sender.PrintLine(Tray, Sender.FormatLine(FormatStr(Sender, FieldValue, DSTR1), false, false, false, false));
                            Sender.AddPrintLine(340, 5, NodeName, FieldValue, DSTR1, false, false, false, false, Tray);
                        end;
                        FieldValue[1] := Format(IncExpEntry."Line No.");
                        NodeName[1] := 'Line No.';
                        NodeName[2] := 'Extra Info Line';
                        if IncExpAcc."Slip Text 1" <> '' then begin
                            Sender.PrintLine(Tray, IncExpAcc."Slip Text 1");
                            FieldValue[2] := IncExpAcc."Slip Text 1";
                            Sender.AddPrintLine(350, 2, NodeName, FieldValue, DSTR1, false, false, false, false, Tray);
                        end;
                        if IncExpAcc."Slip Text 2" <> '' then begin
                            Sender.PrintLine(Tray, IncExpAcc."Slip Text 2");
                            FieldValue[2] := IncExpAcc."Slip Text 2";
                            Sender.AddPrintLine(350, 2, NodeName, FieldValue, DSTR1, false, false, false, false, Tray);
                        end;
                    end;
                    TransInfoEntry.SetRange("Store No.", Transaction."Store No.");
                    TransInfoEntry.SetRange("POS Terminal No.", Transaction."POS Terminal No.");
                    TransInfoEntry.SetRange("Transaction No.", Transaction."Transaction No.");
                    TransInfoEntry.SetRange("Transaction Type", TransInfoEntry."Transaction Type"::"Income/Expense Entry");
                    TransInfoEntry.SetRange("Line No.", IncExpEntry."Line No.");
                    Sender.PrintTransInfoCode(TransInfoEntry, Tray, false);
                end;
            until IncExpEntry.Next = 0;
            if IncomeExpenseLinePrinted then
                Sender.PrintSeperator(Tray);
        end;

        if Transaction."Transaction Type" = Transaction."Transaction Type"::Sales then
            if Globals.UseSalesTax and LocalizationExt.IsNALocalizationEnabled then
                PrintTotal(Sender, Transaction, Tray, 3, true)
            else
                PrintTotal(Sender, Transaction, Tray, 3, false);

        //AlleRSN start
        IF Transaction."Sales Type" <> 'POS' Then begin
            SGST := ABS(Transaction."LSCIN GST Amount" / 2);
            CGST := ABS(Transaction."LSCIN GST Amount" / 2);
        end;
        IF Transaction."Wallet Balance" = '' Then begin
            DSTR1 := '#R################################ #R###';
            NodeName[1] := 'SGST Text';
            NodeName[2] := 'SGST Amount';
            FieldValue[1] := 'SGST @ ' + GSTCode + '% :';
            FieldValue[2] := POSFunctions.FormatAmount(SGST);
            Sender.PrintLine(Tray, Sender.FormatLine(FormatStr(Sender, FieldValue, DSTR1), false, false, false, false));
            Sender.AddPrintLine(800, 2, NodeName, FieldValue, DSTR1, false, false, false, false, Tray);

            DSTR1 := '#R################################ #R###';
            NodeName[1] := 'CGST Text';
            NodeName[2] := 'CGST Amount';
            FieldValue[1] := 'CGST @ ' + GSTCode + '% :';
            FieldValue[2] := POSFunctions.FormatAmount(CGST);
            Sender.PrintLine(Tray, Sender.FormatLine(FormatStr(Sender, FieldValue, DSTR1), false, false, false, false));
            Sender.AddPrintLine(800, 2, NodeName, FieldValue, DSTR1, false, false, false, false, Tray);
            //AlleRSN end
        end;
        if not Transaction."Post as Shipment" then
            PrintPaymInfo(Sender, Transaction, Tray);

        clear(CGST);
        IF Transaction."Wallet Balance" <> '' Then begin
            IF Evaluate(CGST, Transaction."Wallet Balance") Then;
            CGST += ABS(Transaction."Net Amount");
            DSTR1 := '#L######################################';
            NodeName[1] := 'Wallet Amount';
            //NodeName[2] := 'Wallet Amount';
            FieldValue[1] := 'Wallet Balance: ' + POSFunctions.FormatAmount(CGST);
            //FieldValue[2] := POSFunctions.FormatAmount(CGST);
            Sender.PrintLine(Tray, Sender.FormatLine(FormatStr(Sender, FieldValue, DSTR1), false, false, false, false));
            Sender.AddPrintLine(800, 2, NodeName, FieldValue, DSTR1, false, false, false, false, Tray);
        end;

        //Transaction.Rounded := 0;

        // //AlleRSN start
        // DSTR1 := '#L######################################';
        // Clear(CGST);
        // CGST := -Transaction."Gross Amount" + Transaction.Rounded;
        // FieldValue[1] := 'Grand Total: Rs. ' + POSFunctions.FormatAmount(CGST);
        // NodeName[1] := 'Tender Description';
        // Sender.PrintLine(Tray, Sender.FormatLine(FormatStr(Sender, FieldValue, DSTR1), false, true, true, false));
        // Sender.AddPrintLine(200, 5, NodeName, FieldValue, DSTR2, false, true, true, false, Tray);

        // //AlleRSN end

        if POSTerminal."Print Number of Items" and (TotalNumberOfItems <> 0) then begin
            Clear(FieldValue);
            DSTR1 := '#L####################### #R#########';
            FieldValue[1] := Text151;
            NodeName[1] := 'Total Text';
            FieldValue[2] := LocalizationUtility.POSFunctionsFormatQty(TotalNumberOfItems);
            NodeName[2] := 'Total Amount';
            Sender.PrintLine(Tray, Sender.FormatLine(FormatStr(Sender, FieldValue, DSTR1), false, false, false, false));
            Sender.AddPrintLine(800, 2, NodeName, FieldValue, DSTR1, false, false, false, false, Tray);
            Sender.PrintSeperator(Tray);
        end;

        if POSTerminal."Print Total Savings" and (TotalSavings <> 0) then begin
            Clear(FieldValue);
            DSTR1 := '#L####################### #R#########';
            FieldValue[1] := Text152;
            NodeName[1] := 'Total Text';
            FieldValue[2] := POSFunctions.FormatAmount(TotalSavings);
            NodeName[2] := 'Total Amount';
            Sender.PrintLine(Tray, Sender.FormatLine(FormatStr(Sender, FieldValue, DSTR1), false, false, false, false));
            Sender.AddPrintLine(800, 2, NodeName, FieldValue, DSTR1, false, false, false, false, Tray);
            Sender.PrintSeperator(Tray);
        end;
        /*
        Clear(IsHandled);
        //OnBeforePrintSalesINVATInfo(Transaction, PrintBuffer, PrintBufferIndex, LinesPrinted, Tray, IsHandled);
        if GenPosFunc.Get(Globals.FunctionalityProfileID) then;
        if not IsHandled then begin
            VATPrinted := false;
            if not GenPOSFunc."Skip VAT on Receipt" and not Transaction."Post as Shipment" then begin
                if GenPOSFunc."LSCIN Print VAT from Tax Eng." then
                    PrintPostedVATInfo(Sender, Tray, Transaction)
                else begin
                    for i := 1 to 5 do begin
                        if VATCode[i] <> '' then begin
                            if i = 1 then begin
                                Clear(FieldValue);
                                DSTR1 := '#L####################################';
                                FieldValue[1] := Text507;
                                Sender.PrintLine(Tray, Sender.FormatLine(FormatStr(Sender, FieldValue, DSTR1), false, true, false, false));
                                Sender.PrintSeperator(Tray);
                                DSTR1 := '#R####% #R######## #R######## #R########';
                                FieldValue[1] := Text063;
                                FieldValue[2] := Text063_2;
                                FieldValue[3] := Text063;
                                FieldValue[4] := Text004;
                                Sender.PrintLine(Tray, Sender.FormatLine(FormatStr(Sender, FieldValue, DSTR1), false, false, false, false));
                            end;
                            DSTR1 := '#L #N## #N######## #N######## #N########';
                            VATPrinted := true;
                            FieldValue[1] := VATCode[i];
                            NodeName[1] := 'VAT Code';
                            FieldValue[2] := Format(VATPerc[i]);
                            NodeName[2] := 'VAT %';
                            FieldValue[3] := POSFunctions.FormatAmount(-SalesAmountVAT[i] + VATAmount[i]);
                            NodeName[3] := 'Net Amount';
                            FieldValue[4] := POSFunctions.FormatAmount(-VATAmount[i]);
                            NodeName[4] := 'VAT Amount';
                            FieldValue[5] := POSFunctions.FormatAmount(-SalesAmountVAT[i]);
                            NodeName[5] := 'Amount';
                            Sender.PrintLine(Tray, Sender.FormatLine(FormatStr(Sender, FieldValue, DSTR1), false, false, false, false));
                            Sender.AddPrintLine(900, 5, NodeName, FieldValue, DSTR1, false, false, false, false, Tray);
                        end;
                    end;
                end;

                if VATPrinted then
                    Sender.PrintSeperator(Tray);
            end;

            Clear(IsHandled);
            //OnBeforePrintSalesINGSTInfo(Transaction, PrintBuffer, PrintBufferIndex, LinesPrinted, Tray, IsHandled);
            IF NOT IsHandled THEN
                PrintPostedGSTInfo(Sender, Tray, Transaction);

            if CompInfo.Get then
                if (CompInfo."VAT Registration No." <> '') and (GenPOSFunc."VAT Reg.No. on Receipt") then begin
                    Sender.PrintLine(Tray, '');
                    FieldValue[1] := Text133;
                    NodeName[1] := 'x';
                    FieldValue[2] := CompInfo."VAT Registration No.";
                    NodeName[2] := 'VAT Registration No.';
                    DSTR1 := '#L########### #L###################   ';
                    Sender.PrintLine(Tray, Sender.FormatLine(FormatStr(Sender, FieldValue, DSTR1), false, false, false, false));
                    Sender.AddPrintLine(200, 2, NodeName, FieldValue, DSTR1, false, false, false, false, Tray);
                end;
        end;
        if VATPrinted then
            Sender.PrintSeperator(Tray);
        */

        if POSTerminal."Print Discount Detail" then begin
            DSTR1 := '#L################# #R###############   ';
            discountSection := false;
            if (PerDiscOffArrCount > 0) then begin
                Sender.PrintLine(Tray, Sender.FormatLine(CopyStr(Text088, 1, LineLen), false, false, false, false));
                discountSection := true;
            end;

            for i := 1 to PerDiscOffArrCount do begin
                maxCounter := 0;
                MixMatchEntry.SetRange("Store No.", SalesEntry."Store No.");
                MixMatchEntry.SetRange("POS Terminal No.", SalesEntry."POS Terminal No.");
                MixMatchEntry.SetRange("Transaction No.", SalesEntry."Transaction No.");
                if MixMatchEntry.FindSet() then
                    repeat
                        if MixMatchEntry."Mix & Match Group" = PerDiscOffArr[i] then
                            if MixMatchEntry.Counter > maxCounter then
                                maxCounter := MixMatchEntry.Counter;
                    until MixMatchEntry.Next = 0;

                if PeriodicDiscount.Get(PerDiscOffArr[i]) then begin
                    if maxCounter = 0 then
                        FieldValue[1] := PeriodicDiscount.Description
                    else
                        FieldValue[1] := Format(maxCounter) + 'x ' + PeriodicDiscount.Description;
                end else
                    FieldValue[1] := Format(PeriodicDiscount.Type);
                FieldValue[2] := POSFunctions.FormatAmount(PerDiscOffAmtArr[i]);
                Sender.PrintLine(Tray, Sender.FormatLine(FormatStr(Sender, FieldValue, DSTR1), false, false, false, false));
            end;
        end;

        if discountSection then
            Sender.PrintSeperator(Tray);

        if Tray = 2 then
            Sender.PrintCardSlipFromEFTEmbedded('E', Transaction);

        glTrans.Init;
        //IsHandled := true;
    end;

    local procedure GetItemName(ItemNo: Code[20]; VariantCode: Code[20]; CustLanguageCode: Code[10]; StoreLanguageCode: Code[10]): Text
    var
        Item: Record Item;
        ItemVariant: Record "Item Variant";
        ItemName: Text;
        Handled: Boolean;
    begin
        if Item.Get(ItemNo) then begin
            if (VariantCode <> '') and
               (ItemVariant.Get(ItemNo, VariantCode))
            then
                ItemName := CopyStr(ItemVariant.Description, 1, 37)//20)
            else
                ItemName := CopyStr(Item.Description, 1, 37);//20);
        end else begin
            ItemName := ItemNo;
        end;

        GetItemNameTranslation(ItemNo, VariantCode, CustLanguageCode, StoreLanguageCode, ItemName);
        exit(ItemName);
    end;

    local procedure GetItemNameTranslation(ItemNo: Code[20]; VariantCode: Code[20]; CustLanguageCode: Code[10]; StoreLanguageCode: Code[10]; var ItemName: Text)
    var
        ItemTranslation: Record "Item Translation";
    begin
        Clear(ItemTranslation);
        if CustLanguageCode <> '' then begin
            if not ItemTranslation.Get(ItemNo, VariantCode, CustLanguageCode) then
                if StoreLanguageCode <> '' then
                    if ItemTranslation.Get(ItemNo, VariantCode, StoreLanguageCode) then;
        end else
            if StoreLanguageCode <> '' then
                if ItemTranslation.Get(ItemNo, VariantCode, StoreLanguageCode) then;

        if ItemTranslation.Description <> '' then
            ItemName := CopyStr(ItemTranslation.Description, 1, 37);//20);
    end;

    local procedure PrintSalesDiscountInfo(var Sender: Codeunit "LSC POS Print Utility"; var
                                                                                             RecipeBufferTEMP: Record "LSC Trans. Sales Entry" temporary;

    var
        RecipeBufferDetailTEMP: Record "LSC Trans. Discount Entry" temporary;
        Tray: Integer)
    var
        PeriodicDiscount: Record "LSC Periodic Discount";
        CouponHeader: Record "LSC Coupon Header";
        DSTR2: Text[100];
        DiscountText: Text[80];
    begin
        if GenPOSFunc."Print Disc/Cpn Info on Slip" in
          [GenPOSFunc."Print Disc/Cpn Info on Slip"::"Detail for each line and Sub-total",
          GenPOSFunc."Print Disc/Cpn Info on Slip"::"Detail information for each line"]
        then begin
            RecipeBufferDetailTEMP.Reset;
            RecipeBufferDetailTEMP.SetRange("Store No.", RecipeBufferTEMP."Store No.");
            RecipeBufferDetailTEMP.SetRange("POS Terminal No.", RecipeBufferTEMP."POS Terminal No.");
            RecipeBufferDetailTEMP.SetRange("Transaction No.", RecipeBufferTEMP."Transaction No.");
            RecipeBufferDetailTEMP.SetRange(RecipeLineNo, RecipeBufferTEMP."Line No.");
            if RecipeBufferDetailTEMP.FindSet then
                repeat
                    if RecipeBufferDetailTEMP."Offer Type" = RecipeBufferDetailTEMP."Offer Type"::Line then
                        DiscountText := Text084
                    else
                        DiscountText := Format(RecipeBufferDetailTEMP."Offer Type");
                    Clear(PeriodicDiscount);
                    if RecipeBufferDetailTEMP."Offer Type" = RecipeBufferDetailTEMP."Offer Type"::Coupon then begin
                        if CouponHeader.Get(RecipeBufferDetailTEMP."Offer No.") then
                            DiscountText := CouponHeader.Description;
                    end else
                        if PeriodicDiscount.Get(RecipeBufferDetailTEMP."Offer No.") then
                            DiscountText := PeriodicDiscount.Description
                        else
                            case RecipeBufferDetailTEMP."Offer Type" of
                                RecipeBufferDetailTEMP."Offer Type"::Total:
                                    DiscountText := Text024;
                                RecipeBufferDetailTEMP."Offer Type"::Line:
                                    DiscountText := Text084;
                                else
                                    DiscountText := Format(RecipeBufferDetailTEMP."Offer Type");
                            end;
                    DiscountText := ConvertStr(DiscountText, '&', '+');
                    if not PeriodicDiscount."Block Printing" then begin
                        if not RecipeBufferTEMP."Deal Line" then begin
                            if RecipeBufferDetailTEMP."Discount Amount" <> 0 then begin
                                if not ((RecipeBufferDetailTEMP."Offer Type" = RecipeBufferDetailTEMP."Offer Type"::Total) and
                                (GenPOSFunc."Print Disc/Cpn Info on Slip" =
                                GenPOSFunc."Print Disc/Cpn Info on Slip"::"Detail for each line and Sub-total")) then begin
                                    DSTR2 := '   #L################# #N############   ';
                                    FieldValue[1] := DiscountText;
                                    NodeName[1] := 'Detail Text';
                                    FieldValue[2] := POSFunctions.FormatAmount(-RecipeBufferDetailTEMP."Discount Amount");
                                    NodeName[2] := 'Detail Amount';
                                    FieldValue[3] := Format(RecipeBufferTEMP."Line No.");
                                    NodeName[3] := 'Line No.';
                                    Sender.PrintLine(Tray, Sender.FormatLine(FormatStr(Sender, FieldValue, DSTR2), false, false, false, false));
                                    Sender.AddPrintLine(360, 3, NodeName, FieldValue, DSTR2, false, false, false, false, Tray);
                                end;
                            end;
                            if RecipeBufferDetailTEMP.Points <> 0 then begin
                                DSTR2 := '   #L################# #N############   ';
                                FieldValue[1] := DiscountText;
                                NodeName[1] := 'Detail Text';
                                FieldValue[2] := POSFunctions.FormatAmount(RecipeBufferDetailTEMP.Points) + ' ' + Text232;
                                NodeName[2] := 'x';
                                FieldValue[3] := Format(RecipeBufferTEMP."Line No.");
                                NodeName[3] := 'Line No.';
                                FieldValue[4] := POSFunctions.FormatAmount(RecipeBufferDetailTEMP.Points);
                                NodeName[4] := 'Detail Amount';
                                Sender.PrintLine(Tray, Sender.FormatLine(FormatStr(Sender, FieldValue, DSTR2), false, false, false, false));
                                Sender.AddPrintLine(360, 4, NodeName, FieldValue, DSTR2, false, false, false, false, Tray);
                            end;
                        end;
                    end;
                until RecipeBufferDetailTEMP.Next = 0;
        end;
    end;

    local procedure PrintItemPOSText(var Sender: Codeunit "LSC POS Print Utility"; ItemNo: Code[20]; CustLanguageCode: Code[10]; StoreLanguageCode: Code[10]; LineNo: Integer; Tray: Integer)
    var
        ItemPosTextHeader: Record "LSC Item POS Text Header";
        ItemPosTextLine: Record "LSC Item POS Text Line";
        DSTR1: Text[100];
        IsHandled: Boolean;
        TextFound: Boolean;
    begin
        TextFound := false;
        Clear(ItemPosTextHeader);
        if CustLanguageCode <> '' then
            if ItemPosTextHeader.Get(ItemNo, ItemPosTextHeader."Text Type"::"Receipt Text", CustLanguageCode) then
                TextFound := true;
        if not TextFound then
            if StoreLanguageCode <> '' then
                if ItemPosTextHeader.Get(ItemNo, ItemPosTextHeader."Text Type"::"Receipt Text", StoreLanguageCode) then
                    TextFound := true;
        if not TextFound then
            if ItemPosTextHeader.Get(ItemNo, ItemPosTextHeader."Text Type"::"Receipt Text", '') then
                TextFound := true;

        if TextFound then begin
            ItemPosTextLine.Reset;
            ItemPosTextLine.SetRange("Item No.", ItemPosTextHeader."Item No.");
            ItemPosTextLine.SetRange("Text Type", ItemPosTextLine."Text Type"::"Receipt Text");
            ItemPosTextLine.SetRange("Language Code", ItemPosTextHeader."Language Code");
            DSTR1 := '#T######################################';
            if ItemPosTextLine.FindSet() then
                repeat
                    FieldValue[1] := ItemPosTextLine.Text;
                    NodeName[1] := 'Extra Info Line';
                    FieldValue[2] := Format(LineNo);
                    NodeName[2] := 'Line No.';
                    Sender.PrintLine(Tray, ItemPosTextLine.Text);
                    Sender.AddPrintLine(350, 2, NodeName, FieldValue, DSTR1, false, false, false, false, Tray);
                until ItemPosTextLine.Next = 0;
        end;
    end;

    procedure FormatStr(var Sender: Codeunit "LSC POS Print Utility"; Value: array[10] of Text; Design: Text): Text
    var
        Stars: Text;
        Blanks: Text;
        Zeros: Text;
        Type: Text[1];
        AddToStr: Text;
        DesignCopy: Text;
        k: Integer;
        Pos: Integer;
        Pos2: Integer;
        Len: Integer;
        LenValue: Integer;
        a: Integer;
        b: Integer;
        tmpPos: Integer;
    begin
        if LineLen <> 40 then
            Sender.ResizeDesignText(Design, LineLen);

        DesignCopy := CopyStr(Design, 1);
        Stars := '***************************************************************************************************************************************************************';
        Blanks := '                                                                                                                                                               ';
        Zeros := '000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000';

        k := 0;
        Pos := StrPos(Design, '#');
        if Pos = 0 then
            exit('');
        while Pos <> 0 do begin
            Pos2 := Pos;
            Type := CopyStr(Design, Pos + 1, 1);
            Pos2 := Pos + 2;
            while CopyStr(Design, Pos2, 1) = '#' do
                Pos2 := Pos2 + 1;
            k := k + 1;
            Len := Pos2 - Pos;
            LenValue := StrLen(Value[k]);
            if Len < LenValue then begin
                if (Type = 'N') or (Type = 'Z') then
                    AddToStr := CopyStr(Stars, 1, Len)
                else
                    AddToStr := CopyStr(Value[k], 1, Len);
            end
            else begin
                case Type of
                    'N':
                        AddToStr := CopyStr(Blanks, 1, Len - LenValue) + Value[k];
                    'Z':
                        AddToStr := CopyStr(Zeros, 1, Len - LenValue) + Value[k];
                    'T':
                        AddToStr := Value[k];
                    'L':
                        AddToStr := Value[k] + CopyStr(Blanks, 1, Len - LenValue);
                    'R':
                        AddToStr := CopyStr(Blanks, 1, Len - LenValue) + Value[k];
                    'C':
                        begin
                            a := Round((Len - LenValue) / 2, 1, '<');
                            b := Len - LenValue - a;
                            AddToStr := CopyStr(Blanks, 1, a) + Value[k] + CopyStr(Blanks, 1, b);
                        end;
                end;
            end;
            tmpPos := StrPos(CopyStr(Design, Pos2), '#');
            if Pos <> 1 then
                Design := CopyStr(Design, 1, Pos - 1) + AddToStr + CopyStr(Design, Pos2)
            else
                Design := AddToStr + CopyStr(Design, Pos2);

            if tmpPos <> 0 then
                if (Type = 'T') and (LenValue < Len) then
                    Pos := Pos2 + tmpPos - Len + LenValue - 1
                else
                    Pos := Pos2 + tmpPos - 1
            else
                Pos := 0;
        end;
        exit(Design + '<#DESN>' + DesignCopy);
    end;

    procedure PrintTotal(var Sender: Codeunit "LSC POS Print Utility"; Transaction: Record "LSC Transaction Header"; Tray: Integer; RightIndent: Integer; PrintTax: Boolean): Boolean
    var
        CurrencyExchRate: Record "Currency Exchange Rate";
        lPOSTransPeriodicDisc: Record "LSC POS Trans. Per. Disc. Type";
        DSTR1: Text[50];
        TotalDiscountCode: Code[20];
        SecTotal: Decimal;
        Total: Decimal;
        TotalAmtForSummary: Decimal;
        SecSubTotal: Decimal;
        TotalDiscAmt: Decimal;
        IsHandled: Boolean;
        ReturnValue: Boolean;
        gltesttotal: Label 'gl total';
    begin
        Clear(FieldValue);
        Clear(Currency);

        Total := -Transaction."Gross Amount" - Transaction."Income/Exp. Amount" + totSPOAmount;
        TotalDiscAmt := 0;

        if GenPOSFunc."Display Secondary Total Curr" and (GenPOSFunc."Secondary Total Currency" <> '') then begin
            if not Currency.Get(GenPOSFunc."Secondary Total Currency") then
                Clear(Currency);
            SecTotal := Round(CurrencyExchRate.ExchangeAmtFCYToFCY(Transaction.Date, Transaction."Trans. Currency", Currency.Code,
                              Total), Currency."Amount Rounding Precision");
        end;
        // if (GenPOSFunc."Print Disc/Cpn Info on Slip" =
        //     GenPOSFunc."Print Disc/Cpn Info on Slip"::"Summary information below Sub-total") or
        //    (GenPOSFunc."Print Disc/Cpn Info on Slip" =
        //     GenPOSFunc."Print Disc/Cpn Info on Slip"::"Detail for each line and Sub-total") or
        //    (GenPOSFunc."Print Disc/Cpn Info on Slip" =
        //     GenPOSFunc."Print Disc/Cpn Info on Slip"::"Detail information for each line")
        // then begin
        //     PeriodicDiscountInfoTEMP.Reset;
        //     PeriodicDiscountInfoTEMP.SetCurrentKey(Status, Type);
        //     NodeName[1] := 'Totl Text';
        //     NodeName[2] := 'Total Amount';
        //     if PeriodicDiscountInfoTEMP.FindSet then begin
        //         DSTR1 := '#L#################    #R###############';
        //         FieldValue[1] := Text042 + ' ' + Globals.GetValue('CURRSYM');
        //         FieldValue[2] := POSFunctions.FormatAmount(-Subtotal + TipsAmount1 + TipsAmount2);
        //         Sender.PrintLine(Tray, Sender.FormatLine(FormatStr(Sender, FieldValue, DSTR1), false, false, false, false));
        //         Sender.AddPrintLine(800, 2, NodeName, FieldValue, DSTR1, false, false, false, false, Tray);
        //         TotalAmtForSummary := Subtotal;
        //         repeat
        //             if (GenPOSFunc."Print Disc/Cpn Info on Slip" =
        //               GenPOSFunc."Print Disc/Cpn Info on Slip"::"Detail for each line and Sub-total") and
        //               (PeriodicDiscountInfoTEMP.Description <> Text024) then
        //                 PeriodicDiscountInfoTEMP."Discount Amount Value" := 0;
        //             if PeriodicDiscountInfoTEMP."Discount Amount Value" <> 0 then begin
        //                 DSTR1 := '#L#################    #R###############';
        //                 FieldValue[1] := PeriodicDiscountInfoTEMP.Description;
        //                 FieldValue[2] := POSFunctions.FormatAmount(-PeriodicDiscountInfoTEMP."Discount Amount Value");
        //                 Sender.PrintLine(Tray, Sender.FormatLine(FormatStr(Sender, FieldValue, DSTR1), false, false, false, false));
        //                 Sender.AddPrintLine(800, 2, NodeName, FieldValue, DSTR1, false, false, false, false, Tray);
        //                 TotalAmtForSummary := TotalAmtForSummary + PeriodicDiscountInfoTEMP."Discount Amount Value";
        //                 TotalDiscAmt := TotalDiscAmt + PeriodicDiscountInfoTEMP."Discount Amount Value";
        //             end;
        //             if PeriodicDiscountInfoTEMP."Discount % Value" <> 0 then begin   //Points
        //                 DSTR1 := '#L#################    #R###############';
        //                 FieldValue[1] := PeriodicDiscountInfoTEMP.Description;
        //                 FieldValue[2] := POSFunctions.FormatAmount(PeriodicDiscountInfoTEMP."Discount % Value") + ' ' + Text232;
        //                 Sender.PrintLine(Tray, Sender.FormatLine(FormatStr(Sender, FieldValue, DSTR1), false, false, false, false));
        //                 Sender.AddPrintLine(800, 2, NodeName, FieldValue, DSTR1, false, false, false, false, Tray);
        //             end;
        //         until PeriodicDiscountInfoTEMP.Next = 0;

        //         DSTR1 := '#L#################    #R###############';
        //         FieldValue[1] := Text005 + ' ' + Globals.GetValue('CURRSYM');

        //         if Globals.UseSalesTax and LocalizationExt.IsNALocalizationEnabled then
        //             FieldValue[2] := POSFunctions.FormatAmount(Total + TipsAmount1 + TipsAmount2)
        //         else
        //             FieldValue[2] := POSFunctions.FormatAmount(-TotalAmtForSummary + TipsAmount1 + TipsAmount2 + totSPOAmount);

        //         if GenPOSFunc."Display Secondary Total Curr" and (GenPOSFunc."Secondary Total Currency" <> '') and (SecTotal <> 0) then begin
        //             DSTR1 := '#L####### #R#########    #R#############';
        //             FieldValue[1] := Text005 + ' ' + Globals.GetValue('CURRSYM');
        //             FieldValue[2] := Currency.Code + Format(SecTotal, 0, LocalizationUtility.AutoFormatMgtExtAutoFormatMgtExtDoAutoFormatTranslateExt(1, Currency.Code));

        //             if Globals.UseSalesTax and LocalizationExt.IsNALocalizationEnabled then
        //                 FieldValue[3] := POSFunctions.FormatAmount(Total + TipsAmount1 + TipsAmount2)
        //             else
        //                 FieldValue[3] := POSFunctions.FormatAmount(-TotalAmtForSummary + TipsAmount1 + TipsAmount2 + totSPOAmount);
        //             NodeName[2] := 'Sec.Curr';
        //             NodeName[3] := 'Total Amount';
        //         end;
        //         Sender.PrintLine(Tray, Sender.FormatLine(FormatStr(Sender, FieldValue, DSTR1), false, false, false, false));
        //         Sender.AddPrintLine(800, 2, NodeName, FieldValue, DSTR1, false, false, false, false, Tray);
        //         if TipsAmount1 <> 0 then begin
        //             DSTR1 := '#L#################    #R###############';
        //             FieldValue[1] := TipsText1 + ' ' + Globals.GetValue('CURRSYM');
        //             FieldValue[2] := POSFunctions.FormatAmount(-TipsAmount1);
        //             Sender.PrintLine(Tray, Sender.FormatLine(FormatStr(Sender, FieldValue, DSTR1), false, false, false, false));
        //             Sender.AddPrintLine(800, 2, NodeName, FieldValue, DSTR1, false, false, false, false, Tray);
        //         end;
        //         if TipsAmount2 <> 0 then begin
        //             DSTR1 := '#L#################    #R###############';
        //             FieldValue[1] := TipsText2 + ' ' + Globals.GetValue('CURRSYM');
        //             FieldValue[2] := POSFunctions.FormatAmount(-TipsAmount2);
        //             Sender.PrintLine(Tray, Sender.FormatLine(FormatStr(Sender, FieldValue, DSTR1), false, false, false, false));
        //             Sender.AddPrintLine(800, 2, NodeName, FieldValue, DSTR1, false, false, false, false, Tray);
        //         end;
        //         if (GenPOSFunc."Print Disc/Cpn Info on Slip" = GenPOSFunc."Print Disc/Cpn Info on Slip"::"Detail for each line and Sub-total") and
        //           (Transaction."Discount Amount" <> TotalDiscAmt) then begin
        //             lPOSTransPeriodicDisc.DiscType := lPOSTransPeriodicDisc.DiscType::Total;
        //             TotalDiscountCode := Format(lPOSTransPeriodicDisc.DiscType);
        //             if PeriodicDiscountInfoTEMP.FindSet then
        //                 repeat
        //                     if PeriodicDiscountInfoTEMP."No." <> TotalDiscountCode then begin
        //                         DSTR1 := '#L###################################   ';
        //                         FieldValue[1] := ' ' + CopyStr(PeriodicDiscountInfoTEMP.Description, 1, 18) + ' ' +
        //                           POSFunctions.FormatAmount(PeriodicDiscountInfoTEMP."Discount Amount Value");
        //                         FieldValue[2] := '';
        //                         Sender.PrintLine(Tray, Sender.FormatLine(FormatStr(Sender, FieldValue, DSTR1), false, false, false, false));
        //                         Sender.AddPrintLine(800, 2, NodeName, FieldValue, DSTR1, false, false, false, false, Tray);
        //                     end;
        //                 until PeriodicDiscountInfoTEMP.Next = 0;
        //         end;
        //     end
        //     else begin
        //         DSTR1 := '#L#################    #R###############';
        //         FieldValue[1] := Text005 + ' ' + Globals.GetValue('CURRSYM');
        //         if GenPOSFunc."Print Disc/Cpn Info on Slip" in
        //             [GenPOSFunc."Print Disc/Cpn Info on Slip"::"Detail for each line and Sub-total",
        //             GenPOSFunc."Print Disc/Cpn Info on Slip"::"Summary information below Sub-total"] then begin
        //             if Globals.UseSalesTax and LocalizationExt.IsNALocalizationEnabled then
        //                 FieldValue[2] := POSFunctions.FormatAmount(Total + TipsAmount1 + TipsAmount2)
        //             else
        //                 FieldValue[2] := POSFunctions.FormatAmount(-Subtotal + TipsAmount1 + TipsAmount2 + totSPOAmount);
        //             if GenPOSFunc."Display Secondary Total Curr" and (GenPOSFunc."Secondary Total Currency" <> '') and (SecTotal <> 0) then begin
        //                 SecSubTotal := Round(CurrencyExchRate.ExchangeAmtFCYToFCY(Transaction.Date, Transaction."Trans. Currency", Currency.Code,
        //                                Total), Currency."Amount Rounding Precision");
        //                 DSTR1 := '#L####### #R#########    #R#############';
        //                 FieldValue[1] := Text005 + ' ' + Globals.GetValue('CURRSYM');
        //                 FieldValue[2] := Currency.Code + Format(SecSubTotal, 0, LocalizationUtility.AutoFormatMgtExtAutoFormatMgtExtDoAutoFormatTranslateExt(1, Currency.Code));
        //                 FieldValue[3] := POSFunctions.FormatAmount(-Subtotal + TipsAmount1 + TipsAmount2 + totSPOAmount);
        //                 NodeName[2] := 'Sec.Curr';
        //                 NodeName[3] := 'Total Amount';
        //             end;
        //         end
        //         else begin
        //             if Globals.UseSalesTax and LocalizationExt.IsNALocalizationEnabled then
        //                 FieldValue[2] := POSFunctions.FormatAmount(Total + TipsAmount1 + TipsAmount2)
        //             else
        //                 FieldValue[2] := POSFunctions.FormatAmount(Total + TipsAmount1 + TipsAmount2 + totSPOAmount);
        //             if GenPOSFunc."Display Secondary Total Curr" and (GenPOSFunc."Secondary Total Currency" <> '') and (SecTotal <> 0) then begin
        //                 DSTR1 := '#L####### #R#########    #R#############';
        //                 FieldValue[1] := Text005 + ' ' + Globals.GetValue('CURRSYM');
        //                 FieldValue[2] := Currency.Code + Format(SecTotal, 0, LocalizationUtility.AutoFormatMgtExtAutoFormatMgtExtDoAutoFormatTranslateExt(1, Currency.Code));
        //                 FieldValue[3] := POSFunctions.FormatAmount(-TotalAmt + TipsAmount1 + TipsAmount2 + totSPOAmount);
        //                 NodeName[2] := 'Sec.Curr';
        //                 NodeName[3] := 'Total Amount';
        //             end;
        //         end;
        //         Sender.PrintLine(Tray, Sender.FormatLine(FormatStr(Sender, FieldValue, DSTR1), false, false, false, false));
        //         Sender.AddPrintLine(800, 2, NodeName, FieldValue, DSTR1, false, false, false, false, Tray);
        //         if TipsAmount1 <> 0 then begin
        //             DSTR1 := '#L#################    #R###############';
        //             FieldValue[1] := TipsText1 + ' ' + Globals.GetValue('CURRSYM');
        //             FieldValue[2] := POSFunctions.FormatAmount(-TipsAmount1);
        //             Sender.PrintLine(Tray, Sender.FormatLine(FormatStr(Sender, FieldValue, DSTR1), false, false, false, false));
        //             Sender.AddPrintLine(800, 2, NodeName, FieldValue, DSTR1, false, false, false, false, Tray);
        //         end;
        //         if TipsAmount2 <> 0 then begin
        //             DSTR1 := '#L#################    #R###############';
        //             FieldValue[1] := TipsText2 + ' ' + Globals.GetValue('CURRSYM');
        //             FieldValue[2] := POSFunctions.FormatAmount(-TipsAmount2);
        //             Sender.PrintLine(Tray, Sender.FormatLine(FormatStr(Sender, FieldValue, DSTR1), false, false, false, false));
        //             Sender.AddPrintLine(800, 2, NodeName, FieldValue, DSTR1, false, false, false, false, Tray);
        //         end;
        //     end;
        // end
        // else begin
        //     NodeName[1] := 'Total Text';
        //     NodeName[2] := 'Total Amount';
        //     DSTR1 := '#L#################    #R###############';
        //     FieldValue[1] := Text005 + ' ' + Globals.GetValue('CURRSYM');
        //     if Globals.UseSalesTax and LocalizationExt.IsNALocalizationEnabled then
        //         FieldValue[2] := POSFunctions.FormatAmount(Total + TipsAmount1 + TipsAmount2)
        //     else
        //         FieldValue[2] := POSFunctions.FormatAmount(Total + TipsAmount1 + TipsAmount2 + totSPOAmount);
        //     if GenPOSFunc."Display Secondary Total Curr" and (GenPOSFunc."Secondary Total Currency" <> '') and (SecTotal <> 0) then begin
        //         DSTR1 := '#L####### #R#########    #R#############';
        //         FieldValue[1] := Text005 + ' ' + Globals.GetValue('CURRSYM');
        //         FieldValue[2] := Currency.Code + Format(SecTotal, 0, LocalizationUtility.AutoFormatMgtExtAutoFormatMgtExtDoAutoFormatTranslateExt(1, Currency.Code));
        //         if Globals.UseSalesTax and LocalizationExt.IsNALocalizationEnabled then
        //             FieldValue[3] := POSFunctions.FormatAmount(Total + TipsAmount1 + TipsAmount2)
        //         else
        //             FieldValue[3] := POSFunctions.FormatAmount(-TotalAmt + TipsAmount1 + TipsAmount2 + totSPOAmount);
        //         NodeName[2] := 'Sec.Curr';
        //         NodeName[3] := 'Total Amount';
        //     end;
        //     Sender.PrintLine(Tray, Sender.FormatLine(FormatStr(Sender, FieldValue, DSTR1), false, false, false, false));
        //     Sender.AddPrintLine(800, 2, NodeName, FieldValue, DSTR1, false, false, false, false, Tray);
        //     if TipsAmount1 <> 0 then begin
        //         DSTR1 := '#L#################    #R###############';
        //         FieldValue[1] := TipsText1 + ' ' + Globals.GetValue('CURRSYM');
        //         FieldValue[2] := POSFunctions.FormatAmount(-TipsAmount1);
        //         Sender.PrintLine(Tray, Sender.FormatLine(FormatStr(Sender, FieldValue, DSTR1), false, false, false, false));
        //         Sender.AddPrintLine(800, 2, NodeName, FieldValue, DSTR1, false, false, false, false, Tray);
        //     end;
        //     if TipsAmount2 <> 0 then begin
        //         DSTR1 := '#L#################    #R###############';
        //         FieldValue[1] := TipsText2 + ' ' + Globals.GetValue('CURRSYM');
        //         FieldValue[2] := POSFunctions.FormatAmount(-TipsAmount2);
        //         Sender.PrintLine(Tray, Sender.FormatLine(FormatStr(Sender, FieldValue, DSTR1), false, false, false, false));
        //         Sender.AddPrintLine(800, 2, NodeName, FieldValue, DSTR1, false, false, false, false, Tray);
        //     end;
        // end;
        Clear(Total);
        Total := -(Transaction."Net Amount" - Transaction."Discount Amount");
        //DSTR1 := '#R############################ #R####';
        DSTR1 := '#R############################# #R######';
        NodeName[1] := 'Total Text';
        NodeName[2] := 'Total Amount';
        //FieldValue[1] := 'Line Total: ' + POSFunctions.FormatAmount(Total);
        FieldValue[1] := 'Line Total:';
        FieldValue[2] := POSFunctions.FormatAmount(Total);
        //FieldValue[2] := POSFunctions.FormatAmount(Total + TipsAmount1 + TipsAmount2);
        Sender.PrintLine(Tray, Sender.FormatLine(FormatStr(Sender, FieldValue, DSTR1), false, true, false, false));
        Sender.AddPrintLine(800, 2, NodeName, FieldValue, DSTR1, false, true, false, false, Tray);

        IF (Transaction."Sales Type" <> 'TAKEAWAY') AND (Transaction."Discount Amount" <> 0) Then begin
            DSTR1 := '#R############################# #R######';
            NodeName[1] := 'Discount Text';
            NodeName[2] := 'Discount Amount';
            FieldValue[1] := 'Discount:';
            FieldValue[2] := POSFunctions.FormatAmount(Transaction."Discount Amount");
            Sender.PrintLine(Tray, Sender.FormatLine(FormatStr(Sender, FieldValue, DSTR1), false, false, false, false));
            Sender.AddPrintLine(800, 2, NodeName, FieldValue, DSTR1, false, false, false, false, Tray);
        end;

    end;

    [Scope('OnPrem')]
    procedure CollectDiscInfo(TransSalesEntry: Record "LSC Trans. Sales Entry"; Tray: Integer; var TotAmt: Decimal; var Subtot: Decimal; var PeriodicDiscountInfoTEMP: Record "LSC Periodic Discount" temporary)
    var
        TransDiscountEntry: Record "LSC Trans. Discount Entry";
        CouponHeader: Record "LSC Coupon Header";
        PeriodicDiscount: Record "LSC Periodic Discount";
        DiscountText: Text[1000];
        DSTR2: Text[1000];
        OfferCode: Code[20];
    begin
        if Globals.UseSalesTax and LocalizationExt.IsNALocalizationEnabled then
            Subtot := Subtotal + TransSalesEntry."Net Amount" - TransSalesEntry."Discount Amount"
        else
            Subtot := Subtot + TransSalesEntry."Net Amount" + TransSalesEntry."LSCIN GST Amount" - TransSalesEntry."Discount Amount" + TransSalesEntry."VAT Amount";
        if GenPOSFunc."Print Disc/Cpn Info on Slip" in
          [GenPOSFunc."Print Disc/Cpn Info on Slip"::"Summary information below Sub-total",
          GenPOSFunc."Print Disc/Cpn Info on Slip"::"Detail for each line and Sub-total",
          GenPOSFunc."Print Disc/Cpn Info on Slip"::"Detail information for each line"] then begin
            TransDiscountEntry.Reset;
            TransDiscountEntry.SetRange("Store No.", TransSalesEntry."Store No.");
            TransDiscountEntry.SetRange("POS Terminal No.", TransSalesEntry."POS Terminal No.");
            TransDiscountEntry.SetRange("Transaction No.", TransSalesEntry."Transaction No.");
            TransDiscountEntry.SetRange("Line No.", TransSalesEntry."Line No.");
            if TransDiscountEntry.FindSet then
                repeat
                    if TransDiscountEntry."Offer Type" = TransDiscountEntry."Offer Type"::Line then
                        DiscountText := Text084
                    else
                        DiscountText := Format(TransDiscountEntry."Offer Type");
                    Clear(PeriodicDiscount);
                    if TransDiscountEntry."Offer Type" = TransDiscountEntry."Offer Type"::Coupon then begin
                        if CouponHeader.Get(TransDiscountEntry."Offer No.") then
                            DiscountText := CouponHeader.Description;
                    end
                    else
                        if PeriodicDiscount.Get(TransDiscountEntry."Offer No.") then
                            DiscountText := PeriodicDiscount.Description
                        else
                            case TransDiscountEntry."Offer Type" of
                                TransDiscountEntry."Offer Type"::Total:
                                    DiscountText := Text024;
                                TransDiscountEntry."Offer Type"::Line:
                                    DiscountText := Text084;
                                else
                                    DiscountText := Format(TransDiscountEntry."Offer Type");
                            end;
                    DiscountText := ConvertStr(DiscountText, '&', '+');
                    if GenPOSFunc."Print Disc/Cpn Info on Slip" = GenPOSFunc."Print Disc/Cpn Info on Slip"::"Detail for each line and Sub-total" then
                        if TransDiscountEntry."Offer Type" <> TransDiscountEntry."Offer Type"::Total then
                            Subtot := Subtot + TransDiscountEntry."Discount Amount";
                    if GenPOSFunc."Print Disc/Cpn Info on Slip" =
                      GenPOSFunc."Print Disc/Cpn Info on Slip"::"Detail information for each line" then begin
                        TotAmt := TotAmt + TransDiscountEntry."Discount Amount";
                    end
                    else begin
                        if TransDiscountEntry."Discount Amount" <> 0 then begin
                            if not PeriodicDiscount."Block Printing" then begin
                                if TransDiscountEntry."Offer No." <> '' then
                                    OfferCode := TransDiscountEntry."Offer No."
                                else
                                    OfferCode := CopyStr(Format(TransDiscountEntry."Offer Type"), 1, MaxStrLen(OfferCode));
                                if not PeriodicDiscountInfoTEMP.Get(OfferCode) then begin
                                    PeriodicDiscountInfoTEMP := PeriodicDiscount;
                                    PeriodicDiscountInfoTEMP."No." := OfferCode;
                                    PeriodicDiscountInfoTEMP."Discount Amount Value" := TransDiscountEntry."Discount Amount";
                                    PeriodicDiscountInfoTEMP."Discount % Value" := 0;
                                    PeriodicDiscountInfoTEMP.Description := DiscountText;
                                    PeriodicDiscountInfoTEMP.Insert;
                                end
                                else begin
                                    PeriodicDiscountInfoTEMP."Discount Amount Value" := PeriodicDiscountInfoTEMP."Discount Amount Value" +
                                      TransDiscountEntry."Discount Amount";
                                    PeriodicDiscountInfoTEMP.Modify;
                                end;
                            end
                            else
                                Subtotal := Subtotal + TransDiscountEntry."Discount Amount";
                        end;
                        if TransDiscountEntry.Points <> 0 then begin
                            if not PeriodicDiscountInfoTEMP.Get(TransDiscountEntry."Offer No.") then begin
                                PeriodicDiscountInfoTEMP := PeriodicDiscount;
                                PeriodicDiscountInfoTEMP."No." := TransDiscountEntry."Offer No.";
                                PeriodicDiscountInfoTEMP."Discount Amount Value" := 0;
                                PeriodicDiscountInfoTEMP."Discount % Value" := TransDiscountEntry.Points;
                                PeriodicDiscountInfoTEMP.Description := DiscountText;
                                PeriodicDiscountInfoTEMP.Insert;
                            end
                            else begin
                                PeriodicDiscountInfoTEMP."Discount % Value" := PeriodicDiscountInfoTEMP."Discount % Value" +
                                  TransDiscountEntry.Points;
                                PeriodicDiscountInfoTEMP.Modify;
                            end;
                        end;
                    end;
                until TransDiscountEntry.Next = 0;
        end;
    end;

    local procedure PrintPostedGSTInfo(var Sender: Codeunit "LSC POS Print Utility"; Tray: Integer; var Transaction: Record "LSC Transaction Header")
    var
        TaxTransValue: Record "LSCIN Tax Transaction Value V2";
        TransSalesEntry: Record "LSC Trans. Sales Entry";
        TransIncomeExpenseEntry: Record "LSC Trans. Inc./Exp. Entry";
        TaxComponent: Record "Tax Component";
        GSTSetup: Record "GST Setup";
        TaxRateComputation: Codeunit "Tax Rate Computation";
        TaxComponentName: Text[30];
        DSTR1: Text[50];
        Sign: Integer;
        xLineNo: Integer;
        GstHeaderPrinted: Boolean;
    begin
        GSTSetup.Get();
        GSTSetup.TestField("GST Tax Type");
        if Transaction."Sale Is Return Sale" then
            Sign := -1
        else
            Sign := 1;

        TempTaxComponentLineNo := 0;
        TempTaxComponentGroupLineNo := 0;
        xLineNo := 0;
        TempTaxComponent.DeleteAll();
        TempTaxComponentGroup.DeleteAll();
        TempGSTRateGroup.DeleteAll();

        TransSalesEntry.SetRange("Store No.", Transaction."Store No.");
        TransSalesEntry.SetRange("POS Terminal No.", Transaction."POS Terminal No.");
        TransSalesEntry.SetRange("Transaction No.", Transaction."Transaction No.");
        if TransSalesEntry.FindSet() then
            repeat
                Clear(TaxTransValue);
                TaxTransValue.SetRange("Tax Record ID", TransSalesEntry.RecordId);
                TaxTransValue.SetRange("Value Type", TaxTransValue."Value Type"::COMPONENT);
                TaxTransValue.SetRange("Tax Type", GSTSetup."GST Tax Type");
                TaxTransValue.SetFilter(Percent, '<>%1', 0);
                if TaxTransValue.FindSet() then
                    repeat
                        TaxComponent.Get(TaxTransValue."Tax Type", TaxTransValue."Value ID");
                        TaxComponentName := TaxTransValue.GetAttributeColumName();
                        Clear(TempTaxComponentGroup);
                        TempTaxComponentGroup.Reset();
                        TempTaxComponentGroup.SetRange("Line Discount %", TaxTransValue.Percent);
                        TempTaxComponentGroup.SetRange("Document No.", TaxTransValue."Tax Type");
                        if TempTaxComponentGroup.FindFirst then begin
                            if xLineNo <> TransSalesEntry."Line No." then begin
                                TempTaxComponentGroup."Line Amount" += -TransSalesEntry."Net Amount";
                                xLineNo := TransSalesEntry."Line No.";
                            end;
                            TempTaxComponentGroup."Line Discount Amount" += (Sign * TaxRateComputation.RoundAmount(TaxTransValue.Amount, TaxComponent."Rounding Precision", TaxComponent.Direction));
                            TempTaxComponentGroup.Modify();
                        end else begin
                            TempTaxComponentGroup."Document No." := TaxTransValue."Tax Type";
                            TempTaxComponentGroupLineNo := TempTaxComponentGroupLineNo + 1;
                            TempTaxComponentGroup."Line No." := TempTaxComponentGroupLineNo;
                            TempTaxComponentGroup."Order Line No." := TaxTransValue."Value ID";
                            TempTaxComponentGroup.Description := TaxComponentName;
                            TempTaxComponentGroup."Line Discount %" := TaxTransValue.Percent;
                            TempTaxComponentGroup."Line Discount Amount" := (Sign * TaxRateComputation.RoundAmount(TaxTransValue.Amount, TaxComponent."Rounding Precision", TaxComponent.Direction));
                            TempTaxComponentGroup."Line Amount" := -TransSalesEntry."Net Amount";
                            TempTaxComponentGroup.Insert();
                            xLineNo := TransSalesEntry."Line No.";
                        end;
                        InsertGSTRate(TaxTransValue."Tax Type", TaxTransValue."Value ID", TaxTransValue.Percent);
                        Clear(TempTaxComponent);
                        TempTaxComponent.SetRange("Line Discount %", TaxTransValue.Percent);
                        TempTaxComponent.SetRange("Document No.", TaxTransValue."Tax Type");
                        TempTaxComponent.SetRange("Order Line No.", TaxTransValue."Value ID");
                        if not TempTaxComponent.FindFirst() then begin
                            TempTaxComponent."Document No." := TaxTransValue."Tax Type";
                            TempTaxComponentLineNo := TempTaxComponentLineNo + 1;
                            TempTaxComponent."Line No." := TempTaxComponentLineNo;
                            TempTaxComponent."Order Line No." := TaxTransValue."Value ID";
                            TempTaxComponent.Description := TaxComponentName;
                            TempTaxComponent."Line Discount %" := TaxTransValue.Percent;
                            TempTaxComponent.Insert();
                        end;
                        TempTaxComponent."Line Discount Amount" += (Sign * TaxRateComputation.RoundAmount(TaxTransValue.Amount, TaxComponent."Rounding Precision", TaxComponent.Direction));
                        TempTaxComponent."Line Amount" += -TransSalesEntry."Net Amount";
                        TempTaxComponent.Modify();
                    until TaxTransValue.Next() = 0;
            until TransSalesEntry.Next() = 0;

        xLineNo := 0;
        TransIncomeExpenseEntry.SetRange("Store No.", Transaction."Store No.");
        TransIncomeExpenseEntry.SetRange("POS Terminal No.", Transaction."POS Terminal No.");
        TransIncomeExpenseEntry.SetRange("Transaction No.", Transaction."Transaction No.");
        if TransIncomeExpenseEntry.FindSet() then
            repeat
                Clear(TaxTransValue);
                TaxTransValue.SetRange("Tax Record ID", TransIncomeExpenseEntry.RecordId);
                TaxTransValue.SetRange("Value Type", TaxTransValue."Value Type"::COMPONENT);
                TaxTransValue.SetRange("Tax Type", GSTSetup."GST Tax Type");
                TaxTransValue.SetFilter(Percent, '<>%1', 0);
                if TaxTransValue.FindSet() then
                    repeat
                        TaxComponent.Get(TaxTransValue."Tax Type", TaxTransValue."Value ID");
                        TaxComponentName := TaxTransValue.GetAttributeColumName();
                        clear(TempTaxComponentGroup);
                        TempTaxComponentGroup.Reset();
                        TempTaxComponentGroup.SetRange("Line Discount %", TaxTransValue.Percent);
                        TempTaxComponentGroup.SetRange("Document No.", TaxTransValue."Tax Type");
                        if TempTaxComponentGroup.FindFirst then begin
                            if xLineNo <> TransIncomeExpenseEntry."Line No." then begin
                                TempTaxComponentGroup."Line Amount" += -TransIncomeExpenseEntry."Net Amount";
                                xLineNo := TransIncomeExpenseEntry."Line No.";
                            end;
                            TempTaxComponentGroup."Line Discount Amount" += (Sign * TaxRateComputation.RoundAmount(TaxTransValue.Amount, TaxComponent."Rounding Precision", TaxComponent.Direction));
                            TempTaxComponentGroup.Modify();
                        end else begin
                            TempTaxComponentGroup."Document No." := TaxTransValue."Tax Type";
                            TempTaxComponentGroupLineNo := TempTaxComponentGroupLineNo + 1;
                            TempTaxComponentGroup."Line No." := TempTaxComponentGroupLineNo;
                            TempTaxComponentGroup."Order Line No." := TaxTransValue."Value ID";
                            TempTaxComponentGroup.Description := TaxComponentName;
                            TempTaxComponentGroup."Line Discount %" := TaxTransValue.Percent;
                            TempTaxComponentGroup."Line Discount Amount" := (Sign * TaxRateComputation.RoundAmount(TaxTransValue.Amount, TaxComponent."Rounding Precision", TaxComponent.Direction));
                            TempTaxComponentGroup."Line Amount" := -TransIncomeExpenseEntry."Net Amount";
                            TempTaxComponentGroup.Insert();
                            xLineNo := TransIncomeExpenseEntry."Line No.";
                        end;
                        InsertGSTRate(TaxTransValue."Tax Type", TaxTransValue."Value ID", TaxTransValue.Percent);
                        Clear(TempTaxComponent);
                        TempTaxComponent.SetRange("Line Discount %", TaxTransValue.Percent);
                        TempTaxComponent.SetRange("Document No.", TaxTransValue."Tax Type");
                        TempTaxComponent.SetRange("Order Line No.", TaxTransValue."Value ID");
                        if not TempTaxComponent.FindFirst() then begin
                            TempTaxComponent."Document No." := TaxTransValue."Tax Type";
                            TempTaxComponentLineNo := TempTaxComponentLineNo + 1;
                            TempTaxComponent."Line No." := TempTaxComponentLineNo;
                            TempTaxComponent."Order Line No." := TaxTransValue."Value ID";
                            TempTaxComponent.Description := TaxComponentName;
                            TempTaxComponent."Line Discount %" := TaxTransValue.Percent;
                            TempTaxComponent.Insert();
                        end;
                        TempTaxComponent."Line Discount Amount" += (Sign * TaxRateComputation.RoundAmount(TaxTransValue.Amount, TaxComponent."Rounding Precision", TaxComponent.Direction));
                        TempTaxComponent."Line Amount" += -TransIncomeExpenseEntry."Net Amount";
                        TempTaxComponent.Modify();
                    until TaxTransValue.Next() = 0;
            until TransIncomeExpenseEntry.Next() = 0;

        TempTaxComponentGroup.Reset();
        if TempTaxComponentGroup.FindSet() then begin
            Clear(FieldValue);
            DSTR1 := '#L####################################';
            FieldValue[1] := Text506;
            Sender.PrintLine(Tray, Sender.FormatLine(FormatStr(Sender, FieldValue, DSTR1), false, true, false, false));

            Clear(FieldValue);
            DSTR1 := '#R### #R########## #R####### #R#########';
            FieldValue[1] := Text503;
            FieldValue[2] := Text502;
            FieldValue[3] := Text504;
            FieldValue[4] := Text004;
            Sender.PrintLine(Tray, Sender.FormatLine(FormatStr(Sender, FieldValue, DSTR1), false, false, false, false));
            Sender.PrintSeperator(Tray);

            DSTR1 := '#N### #N########## #N####### #N#########';
            repeat
                Clear(FieldValue);
                FieldValue[1] := Format(GetTotalGSTRate(TempTaxComponentGroup."Document No.", TempTaxComponentGroup."Line Discount %"));
                FieldValue[2] := POSFunctions.FormatAmount(TempTaxComponentGroup."Line Amount");
                FieldValue[3] := POSFunctions.FormatAmount(TempTaxComponentGroup."Line Discount Amount");
                FieldValue[4] := POSFunctions.FormatAmount(TempTaxComponentGroup."Line Amount" + TempTaxComponentGroup."Line Discount Amount");
                Sender.PrintLine(Tray, Sender.FormatLine(FormatStr(Sender, FieldValue, DSTR1), false, false, false, false));
            until TempTaxComponentGroup.Next() = 0;
            Sender.PrintSeperator(Tray);
        end;
        TempTaxComponent.Reset();
        if not TempTaxComponent.FindSet() then
            exit;

        DSTR1 := '#L######## #R######## #R##### #R########';
        Clear(FieldValue);
        FieldValue[1] := Text501;
        FieldValue[2] := Text502;
        FieldValue[3] := Text503;
        FieldValue[4] := Text504;
        Sender.PrintLine(Tray, Sender.FormatLine(FormatStr(Sender, FieldValue, DSTR1), false, false, false, false));
        Sender.AddPrintLine(800, 2, NodeName, FieldValue, DSTR1, false, false, false, false, Tray);

        Sender.PrintSeperator(Tray);

        repeat
            FieldValue[1] := TempTaxComponent.Description;
            FieldValue[2] := POSFunctions.FormatAmount(TempTaxComponent."Line Amount");
            FieldValue[3] := POSFunctions.FormatAmount(TempTaxComponent."Line Discount %");
            FieldValue[4] := POSFunctions.FormatAmount(TempTaxComponent."Line Discount Amount");

            Sender.PrintLine(Tray, Sender.FormatLine(FormatStr(Sender, FieldValue, DSTR1), false, false, false, false));
            Sender.AddPrintLine(800, 2, NodeName, FieldValue, DSTR1, false, false, false, false, Tray);
        until TempTaxComponent.Next() = 0;
    end;

    local procedure PrintPostedVATInfo(var Sender: Codeunit "LSC POS Print Utility"; Tray: Integer; var Transaction: Record "LSC Transaction Header")
    var
        TaxTransValue: Record "LSCIN Tax Transaction Value V2";
        TransSalesEntry: Record "LSC Trans. Sales Entry";
        TransIncomeExpenseEntry: Record "LSC Trans. Inc./Exp. Entry";
        TaxComponent: Record "Tax Component";
        GSTSetup: Record "GST Setup";
        TaxRateComputation: Codeunit "Tax Rate Computation";
        TaxComponentName: Text[30];
        DSTR1: Text[50];
        Sign: Integer;
        xLineNo: Integer;
        GstHeaderPrinted: Boolean;
    begin
        GSTSetup.Get();
        GSTSetup.TestField("LSCIN VAT Tax Type");
        if Transaction."Sale Is Return Sale" then
            Sign := -1
        else
            Sign := 1;

        TempTaxComponentLineNo := 0;
        TempTaxComponentGroupLineNo := 0;
        xLineNo := 0;
        TempTaxComponent.DeleteAll();
        TempTaxComponentGroup.DeleteAll();
        TempGSTRateGroup.DeleteAll();

        TransSalesEntry.SetRange("Store No.", Transaction."Store No.");
        TransSalesEntry.SetRange("POS Terminal No.", Transaction."POS Terminal No.");
        TransSalesEntry.SetRange("Transaction No.", Transaction."Transaction No.");
        if TransSalesEntry.FindSet() then
            repeat
                Clear(TaxTransValue);
                TaxTransValue.SetRange("Tax Record ID", TransSalesEntry.RecordId);
                TaxTransValue.SetRange("Value Type", TaxTransValue."Value Type"::COMPONENT);
                TaxTransValue.SetRange("Tax Type", GSTSetup."LSCIN VAT Tax Type");
                TaxTransValue.SetFilter(Percent, '<>%1', 0);
                if TaxTransValue.FindSet() then
                    repeat
                        TaxComponent.Get(TaxTransValue."Tax Type", TaxTransValue."Value ID");
                        TaxComponentName := TaxTransValue.GetAttributeColumName();
                        Clear(TempTaxComponentGroup);
                        TempTaxComponentGroup.Reset();
                        TempTaxComponentGroup.SetRange("Line Discount %", TaxTransValue.Percent);
                        if TempTaxComponentGroup.FindFirst then begin
                            if xLineNo <> TransSalesEntry."Line No." then begin
                                TempTaxComponentGroup."Line Amount" += -TransSalesEntry."Net Amount";
                                xLineNo := TransSalesEntry."Line No.";
                            end;
                            TempTaxComponentGroup."Line Discount Amount" += (Sign * TaxRateComputation.RoundAmount(TaxTransValue.Amount, TaxComponent."Rounding Precision", TaxComponent.Direction));
                            TempTaxComponentGroup.Modify();
                        end else begin
                            TempTaxComponentGroup."Document No." := TaxTransValue."Tax Type";
                            TempTaxComponentGroupLineNo := TempTaxComponentGroupLineNo + 1;
                            TempTaxComponentGroup."Line No." := TempTaxComponentGroupLineNo;
                            TempTaxComponentGroup."Order Line No." := TaxTransValue."Value ID";
                            TempTaxComponentGroup.Description := TaxComponentName;
                            TempTaxComponentGroup."Line Discount %" := TaxTransValue.Percent;
                            TempTaxComponentGroup."Line Discount Amount" := (Sign * TaxRateComputation.RoundAmount(TaxTransValue.Amount, TaxComponent."Rounding Precision", TaxComponent.Direction));
                            TempTaxComponentGroup."Line Amount" := -TransSalesEntry."Net Amount";
                            TempTaxComponentGroup.Insert();
                            xLineNo := TransSalesEntry."Line No.";
                        end;

                    until TaxTransValue.Next() = 0;
            until TransSalesEntry.Next() = 0;

        xLineNo := 0;
        TransIncomeExpenseEntry.SetRange("Store No.", Transaction."Store No.");
        TransIncomeExpenseEntry.SetRange("POS Terminal No.", Transaction."POS Terminal No.");
        TransIncomeExpenseEntry.SetRange("Transaction No.", Transaction."Transaction No.");
        if TransIncomeExpenseEntry.FindSet() then
            repeat
                Clear(TaxTransValue);
                TaxTransValue.SetRange("Tax Record ID", TransIncomeExpenseEntry.RecordId);
                TaxTransValue.SetRange("Value Type", TaxTransValue."Value Type"::COMPONENT);
                TaxTransValue.SetRange("Tax Type", GSTSetup."LSCIN VAT Tax Type");
                TaxTransValue.SetFilter(Percent, '<>%1', 0);
                if TaxTransValue.FindSet() then
                    repeat
                        TaxComponent.Get(TaxTransValue."Tax Type", TaxTransValue."Value ID");
                        TaxComponentName := TaxTransValue.GetAttributeColumName();
                        clear(TempTaxComponentGroup);
                        TempTaxComponentGroup.Reset();
                        TempTaxComponentGroup.SetRange("Line Discount %", TaxTransValue.Percent);
                        if TempTaxComponentGroup.FindFirst then begin
                            if xLineNo <> TransIncomeExpenseEntry."Line No." then begin
                                TempTaxComponentGroup."Line Amount" += -TransIncomeExpenseEntry."Net Amount";
                                xLineNo := TransIncomeExpenseEntry."Line No.";
                            end;
                            TempTaxComponentGroup."Line Discount Amount" += (Sign * TaxRateComputation.RoundAmount(TaxTransValue.Amount, TaxComponent."Rounding Precision", TaxComponent.Direction));
                            TempTaxComponentGroup.Modify();
                        end else begin
                            TempTaxComponentGroup."Document No." := TaxTransValue."Tax Type";
                            TempTaxComponentGroupLineNo := TempTaxComponentGroupLineNo + 1;
                            TempTaxComponentGroup."Line No." := TempTaxComponentGroupLineNo;
                            TempTaxComponentGroup."Order Line No." := TaxTransValue."Value ID";
                            TempTaxComponentGroup.Description := TaxComponentName;
                            TempTaxComponentGroup."Line Discount %" := TaxTransValue.Percent;
                            TempTaxComponentGroup."Line Discount Amount" := (Sign * TaxRateComputation.RoundAmount(TaxTransValue.Amount, TaxComponent."Rounding Precision", TaxComponent.Direction));
                            TempTaxComponentGroup."Line Amount" := -TransIncomeExpenseEntry."Net Amount";
                            TempTaxComponentGroup.Insert();
                            xLineNo := TransIncomeExpenseEntry."Line No.";
                        end;

                    until TaxTransValue.Next() = 0;
            until TransIncomeExpenseEntry.Next() = 0;

        TempTaxComponentGroup.Reset();
        if TempTaxComponentGroup.FindSet() then begin
            Clear(FieldValue);
            DSTR1 := '#L####################################';
            FieldValue[1] := Text507;
            Sender.PrintLine(Tray, Sender.FormatLine(FormatStr(Sender, FieldValue, DSTR1), false, true, false, false));
            Sender.PrintSeperator(Tray);
            Clear(FieldValue);
            DSTR1 := '#R### #R########## #R####### #R#########';
            FieldValue[1] := text508;
            FieldValue[2] := Text063_2;
            FieldValue[3] := Text063;
            FieldValue[4] := Text004;
            Sender.PrintLine(Tray, Sender.FormatLine(FormatStr(Sender, FieldValue, DSTR1), false, false, false, false));
            Sender.PrintSeperator(Tray);

            DSTR1 := '#N### #N########## #N####### #N#########';
            repeat
                Clear(FieldValue);
                FieldValue[1] := POSFunctions.FormatAmount(TempTaxComponentGroup."Line Discount %");
                FieldValue[2] := POSFunctions.FormatAmount(TempTaxComponentGroup."Line Amount");
                FieldValue[3] := POSFunctions.FormatAmount(TempTaxComponentGroup."Line Discount Amount");
                FieldValue[4] := POSFunctions.FormatAmount(TempTaxComponentGroup."Line Amount" + TempTaxComponentGroup."Line Discount Amount");
                Sender.PrintLine(Tray, Sender.FormatLine(FormatStr(Sender, FieldValue, DSTR1), false, false, false, false));
            until TempTaxComponentGroup.Next() = 0;
            Sender.PrintSeperator(Tray);
        end;
    end;

    [Scope('OnPrem')]
    procedure PrintPaymInfo(var Sender: Codeunit "LSC POS Print Utility"; Transaction: Record "LSC Transaction Header";
            Tray: Integer)
    var
        PaymEntry: Record "LSC Trans. Payment Entry";
        Tendertype: Record "LSC Tender Type";
        Tendercard: Record "LSC Tender Type Card Setup";
        Currency: Record Currency;
        TransInfoCode: Record "LSC Trans. Infocode Entry";
        CouponEntry: Record "LSC Trans. Coupon Entry";
        DSTR1: Text[100];
        DSTR2: Text[100];
        Payment: Text[30];
        tmpStr: Text[50];
        GrandTot: Decimal;
        PosDataEntry: Record "LSC POS Data Entry";
        CreditNoteNoString: Text;
        CreditNoteNo: Code[20];
        i: Integer;
        IsHandled: Boolean;
    begin
        DSTR1 := '#L############## #R##    #R#############';
        Sender.PrintLine(Tray, '');

        Clear(PaymEntry);
        PaymEntry.SetRange("Store No.", Transaction."Store No.");
        PaymEntry.SetRange("POS Terminal No.", Transaction."POS Terminal No.");
        PaymEntry.SetRange("Transaction No.", Transaction."Transaction No.");
        if PaymEntry.FindSet() then begin
            repeat
                Clear(FieldValue);
                Payment := PaymEntry."Tender Type";
                if Tendertype.Get(PaymEntry."Store No.", PaymEntry."Tender Type") then begin
                    if PaymEntry."Change Line" and (Tendertype."Change Line on Receipt" <> '') then
                        Payment := Tendertype."Change Line on Receipt"
                    else
                        Payment := Tendertype.Description;
                end
                else
                    Clear(Tendertype);
                if not Tendertype."Auto Account Payment Tender" then begin
                    /*
                    FieldValue[1] := Payment;
                    NodeName[1] := 'Tender Description';
                    if (Tendertype."Function" = Tendertype."Function"::Coupons) and (PaymEntry.Quantity > 1) then
                        FieldValue[2] := Format(PaymEntry.Quantity);
                    NodeName[2] := 'Quantity';
                    FieldValue[3] := POSFunctions.FormatAmount(-PaymEntry."Amount Tendered");
                    NodeName[3] := 'Amount In Tender';
                    FieldValue[4] := PaymEntry."Tender Type";
                    NodeName[4] := 'Tender Type';
                    FieldValue[5] := Format(PaymEntry."Line No.");
                    NodeName[5] := 'Line No.';
                    Sender.PrintLine(Tray, Sender.FormatLine(FormatStr(Sender, FieldValue, DSTR1), false, true, false, false));
                    Sender.AddPrintLine(700, 5, NodeName, FieldValue, DSTR1, false, true, false, false, Tray);
                    if (Tendertype."Function" = Tendertype."Function"::Card) then begin
                        DSTR2 := '  #L##################################  ';
                        if Tendercard.Get(PaymEntry."Store No.", PaymEntry."Tender Type", PaymEntry."Card No.") then begin
                            if Tendercard.Description <> '' then begin
                                FieldValue[1] := Tendercard.Description;
                                NodeName[1] := 'Card Name';
                                FieldValue[2] := Format(PaymEntry."Line No.");
                                NodeName[2] := 'Line No.';
                                Sender.PrintLine(Tray, Sender.FormatLine(FormatStr(Sender, FieldValue, DSTR2), false, true, false, false));
                                Sender.AddPrintLine(700, 2, NodeName, FieldValue, DSTR2, false, true, false, false, Tray);
                            end;
                        end;
                        if PaymEntry."Card or Account" <> '' then begin
                            tmpStr := PaymEntry."Card or Account";
                            for i := 1 to StrLen(tmpStr) - 6 do
                                tmpStr[i] := '*';
                            FieldValue[1] :=
                              CopyStr(tmpStr, 1, 4) + ' ' +
                              CopyStr(tmpStr, 5, 4) + ' ' +
                              CopyStr(tmpStr, 9, 4) + ' ' +
                              CopyStr(tmpStr, 13, 4) + ' ' +
                              CopyStr(tmpStr, 17, 4);
                            NodeName[1] := 'Detail Text';
                            FieldValue[2] := Format(PaymEntry."Line No.");
                            NodeName[2] := 'Line No.';
                            Sender.PrintLine(Tray, Sender.FormatLine(FormatStr(Sender, FieldValue, DSTR2), false, true, false, false));
                            Sender.AddPrintLine(700, 2, NodeName, FieldValue, DSTR2, false, true, false, false, Tray);
                        end;
                    end
                    else
                        if Tendertype."Card/Account No." then begin
                            DSTR2 := '  #L##################################  ';
                            FieldValue[1] := Tendertype."Ask for Card/Account" + ' ' + PaymEntry."Card or Account";
                            NodeName[1] := 'Detail Text';
                            FieldValue[2] := Format(PaymEntry."Line No.");
                            NodeName[2] := 'Line No.';
                            Sender.PrintLine(Tray, Sender.FormatLine(FormatStr(Sender, FieldValue, DSTR2), false, true, false, false));
                            Sender.AddPrintLine(700, 2, NodeName, FieldValue, DSTR2, false, true, false, false, Tray);
                        end;
                    if Tendertype."Foreign Currency" then begin
                        if PaymEntry."Amount in Currency" = 0 then
                            PaymEntry."Amount in Currency" := 1;
                        Currency.Get(PaymEntry."Currency Code");
                        DSTR2 := '  #L###### #L####################       ';
                        FieldValue[1] := Currency.Code;
                        NodeName[1] := 'Currency Code';
                        FieldValue[2] := LocalizationUtility.POSFunctionsFormatCurrency(-PaymEntry."Amount in Currency", PaymEntry."Currency Code") +
                        ' @ ' + Format(Round(PaymEntry."Exchange Rate", 0.001, '='));
                        NodeName[2] := 'x';
                        FieldValue[3] := Format(PaymEntry."Line No.");
                        NodeName[3] := 'Line No.';
                        FieldValue[4] := LocalizationUtility.POSFunctionsFormatCurrency(-PaymEntry."Amount in Currency", PaymEntry."Currency Code");
                        NodeName[4] := 'Amount In Currency';
                        FieldValue[5] := Format(PaymEntry."Exchange Rate");
                        NodeName[5] := 'Exchange Rate';
                        Sender.PrintLine(Tray, Sender.FormatLine(FormatStr(Sender, FieldValue, DSTR2), false, true, false, false));
                        Sender.AddPrintLine(700, 5, NodeName, FieldValue, DSTR2, false, true, false, false, Tray);
                    end;
                    */

                    DSTR1 := '#R######################################';
                    FieldValue[1] := Payment + ':' + POSFunctions.FormatAmount(PaymEntry."Amount Tendered");
                    NodeName[1] := 'Tender Description';
                    Sender.PrintLine(Tray, Sender.FormatLine(FormatStr(Sender, FieldValue, DSTR1), false, false, false, false));
                    Sender.AddPrintLine(200, 5, NodeName, FieldValue, DSTR2, false, false, false, false, Tray);

                    TransInfoCode.SetRange("Store No.", Transaction."Store No.");
                    TransInfoCode.SetRange("POS Terminal No.", Transaction."POS Terminal No.");
                    TransInfoCode.SetRange("Transaction No.", Transaction."Transaction No.");
                    TransInfoCode.SetRange("Transaction Type", TransInfoCode."Transaction Type"::"Payment Entry");
                    TransInfoCode.SetRange("Line No.", PaymEntry."Line No.");
                    Sender.PrintTransInfoCode(TransInfoCode, Tray, false);
                end;
            until PaymEntry.Next = 0;

            IF Transaction."Wallet Balance" <> '' Then
                Transaction.Rounded := 0;

            if not Globals.UseSalesTax or not LocalizationExt.IsNALocalizationEnabled then begin
                if Transaction.Rounded <> 0 then begin
                    Sender.PrintLine(Tray, '');
                    //DSTR1 := '#L#################    #R###############';
                    //DSTR1 := '#R############################# #R######';
                    DSTR1 := '#R######################################';
                    //FieldValue[1] := Text093;
                    FieldValue[1] := '(round off ' + POSFunctions.FormatAmount(Transaction.Rounded) + ')';  //AlleRSN
                    NodeName[1] := 'x';
                    //FieldValue[2] := POSFunctions.FormatAmount(Transaction.Rounded);
                    //NodeName[2] := 'Rounding Amount';
                    Sender.PrintLine(Tray, Sender.FormatLine(FormatStr(Sender, FieldValue, DSTR1), false, false, false, false));
                    Sender.AddPrintLine(200, 5, NodeName, FieldValue, DSTR2, false, false, false, false, Tray);
                end;
            end;
            //Sender.PrintSeperator(Tray);
            //AlleRSN start
            DSTR1 := '#C######################################';
            PosDataEntry.Reset();
            PosDataEntry.SetRange("Created by Receipt No.", Transaction."Receipt No.");
            IF PosDataEntry.FindFirst() then
                CreditNoteNo := PosDataEntry."Entry Code";

            IF CreditNoteNo <> '' Then
                Sender.PrintBarcode(Tray, CreditNoteNo, 40, 8, 'CODE128_A', 2);
            //CreditNoteNoString := getBarcode(CreditNoteNo);

            DSTR1 := '#L######################################';
            Clear(GrandTot);
            GrandTot := -Transaction."Gross Amount" + Transaction.Rounded;
            FieldValue[1] := 'Grand Total: Rs. ' + POSFunctions.FormatAmount(GrandTot);
            NodeName[1] := 'Tender Description';
            //Sender.PrintLine(Tray, Sender.FormatLine(FormatStr(Sender, FieldValue, DSTR1), false, true, true, false));
            //Sender.AddPrintLine(200, 5, NodeName, FieldValue, DSTR2, false, true, true, false, Tray);
            Sender.PrintLine(Tray, Sender.FormatLine(FormatStr(Sender, FieldValue, DSTR1), false, false, true, false));
            Sender.AddPrintLine(200, 5, NodeName, FieldValue, DSTR2, false, false, true, false, Tray);


            //AlleRSN end 010224
        end;

        DSTR1 := '#C######################################';
        // FieldValue[1] := Transaction."Receipt No.";
        // NodeName[1] := 'Receipt ';
        // Sender.PrintLine(Tray, Sender.FormatLine(FormatStr(Sender, FieldValue, DSTR1), false, true, true, false));
        // Sender.AddPrintLine(200, 5, NodeName, FieldValue, DSTR2, false, true, true, false, Tray);
        //Sender.PrintBitmap(Tray, '', 1);
        //Sender.PrintSeperator(Tray);
        //Sender.PrintBarcode(Tray, 'T' + Transaction."Receipt No.", 100, 40, 'CODE128_A', 2);
        Sender.PrintBarcode(Tray, Transaction."Receipt No.", 40, 8, 'CODE128_A', 2);
        //Sender.PrintSeperator(Tray);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Print Utility", 'OnBeforePrintVATInfo', '', false, false)]
    local procedure PrintGSTInfo(var Sender: Codeunit "LSC POS Print Utility"; var POSTransaction: Record "LSC POS Transaction"; var PrintBuffer: Record "LSC POS Print Buffer"; var PrintBufferIndex: Integer; var LinesPrinted: Integer; var DSTR1: Text[100]; var IsHandled: Boolean)
    var
        POSSalesEntry: Record "LSC POS Trans. Line";
        CompInfo: Record "Company Information";
        TaxTransValue: Record "Tax Transaction Value";
        GSTSetup: Record "GST Setup";
        TaxComponentName: Text[100];
        SplitNumber: Integer;
        Tray: Integer;
        VATPrinted: Boolean;
    begin
        Clear(FieldValue);
        Clear(POSSalesEntry);
        Tray := 2;
        SplitNumber := 0;
        TempTaxComponentLineNo := 0;
        LineLen := Sender.GetLineLen();
        TempTaxComponent.DeleteAll();
        GSTSetup.Get();

        POSSalesEntry.SetRange("Receipt No.", POSTransaction."Receipt No.");
        POSSalesEntry.SetFilter("Entry Type", '%1|%2', POSSalesEntry."Entry Type"::Item,
          POSSalesEntry."Entry Type"::IncomeExpense);
        POSSalesEntry.SetRange("Entry Status", POSSalesEntry."Entry Status"::" ");

        if SplitNumber <> 0 then begin
            if SplitNumber <> 1 then
                POSSalesEntry.SetRange(POSSalesEntry."Guest/Seat No.", SplitNumber - 1)
            else
                POSSalesEntry.SetRange(POSSalesEntry."Guest/Seat No.", 0);
        end;

        //OnBeforePrintGSTInfoLSCIN(POSTransaction, PrintBuffer, PrintBufferIndex, LinesPrinted, IsHandled);
        if IsHandled then
            exit;

        //Handle VAT by Tax Engine
        if GSTSetup."LSCIN VAT Tax Type" <> '' then begin
            if POSSalesEntry.FindSet() then
                repeat
                    if GSTSetup."LSCIN VAT Tax Type" = POSDisplayMgt.GetTaxType(POSSalesEntry) then begin
                        ProcessPreBillComponent(POSSalesEntry, TempTaxComponent, GSTSetup."LSCIN VAT Tax Type");
                    end;
                until POSSalesEntry.Next() = 0;
        end;

        TempTaxComponent.Reset();
        if TempTaxComponent.FindSet() then begin
            Sender.PrintSeperator(Tray);
            Clear(FieldValue);
            DSTR1 := '#L####################################';
            FieldValue[1] := Text507;
            Sender.PrintLine(Tray, Sender.FormatLine(FormatStr(Sender, FieldValue, DSTR1), false, true, false, false));
            Sender.PrintSeperator(Tray);
            DSTR1 := '#R#####% #R######## #R####### #R########';
            FieldValue[1] := Text063;
            FieldValue[2] := Text063_2;
            FieldValue[3] := Text063;
            FieldValue[4] := Text004;
            Sender.PrintLine(Tray, Sender.FormatLine(FormatStr(Sender, FieldValue, DSTR1), false, false, false, false));
            DSTR1 := '#L #N### #N######## #N####### #N########';

            repeat
                FieldValue[1] := '';
                FieldValue[2] := POSFunctions.FormatAmount(TempTaxComponent."Line Discount %");
                FieldValue[3] := POSFunctions.FormatAmount(TempTaxComponent."Line Amount");
                FieldValue[4] := POSFunctions.FormatAmount(TempTaxComponent."Line Discount Amount");
                FieldValue[5] := POSFunctions.FormatAmount(TempTaxComponent."Line Amount" + TempTaxComponent."Line Discount Amount");
                Sender.PrintLine(Tray, Sender.FormatLine(FormatStr(Sender, FieldValue, DSTR1), false, false, false, false));
                Sender.AddPrintLine(900, 5, NodeName, FieldValue, DSTR1, false, false, false, false, Tray);
            until TempTaxComponent.Next() = 0;
            VATPrinted := true;
        end;

        if VATPrinted then begin
            Sender.PrintSeperator(Tray);
            VATPrinted := false;
        end;

        TempTaxComponentLineNo := 0;
        TempTaxComponent.DeleteAll();
        if GSTSetup."GST Tax Type" <> '' then begin
            if POSSalesEntry.FindSet() then
                repeat
                    if GSTSetup."GST Tax Type" = POSDisplayMgt.GetTaxType(POSSalesEntry) then begin
                        ProcessPreBillComponent(POSSalesEntry, TempTaxComponent, GSTSetup."GST Tax Type");
                    end;
                until POSSalesEntry.Next() = 0;
        end;

        if not GenPosFunc."Skip VAT on Receipt" and not POSTransaction."Post as Shipment" then begin
            TempTaxComponent.Reset();
            if TempTaxComponent.FindSet() then begin
                DSTR1 := '#L####### #R######## #R#### #R#######   ';
                Clear(FieldValue);
                FieldValue[1] := Text501;
                FieldValue[2] := Text502;
                FieldValue[3] := Text503;
                FieldValue[4] := Text504;
                Sender.PrintLine(Tray, Sender.FormatLine(FormatStr(Sender, FieldValue, DSTR1), false, false, false, false));
                Sender.AddPrintLine(900, 2, NodeName, FieldValue, DSTR1, false, false, false, false, Tray);
                Sender.PrintSeperator(Tray);
                repeat
                    FieldValue[1] := TempTaxComponent.Description;
                    FieldValue[2] := POSFunctions.FormatAmount(TempTaxComponent."Line Amount");
                    FieldValue[3] := POSFunctions.FormatAmount(TempTaxComponent."Line Discount %");
                    FieldValue[4] := POSFunctions.FormatAmount(TempTaxComponent."Line Discount Amount");
                    Sender.PrintLine(Tray, Sender.FormatLine(FormatStr(Sender, FieldValue, DSTR1), false, false, false, false));
                    Sender.AddPrintLine(900, 2, NodeName, FieldValue, DSTR1, false, false, false, false, Tray);
                until TempTaxComponent.Next() = 0;
                VATPrinted := true;
            end;
        end;

        if CompInfo.Get() then
            if (CompInfo."VAT Registration No." <> '') and (GenPosFunc."VAT Reg.No. on Receipt") then begin
                Sender.PrintLine(Tray, '');
                FieldValue[1] := Text133;
                NodeName[1] := 'x';
                FieldValue[2] := CompInfo."VAT Registration No.";
                NodeName[2] := 'VAT Registration No.';
                DSTR1 := '#L########### #L###################   ';
                Sender.PrintLine(Tray, Sender.FormatLine(FormatStr(Sender, FieldValue, DSTR1), false, false, false, false));
                Sender.AddPrintLine(200, 2, NodeName, FieldValue, DSTR1, false, false, false, false, Tray);
            end;

        if VATPrinted then
            Sender.PrintSeperator(Tray);
        //OnAfterPrintGSTInfoLSCIN(POSTransaction, PrintBuffer, PrintBufferIndex, LinesPrinted);

        IsHandled := true;
    end;

    local procedure InsertGSTRate(TaxType: Code[20]; ComponentID: Integer; GSTPercent: Decimal)
    begin
        TempGSTRateGroup.Reset();
        if not TempGSTRateGroup.Get(TaxType, ComponentID) then begin
            TempGSTRateGroup.Init();
            TempGSTRateGroup."Receipt No." := TaxType;
            TempGSTRateGroup."Line No." := ComponentID;
            TempGSTRateGroup.Quantity := GSTPercent;
            TempGSTRateGroup.Insert();
        end;
    end;

    local procedure GetTotalGSTRate(TaxType: Code[20]; GSTPercent: Decimal): Decimal
    var
        TotalGSTRate: Decimal;
    begin
        TempGSTRateGroup.Reset();
        TempGSTRateGroup.SetRange("Receipt No.", TaxType);
        TempGSTRateGroup.SetRange(Quantity, GSTPercent);
        if TempGSTRateGroup.FindSet() then
            repeat
                TotalGSTRate += TempGSTRateGroup.Quantity;
            until TempGSTRateGroup.Next() = 0;
        exit(TotalGSTRate);
    end;

    local procedure ProcessPreBillComponent(Line: Record "LSC POS Trans. Line"; var TempTaxComp: Record "Sales Invoice Line" temporary; TaxType: Code[20])
    var
        TaxTransValue: Record "Tax Transaction Value";
        TaxComponentName: Text[100];
    begin
        TaxTransValue.SetRange("Tax Record ID", Line.RecordId);
        TaxTransValue.SetRange("Tax Type", TaxType);
        TaxTransValue.SetRange("Value Type", TaxTransValue."Value Type"::COMPONENT);
        TaxTransValue.SetFilter(Percent, '<>%1', 0);
        if TaxTransValue.FindSet() then
            repeat
                TaxComponentName := TaxTransValue.GetAttributeColumName();
                Clear(TempTaxComp);
                TempTaxComp.SetRange("Line Discount %", TaxTransValue.Percent);
                TempTaxComp.SetRange("Document No.", TaxTransValue."Tax Type");
                TempTaxComp.SetRange("Order Line No.", TaxTransValue."Value ID");
                if not TempTaxComp.FindFirst() then begin
                    TempTaxComp."Document No." := TaxTransValue."Tax Type";
                    TempTaxComponentLineNo := TempTaxComponentLineNo + 1;
                    TempTaxComp."Line No." := TempTaxComponentLineNo;
                    TempTaxComp."Order Line No." := TaxTransValue."Value ID";
                    TempTaxComp.Description := TaxComponentName;
                    TempTaxComp."Line Discount %" := TaxTransValue.Percent;
                    TempTaxComp.Insert();
                end;
                TempTaxComp."Line Discount Amount" += TaxTransValue.Amount;
                TempTaxComp."Line Amount" += Line."Net Amount";
                TempTaxComp.Modify();
            until TaxTransValue.Next() = 0;
    end;




}
codeunit 50022 "Packaging BOM"
{
    var
        pos: Codeunit "LSC POS Transaction";
        func: Codeunit "UP Functions";
        bom_items: record "Packaging Item" temporary;


    trigger OnRun()
    begin

    end;


    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Transaction Events", 'OnBeforeTotalExecuted', '', false, false)]
    procedure OnBeforeTotalExecuted(var IsHandled: Boolean; var POSTransaction: Record "LSC POS Transaction")
    var
        infocode: record "LSC POS Trans. Infocode Entry";
        infocode_id: text;
        infocode_val: text;
        pos_trans: Codeunit "LSC POS Transaction";
    begin
        infocode_id := func.GetConfig('PACKAGING_BOM', 'INFOCODE_ID');
        infocode_val := func.GetConfig('PACKAGING_BOM', 'INFOCODE_VALUE');
        if (infocode_id <> '') and (infocode_val <> '') then begin
            infocode.SetFilter("Receipt No.", POSTransaction."Receipt No.");
            infocode.SetFilter(Infocode, infocode_id);
            infocode.SetFilter(Information, infocode_val);
            if infocode.FindLast() then begin
                IsHandled := AddPackingBOMItem(POSTransaction."Receipt No.");
                if IsHandled then
                    pos_trans.TotalPressed(false);
            end;
        end;
    end;



    procedure AddPackingBOMItem(receipt: text) isHandled: boolean
    var
        msg: text;
        trans: record "LSC POS Transaction";
        line: record "LSC POS Trans. Line";
        item: record item;
        bom_line: record "Production BOM Line";
        bom_header: record "Production BOM Header";
        bom_count: integer;
    //Ashish CU: Codeunit 99008923;
    begin
        if isPackagingBomDisabled() then
            exit;

        // if isPackagingBomAdded(receipt) then //AlleRSN 041023 comment
        //   exit;

        line.SetFilter("Receipt No.", receipt);
        line.SetFilter("Entry Status", '=%1', line."Entry Status"::" ");
        line.SetRange("Packaging BOM Applied", FALSE); //AlleRSN 041023
        line.SetRange("Parent BOM Line No", 0); //AlleRSN 041023

        if line.FindLast() then begin
            repeat begin
                item.Reset();
                item.SetFilter("No.", line.Number);
                if item.FindLast() then begin
                    if item."Packaging BOM" <> '' then begin
                        //AlleRSN 041023 start
                        if isPackagingBomAddedLine(receipt, line.Number, line."Line No.") then
                            exit;
                        //AlleRSN 041023 end    
                        bom_header.Reset();
                        bom_header.SetFilter("No.", item."Packaging BOM");
                        if bom_header.FindLast() then begin
                            bom_line.Reset();
                            bom_line.SetFilter("Production BOM No.", bom_header."No.");
                            if bom_line.FindSet() then begin
                                repeat begin
                                    bom_items.Reset();
                                    bom_items.SetFilter(item_code, bom_line."No.");
                                    if not bom_items.FindLast() then begin
                                        bom_count := bom_count + 1;
                                        bom_items.Init();
                                        bom_items.no_ := bom_count;
                                        bom_items.receipt_no := receipt;
                                        bom_items.item_code := bom_line."No.";
                                        bom_items.item_desc := bom_line.Description;
                                        bom_items.quantity := bom_line."Quantity per" * line.Quantity;
                                        bom_items.Parent_BOM_Line_No := line."Line No."; //AlleRSN 041023
                                        bom_items.Insert();
                                    end
                                    else begin
                                        bom_items.quantity := bom_items.quantity + (bom_line.Quantity * line.Quantity);
                                        bom_items.Modify();
                                    end;
                                    // pos.PluKeyPressed(bom_line."No.");
                                end until bom_line.Next() = 0;
                            end;
                        end;
                        //AlleRSN 041023 start
                        line."Packaging BOM Applied" := true;
                        line.Modify();
                        //AlleRSN 041023 end
                    end;
                end;

            end until line.Next(-1) = 0;
        end;

        msg := '';
        bom_items.Reset();
        if bom_items.FindSet() then begin
            repeat begin
                msg := msg + bom_items.item_code + ' ' + format(bom_items.quantity) + '\';
                //Ashish pos.PluKeyPressed(bom_items.item_code);
                line.Reset();
                line.SetFilter("Receipt No.", receipt);
                line.SetFilter(Number, bom_items.item_code);
                line.FindLast();
                line.Quantity := bom_items.quantity;
                line."Parent BOM Line No" := bom_items.Parent_BOM_Line_No; //AlleRSN 041023

                //AlleRSN 091123 start
                line."Discount %" := 0;
                line."Discount Amount" := 0;
                line.Amount := 0;
                line."Net Amount" := 0;
                // line.Modify();
                //AlleRSN 091123 end
                //AlleRSN 141123 uncomment
                line.Modify(true);

                // pos.TotalPressed(false);
                // pos.CalcTotals();
            end until bom_items.Next() = 0;
            //AlleRSN 041023 comment start

            trans.SetFilter("Receipt No.", receipt);
            if trans.FindLast() then begin
                trans.PackagingBOMApplied := true;
                trans.Modify();
                commit;
                isHandled := true;
            end;

            //AlleRSN 041023 comment end
        end;

        //isHandled := true; //AlleRSN 041023
    end;

    local procedure isPackagingBomAdded(receipt: text) added: Boolean
    var
        trans: record "LSC POS Transaction";
    begin
        trans.SetFilter("Receipt No.", receipt);
        if trans.FindLast() then begin
            if trans.PackagingBOMApplied then
                added := true;
        end;
    end;

    local procedure isPackagingBomAddedLine(receipt: text; ItemNo: Code[20]; LineNo: Integer) added: Boolean
    var
        TransLine: record "LSC POS Trans. Line";
    begin
        TransLine.SetFilter("Receipt No.", receipt);
        TransLine.SetFilter(Number, ItemNo);
        TransLine.SetRange("Line No.", LineNo);
        if TransLine.FindLast() then begin
            if TransLine."Packaging BOM Applied" then
                added := true;
        end;
    end;

    local procedure isPackagingBomDisabled() disabled: Boolean
    var
        config: record "TWC Configuration";
        store: record "LSC Store";
        pos: Codeunit "LSC POS Session";
    begin
        config.SetFilter(Key_, '@PackagingBOM');
        config.SetFilter(Name, '@Disable');
        config.SetFilter(Value_, '1');

        store.SetFilter("No.", pos.StoreNo());
        if (config.FindLast() or store.DisablePackagingBom) then
            disabled := true;
    end;
}
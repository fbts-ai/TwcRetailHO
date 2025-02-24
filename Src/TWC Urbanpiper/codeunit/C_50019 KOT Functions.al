codeunit 50019 "KOT Functions"
{
    trigger OnRun()
    begin

    end;

    procedure print_kot(receipt_no: text)
    var
        pos_trans_line: record "LSC POS Trans. Line";
    begin
        pos_transaction.SetFilter("Receipt No.", receipt_no);
        if pos_transaction.FindLast() then begin
            pos_trans_line.SetFilter("Receipt No.", receipt_no);
            pos_trans_line.SetFilter("Entry Status", format(pos_trans_line."Entry Status"::" "));
            if pos_trans_line.FindSet() then begin
                repeat begin
                    PrintKOT(pos_trans_line);
                    // send_to_kds.SendReceiptToKDS(receipt_no, "LSC KDS-Send Receipt to KDS"::"All Items", 0, 0DT);
                end
                until pos_trans_line.Next() = 0;
            end;
        end;
    end;

    local procedure PrintKOT(
        posTransLine: record "LSC POS Trans. Line"
    )
    var
        preOrderSalesType: text;
        store: record "LSC Store";
    begin
        store.SetFilter("No.", posTransLine."Store No.");
        store.FindLast();
        preOrderSalesType := pos_transaction."Sales Type";

        //Ashish        send_to_kds.SetKDSRouting(posTransLine, store, preOrderSalesType);
    end;



    local procedure InsertRecords()
    begin
        insertHospOrderKitcheStatus();
        //insertHospOrderTransStatus(ref_receipt_no, newreceiptno);
        //.insertPOSTrLineDisStatR(ref_receipt_no, newreceiptno, true);
        //insertPOSTrLineDisStatR(ref_receipt_no, newreceiptno, false);
        //insertPOSTransGuestInfo(ref_receipt_no, newreceiptno);
        //insertTransactionInUseOnPOS(ref_receipt_no, newreceiptno);
    end;


    local procedure insertHospOrderKitcheStatus()
    var
    begin
        kds_func.CreateKitchenStatusIfMissing(pos_transaction, diningAreaProfId, statusFlowId);
    end;

    local procedure insertHospOrderTransStatus(receiptNo: text; newreceiptno: text)
    var
    begin
        //Ashish   hosp_func.CreateHospOrderTransStatus(pos_transaction, diningAreaProfId, statusFlowId);
    end;

    local procedure insertPOSTrLineDisStatR()
    var
        ReceiptNo: Code[20];
        PosTrLineNo: Integer;
        RestaurantNo: Code[10];
        LoadConfigCode: Code[20];
        SalesType: Code[20];
        PosTerminalNo: Code[10];
        PosTermGrNo: Code[20];
        KDSItemSectionRouting: Record 10012131;
        InsertRoutingLine: Boolean;
        PosTrLineDisplStatRoutTEMP: Record 10012154;
        KDSDisplayStatRouting: Record 10001234;
        ItemNo: Code[20];
    begin
        //Ashish
        // send_to_kds.InsertTransRouting
        // (
        //     ReceiptNo,
        //     PosTrLineNo,
        //     RestaurantNo,
        //     LoadConfigCode,
        //     SalesType,
        //     PosTerminalNo,
        //     PosTermGrNo,
        //     KDSItemSectionRouting,
        //     InsertRoutingLine,
        //     PosTrLineDisplStatRoutTEMP,
        //     KDSDisplayStatRouting,
        //     ItemNo
        // );
    end;

    local procedure insertPOSTransGuestInfo(receiptNo: text; newreceiptno: text);
    var
    begin
    end;

    local procedure insertTransactionInUseOnPOS(receiptNo: text; newreceiptno: text)
    var
    begin
        //Ashish pos_func.InsertTransInUseOnPos(pos_transaction."Receipt No.", pos_transaction."POS Terminal No.", TRUE, TRUE);
    end;

    var
        ref_receipt_no: text;
        func: Codeunit "UP Functions";
        // Ashish send_to_kds: codeunit "LSC Send to KDS";
        kds_func: Codeunit "LSC KDS Functions";
        //Ashish hosp_func: codeunit "LSC Hospitality Functions";
        pos_func: Codeunit "LSC POS Functions";


        pos_transaction: record "LSC POS Transaction";
        diningAreaProfId, statusFlowId : text;

        PosPrint: Codeunit "LSC POS Print Utility";
}
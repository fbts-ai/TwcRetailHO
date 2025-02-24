codeunit 50030 "Receipt No. Format"
{

    [EventSubscriber(ObjectType::Table, Database::"LSC Transaction Header", 'OnBeforeInsertEvent', '', false, false)]
    local procedure OnBeforeInsert(RunTrigger: Boolean; var Rec: Record "LSC Transaction Header")
    begin
        rec."Cust Receipt No" := getTWCReceiptNo(rec."Receipt No.", rec."Created on POS Terminal");
    end;

    [EventSubscriber(ObjectType::Table, Database::"LSC POS Transaction", 'OnBeforeInsertEvent', '', false, false)]
    local procedure POStransactionOnBeforeInsert(RunTrigger: Boolean; var Rec: Record "LSC POS Transaction")
    begin
        if rec."Cust Receipt No" = '' then begin
            rec."Cust Receipt No" := getTWCReceiptNo(rec."Receipt No.", rec."Created on POS Terminal");
        end
    end;

    procedure getTWCReceiptNo(receiptNo: text; terminal: text) twc_receipt_no: text
    var
        tempReceiptNo: text[20];
        temp: text[5];
        fiscalYear: Codeunit "Accounting Period Mgt.";
        yy: text[2];
        typeprefix: text[1];
        db: record "LSC POS Trans. Line";
        start: Integer;
    begin
        tempReceiptNo := receiptNo;
        if receiptNo <> '' then begin
            start := strpos(receiptNo, terminal);
            if start <> 0 then begin
                temp := CopyStr(receiptNo, 1, 2);
                if (temp = '00') then begin
                    tempReceiptNo := CopyStr(receiptNo, start, 20);
                    yy := CopyStr(Format(Date2DMY(fiscalYear.FindFiscalYear(Today), 3)), 3, 2);

                    db.Reset();
                    db.SetFilter("Receipt No.", receiptNo);
                    db.SetFilter("Entry Status", Format(db."Entry Status"::" "));
                    db.SetFilter(Quantity, '<0');

                    if db.FindSet() then
                        typeprefix := 'R'
                    else
                        typeprefix := 'I';
                end;

                twc_receipt_no := yy + typeprefix + tempReceiptNo;
            end;
        end;
    end;
}

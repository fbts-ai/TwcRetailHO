codeunit 50034 "Store Staff Session"
{
    trigger OnRun()
    begin

    end;

    [EventSubscriber(ObjectType::Table, Database::"LSC Transaction Header", 'OnAfterInsertEvent', '', false, false)]
    local procedure OnAfterInsertEvent(RunTrigger: Boolean; var Rec: Record "LSC Transaction Header")
    var
        session: record "Store Staff Session";
        lastSession: record "Store Staff Session";
    begin
        if (rec."Transaction Type" = rec."Transaction Type"::"Float Entry")
            and (rec."Entry Status" = rec."Entry Status"::" ") then begin

            session.SetFilter(store, rec."Store No.");
            session.SetFilter(terminal, rec."POS Terminal No.");
            session.SetFilter(staff, rec."Staff ID");
            if session.FindFirst() then begin
                session.startedOn := CurrentDateTime;
                session.endedOn := 0DT;
                session.sessionEnded := false;
                session.Modify();
            end
            else begin
                session.Init();

                session.Id := 1;
                if lastSession.FindLast() then
                    session.Id := lastSession.Id + 1;

                session.store := rec."Store No.";
                session.terminal := rec."POS Terminal No.";
                session.staff := rec."Staff ID";
                session.startedOn := CurrentDateTime;
                session.endedOn := 0DT;
                session.sessionEnded := false;
                session.Insert();
            end;
        end
        else
            if (rec."Transaction Type" = rec."Transaction Type"::"Tender Decl.")
           and (rec."Entry Status" = rec."Entry Status"::" ") then begin
                session.SetFilter(store, rec."Store No.");
                session.SetFilter(terminal, rec."POS Terminal No.");
                session.SetFilter(staff, rec."Staff ID");
                if session.FindFirst() then begin
                    session.endedOn := CurrentDateTime;
                    session.sessionEnded := true;
                    session.Modify();
                end;
            end;
    end;

    //NICK_ALLE_17202023
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Controller", 'OnBeforeRunPos', '', false, false)]
    local procedure OnBeforeRunPos(PosTerminal: Code[10]; StaffID: Code[20])
    var
        ActiveonPos: Record "Active On Pos";
        ActiveSe: Record "Active Session";
        UniqueID: text[100];
        test: codeunit "LSC POS Transaction";

    begin
        // ActiveonPos.DeleteAll();
        if ActiveonPos.Get(StaffID) then begin
            if ActiveonPos."Terminal No." <> '' then begin
                if ActiveonPos."Terminal No." <> PosTerminal then
                    Error('You are already logged in to terminal %1. First, log off from that terminal, and then log in again.', ActiveonPos."Terminal No.");
            end;
        end else begin
            ActiveonPos.SetRange("Staff ID", StaffID);
            if not ActiveonPos.FindFirst() then begin
                ActiveonPos.Init();
                ActiveonPos."Staff ID" := StaffID;
                ActiveonPos."Terminal No." := PosTerminal;
                ActiveonPos.Insert();
            end;
        end;

    end;


    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Controller", 'OnButtonPressed', '', false, false)]
    local procedure OnButtonPressed(var POSMenuLine: Record "LSC POS Menu Line"; var handled: Boolean)
    var
        LSCPOSSESSION: Codeunit "LSC POS Session";
        StaffId: Code[20];
        ActiveonPos: Record "Active On Pos";
    begin
        POSMenuLine.SetRange("Profile ID", '##DEFAULT');
        POSMenuLine.SetRange("Menu ID", '#LAY-FUNC-ORD-LIST-O');
        if POSMenuLine.Find() then begin
            if POSMenuLine.Command = 'LOGOFF' then begin
                StaffId := LSCPOSSESSION.StaffID();
                ActiveonPos.SetRange("Staff ID", StaffId);
                if ActiveonPos.FindFirst() then begin
                    ActiveonPos.DeleteAll();
                    Commit();
                end;
            end;

        end;


    end;
    //NICK_ALLE_17202023

    var
        myInt: Integer;
        test: Record "LSC POS Transaction";
}
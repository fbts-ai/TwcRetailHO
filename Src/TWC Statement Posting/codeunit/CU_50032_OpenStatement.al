codeunit 50032 "Open Statement"
{
    [EventSubscriber(ObjectType::Page, Page::"LSC Open Statement", 'OnBeforeActionEvent', 'C&alculate Statement', false, false)]
    local procedure MyProcedure(var Rec: Record "LSC Statement")
    var
        staff: code[20];
        session: record "Store Staff Session";

        func: codeunit "UP Functions";
        eod_check_enabled: Boolean;
    begin
        // staff := Rec."Staff/POS Term Filter Internal";
        // if staff = '' then begin
        //     Error('Please select the staff to post statement.');
        //     exit;
        // end;

        eod_check_enabled := (func.GetConfig('STATEMENT_POSTING', 'EOD_VALIDATION') = '1');
        if eod_check_enabled then begin
            session.SetFilter(store, rec."Store No.");
            session.SetFilter(staff, rec."Staff/POS Term Filter Internal");
            session.SetFilter(startedOn, '>%1', 0DT);
            session.SetFilter(sessionEnded, 'false');
            if session.FindLast() then begin
                Error('Selected staff has not done completed the EOD!');
                exit;
            end;
        end;
    end;
}

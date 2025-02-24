page 50090 ActiveSessionsPage
{
    Caption = 'Active Sessions';
    PageType = List;
    UsageCategory = Lists;
    ApplicationArea = All;
    SourceTable = ActiveSessionsTable;
    DeleteAllowed = false;
    InsertAllowed = false;
    ModifyAllowed = false;

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field(Id; Rec.ID)
                {
                    ApplicationArea = All;
                }
                field(Date; Rec.Date)
                {
                    ApplicationArea = All;
                }
                field(Time; Rec.Time)
                {
                    ApplicationArea = All;
                }
                field(Store; Rec.Store)
                {
                    ApplicationArea = All;
                }
                field(Terminal; Rec.Terminal)
                {
                    ApplicationArea = All;
                }
                field(Status; Rec.Status)
                {

                }
                field(Role; Rec.Role)
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    trigger OnOpenPage()
    var
        q: Query "ActiveManagerShiftQuery";
        cuPOSSession: Codeunit "LSC POS Session";
    begin
        if not (cuPOSSession.StoreNo() = '') then begin
            q.SetRange(q.Store_No_, cuPOSSession.StoreNo());
        end;
        q.SetFilter(q.Status, '<2');
        if q.Open() then begin
            while q.Read() do begin
                Rec.Init();
                Rec.ID := q.ID;
                Rec.Date := q.Date;
                Rec.Time := q.Time;
                Rec.Store := q.Store_No_;
                Rec.Terminal := q.POS_Terminal_No_;
                Rec.Role := q.Permission_Group;
                Rec.Status := q.Status;
                Rec.Insert();
            end;
            q.Close();
        end;
    end;
}
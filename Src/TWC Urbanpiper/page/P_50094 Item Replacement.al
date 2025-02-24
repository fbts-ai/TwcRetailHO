page 50094 "Item Replacement"
{
    PageType = Worksheet;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "Item";
    DeleteAllowed = false;
    LinksAllowed = false;
    InsertAllowed = false;
    ModifyAllowed = false;

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field("No."; "No.") { ApplicationArea = All; }
                field(Description; Description) { ApplicationArea = All; }
            }
        }
        area(Factboxes)
        {

        }
    }

    actions
    {
        area(Processing)
        {
            action("Replace")
            {
                ApplicationArea = all;
                Promoted = true;
                PromotedIsBig = true;
                PromotedCategory = Process;

                trigger OnAction()
                var
                begin
                    if rec."No." = '' then begin
                        item_no := '';
                        item_desc := '';
                    end
                    else begin
                        item_no := rec."No.";
                        item_desc := rec.Description;
                    end;
                    CurrPage.Close();
                end;

            }
        }
    }

    trigger OnInit()
    begin
        rec.SetFilter("No.", '@FG*');
    end;


    var
        item_no: text;
        item_desc: text;

    procedure GetSelectedItemNo() no: text
    begin
        no := item_no;
    end;

    procedure GetSelectedItemDesc() desc: text
    begin
        desc := item_desc;
    end;
}
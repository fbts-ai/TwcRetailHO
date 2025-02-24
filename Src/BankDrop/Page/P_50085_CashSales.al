page 50085 "Cash Sales"
{
    ApplicationArea = All;
    Caption = 'Cash Sales';
    PageType = List;
    SourceTable = 99001489;
    UsageCategory = Administration;
    //ContextSensitiveHelpPage = 'ui-enter-date-ranges';

    layout
    {
        area(Content)
        {

            field("Staff ID"; Rec."Staff ID")
            {
                ApplicationArea = All;
            }
            field("Tender Type Name"; Rec."Tender Type Name")
            {
                ApplicationArea = All;
            }
            field("Counted Amount"; Rec."Counted Amount")
            {
                ApplicationArea = All;
            }

        }
    }

}
page 60121 "FreeItemList"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "FreeItem Offer Header";
    DeleteAllowed = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    Editable = false;
    CardPageId = "Free Item Offer Header";
    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {

                field(Rec; Rec."Offer No.")
                {
                    ApplicationArea = All;
                }
                field("Offer Description"; Rec."Offer Description")
                {
                    ApplicationArea = All;
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = All;
                }
                field("Validation Period ID"; Rec."Validation Period ID")
                {
                    ApplicationArea = All;
                }
            }
        }
        area(Factboxes)
        {

        }
    }

}
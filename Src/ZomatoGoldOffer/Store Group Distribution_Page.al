page 60124 "Store Group Distribution_1"
{
    PageType = ListPart;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "Offer Store wise Dist.";
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
                field("Store No."; Rec."Store No.")
                {
                    ApplicationArea = All;
                }
            }
            // area(Factboxes)
            // {

            // }
        }

    }
}
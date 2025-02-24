page 60123 "Free Item Offer Lines"
{
    PageType = ListPart;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "Free Item Offer Line";
    DelayedInsert = true;
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
                field("Line No."; Rec."Line No.")
                {
                    ApplicationArea = All;
                }
                field(Type; Rec.Type)
                {
                    ApplicationArea = All;
                }
                field("No."; Rec."No.")
                {
                    ApplicationArea = All;
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = all;
                }
                field("Free Item"; Rec."Free Item")
                {
                    ApplicationArea = All;
                    trigger OnValidate()
                    var
                        OfferHeader: Record "FreeItem Offer Header";
                    begin
                        if OfferHeader.Get(Rec."Offer No.") then begin
                            if OfferHeader.DiscountOffer then
                                if Rec."Free Item" then
                                    Error('Free Item Offer not club with Discount offer');
                        end;
                    end;
                }
            }
            // area(Factboxes)
            // {

            // }
        }

    }
}
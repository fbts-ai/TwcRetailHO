pageextension 50079 ItemcategoryUpExt extends "Item Category Card"
{
    layout
    {
        // Add changes to page layout here
        addlast(General)
        {
            Field(SortingOrder; Rec.SortingOrder)
            {
                ApplicationArea = all;
            }
            field(TimeGroup; Rec.TimeGroup)
            {
                ApplicationArea = all;
            }
            field(ActiveforUP; Rec.ActiveforUP)
            {
                ApplicationArea = all;
            }
            //Alle-RSN
            field("Packaging Bom"; rec."Packaging Bom")
            {
                ApplicationArea = all;
            }
            //Alle-RSN
        }
    }

    actions
    {
        // Add changes to page actions here
    }

    var
        myInt: Integer;
}
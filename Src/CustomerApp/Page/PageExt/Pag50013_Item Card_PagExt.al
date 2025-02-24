pageextension 50013 ItemCardExt extends "Item Card"
{
    layout
    {
        addafter(Blocked)
        {
            field("Send to Cust app"; "Send to Cust app")
            {
                ApplicationArea = all;
            }
            field(Allergens; rec.Allergens)
            {
                ApplicationArea = all;
            }
            field(Calorie; rec.Calorie)
            {
                ApplicationArea = all;
            }
            field("Calorie UOM"; rec."Calorie UOM")
            {
                ApplicationArea = all;
            }
            field("Online Item Group"; rec."Online Item Group")
            {
                ApplicationArea = all;
            }
            field(Size; rec.Size)
            {
                ApplicationArea = all;
            }
            //Urban piper mahendra
            field(IsUPVariant; Rec.IsUPVariant)
            {
                ApplicationArea = all;
            }
        }
        addafter("Item")
        {
            group("Item Packaging")
            {
                /*
                field("Packing BOM"; rec."Packing BOM")
                {
                    ApplicationArea = all;
                }
*/
                field("Packaging BOM"; Rec."Packaging BOM")
                {
                    ApplicationArea = all;
                }
            }
        }
        addafter("No.")
        {
            field("No. 2"; rec."No. 2")
            {
                ApplicationArea = all;
            }
        }
    }

    actions
    {
        // Add changes to page actions here
    }

    var
        myInt: Integer;
}
//AJ_ALLE_13122023
pageextension 50151 LscTransactionCardExt extends "LSC Transaction Card"
{
    layout
    {
        // Add changes to page layout here
        addafter(Comment)
        {
            field("Tax Area Code"; rec."Tax Area Code")
            {
                Caption = 'App Discount ID';
                ApplicationArea = all;
            }
            field("Tax Exemption No."; "Tax Exemption No.")
            {
                Caption = 'App Discount Code';
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
//AJ_ALLE_13122023
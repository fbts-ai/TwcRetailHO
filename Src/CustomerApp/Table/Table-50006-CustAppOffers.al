table 50006 Cust_App_Offers
{
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            DataClassification = ToBeClassified;
            AutoIncrement = true;
        }

        field(2; UserId; Text[30])
        { }
        field(3; "Offer Type"; Option)
        {
            OptionMembers = "","loyaltyDiscounts","orderDiscounts","productDiscounts","bogoDiscounts";
        }
        field(4; "Discount Type"; Code[30])
        { }
        field(5; "Code"; Code[100])
        { }
        field(6; "Discount Id"; Code[20]) { }
        field(7; "appProductId"; Code[20]) { }
        field(8; "posItemId"; Code[20]) { }
        field(9; "productName"; Text[100]) { }
        field(10; "Token ID"; Code[30])
        { }
        //AJ_Alle 30102023
        field(11; "Receipt No"; Code[20])
        { }
        //AJ_Alle 30102023
        //AJ_Alle 01112023
        field(12; "Wallet Balance"; Text[100])
        { }
        field(13; "Wave Coin Balance"; Text[100])
        { }
        //AJ_Alle 01112023
    }

    keys
    {
        key(Key1; "Entry No.")
        {
            Clustered = true;
        }
    }

    var
        myInt: Integer;

    trigger OnInsert()
    begin

    end;

    trigger OnModify()
    begin

    end;

    trigger OnDelete()
    begin

    end;

    trigger OnRename()
    begin

    end;

}
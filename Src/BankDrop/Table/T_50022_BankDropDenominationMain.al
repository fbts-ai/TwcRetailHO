table 50022 "Bank Drop Denomination Main"
{
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "Tender Type"; Code[10])
        {
            Caption = 'Tender Type';
            TableRelation = "LSC Tender Type".Code;
            DataClassification = CustomerContent;
        }

        field(2; "Currency Code"; Code[10])
        {
            Caption = 'Currency Code';
            DataClassification = CustomerContent;
        }
        field(3; Type; Option)
        {
            Caption = 'Type';
            OptionCaption = 'Coin,Note,Roll,Total';
            OptionMembers = Coin,Note,Roll,Total;
            DataClassification = CustomerContent;
        }
        field(5; Amount; Decimal)
        {
            Caption = 'Amount';
            DataClassification = CustomerContent;
        }

        field(6; "Qty."; Integer)
        {
            Caption = 'Qty.';
            DataClassification = CustomerContent;
        }

        field(7; Total; Decimal)
        {
            Caption = 'Total';
            DataClassification = CustomerContent;
        }

        field(8; Description; Text[30])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }

        field(9; Store_No; Text[30])
        {
            Caption = 'Store_No';
            DataClassification = CustomerContent;
        }

        field(10; ID; Integer)
        {
            //AutoIncrement = true;
        }
        field(11; "Date"; DateTime)
        {

        }

        field(12; "Terminal_No"; Text[30])
        {

        }
        field(13; Staff_ID; Text[30])
        {

        }
        field(15; BankDropID; Integer)
        {

        }

        field(16; BankDropDate; Date)
        {

        }
    }

    keys
    {
        key(Key1; ID)
        {
            Clustered = true;
            SumIndexFields = Total;
        }
    }

    var
        myInt: Integer;

}
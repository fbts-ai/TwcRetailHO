table 50024 "EOD Main"
{
    fields
    {
        field(1; ID; Integer)
        {
            AutoIncrement = true;
        }

        field(2; "Date/Time"; DateTime)
        {
            Caption = 'Date/Time';
            DataClassification = CustomerContent;
        }

        field(4; Remarks; Code[10])
        {
            Caption = 'Remarks';
        }

        field(6; StoreCode; Text[100])
        {

        }

        field(7; PostedStatus; Boolean)
        {

        }
    }

    keys
    {
        key(PK; ID, StoreCode)
        {
            Clustered = true;
        }
    }
}

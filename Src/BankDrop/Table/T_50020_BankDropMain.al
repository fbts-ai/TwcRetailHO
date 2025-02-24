table 50020 "Bank Drop Main"
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

        field(5; Acknowlegement_No; Text[100])
        {

        }

        field(6; StoreCode; Text[100])
        {

        }
        field(7; PostedStatus; Boolean)
        {

        }

        field(8; BankDropDate1; Date)
        {

        }
    }

    keys
    {
        key(PK; ID)
        {
            Clustered = true;
        }
    }
}

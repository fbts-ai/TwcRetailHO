table 50023 EODCheckListTempTable
{
    Caption = 'EODCheckListTempTable';
    DataClassification = ToBeClassified;

    fields
    {
        field(1; ID; Integer)
        {
            AutoIncrement = true;
        }
        field(2; "Tasks"; Text[100])
        {
            DataClassification = ToBeClassified;
        }

        field(3; Status; Option)
        {
            OptionCaption = ' ,Mark Done, Mark Not Done';
            OptionMembers = " ","Mark Done","Mark Not Done";
            //DataClassification = ToBeClassified;
        }

        field(4; Store_No; Text[30])
        {
            Caption = 'Store_No';
            DataClassification = CustomerContent;
        }

        field(5; "Date"; DateTime)
        {

        }
        field(6; EOD_ID; Integer)
        {
            TableRelation = "Bank Drop Main".ID;
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
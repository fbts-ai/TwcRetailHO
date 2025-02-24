table 50030 UP_Log
{
    DataClassification = ToBeClassified;

    fields
    {
        field(1; ID; BigInteger)
        {
            AutoIncrement = true;
        }
        field(2; OrderID; BigInteger)
        {
            DataClassification = ToBeClassified;
        }

        field(3; Message; Text[100])
        {
            DataClassification = ToBeClassified;
        }
        field(4; OrderStatus; Text[50])
        {
            DataClassification = ToBeClassified;
        }
    }

    keys
    {
        key(Key1; ID)
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
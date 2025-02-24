//AJ_ALLE_17102023
table 50034 "Active On Pos"
{
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "Staff ID"; Code[20])
        {
            DataClassification = ToBeClassified;

        }
        field(2; "Terminal No."; Code[10])
        {
            DataClassification = ToBeClassified;
        }
        field(3; SessionId; Integer)
        {
            DataClassification = ToBeClassified;
        }
    }

    keys
    {
        key(Key1; "Staff ID")
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
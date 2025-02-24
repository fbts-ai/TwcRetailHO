table 50029 "Store Staff Session"
{
    DataClassification = CustomerContent;

    fields
    {
        field(1; Id; Integer)
        {
            DataClassification = ToBeClassified;
            AutoIncrement = true;
        }

        field(2; store; code[20]) { }
        field(3; terminal; code[20]) { }
        field(4; staff; code[20]) { }
        field(5; startedOn; DateTime) { }
        field(6; endedOn; DateTime) { }
        field(7; sessionEnded; Boolean) { }
    }

    keys
    {
        key(PK; store, terminal, staff)
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
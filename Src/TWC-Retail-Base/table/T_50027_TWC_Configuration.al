table 50027 "TWC Configuration"
{
    DataClassification = CustomerContent;

    fields
    {
        field(1; Id; Integer)
        {
            DataClassification = CustomerContent;
            AutoIncrement = true;
        }

        field(2; Key_; Text[50])
        {
            Caption = 'Key';
            DataClassification = CustomerContent;
        }

        field(3; Name; Text[50])
        {
            Caption = 'Name';
            DataClassification = CustomerContent;
        }

        field(4; Value_; Text[255])
        {
            Caption = 'Value';
            DataClassification = CustomerContent;
        }

        field(5; Sequence_No; Integer)
        {
            Caption = 'Sequence No.';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; Id)
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
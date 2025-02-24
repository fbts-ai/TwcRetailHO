table 50019 "Packaging Item"
{
    DataClassification = CustomerContent;
    TableType = Temporary;

    fields
    {
        field(1; no_; Integer)
        {
            AutoIncrement = true;
        }

        field(2; receipt_no; code[20]) { }
        field(3; item_code; code[20]) { }
        field(4; item_desc; text[100]) { }
        field(5; quantity; decimal) { }
        field(6; Parent_BOM_Line_No; Integer) { } //AlleRSN 041023
    }

    keys
    {
        key(Key1; No_)
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
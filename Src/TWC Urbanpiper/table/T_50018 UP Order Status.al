table 50018 "UP Order Status"
{
    DataClassification = CustomerContent;

    fields
    {
        field(1; No_; BigInteger)
        {
            AutoIncrement = true;
        }

        field(2; order_no; BigInteger)
        {
            TableRelation = "UP Header".order_details_id;
            ValidateTableRelation = false;
        }

        field(3; store_id; text[20]) { }
        field(4; prev_state; text[50]) { }
        field(5; new_state; text[50]) { }
        field(6; updated_on; datetime) { }
    }

    keys
    {
        key(PK; No_)
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
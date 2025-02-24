Table 60032 "Free Item Offer Line"
{

    fields
    {
        field(1; "Offer No."; Code[20])
        {

        }
        field(2; "Line No."; Integer)
        {

        }
        field(3; Type; Option)
        {
            OptionMembers = Item,All;
        }
        field(4; "No."; Code[20])
        {
            TableRelation = IF (Type = CONST(Item)) Item;
            trigger OnValidate()
            var
                Item: Record Item;
            begin
                IF "No." <> '' THEN BEGIN
                    CASE Type OF
                        Type::Item:
                            BEGIN
                                IF Item.GET("No.") THEN BEGIN
                                    VALIDATE(Description);
                                END;
                            END;
                    END;  //Case
                END;

            end;
        }
        field(5; Description; Text[100])
        {

        }
        field(6; "Free Item"; Boolean)
        {

        }

    }

    keys
    {
        key(Key1; "Offer No.", "Line No.")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
    }

    var
    // Item: Record 27;
    // // ProductGroup: Record 5723;
    // ItemCategory: Record 5722;
    // SpecialGroup: Record 10000735;
}


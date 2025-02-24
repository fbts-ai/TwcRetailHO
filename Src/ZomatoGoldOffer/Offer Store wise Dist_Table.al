Table 60033 "Offer Store wise Dist."
{
    fields
    {
        field(1; "Offer No."; Code[20])
        {

        }
        field(2; "Store No."; Code[20])
        {
            TableRelation = "LSC Store"."No.";
        }
    }
    keys
    {
        key(Key1; "Offer No.", "Store No.")
        {
            Clustered = true;
        }
    }
}
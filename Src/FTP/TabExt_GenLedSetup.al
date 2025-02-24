tableextension 50000 GenLedSetup extends "General Ledger Setup"
{
    fields
    {
        // Add changes to table fields here
        field(50000; Sno; Integer)
        {
            DataClassification = ToBeClassified;
        }
    }

    keys
    {
        // Add changes to keys here
    }

    fieldgroups
    {
        // Add changes to field groups here
    }

    var
        myInt: Integer;
}
tableextension 50059 ItemCategoryUpExt extends "Item Category"
{
    fields
    {
        //Mahendra Urban piper mapping
        // Add changes to table fields here
        field(50020; SortingOrder; Integer)
        {
            Caption = 'Sorting Order';
        }
        field(50021; TimeGroup; Text[40])
        {
            Caption = 'Time Group';
        }
        field(50022; ActiveforUP; Boolean)
        {
            Caption = 'Active for Urban Piper';
        }
        field(50023; "Packaging Bom"; Boolean)
        {
            DataClassification = ToBeClassified;
        }
    }

    var
        myInt: Integer;
}
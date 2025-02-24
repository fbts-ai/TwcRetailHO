tableextension 50009 ItemExt extends Item
{
    fields
    {
        // Add changes to table fields here
        field(50003; "Sort Order"; Integer)
        {
            DataClassification = ToBeClassified;
        }
        field(50004; "Send to Cust app"; Boolean)
        { }
        field(50005; "Allergens"; Text[100])
        {

        }
        field(50006; FoodLockStatus; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(50007; Select; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(50008; "Store code"; Code[20])
        {
            TableRelation = "LSC Store";
        }
        field(50009; "Packing BOM"; Code[30])
        {
            TableRelation = "Production BOM Header";
        }
        field(50010; IGST; Decimal)
        {

        }
        field(50011; CGST; Decimal)
        { }
        field(50012; SGST; Decimal)
        { }
        field(50013; "Calorie"; Decimal)
        { }
        field(50014; "Calorie UOM"; Code[20])
        {
            TableRelation = "Unit of Measure".Code;
        }
        field(50015; "Online Item Group"; Text[100])
        { }
        field(50016; "Size"; Code[25])
        { }
        field(50017; "Subscription Item"; Boolean)
        {

        }
        //UP mahendra
        field(50018; IsUPVariant; Boolean)
        {
            Caption = 'IsUPVariant';
        }
        //urban piper
        field(50200; "Packaging BOM"; code[20])
        {
            TableRelation = "Production BOM Header";
        }


        //chetan__30/12/2024

        field(50000; MyField; Blob)
        {
            DataClassification = ToBeClassified;
        }

        //chetan__30/12/2024

        modify("GST Group Code")
        {
            trigger OnAfterValidate()
            begin
                IF "GST Group Code" <> '' then begin
                    Evaluate(IGST, "GST Group Code");
                    CGST := IGST / 2;
                    SGST := CGST;
                    Modify(true);

                end;

            end;
        }
    }

    var
        myInt: Integer;
}
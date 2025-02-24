pageextension 50015 AssemblyBOM extends "Assembly BOM"
{
    layout
    {
        addafter("Assembly BOM")
        {
            field(Allergens; rec.Allergens)
            {
                ApplicationArea = all;
            }
        }
    }


}
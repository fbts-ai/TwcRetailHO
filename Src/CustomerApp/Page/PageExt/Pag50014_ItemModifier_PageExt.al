pageextension 50014 ItemModifier extends "LSC Table Specific Infocodes"
{
    layout
    {
        addafter("Infocode Code")
        {
            field("Is add-on"; "Is add-on")
            {
                ApplicationArea = all;
            }
        }
    }


    var
        myInt: Integer;
}

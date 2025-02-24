pageextension 50016 ItemModifierCard extends "LSC Item Mod. Select. Subc."
{
    layout
    {
        modify("Serial/Lot No. Needed")
        {
            Editable = true;
        }
    }

    actions
    {
        // Add changes to page actions here
    }

    var
        myInt: Integer;
}
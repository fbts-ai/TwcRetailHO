page 50021 "Item Modifier subpage"
{
    DelayedInsert = true;
    APIVersion = 'v2.0';
    EntityCaption = 'itemmodifiers-addon';
    EntitySetCaption = 'Item Modifiers sub';
    PageType = API;
    ODataKeyFields = SystemId;
    EntityName = 'itemmodifiersub';
    EntitySetName = 'itemmodifierssub';
    SourceTable = "LSC Information Subcode";
    Extensible = false;

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field(SystemId; rec.SystemId) { }

                field("ItemNo"; Rec."Trigger Code") { }

                field(Description; rec.Description)
                {
                    ShowCaption = false;

                }
                field("UnitofMeasure"; rec."Unit of Measure")
                { }
                field("PriceType"; rec."Price Type")
                { }

                field("Price"; rec."Amount /Percent")
                { }
                field("MinSelection"; rec."Min. Selection")
                { }

            }
        }
    }
}
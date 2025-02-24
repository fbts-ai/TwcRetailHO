page 50030 "FoodLockAPI"
{
    APIVersion = 'v2.0';
    EntityCaption = 'Food Lock';
    EntitySetCaption = 'Food Locks';
    ChangeTrackingAllowed = true;
    DelayedInsert = true;
    EntityName = 'foodlock';
    EntitySetName = 'foodlocks';
    ODataKeyFields = SystemId;
    PageType = API;
    SourceTable = Item;
    SourceTableView = where(FoodLockStatus = const(true));
    Extensible = false;

    layout
    {
        area(Content)
        {
            repeater(FoodLock)
            {
                field("Storecode"; "Store code")
                {
                }
                field(POSItemId; rec."No.")
                { }
                field(FoodLockStatus; rec.FoodLockStatus)
                { }
                field("LastDateTimeModified"; rec."Last DateTime Modified")
                { }
                field(SystemModifiedBy; SystemModifiedBy)
                { }

            }
        }
    }

}
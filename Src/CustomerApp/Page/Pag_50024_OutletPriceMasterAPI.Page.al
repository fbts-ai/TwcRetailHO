page 50024 "Outlet Price Master API"
{
    APIVersion = 'v2.0';
    EntityCaption = 'outlet price master';
    EntitySetCaption = 'outlet price masters';
    ChangeTrackingAllowed = true;
    DelayedInsert = true;
    EntityName = 'outletpricemaster';
    EntitySetName = 'outletpricemasters';
    // ODataKeyFields = SystemId;
    PageType = API;
    SourceTable = "LSC Store Price Group";
    Extensible = false;

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field("PriceGroupCode"; rec."Price Group Code")
                { }
                field("PriceGroupDescription"; rec."Price Group Description")
                { }
                field(Priority; rec.Priority)
                { }
            }

        }
    }

    var
        myInt: Integer;
}
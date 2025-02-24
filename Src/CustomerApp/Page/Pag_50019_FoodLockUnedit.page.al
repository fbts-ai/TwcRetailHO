page 50019 FoodLock
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = FoodLock;
    Editable = false;

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field(StoreCode; rec.StoreCode)
                {
                    ApplicationArea = All;
                }
                field(POSItemId; rec.POSItemId)
                {
                    ApplicationArea = All;
                }
                field(FoodLockStatus; rec.FoodLockStatus)
                {
                    ApplicationArea = All;
                }
                field(LastModifiedDate; rec.LastModifiedDate)
                {
                    ApplicationArea = All;
                }
                field(LastModifiedBy; rec.LastModifiedBy)
                {
                    ApplicationArea = All;
                }
            }
        }

    }


}
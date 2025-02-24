page 50018 "Sales Price API"
{
    DelayedInsert = true;
    APIVersion = 'v2.0';
    EntityCaption = 'Sales Price';
    EntitySetCaption = 'Sales Prices';
    PageType = API;
    ODataKeyFields = SystemId;
    EntityName = 'salesprice';
    EntitySetName = 'salesprices';
    SourceTable = "Sales Price";
    // SourceTableTemporary = true;
    Extensible = false;
    //SourceTableView = where("Price Type" = filter(Sale), "Amount Type" = filter(Price | 'Price & Discount'));

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                Caption = 'channelMrpS';
                field(SystemId; SystemId)
                { Visible = false; }

                field(PriceListType; Rec."Sales Code")
                {


                }

                field(SalesPrice; Rec."Unit Price")
                {

                }
                field(SalesUOM; Rec."Unit of Measure Code")
                {

                }
                field(ValidFrom; rec."Starting Date")
                {

                }
                field(ValidTo; rec."Ending Date")
                {



                }
            }

        }
    }
}
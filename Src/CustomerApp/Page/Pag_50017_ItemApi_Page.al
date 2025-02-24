page 50017 "API - Items"
{
    APIVersion = 'v2.0';
    EntityCaption = 'Item';
    EntitySetCaption = 'Items';
    ChangeTrackingAllowed = true;
    DelayedInsert = true;
    EntityName = 'item';
    EntitySetName = 'items';
    ODataKeyFields = SystemId;
    PageType = API;
    SourceTable = Item;
    Extensible = false;
    SourceTableView = where("Send to Cust app" = const(true));

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                Caption = 'products';
                field(SystemId; SystemId)
                {
                    Visible = false;
                }
                field("POSItemId"; rec."No.")
                {
                    Visible = false;
                }
                field("ExternalItemId"; Rec."No. 2")
                { }
                field("productCategoryType"; rec."LSC Division Code")
                { }
                field("productSubCategoryType"; rec."Item Category Code")
                {
                }
                field(ProductName; rec."Description")
                {
                }
                field("SpecialGroupCode"; rec."Online Item Group")
                { }
                field("preparationTime"; rec."LSC Production Time (Min.)")
                { }
                field(CGST; rec.CGST)
                { }
                field(IGST; rec.IGST)
                { }
                field(SGST; rec.SGST)
                { }

                field(Allergens; rec.Allergens)
                { }

                field("productType"; rec."LSC Recipe Category")
                { }
                // field("OnlineItemGroup"; rec."Online Item Group")
                // { }
                field(Size; rec.Size)
                { }

                part(itemmodifiers; 50020)
                {
                    Caption = 'itemmodifiers-addon';
                    EntityName = 'itemmodifier';
                    EntitySetName = 'itemmodifiers';
                    SubPageLink = value = field("No.");
                    ShowFilter = false;

                }
                part(salesprices; 50018)
                {
                    Caption = 'SalesPrices';
                    EntityName = 'salesprice';
                    EntitySetName = 'salesprices';
                    SubPageLink = "Item No." = field("No.");
                }


            }

        }

    }

    trigger OnAfterGetRecord()
    begin
        Clear(specialgrpcode);


        Rec.CalcFields("LSC Special Group Code");
        specialgrp.Reset();
        specialgrp.SetRange(Code, Rec."LSC Special Group Code");
        IF specialgrp.FindFirst() then
            specialgrpcode := specialgrp.Description
        else
            // rec."LSC Special Group Code" = '' then
            specialgrpcode := CopyStr(Rec.Description, 1, 30);
    end;

    // end;

    var

        specialgrpcode: Code[30];
        specialgrp: Record "LSC Item Special Groups";

}

page 50023 OutletMasterAPI
{
    APIVersion = 'v2.0';
    EntityCaption = 'outlet master';
    EntitySetCaption = 'outlet masters';
    ChangeTrackingAllowed = true;
    DelayedInsert = true;
    EntityName = 'outletmaster';
    EntitySetName = 'outletmasters';
    // ODataKeyFields = SystemId;
    PageType = API;
    SourceTable = "LSC Store";
    Extensible = false;

    // SourceTable = TableName;

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field("StoreCode"; rec."No.") { }
                field(StoreName; rec.Name)
                { }
                field("ExternalIdentity"; rec."Agave Store ID")
                { }
                field(StoreAddress1; rec.Address)
                { }
                field("StoreAddress2"; rec."Address 2")
                { }
                field(City; rec.City)
                {

                }
                field(State; location."State Code")
                { }

                field("PostalCode"; rec."Post Code")
                { }
                field("PhoneNumber"; rec."Phone No.")
                { }
                field(Latitude; rec.Latitude)
                { }
                field(Longitude; rec.Longitude)
                { }
                field("GSTRegistrationNo"; location."GST Registration No.")
                { }
                field("DistributionGroup"; location."LSC Distribution Loc. Code")
                { }
                field("Status"; rec."Ordering Status")
                { }
                field("LastDateModified"; rec."Last Date Modified")
                { }
                field(ModifiedBy; rec.SystemModifiedBy)
                { }
                part(outletpricemasters; 50024)
                {
                    Caption = 'outletpricemasters';
                    EntityName = 'outletpricemaster';
                    EntitySetName = 'outletpricemasters';
                    SubPageLink = store = field("No.");
                }


            }
        }
    }
    trigger OnAfterGetRecord()
    begin
        IF location.Get(rec."No.") then;
    end;

    var
        location: Record Location;

}
page 50020 "Item Modifier API"
{
    DelayedInsert = true;
    APIVersion = 'v2.0';
    EntityCaption = 'itemmodifiers-addon';
    EntitySetCaption = 'Item Modifiers';
    PageType = API;
    ODataKeyFields = SystemId;
    EntityName = 'itemmodifier';
    EntitySetName = 'itemmodifiers';
    SourceTable = "LSC Table Specific Infocode";
    // SourceTableTemporary = true;
    Extensible = false;
    SourceTableView = where("Is add-on" = const(true), "Table ID" = const(27), "Usage Category" = filter('Item Modifier'));
    ShowFilter = false;
    layout
    {
        area(content)
        {
            repeater(Group)
            {
                Caption = 'applicableAddOnTypes';

                field(SystemId; SystemId) { }
                field("InfocodeCode"; rec."Infocode Code")
                {
                    Caption = 'Modifier ID';
                }
                part(itemmodifiersaddon; 50021)
                {

                    EntityName = 'itemmodifiersub';
                    EntitySetName = 'itemmodifierssub';
                    SubPageLink = code = field("Infocode Code");
                    Caption = 'item modifier list';
                }


            }
        }
    }



    var
        myInt: Integer;
}
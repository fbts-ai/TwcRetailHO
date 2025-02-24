page 50087 "No Sales Reason Code"
{
    ApplicationArea = All;
    Caption = 'No Sales Reason Code';
    PageType = List;
    SourceTable = "Bank Drop Main";
    UsageCategory = Administration;
    //ContextSensitiveHelpPage = 'ui-enter-date-ranges';
    InsertAllowed = false;
    DeleteAllowed = false;
    ModifyAllowed = false;
    // PromotedActionCategories = 'Process';

    layout
    {
        area(Content)
        {
            field("Reason Code"; reasonCode)
            {
                Caption = 'Reason';
                OptionCaption = 'Canceled, Closed, Holdiay, No Sale';

                ApplicationArea = All;
            }
        }
    }
    var
        reasonCode: Option;
}
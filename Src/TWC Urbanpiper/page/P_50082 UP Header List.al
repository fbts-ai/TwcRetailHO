page 50082 "UP Header List"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "UP Header";
    InsertAllowed = true;
    CardPageId = 50079;

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {

                field(transaction_created; Rec.transaction_created) { }
                field(order_details_channel; Rec.order_details_channel) { }
                field(order_details_id; Rec.order_details_id) { }
                field(order_details_ext_platforms_id; Rec.order_details_ext_platforms_id) { }
                field(order_details_order_type; Rec.order_details_order_type) { }
                field(order_details_order_state; Rec.order_details_order_state) { }
                field(order_details_instructions; Rec.order_details_instructions) { }
                field(current_status; Rec.current_status) { }

                field(receiptNo; Rec.receiptNo) { }
                //AlleRSN 171023
                field(app_Discount_Code; Rec.app_Discount_Code)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the app_Discount_Code field.';
                }
                field(app_Discount_ID; Rec.app_Discount_ID)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the app_Discount_ID field.';
                }

            }
        }
        area(Factboxes)
        {

        }
    }

    actions
    {
        area(Processing)
        {
            action(ActionName)
            {
                ApplicationArea = All;

                trigger OnAction();
                begin

                end;
            }
        }
    }
}
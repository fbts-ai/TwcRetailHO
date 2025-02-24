page 50081 "UP Order Status"
{
    PageType = CardPart;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "UP Order Status";

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field(order_no; Rec.order_no) { }
                field(new_state; Rec.new_state) { }
                field(updated_on; Rec.updated_on) { }
                field(prev_state; Rec.prev_state) { }
                field(store_id; Rec.store_id) { }
            }
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
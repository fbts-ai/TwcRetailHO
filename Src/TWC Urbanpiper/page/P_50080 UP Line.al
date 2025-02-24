page 50080 "UP Line"
{
    PageType = CardPart;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = "UP Line";

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field(line_no; Rec.line_no) { }
                field(parent_line_no; Rec.parent_line_no) { }
                field(indent; Rec.indent) { }

                field(order_items_title; Rec.order_items_title) { }
                field(order_items_merchant_id; Rec.order_items_merchant_id) { }
                field(order_items_price; Rec.order_items_price) { }
                field(order_items_quantity; Rec.order_items_quantity) { }

                field(order_items_is_variant; Rec.order_items_is_variant) { }

                field(order_items_discount; Rec.order_items_discount) { }

                field(order_items_sgst_value; Rec.order_items_sgst_value) { }
                field(order_items_cgst_value; Rec.order_items_cgst_value) { }
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

                trigger OnAction()
                begin

                end;
            }
        }
    }

    var
        myInt: Integer;
}
page 50079 "UP Header"
{
    PageType = Card;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = "UP Header";
    SourceTableView = sorting(order_details_id) order(descending);

    layout
    {
        area(Content)
        {
            group(orderGroup)
            {
                caption = 'Order Info';

                field(transaction_created; Rec.transaction_created) { }
                field(order_details_channel; Rec.order_details_channel) { }
                field(order_details_id; Rec.order_details_id) { }
                field(order_details_ext_platforms_id; order_details_ext_platforms_id) { }
                field(order_details_order_type; Rec.order_details_order_type) { }
                field(order_details_order_state; Rec.order_details_order_state) { }
                field(order_details_instructions; Rec.order_details_instructions) { }
                field(current_status; Rec.current_status) { }

                field(receiptNo; Rec.receiptNo) { }
                //AlleRSN 171023
                field(app_Discount_ID; Rec.app_Discount_ID)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the app_Discount_ID field.';
                }
                field(app_Discount_Code; Rec.app_Discount_Code)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the app_Discount_Code field.';
                }
            }

            group(storeGroup)
            {
                caption = 'Store';
                field(order_store_name; Rec.order_store_name) { }
                field(order_store_merchant_ref_id; Rec.order_store_merchant_ref_id) { }
            }

            group(customerGroup)
            {
                caption = 'Customer';
                field(customer_name; Rec.customer_name) { }
                field(customer_phone; Rec.customer_phone) { }
                field(customer_email; Rec.customer_email) { }
            }

            group(timestampGroup)
            {
                caption = 'Timestamps';
                field(order_details_created; Rec.order_details_created)
                {
                    caption = 'Created On';
                }
                field(order_details_expected_pickup_time; Rec.order_details_expected_pickup_time)
                {
                    caption = 'Expected Pickup Time';
                }
                field(order_details_delivery_datetime; Rec.order_details_delivery_datetime)
                {
                    caption = 'Delivery Date Time';
                }
            }

            group(UpdateGroup)
            {
                caption = 'Order Updates';
                field(insertedOn; Rec.insertedOn) { }
                field(acceptedOn; Rec.acceptedOn) { }

                field(mfrOn; Rec.mfrOn) { }
                field(confirmedOn; Rec.confirmedOn) { }
                field(kotPrintedOn; Rec.kotPrintedOn) { }
                field(dispatchedOn; Rec.dispatchedOn) { }
                field(cancelledOn; Rec.cancelledOn) { }
                field(statusBeforeCanceled; Rec.statusBeforeCanceled)
                {
                    caption = 'Status before cancel';
                }
            }

            group(amountGroup)
            {
                caption = 'Amounts';
                field(order_items_total; Rec.order_items_total) { }
                field(order_details_total_taxes; Rec.order_details_total_taxes) { }
                field(order_details_payable_amount; Rec.order_details_payable_amount) { }
                field(order_details_order_total; Rec.order_details_order_total) { }
                field(order_details_discount; Rec.order_details_discount) { }
                field(order_details_total_charges; Rec.order_details_total_charges) { }
                field(order_details_order_level_total_taxes; Rec.order_details_order_level_total_taxes) { }
                field(order_details_order_subtotal; Rec.order_details_order_subtotal) { }
                field(order_payment_amount; Rec.order_payment_amount) { }
            }

            group(itemGroup)
            {
                Caption = 'Items';
                part(items; "UP Line")
                {
                    SubPageLink = order_id = field(order_details_id);
                }
            }

            group(statusGroup)
            {
                caption = 'Status Updates';
                part(status; "UP Order Status")
                {
                    SubPageLink = order_no = field(order_details_id);
                }

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
                Caption = 'Test';
                Promoted = true;
                PromotedIsBig = true;
                PromotedCategory = New;

                trigger OnAction()
                var
                    cu: Codeunit "LSC POS Transaction";
                begin
                    cu.StartNewTransaction();
                    message(cu.GetReceiptNo());
                end;
            }
        }
    }

    var
        myInt: Integer;
}
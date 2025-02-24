table 50016 "UP Header"
{
    DataClassification = CustomerContent;

    fields
    {

        field(1; customer_phone; text[50]) { }
        field(2; customer_email; text[100]) { }
        field(3; customer_name; text[50]) { }
        field(4; order_items_total; decimal) { }
        field(5; order_details_total_taxes; decimal) { }
        field(6; order_details_id; biginteger) { }
        field(7; order_details_payable_amount; decimal) { }
        field(8; order_details_order_total; decimal) { }
        field(9; order_details_order_type; text[50]) { }
        field(10; order_details_expected_pickup_time; datetime) { }
        field(11; order_details_discount; decimal) { }
        field(12; order_details_channel; text[50]) { }
        field(13; order_details_delivery_datetime; datetime) { }
        field(14; order_details_order_state; text[50]) { }
        field(15; order_details_instructions; text[100]) { }
        field(16; order_details_total_charges; decimal) { }
        field(17; order_details_created; datetime) { }
        field(18; order_details_order_level_total_taxes; decimal) { }
        field(19; order_details_order_subtotal; decimal) { }
        field(20; order_payment_amount; decimal) { }
        field(21; order_store_name; text[100]) { }
        field(22; order_store_merchant_ref_id; text[50]) { }

        field(100; current_status; Option)
        {
            OptionMembers = "",PLACED,Acknowledged,"Food Ready",COMPLETED,CANCELLED,"No Show";
        }

        field(101; insertedOn; datetime) { }
        field(102; acceptedOn; datetime) { }
        field(103; confirmedOn; datetime) { }
        field(104; kotPrintedOn; datetime) { }
        field(105; mfrOn; datetime) { }
        field(106; dispatchedOn; datetime) { }
        field(107; cancelledOn; datetime) { }
        field(108; statusBeforeCanceled; text[50]) { }
        field(109; transaction_created; boolean) { }
        field(110; receiptNo; text[20]) { }
        field(111; replication; integer) { }
        field(112; order_details_tableno; Text[50]) { }
        field(113; order_details_ext_platforms_id; text[50]) { }
        //AlleRSN 171023
        field(114; app_Discount_ID; Code[10]) { }
        field(115; app_Discount_Code; Code[50]) { }
        field(116; StoreNo; Code[10]) { }
        field(117; PosTerminalNo; Code[10]) { }
        field(118; TransactionNo; Integer) { }
    }

    keys
    {
        key(PK; order_details_id)
        {
            Clustered = true;
        }
    }

    var
        tab: record "UP Header";

    trigger OnInsert()
    begin
        tab.Reset();
        if tab.FindLast() then
            rec.replication := tab.replication + 1
        else
            rec.replication := 1;
    end;

    trigger OnModify()
    begin
        tab.Reset();
        if tab.FindLast() then
            rec.replication := tab.replication + 1
        else
            rec.replication := 1;
    end;

    trigger OnDelete()
    begin

    end;

    trigger OnRename()
    begin

    end;

}
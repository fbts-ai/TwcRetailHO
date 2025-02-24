table 50017 "UP Line"
{
    DataClassification = CustomerContent;

    fields
    {
        field(1; order_items_total_with_tax; decimal) { }
        field(2; order_items_price; decimal) { }
        field(3; order_items_title; text[100]) { }
        field(4; order_items_discount; decimal) { }
        field(5; order_items_instructions; text[100]) { }
        field(6; order_items_merchant_id; text[50]) { }
        field(8; order_items_is_variant; boolean) { }
        field(7; order_items_quantity; integer) { }

        field(100; order_id; BigInteger)
        {
            TableRelation = "UP Header".order_details_id;
        }

        field(101; line_no; Integer) { }
        field(102; parent_line_no; Integer) { }
        field(103; indent; Integer) { }
        field(104; order_items_cgst_rate; Decimal) { }
        field(105; order_items_cgst_value; Decimal) { }
        field(106; order_items_sgst_rate; Decimal) { }
        field(107; order_items_sgst_value; Decimal) { }
        field(108; replication; integer) { }
        field(109; replacement_item_no; text[20]) { }
        field(110; replacement_item_desc; text[100]) { }
        field(111; StoreNo; Code[10]) { }
        field(112; PosTerminalNo; Code[10]) { }
        field(113; TransactionNo; Integer) { }
        field(114; "Subscription Code"; Text[50]) { }
    }

    keys
    {
        key(PK; order_id, line_no)
        {
            Clustered = true;
        }
    }

    var
        tab: record "UP Line";

    trigger OnInsert()
    begin
        tab.Reset();
        if tab.FindLast() then
            replication := tab.replication + 1
        else
            replication := 1;
    end;

    trigger OnModify()
    begin
        tab.Reset();
        if tab.FindLast() then
            replication := tab.replication + 1
        else
            replication := 1;
    end;

    trigger OnDelete()
    begin

    end;

    trigger OnRename()
    begin

    end;

}
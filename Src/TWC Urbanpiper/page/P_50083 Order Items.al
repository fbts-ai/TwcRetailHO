page 50083 "Order Items"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "UP Line";
    DeleteAllowed = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    LinksAllowed = false;
    //SourceTableTemporary = true;

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field(line_no; Rec.line_no)
                {
                    Caption = 'Line No.';
                }

                field(order_items_merchant_id; Rec.order_items_merchant_id)
                {
                    Caption = 'Item Id';
                }

                field(order_items_title; Rec.order_items_title)
                {
                    Caption = 'Item';
                }

                field(order_items_quantity; Rec.order_items_quantity)
                {
                    caption = 'Qty';
                }

                field(order_items_price; Rec.order_items_price)
                {
                    caption = 'Price';
                }

                field(replacement_item_no; replacement_item_no)
                {
                    Caption = 'Replace Item Id';
                }
                field(replacement_item_desc; replacement_item_desc)
                {
                    Caption = 'Replace Item Desc';
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
            action("Replace Item")
            {
                ApplicationArea = all;
                Promoted = true;
                PromotedIsBig = true;
                PromotedCategory = Process;

                trigger OnAction()
                var
                    no: text;
                    desc: text;
                    response: Action;
                    up_header: record "UP Header";
                    trans_line: record "LSC POS Trans. Line";
                    receipt_no: text;
                begin
                    if rec.line_no = 0 then
                        exit;

                    clear(replacement);
                    response := replacement.RunModal();
                    if response = Action::OK then begin

                        no := replacement.GetSelectedItemNo();
                        desc := replacement.GetSelectedItemDesc();
                        // message('Replaced Item: %1 %2', no, desc);
                        rec.replacement_item_no := no;
                        rec.replacement_item_desc := desc;
                        // rec.Modify();

                        up_header.Reset();
                        up_header.SetFilter(order_details_id, format(rec.order_id));
                        if up_header.FindLast() then begin
                            receipt_no := up_header.receiptNo;

                            if receipt_no <> '' then begin
                                trans_line.Reset();
                                trans_line.SetFilter("Receipt No.", receipt_no);
                                trans_line.SetFilter(Number, rec.order_items_merchant_id);
                                if trans_line.FindLast() then begin
                                    if rec.replacement_item_no <> '' then begin
                                        trans_line.Number := rec.replacement_item_no;
                                        trans_line.Description := rec.replacement_item_desc;
                                    end
                                    else begin
                                        trans_line.Number := rec.order_items_merchant_id;
                                        trans_line.Description := rec.order_items_title;
                                    end;
                                    trans_line.Modify();
                                end;
                            end
                        end;



                        CurrPage.Update();


                    end
                    else
                        message(format(response));
                end;
            }
        }
    }



    trigger OnOpenPage()
    begin
        // loadData;
        rec.SetFilter(order_id, format(order_id));
    end;

    local procedure loadData()
    var
        line: record "UP Line";
    begin
        if order_id = 0 then
            exit;

        line.SetFilter(order_id, format(order_id));
        if line.FindSet() then begin
            repeat begin
                rec.Init();
                rec.line_no := line.line_no;
                rec.order_items_merchant_id := line.order_items_merchant_id;
                rec.order_items_title := line.order_items_title;
                rec.order_items_quantity := line.order_items_quantity;
                rec.order_items_price := line.order_items_price;
                rec.Insert();
            end
            until line.Next() = 0;
        end;

    end;

    procedure SetOrderId(orderid: BigInteger)
    begin
        order_id := orderid;
    end;

    var
        order_id: BigInteger;
        replacement: page "Item Replacement";
}
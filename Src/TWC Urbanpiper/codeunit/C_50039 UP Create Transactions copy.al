// //updateorderforsamedayrev
// codeunit 50039 UPCreateTransactionsForDate
// {
//     trigger OnRun()
//     var
//         counter: Integer;
//         postrans: Codeunit "LSC POS Transaction";
//         APISetup: Record TwcApiSetupUrl;
//         hardwareProfile: Record "LSC POS Hardware Profile";
//         opos: Codeunit "LSC POS OPOS Utility";
//         Hardwareinterface: Codeunit "LSC POS Hardware Interface";
//         ipos: Codeunit "LSC POS Hardware Interface";
//     begin
//         checkProperties();
//         counter := processPendingOrders();



//         if GuiAllowed then begin
//             Message('Orders processed ' + Format(counter));
//             //  postrans.MessageBeep('Order Received');
//         end;
//         //  IF not GuiAllowed then
//         // postrans.MessageBeep('Order Received');
//         //opos.Beeper();

//     end;



//     [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSCIN Calculate Tax", 'OnBeforeCalculateTaxOnSelectedLine', '', false, false)]
//     local procedure OnBeforeCalculateTaxOnSelectedLine(var POSTransLine: Record "LSC POS Trans. Line"; var Ishandled: Boolean)
//     var
//         trans: Record "LSC POS Transaction";
//     begin
//         trans.SetFilter("Receipt No.", POSTransLine."Receipt No.");
//         trans.SetFilter(OrderId, '<>0');
//         if trans.FindFirst() then begin
//             Ishandled := true;
//         end;
//     end;

//     local procedure checkProperties()
//     var
//         pos: Codeunit "LSC POS Session";
//     begin
//         if terminal = '' then
//             terminal := pos.TerminalNo();

//         if store = '' then
//             store := pos.StoreNo();

//         if staff = '' then
//             staff := pos.StaffID();
//     end;

//     local procedure processPendingOrders(): Integer
//     var
//         receiptNo: text;
//         header: record "UP Header";
//         line: record "UP Line";
//         counter: Integer;
//         upOrderstatus: Record "UP Order Status";
//         orderNo: BigInteger;

//         kds: Codeunit "LSC KDS Functions";
//         kot: codeunit "KOT Functions";

//         APISetup: Record TwcApiSetupUrl;
//         hardwareProfile: Record "LSC POS Hardware Profile";
//         postrans: Codeunit "LSC POS Transaction";
//         Hardwareinterface: Codeunit "LSC POS Hardware Interface";
//         posview: Codeunit LSCWebPOS;
//         Update: Text;//updateorderforsamedayrev
//         Uptime: Text;//updateorderforsamedayrev
//     begin
//         header.Reset();
//         header.SetFilter(transaction_created, '=false');
//         if header.FindSet() then begin
//             repeat begin
//                 upOrderstatus.Init();
//                 upOrderstatus.SetFilter(order_no, Format(header.order_details_id));
//                 upOrderstatus.SetFilter(new_state, 'Completed');

//                 if not upOrderstatus.FindLast() then begin
//                     counter := counter + 1;
//                     //receiptNo := getReceiptNo();
//                     receiptNo := IncStr(posview.GetLastReceiptNo(terminal));
//                     Update := Format(header.order_details_created, 10, '<Day,2>/<Month,2>/<Year4>');//updateorderforsamedayrev
//                     //Uptime := Format(header.order_details_created, 15, '<Hours24,2>:<Minutes,2>:<Seconds,2>');//updateorderforsamedayrev
//                     Uptime := Format(header.order_details_created, 15, '<Hours12,2>:<Minutes,2>:<Seconds,2>');//updateorderforsamedayrev


//                     createTransaction(receiptNo, header.order_details_id, header.order_details_order_state, header.order_details_channel, header.order_details_order_type, header.order_details_channel, Update, Uptime);//updateorderforsamedayrev

//                     kot.print_kot(receiptNo);
//                     // createPOSTransaction(receiptNo, header.order_details_id, header.order_details_order_state);

//                     header.transaction_created := true;
//                     header.receiptNo := receiptNo;
//                     header.Modify(true);
//                 end
//                 else begin
//                     header.transaction_created := true;
//                     header.Modify(true);
//                 end;
//             end
//             until header.Next() = 0;


//             // postrans.MessageBeep('test');


//             exit(counter);
//         end;
//     end;

//     local procedure getReceiptNo() receiptNo: Text
//     var
//         posTransaction: Record "LSC POS Transaction";
//         transactionHeader: Record "LSC Transaction Header";
//         posID: Integer;
//         transID: Integer;
//         receiptID: Integer;
//     begin
//         posTransaction.Init();
//         posTransaction.SetFilter("Receipt No.", '0000' + terminal + '*');
//         if posTransaction.FindLast() then begin
//             Evaluate(posID, CopyStr(posTransaction."Receipt No.", 11));
//         end;

//         transactionHeader.Init();
//         transactionHeader.SetFilter("Receipt No.", '0000' + terminal + '*');
//         if transactionHeader.FindLast() then begin
//             Evaluate(transID, CopyStr(transactionHeader."Receipt No.", 11));
//         end;

//         if posID > transID then begin
//             receiptNo := IncStr(posTransaction."Receipt No.");
//         end
//         else
//             receiptNo := IncStr(transactionHeader."Receipt No.");

//         if (posId = 0) and (transID = 0) then
//             receiptNo := '0000' + terminal + '000000001';
//     end;

//     local procedure createPOSTransaction(receiptNo: text; orderId: BigInteger; orderStatus: Text)
//     var
//         pos_trans_line_no: integer;
//         mapping_line_no: Integer;
//         restaurant_no: text;
//         prod_section_code: text;
//         display_station_id: text;
//         quantity_sent: integer;
//         routing_item_type: Text;
//         routing_code: text;
//         active_item_no: text;
//         active_sale_type: text;
//         active_pos_terminal: text;
//         routing_line_no: Integer;
//         active_restaurant_no: text;

//         lines: record "LSC POS Trans. Line";
//         lsc_pos_transaction: record "LSC POS Transaction";
//         diningAreaProfId: text;
//         statusFlowId: text;
//         kds: Codeunit "LSC KDS Functions";
//     begin
//         // lines.gst
//         insertHospOrderKitcheStatus(receiptNo);
//         insertHospOrderTransStatus(receiptNo);
//         insertPOSTrLineDisStatR(receiptNo, 10000, 0, '', '', '', 0, 'All', '', '', '', '', 0, '');

//         lines.SetFilter("Receipt No.", receiptNo);
//         if lines.FindSet() then begin
//             repeat begin

//                 // insertPOSTrLineDisStatR(receiptNo, 10000,   0,      '',      '',        '', 0,  'All',        '',        '',         '',      '',     0,      '');
//                 // insertPOSTrLineDisStatR(receiptNo, 10000, 168, 'S0002', 'GRILL', 'PRINTER', 0, 'Item', 'FG00167', 'FG00167', 'TAKEAWAY', 'P0003', 10000, 'S0002');
//                 pos_trans_line_no := lines."Line No.";
//                 mapping_line_no := 3;
//                 restaurant_no := lines."Store No.";
//                 prod_section_code := 'SANDWITCHSECTION';
//                 display_station_id := 'DISPLAY 3';
//                 quantity_sent := 0;
//                 routing_item_type := 'Item';
//                 routing_code := 'FG000020';
//                 active_item_no := 'FG000020';
//                 active_sale_type := 'TAKEAWAY';
//                 active_pos_terminal := 'T2';
//                 routing_line_no := 10000;
//                 active_restaurant_no := 'TW001';
//                 insertPOSTrLineDisStatR(receiptNo, pos_trans_line_no, mapping_line_no,
//                     restaurant_no, prod_section_code, display_station_id, quantity_sent, routing_item_type,
//                     routing_code, active_item_no, active_sale_type, active_pos_terminal, routing_line_no, active_restaurant_no);

//             end
//             until lines.Next() = 0;
//         end;

//         /*
//                                                             3
//                                                             TW001
//                                                             SANDWITCHSECTION
//                                                             DISPLAY 3
//                                                             FG000020
//                                                             FG000020
//                                                             T2
//                                                             TW001

//         */

//         // insertPOSTransGuestInfo(receiptNo);
//         insertTransactionInUseOnPOS(receiptNo);
//     end;

//     local procedure insertHospOrderKitcheStatus(receiptNo: text)
//     var
//         r: record "LSC Hosp. Order Kitchen Status";
//     begin
//         r.Init();
//         r."Active KOT From Other Order" := false;
//         r."Active KOT Is Coursing KOT" := false;
//         r."Active KOT No." := '';
//         r."Confirmed by Expeditor Station" := false;
//         r."Current Menu Course Abbr." := '';
//         r."Current Menu Course Code" := '';
//         r."Current Menu Course Descr." := '';
//         r."Current Menu Course Kit. Stat" := r."Current Menu Course Kit. Stat"::Announced;
//         r."Date Time Created" := CurrentDateTime();
//         r."Dining Area ID" := '';
//         r."Dining Table No." := 0;
//         r."Kitchen Status" := r."Kitchen Status"::"Not Sent"; // "Sent";
//         // r."KOT Expected Start Date Time" := CurrentDateTime();
//         // r."Last Sent to Kitchen" := CurrentDateTime();
//         r."Menu Type Code" := '';
//         r."No. of Attribute Entries" := 0;
//         r."No. of Finished KOTs" := 0;
//         r."No. of KOTs" := 0;
//         r."No. of Served KOTs" := 0;
//         r."No. of Served Transferred KOTs" := 0;
//         r."No. of Transferred KOTs" := 0;
//         r."On Hold Offset (Min.)" := 0;
//         r."Order ID" := '';
//         r."Ready to be Served (Manually)" := false;
//         r."Receipt No." := receiptNo;
//         r."Service Flow ID" := 'TAKE-AWAY-FLOW';
//         r."Store No." := '';
//         r."Trans. Status" := r."Trans. Status"::Open;
//         r."Transferred From KOT Filter" := '';

//         r.Insert(true);
//     end;

//     local procedure insertHospOrderTransStatus(receiptNo: text)
//     var
//         r: Record "LSC Hosp. Order Trans. Status";
//     begin
//         r.Init();
//         r."Currently Served" := false;
//         r."Date Time Created" := CurrentDateTime();
//         r."Dining Area ID" := '';
//         r."Dining Table Description" := '';
//         r."Dining Table No." := 0;
//         r."Receipt No." := receiptNo;
//         r."Service Flow ID" := 'TAKE-AWAY-FLOW';
//         r."Trans. Status" := r."Trans. Status"::Open;
//         r.Insert(true);
//     end;

//     local procedure insertPOSTrLineDisStatR(
//         receiptNo: text;
//         pos_trans_line_no: integer;
//         mapping_line_no: Integer;
//         restaurant_no: text;
//         prod_section_code: text;
//         display_station_id: text;
//         quantity_sent: integer;
//         routing_item_type: Text;
//         routing_code: text;
//         active_item_no: text;
//         active_sale_type: text;
//         active_pos_terminal: text;
//         routing_line_no: Integer;
//         active_restaurant_no: text
//     )
//     var
//         r: Record "LSC POS Tr. Line Dis. Stat. R.";
//     begin
//         r.Init();
//         r."Active Item No." := active_item_no;
//         r."Active Load Config. Code" := '';
//         r."Active POS Terminal Gr." := '';
//         r."Active POS Terminal No." := active_pos_terminal;
//         r."Active Restaurant No." := active_restaurant_no;
//         r."Active Sales Type" := active_sale_type;
//         // r."Announced Date Time" := CurrentDateTime;
//         r."Coursing Kitchen Status Abbr." := '';
//         r."Display Station ID" := display_station_id;
//         // r."Fired Date Time" := CurrentDateTime;
//         r."Line Course Kitchen Status" := r."Line Course Kitchen Status"::"No Items"; //r."Line Course Kitchen Status"::;
//         r."Mapping Line No." := mapping_line_no;
//         r."Order" := 0;
//         r."Pos Trans. Line No." := pos_trans_line_no;
//         r."Prod. Section  Code" := prod_section_code;
//         r."Quantity Sent" := quantity_sent;
//         r."Receipt No." := receiptNo;
//         r."Restaurant No." := restaurant_no;
//         r."Routing Code" := routing_code;
//         // r."Routing Item Type" := r."Routing Item Type"::Item;
//         Evaluate(r."Routing Item Type", routing_item_type);

//         r."Routing Line No." := routing_line_no;
//         // r."Served Date Time" := CurrentDateTime;
//         r."Voided" := false;
//         r.Insert(true);
//     end;

//     local procedure insertPOSTransGuestInfo(receiptNo: text);
//     var
//         r: record "LSC POS Trans. Guest Info";
//     begin
//         r.Init();
//         r."Customer No." := '';
//         r."Guest/Seat No." := 0;
//         r."Member No." := '';
//         r."No. of Item Lines" := 0;
//         r."Pre-receipt Counter" := 0;
//         r."Receipt No." := receiptNo;
//         r."Reservation No." := '';
//         r."Split from Receipt No." := '';
//         r."System Entry" := false;
//         r."Table No." := 0;
//         r."Transfer from Table No." := 0;
//         r.Insert(true);
//     end;

//     local procedure insertTransactionInUseOnPOS(receiptNo: text)
//     var
//         r: record "LSC Transaction in Use on POS";
//     begin
//         r.Init();
//         r."Date-Time Released" := CurrentDateTime();
//         r."Date-Time Set" := CurrentDateTime();
//         r."In Use on POS Terminal" := '';
//         r."Receipt No." := receiptNo;
//         r."Staff ID" := '555';
//         r."User ID" := 'DYNAMICS-DEV-VM\EY1';
//         r.Insert(true);
//     end;

//     local procedure getHospSeqNo(salesType: text) seq: Integer
//     var
//         hosp: Record "LSC Hospitality Type";
//         pos: Codeunit "LSC POS Session";
//     begin
//         hosp.SetFilter("Restaurant No.", pos.StoreNo());
//         hosp.SetFilter("Sales Type", salesType);
//         if hosp.FindLast() then begin
//             seq := hosp.Sequence;
//         end
//         else begin
//             seq := 1;
//         end;
//     end;

//     local procedure createTransaction(receiptNo: text; orderId: BigInteger; orderStatus: Text; orderChannel: Text; orderType: Text; channel: text; Update: Text; UpTime: Text)//updateorderforsamedayrev
//     var
//         trans: Record "LSC POS Transaction";
//         nullTime: Time;
//         nullDate: Date;

//         lineNo: Integer;
//         up_line: record "UP Line";
//         up_header: record "UP Header";

//         newline: Record "LSC POS Trans. Line";
//         retailitem: record "Item";

//         customer: text;
//         parentlineno: BigInteger;

//         retail_product_code: text;
//         item_category_code: text;
//         gen_bus_posting_group: text;
//         gen_prod_posting_group: text;
//         vat_bus_posting_group: text;
//         vat_prod_posting_group: text;

//         total_gross_amount: decimal;
//         total_net_amount: decimal;
//         total_tax_amount: decimal;
//         total_discount_amount: decimal;

//         line_gross_amount: decimal;
//         line_net_amount: decimal;
//         line_tax_amount: decimal;
//         line_discount: decimal;

//         cust_receipt: Codeunit "Receipt No. Format";

//         first_line_no: integer;
//         comment_line_no: integer;

//         uom: text;
//         uom_qty: Decimal;

//         // 2023-07-31 modifier infocode values
//         infocode_code: text;
//         infocode_subcode: text;
//         // !2023-07-31 modifier infocode values

//         parent_item_no: text;
//         saved_line: record "LSC POS Trans. Line";

//         bc_itemdesc: text;
//     begin
//         up_header.Reset();
//         up_header.SetFilter(order_details_id, format(orderId));
//         if up_header.FindLast() then begin
//             trans.Init();
//             trans."Receipt No." := receiptNo;
//             trans."Store No." := store;
//             trans."POS Terminal No." := terminal;
//             trans."Created on POS Terminal" := terminal;
//             trans."Staff ID" := staff;
//             // trans."Trans. Date" := Today();//updateorderforsamedayrev
//             // trans."Trans Time" := Time();
//             // trans."Original Date" := Today();
//             Evaluate(trans."Trans. Date", Update);//updateorderforsamedayrev
//             Evaluate(trans."Trans Time", UpTime);
//             Evaluate(trans."Original Date", Update);
//             trans."New Transaction" := false;
//             trans."Transaction Type" := 2;
//             if orderChannel = 'ConsumerApp' then begin
//                 trans."Sales Type" := 'PRE-ORDER';
//             end
//             else begin
//                 trans."Sales Type" := 'TAKEAWAY';
//             end;
//             trans."Hosp. Type Sequence" := getHospSeqNo(trans."Sales Type");
//             trans.OrderId := orderId;
//             trans.ExtOrderId := up_header.order_details_ext_platforms_id;
//             trans.OrderType := orderType;
//             trans.Channel := channel;

//             if orderStatus = 'ORDER_PLACED' then begin
//                 orderStatus := 'Placed';
//             end
//             else
//                 if orderStatus = 'ACKNOWLEDGED' then begin
//                     orderStatus := 'Acknowledged';
//                 end
//                 else
//                     if orderStatus = 'FOOD_READY' then begin
//                         orderStatus := 'Food Ready';
//                     end
//                     else
//                         if orderStatus = 'COMPLETED' then begin
//                             orderStatus := 'Completed';
//                         end
//                         else
//                             if orderStatus = 'CANCELLED' then begin
//                                 orderStatus := 'Cancelled';
//                             end;
//             Evaluate(trans.OrderStatus, orderStatus);

//             // KOT data check

//             // 2023-08-07 Fix posting issue with UP/CA orders
//             trans."VAT Bus.Posting Group" := 'DOMESTIC';
//             // !2023-08-07 Fix posting issue with UP/CA orders

//             trans."Price Group Code" := 'ALL';
//             trans."Gen. Bus. Posting Group" := 'DOMESTIC'; // Customer
//             trans."Currency Factor" := 1;

//             trans."Manager Key" := 1;
//             // trans."Hosp. Type Sequence" := 1;
//             // !KOT data check

//             customer := getChannelCustomer(orderChannel);
//             if customer <> '' then
//                 trans."Customer No." := customer;

//             trans."Cust Receipt No" := cust_receipt.getTWCReceiptNo(receiptNo, trans."POS Terminal No.");

//             trans.Table_No := up_header.order_details_tableno;
//             // trans."App Discount ID" := up_header.app_Discount_ID; //AlleRSN 171023
//             // trans."App Discount Code" := up_header.app_Discount_Code; //AlleRSN 171023

//             trans.Insert(true);

//             up_line.Reset();
//             up_line.SetFilter(order_id, format(orderId));
//             if up_line.FindSet() then begin
//                 trans.Reset();
//                 trans.SetFilter("Receipt No.", receiptNo);
//                 if trans.FindLast() then begin

//                     repeat begin
//                         lineNo := up_line.line_no;

//                         parentlineno := up_line.parent_line_no;

//                         if lineNo < 1000 then
//                             lineNo := lineNo * 10000;

//                         if up_line.parent_line_no = up_line.line_no then
//                             parentlineno := lineNo
//                         else begin
//                             if parentlineno = 0 then
//                                 parentlineno := lineNo
//                             else begin
//                                 if (parentlineno < 1000) and (parentlineno <> lineNo) then
//                                     parentlineno := parentlineno * 10000;
//                             end;

//                         end;

//                         if first_line_no = 0 then
//                             first_line_no := lineNo;

//                         newline.Reset();
//                         newline.Init();
//                         newline."Store No." := store;
//                         newline."Receipt No." := receiptNo;
//                         newline."Line No." := lineNo;
//                         newline."Indent No." := up_line.indent;
//                         newline.Number := up_line.order_items_merchant_id;
//                         newline.Description := up_line.order_items_title;
//                         newline."POS Terminal No." := terminal;

//                         newline.Quantity := up_line.order_items_quantity;
//                         // price = gross amount


//                         //line_gross_amount := up_line.order_items_price * up_line.order_items_quantity; //AlleRSN 131023 ori commented
//                         line_gross_amount := (up_line.order_items_price * up_line.order_items_quantity) - up_line.order_items_discount; //AlleRSN 131023
//                         // line_net_amount := (up_line.order_items_price - up_line.order_items_discount) * up_line.order_items_quantity;
//                         line_net_amount := (up_line.order_items_price * up_line.order_items_quantity) - up_line.order_items_discount;

//                         // newline.Price := line_gross_amount;
//                         // newline."Net Price" := line_net_amount;

//                         // newline.Price := (up_line.order_items_price * up_line.order_items_quantity) - up_line.order_items_discount;
//                         newline.Price := up_line.order_items_price;  //AlleRSN 260923 
//                         //newline."Discount Amount" := (up_line.order_items_price * up_line.order_items_quantity) - up_line.order_items_discount;
//                         newline."Net Price" := up_line.order_items_price; //AlleRSN 260923

//                         // newline."Net Price" := (up_line.order_items_price * up_line.order_items_quantity) - up_line.order_items_discount;
//                         //newline.Price := up_line.order_items_price - up_line.order_items_discount; //AlleRSN 131023 ori commented
//                         //newline."Net Price" := up_line.order_items_price - up_line.order_items_discount; //AlleRSN 131023 ori commented
//                         //AlleRSN 231023 start
//                         IF up_line.order_items_price <> 0 THEN begin  //AlleRSN 141123
//                                                                       //IF (up_line.order_items_price * up_line.order_items_quantity) - (up_line.order_items_discount * up_line.order_items_quantity) = 0 THEN begin
//                             IF (up_line.order_items_price * up_line.order_items_quantity) - (up_line.order_items_discount) = 0 THEN begin  //AlleRSN 221123
//                                 newline."Discount %" := 100;
//                                 //newline."Discount Amount" := up_line.order_items_discount * up_line.order_items_quantity;
//                                 newline."Discount Amount" := up_line.order_items_discount; //AlleRSN 221123
//                             end else begin
//                                 //newline."Discount Amount" := up_line.order_items_discount * up_line.order_items_quantity;
//                                 newline."Discount Amount" := up_line.order_items_discount; //AlleRSN 221123
//                                 //newline."Discount %" := (up_line.order_items_discount * 100) / (up_line.order_items_price + up_header.order_details_total_taxes);  //AlleRSN 071123
//                                 newline."Discount %" := ((up_line.order_items_discount / up_line.order_items_quantity) * 100) / (up_line.order_items_price + up_header.order_details_total_taxes);  //AlleRSN 221123
//                             end;
//                         end;
//                         //AlleRSN 231023 end

//                         newline."Net Amount" := line_net_amount;

//                         newline."Cost Amount" := up_line.order_items_price;
//                         newline.Amount := line_gross_amount + (up_line.order_items_cgst_value + up_line.order_items_sgst_value) * up_line.order_items_quantity;

//                         newline."Cost Price" := up_line.order_items_price;
//                         newline."Org. Price Inc. VAT" := up_line.order_items_price;
//                         newline."Org. Price Exc. VAT" := up_line.order_items_price;

//                         newline."Parent Line" := parentlineno;
//                         // newline."Trans. Date" := Today;//updateorderforsamedayrev
//                         // newline."Trans. Time" := Time();
//                         Evaluate(newline."Trans. Date", Update); //updateorderforsamedayrev
//                         Evaluate(newline."Trans. Time", UpTime);
//                         newline."Created by Staff ID" := staff;

//                         // 2023-08-07 Statement posting issues with UP/CA orders
//                         getItemFields(up_line.order_items_merchant_id, retail_product_code, gen_prod_posting_group, item_category_code, vat_bus_posting_group, vat_prod_posting_group);

//                         // KOT data check
//                         newline."Item Category Code" := item_category_code;
//                         newline."Retail Product Code" := retail_product_code;
//                         newline."Gen. Bus. Posting Group" := gen_bus_posting_group;
//                         newline."Gen. Prod. Posting Group" := gen_prod_posting_group;
//                         newline."Vat Bus. Posting Group" := vat_bus_posting_group;
//                         newline."Vat Prod. Posting Group" := vat_prod_posting_group;
//                         // !2023-08-07 Statement posting issues with UP/CA orders

//                         newline."LSCIN GST Amount" := up_line.order_items_cgst_value + up_line.order_items_sgst_value;
//                         newline."LSCIN GST Group Code" := '';
//                         newline."LSCIN HSN/SAC Code" := '';
//                         newline."LSCIN Tax Type" := 'GST';

//                         newline."LSCIN Parent Line No" := newline."Line No.";

//                         // newline."Price Group Code" := 'TAKEAWAY';

//                         // NR
//                         newline."Prompted for IPO" := true;
//                         // !NR

//                         if newline."Parent Line" = 0 then begin
//                             newline."Parent Line" := newline."Line No.";
//                         end;

//                         newline."Kitchen Routing" := 1;
//                         // newline."Sales Type" := UpperCase(up_header.order_details_order_type); // TAKEAWAY
//                         // newline."Sales Type" := 'TAKEAWAY';
//                         newline."Sales Type" := trans."Sales Type";
//                         // !KOT data check

//                         total_discount_amount := total_discount_amount + line_discount;
//                         total_net_amount := total_net_amount + line_net_amount;
//                         total_gross_amount := total_gross_amount + line_gross_amount;


//                         // 23-07-19 KOT Changes
//                         if newline."Indent No." = 1 then begin
//                             newline."Infocode Selected Qty." := up_line.order_items_quantity;
//                             newline."Kitchen Routing" := newline."Kitchen Routing"::"Follow Parent";

//                             parent_item_no := '';
//                             saved_line.Reset();
//                             saved_line.SetFilter("Receipt No.", receiptNo);
//                             saved_line.SetFilter("Line No.", format(newline."Parent Line"));
//                             if saved_line.FindLast() then begin
//                                 parent_item_no := saved_line.Number;
//                                 getUomAndQty(up_line.order_items_merchant_id, parent_item_no, uom, uom_qty, infocode_code, infocode_subcode);

//                                 if uom <> '' then begin
//                                     newline."Unit of Measure" := uom;

//                                     if uom_qty <> 0 then begin
//                                         newline.Quantity := uom_qty;
//                                     end;
//                                 end;

//                                 // 2023-07-31 modifier infocode values
//                                 if infocode_code <> '' then begin
//                                     newline."Orig. from Infocode" := infocode_code;
//                                     newline."Orig. from Subcode" := format(infocode_subcode);
//                                 end
//                                 // !2023-07-31 modifier infocode values
//                             end;


//                         end;
//                         // !23-07-19 KOT Changes

//                         // 23-07-23 Item description
//                         if trans."Sales Type" = 'TAKEAWAY' then begin
//                             bc_itemdesc := getitemdesc(newline.Number);
//                             if bc_itemdesc <> '' then
//                                 newline.Description := bc_itemdesc;
//                         end;
//                         // !23-07-23 Item description

//                         newline.Insert(true);
//                     end
//                     until up_line.Next() = 0;

//                     trans."Gross Amount" := total_gross_amount;
//                     trans."Net Amount" := total_net_amount;
//                     trans."Total Discount" := total_discount_amount;
//                     trans.Modify(true);
//                     //Alle-AS-13112023
//                     // if up_header.order_details_instructions <> '' then begin
//                     //     comment_line_no := getNewCommentLineNo(receiptNo, first_line_no);
//                     //     insertKOTInstruction(receiptNo, up_header.order_details_instructions, comment_line_no, first_line_no);
//                     // end;
//                     //Alle-AS-13112023
//                     if orderChannel = 'ConsumerApp' then begin
//                         getPickInOrderAutoAcknowledge();
//                     end
//                 end;
//             end;
//         end;
//     end;

//     local procedure getitemdesc(item_no: text) desc: text
//     var
//         item: record Item;
//     begin
//         if item_no = '' then
//             exit;
//         item.SetFilter("No.", item_no);
//         if item.FindLast() then
//             desc := item.Description;
//     end;


//     local procedure getUomAndQty(item_no: text; parent_item_no: text; var uom: text; var uom_qty: decimal; var infocode_code: text; var infocode_subcode: text)
//     var
//         infocode: record "LSC Table Specific Infocode";
//         subcode: record "LSC Information Subcode";
//     begin
//         if (item_no = '') or (parent_item_no = '') then
//             exit;

//         infocode.SetFilter(Value, parent_item_no);
//         if infocode.FindSet() then begin
//             repeat begin
//                 subcode.Reset();
//                 subcode.SetFilter("Trigger Code", item_no);
//                 subcode.SetFilter(Code, infocode."Infocode Code");
//                 if subcode.FindLast() then begin
//                     uom := subcode."Unit of Measure";
//                     uom_qty := subcode."Qty. per Unit of Measure";

//                     // 2023-07-31 modifier infocode values
//                     infocode_code := subcode.Code;
//                     infocode_subcode := subcode.Subcode;
//                     // !2023-07-31 modifier infocode values
//                 end;
//             end until infocode.Next() = 0;
//         end;
//     end;

//     local procedure getNewCommentLineNo(receipt_no: text; parent_line: integer) new_line_no: Integer
//     var
//         line: record "LSC POS Trans. Line";
//     begin
//         line.SetFilter("Receipt No.", receipt_no);
//         if line.FindLast() then
//             new_line_no := line."Line No." + 1
//         else
//             new_line_no := 1;
//     end;

//     local procedure insertKOTInstruction(
//         receipt_no: text;
//         comment: text;
//         line_no: integer;
//         parent_line: integer)
//     var
//         newline: record "LSC POS Trans. Line";
//     begin
//         newline.Reset();
//         newline.Init();
//         newline.Description := comment;
//         newline."Entry Type" := newline."Entry Type"::FreeText;
//         newline."Indent No." := 1;
//         newline."Kitchen Routing" := 2;
//         newline."Line No." := line_no;
//         newline."Parent Line" := parent_line;
//         newline."POS Terminal No." := terminal;
//         newline.Quantity := 1;
//         newline."Receipt No." := receipt_no;
//         newline."Store No." := store;
//         newline."Text Type" := newline."Text Type"::"Freetext Input";
//         newline."Trans. Date" := Today;
//         newline."Trans. Time" := Time();

//         newline.Insert(true);
//     end;

//     local procedure getChannelCustomer(channel: text) customer: Text
//     var
//         config: record "TWC Configuration";
//     begin
//         config.SetFilter(Key_, 'UP');
//         config.SetFilter(Name, '@' + channel + '_CUSTOMER_NO');
//         if config.FindLast() then begin
//             customer := config.Value_;
//         end;
//     end;

//     local procedure getItemFields(
//         item_no: text;
//         var retail_product_code: text;
//         var gen_prod_posting_group: text;
//         var item_category_code: text;
//         var vat_bus_posting_group: text;
//         var vat_prod_posting_group: text
//     )
//     var
//         retail_item: record Item;
//     begin
//         retail_item.Reset();
//         retail_item.SetFilter("No.", item_no);
//         if retail_item.FindLast() then begin
//             retail_product_code := retail_item."LSC Retail Product Code";
//             gen_prod_posting_group := retail_item."Gen. Prod. Posting Group";
//             item_category_code := retail_item."Item Category Code";
//             vat_bus_posting_group := retail_item."VAT Bus. Posting Gr. (Price)";
//             vat_prod_posting_group := retail_item."VAT Prod. Posting Group";
//         end
//         else begin
//             retail_product_code := '';
//             gen_prod_posting_group := '';
//             item_category_code := '';
//             vat_bus_posting_group := '';
//             vat_prod_posting_group := '';
//         end;

//     end;

//     local procedure getRetailProductCode(item_no: text) retail_product_code: text
//     var
//         retail_item: Record Item;
//     begin
//         retail_item.Reset();
//         retail_item.SetFilter("No.", item_no);
//         if retail_item.FindLast() then begin
//             retail_product_code := retail_item."LSC Retail Product Code";
//         end;
//     end;

//     local procedure getPickInOrderAutoAcknowledge()
//     var
//         transaction: Record "LSC POS Transaction";
//         orderID: BigInteger;
//         receiptNo: Text;
//         requestStatus: Boolean;
//         errorMessage: Text;
//         caFunctions: Codeunit "CA Functions";
//         posSession: Codeunit "LSC POS Session";
//     begin
//         transaction.Init();
//         transaction.SetFilter(Channel, 'ConsumerApp');
//         transaction.SetFilter("Sales Type", 'PRE-ORDER');
//         transaction.SetFilter("Store No.", posSession.StoreNo());
//         transaction.SetFilter(OrderStatus, Format(transaction.OrderStatus::Placed));
//         if transaction.FindSet() then begin
//             repeat
//                 orderID := transaction.OrderId;
//                 receiptNo := transaction."Receipt No.";

//                 if (caFunctions.CallOrderUpdateAPI('ACKNOWLEDGED', requestStatus, errorMessage, orderID, receiptNo)) then begin //ALLE-AS-17102023
//                     caFunctions.UpdatePOSTransactionTableOrderStatus('ACKNOWLEDGED', receiptNo, orderID);
//                 end;
//             until transaction.Next = 0;
//             func.RefreshActiveGrid();
//         end;

//     end;

//     procedure SetOrderDefaults(pStore: text; pTerminal: text; pStaff: text)
//     begin
//         terminal := pTerminal;
//         store := pStore;
//         staff := pStaff;
//     end;

//     var
//         terminal: text;
//         store: text;
//         staff: text;

//         func: Codeunit "UP Functions";

// }
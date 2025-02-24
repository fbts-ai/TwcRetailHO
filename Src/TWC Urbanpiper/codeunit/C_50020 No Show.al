codeunit 50020 "No Show"
{
    trigger OnRun()
    var
        api_status: Boolean;
        errorMessage: Text;
        order_id: Integer;
        up_header: record "UP Header";
        trans: record "LSC POS Transaction";
        EPosCtrl: Codeunit "LSC POS Control Interface";
        noshowdelay: BigInteger;
        allownowshowafter: DateTime;
        mfrtime: DateTime;
        config_value: text;
    begin
        if not (func.IsOrderCancelled(func.GetSelectedOrderID())) then begin
            order_id := func.GetSelectedOrderID();
            trans.Reset();
            trans.SetFilter(OrderId, format(order_id));
            if trans.FindLast() then begin
                if trans.OrderStatus <> trans.OrderStatus::"Food Ready" then begin
                    error('This order status cannot be changed to No Show! \ Order status should be in Food Ready to mark as No Show');
                    exit;
                end;

                up_header.Reset();
                up_header.SetFilter(order_details_id, format(order_id));
                if up_header.FindLast() then begin

                    config_value := func.GetConfig('UP', 'NO_SHOW_DELAY');
                    if config_value = '' then
                        config_value := '60';

                    Evaluate(noshowdelay, config_value);

                    noshowdelay := noshowdelay * 60000L;
                    mfrtime := up_header.mfrOn;
                    allownowshowafter := mfrtime + noshowdelay;
                    if (allownowshowafter > CurrentDateTime) then begin
                        error('No Show for this order cannot be done before %1', DT2Time(allownowshowafter));
                        exit;
                    end
                    else begin
                        if not confirm('No show cannot be undone. Are you sure you want to continue?') then begin
                            exit
                        end;
                    end;

                    up_header.current_status := up_header.current_status::"No Show";
                    up_header.Modify();


                    trans.OrderStatus := trans.OrderStatus::"No Show";
                    trans.Modify();
                    EposCtrl.RefreshDataGrid(EposCtrl.ActiveDataGrid());
                end;
            end;
        end
        else
            Error('Order is in Cancelled state, please click on Complete to clear the transaction from screen');
    end;

    var
        func: codeunit "UP Functions";
}

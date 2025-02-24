codeunit 50016 "Acknowledge"
{
    trigger OnRun()
    var
        api_status: Boolean;
        errorMessage: Text;
        EPosCtrl: Codeunit "LSC POS Control Interface";
        order_id: BigInteger;
        new_status: Enum "TWC Order Status";
    begin
        order_id := func.GetSelectedOrderID();
        if not (func.IsOrderCancelled(order_id)) then begin
            if not (func.validateStatusChange(func.GetSelectedOrderStatus(), new_status::Acknowledged)) then begin
                error('This request is not valid for the selected order!');
                exit;
            end;

            func.CallOrderUpdateAPI('Acknowledged', api_status, errorMessage);
            func.RefreshActiveGrid();
        end
        else
            Error('Order is in Cancelled state, please click on Dispatch/Complete to clear the transaction from screen');
    end;

    var
        func: Codeunit "UP Functions";
}

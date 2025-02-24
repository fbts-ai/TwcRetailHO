codeunit 50023 "CustomerApp Cancel"
{
    trigger OnRun()
    var
        upFunctions: Codeunit "UP Functions";
        caFunctions: Codeunit "CA Functions";
        requestStatus: Boolean;
        errorMessage: Text;
        up_header: record "UP Header";
        trans: record "LSC POS Transaction";
        EPosCtrl: Codeunit "LSC POS Control Interface";
        orderID: BigInteger;
        receipt: text;
        api_status: Boolean;
    begin
        receipt := EPosCtrl.GetDataGridKeyValue(EPosCtrl.ActiveDataGrid);
        if receipt <> '' then begin
            orderID := upFunctions.GetSelectedOrderID();
            if upFunctions.IsOrderCancelled(orderID) then begin
                Message('This order is cancelled, this transaction will be voided');
            end
            else begin
                trans.Init();
                trans.SetFilter(OrderId, Format(orderID));
                if trans.FindLast() then begin
                    caFunctions.CallOrderUpdateAPI('CANCELLED', api_status, errorMessage, orderID, trans."Receipt No.");//ALLE-AS-17102023
                    EposCtrl.RefreshDataGrid(EposCtrl.ActiveDataGrid());
                end;
            end;
        end
        else
            Error('Order is in Cancelled state, transaction will be voided');
    end;
}
codeunit 50025 "CA_Acknowledge"
{
    trigger OnRun()
    var
        upFunctions: Codeunit "UP Functions";
        caFunctions: Codeunit "CA Functions";
        api_status: Boolean;
        errorMessage: Text;
        EPosCtrl: Codeunit "LSC POS Control Interface";
        order_id: BigInteger;
        new_status: Enum "TWC Order Status";
        receipt: Text; //ALLE-AS-17102023
    begin
        order_id := upFunctions.GetSelectedOrderID();
        receipt := upFunctions.GetSelectedReceiptNo(); //ALLE-AS-17102023
        if not (upFunctions.IsOrderCancelled(order_id)) then begin
            caFunctions.CallOrderUpdateAPI('ACKNOWLEDGED', api_status, errorMessage, order_id, receipt); //ALLE-AS-17102023
            EposCtrl.RefreshDataGrid(EposCtrl.ActiveDataGrid());
        end
        else
            Error('Order is in Cancelled state, please click on Dispatch/Complete to clear the transaction from screen');
    end;
}
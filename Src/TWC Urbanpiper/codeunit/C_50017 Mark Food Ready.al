codeunit 50017 "Mark Food Ready"
{
    trigger OnRun()
    var
        receiptNo: Text;
        posTransaction: Record "LSC POS Transaction";
        api_status: Boolean;
        errorMessage: Text;
        hardwareprofile: Record "LSC POS Hardware Profile";
    begin
        receiptNo := func.GetSelectedReceiptNo();
        posTransaction.SetFilter("Receipt No.", receiptNo);


        if posTransaction.FindLast() then begin
            if not (func.IsOrderCancelled(func.GetSelectedOrderID())) then begin
                func.CallOrderUpdateAPI('Food Ready', api_status, errorMessage);
                func.RefreshActiveGrid();
            end
            else
                Error('Order selected is in cancelled status, cannot change the status')
        end;
    end;

    var
        func: codeunit "UP Functions";

}
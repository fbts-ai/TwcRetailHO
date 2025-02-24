codeunit 50021 "View Order Items"
{
    trigger OnRun()
    var
        func: Codeunit "UP Functions";
        orderid: Integer;
        items: page "Order Items";
    begin
        orderid := func.GetSelectedOrderID();
        if orderid <> 0 then begin
            items.SetOrderId(orderid);
            items.RunModal();
        end
        else
            error('Order Id not found!');
    end;

    var
        myInt: Integer;
}
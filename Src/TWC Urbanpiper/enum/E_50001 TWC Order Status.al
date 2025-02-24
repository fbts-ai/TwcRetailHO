enum 50001 "TWC Order Status"
{
    Extensible = true;

    value(0; Placed) { }
    value(1; Acknowledged) { }
    value(2; "KOT Printed") { }
    value(3; "Food Ready") { }
    value(4; Dispatched) { }
    value(5; Completed) { }
    value(6; Cancelled) { }
    value(7; "No Show") { }
}
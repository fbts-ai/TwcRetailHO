tableextension 50049 TendertypeSetupExt extends "LSC Tender Type Setup"
{
    fields
    {
        // Add changes to table fields here
        field(50100; PinelabCard; Boolean)
        { }
        field(50101; PineLabUPI; Boolean)
        { }
        field(50102; PineLabGiftCard; Boolean)
        { }
        field(50103; PineLabPaymentTender; Boolean)
        { }
        field(50104; PineLabReturn; Boolean)
        { }
    }
    var
        myInt: Integer;
}
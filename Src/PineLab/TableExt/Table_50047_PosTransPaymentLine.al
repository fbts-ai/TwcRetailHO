tableextension 50047 PinelabsTransPaymentExt extends "LSC Trans. Payment Entry"
{
    fields
    {
        // Add changes to table fields here
        field(50105; PlutusTransaction; Text[10])
        {
            caption = 'PlutusTransactionReferenceID';
        }
    }

    var
        myInt: Integer;
}
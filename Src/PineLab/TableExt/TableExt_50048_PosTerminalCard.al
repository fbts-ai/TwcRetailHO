tableextension 50048 PosTerminalCardExt extends "LSC POS Terminal"
{
    fields
    {
        // Add changes to table fields here
        field(50100; IMEI; Code[15])
        {

        }
        field(50101; MerchantStorePosCode; Code[10])
        {

        }
        field(50102; MerchantID; code[10])
        {

        }
        field(50103; SecurityToken; Text[50])
        {

        }
    }

    var
        myInt: Integer;
}
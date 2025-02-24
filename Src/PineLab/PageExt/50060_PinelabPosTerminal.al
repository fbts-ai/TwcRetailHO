pageextension 50060 PosterminalExt extends "LSC POS Terminal Card"
{
    layout
    {
        // Add changes to page layout here
        addlast(General)
        {
            field(MerchantID; Rec.MerchantID)
            { }
            field(MerchantStorePosCode; Rec.MerchantStorePosCode)
            { }
            field(IMEI; Rec.IMEI)
            { }
            field(SecurityToken; Rec.SecurityToken)
            { }
        }
    }

    actions
    {
        // Add changes to page actions here
    }

    var
        myInt: Integer;
}
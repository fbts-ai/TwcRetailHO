tableextension 50015 LSCTransSalesEntry extends "LSC Trans. Sales Entry"
{
    fields
    {
        field(50000; "Subscription ID"; Code[50])
        { }
        field(50001; "Offer ID"; Code[50])
        { }
        field(50002; "Subscription Qty"; Decimal)
        { }
        field(50003; "User Plan Id"; Code[20])
        { }
        field(50004; "CustAppUserId"; Code[20])
        { }
        field(50005; "Review Cart done"; Boolean)
        { }
        field(50006; "Check out done"; Boolean)
        { }
        field(50007; "Cust App Order"; Boolean)
        { }
        field(50008; "Cart Offer ID"; Code[50])
        { }
        field(50010; "Wave Coin Balance"; Text[100])
        { }
        field(50011; "Wallet Balance"; Text[100])
        { }
        field(50012; "Promo Balance"; Text[100])
        { }
        field(50013; "WaveCoinApplied"; Boolean)
        { }
        field(50014; "txnId"; Code[20])
        { }
        field(50015; "batchNumber"; Code[20])
        { }
        field(50016; "redemptionValue"; Decimal)
        { }
        field(50017; "PromoTxnId"; Code[20])
        { }
        //FBTS YM 161224 Suscription 
        field(60104; "Subscription Code"; Text[50])
        {
        }
        //FBTS YM 161224 Suscription 

    }

    var
        myInt: Integer;
}
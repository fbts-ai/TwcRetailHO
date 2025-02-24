tableextension 50014 POSTransactionExtn extends "LSC POS Transaction"
{
    fields
    {
        field(50000; "Subscription ID"; Code[50])
        { }
        field(50001; "Offer ID"; Code[50])
        { }
        field(50002; "Subscription Qty"; Decimal)
        { }
        field(50003; IsSubscriptionTransaction; Boolean)
        { }
        field(50009; "User Plan Id"; Code[20])
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



        //uraban piper
        field(50018; OrderId; BigInteger) { }

        field(50019; OrderStatus; Enum "TWC Order Status") { }

        field(50020; OrderType; Text[50]) { }

        field(50021; Channel; Text[50]) { }

        field(50022; PackagingBOMApplied; Boolean) { }

        field(50023; "Cust Receipt No"; text[20]) { }
        //!urban piper

        field(50024; "Table_No"; Text[50]) { }
        field(50025; "ExtOrderId"; text[50]) { }
        field(50027; "Is wallet Error"; Boolean)
        { }
        field(50028; "Is wallet loaded"; Boolean)
        { }
        //AlleRSN 171023
        field(50029; "App Discount ID"; Code[10])
        { }
        field(50030; "App Discount Code"; Code[50])
        { }
    }
    keys
    {
        key(key1; OrderStatus) { }
    }


    var
        myInt: Integer;

}
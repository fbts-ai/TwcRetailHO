tableextension 50017 TransactionHeaderExt extends "LSC Transaction Header"
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
        field(50009; "User Plan Id"; Code[20])
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

        // Receipt Format No.
        field(50018; "Cust Receipt No"; text[20]) { }
        // field(50019; Channel; text[50])  ///PT-FBTS-19-06-2024
        // {
        // }
        //FBTS YM Non-App Customer detail
        field(70100; "Non-App Cust Mobile"; Text[10])
        { }
        field(70101; "Non-App Cust Email"; Text[50])
        { }
        //FBTS YM Customise offer
        field(60101; "Free Item Offer"; Code[20])
        { }
        field(60102; "Free Offer Validation Period"; Code[20])
        { }
        //FBTS YM Customise Offer
        //FBTS YM 180824 Update Channel
        field(60104; "Channel Name"; Code[20])
        { }
        //FBTS YM 180824 Update Channel
        //FBTS YM Promo Integration 041024
        field(60105; "Promo Wallet Discount"; Boolean)
        { }
        //FBTS YM Promo Integration 041024
        field(60106; OrderId; BigInteger)
        { }

        //AlleRSN 171023
        field(50019; "App Discount ID"; Code[10]) { }
        field(50020; "App Discount Code"; Code[50]) { }
        //ALLE_NICK

        // field(50021; "BILL ME URL"; text[100])
        // {
        //     ExtendedDatatype = URL;
        //     DataClassification = SystemMetadata;
        //     Editable = false;
        // }
        // field(50022; "Msg"; text[100])
        // { }
    }

    var
        myInt: Integer;
}
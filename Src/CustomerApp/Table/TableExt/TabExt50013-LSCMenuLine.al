tableextension 50013
 LSCMenuLineExt extends "LSC POS Menu Line"
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
        field(50013; "IsSubscription"; Boolean)
        { }
        //ALLE_NICK_081123_START
        field(50014; "Mobile NO."; Text[100])
        { }

    }

    var
        myInt: Integer;
}
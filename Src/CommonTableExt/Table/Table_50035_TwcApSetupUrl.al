
table 50035 TwcApiSetupUrl
{
    Caption = 'TwcApiSetupUrl';

    fields
    {
        field(1; "Primary Key"; Code[10])
        {
            Caption = 'Primary Key';
        }
        field(2; PineLabSalesUploadUrl; Text[100])
        {
            caption = 'Pinelab Sales Upload Url';
        }
        field(3; PineLabGetStatusUrl; Text[100])
        {
            caption = 'Pinelab Get Status Url';
        }
        field(4; PineLabCancelUrl; Text[100])
        {
            caption = 'Pinelab Cancel Url';
        }
        field(5; VerifyAPIUrl; Text[100])
        {
            caption = 'Verify API Url';
        }
        field(6; SubscriptionAPIUrl; Text[100])
        {
            caption = 'Subscription API Url';
        }
        field(7; OffersAPIUrl; Text[100])
        {
            caption = 'Offers API Url';
        }
        field(8; ReviewCartAPIUrl; Text[100])
        {
            caption = 'Review Cart API Url';
        }
        field(9; CheckOutAPIUrl; Text[100])
        {
            caption = 'CheckOut API Url';
        }
        field(10; WalletLoadAPIUrl; Text[100])
        {
            caption = 'Wallet Load API Url';
        }
        field(11; WalletRedempAPIUrl; Text[100])
        {
            caption = 'Wallet Redemption API Url';
        }
        field(12; WaveCoinRedempAPIUrl; Text[100])
        {
            caption = 'Wave Coin Redemption API Url';
        }
        field(13; FoodLockAPIUrl; Text[100])
        {
            caption = 'FoodLock API Url';
        }
        field(14; CancellationAPIUrl; Text[100])
        {
            caption = 'Cancellation API Url';
        }
        field(15; "Min. Wave Coin Redemp"; Integer)
        {
            caption = 'Minimum Wave Coin to be redeemed';
        }
        field(16; "X-API-KEY"; Text[50])
        {
            Caption = 'API Key for Customer app';
        }
        field(17; "X-API-VERSION"; Integer)
        {
            Caption = 'API Key Version for Customer app';
        }
        field(18; "Max Wallet Load"; Decimal)
        {

        }
        field(19; "Tone 1 Pitch"; Integer)
        { }
        field(20; "Tone 1 Volume"; Integer)
        { }
        field(21; "Tone 1 Duration"; Integer)
        { }

        //ALLENICK
        field(22; "Bill ME URL"; Text[250])
        {
            Caption = 'Bill ME URL';
        }
        field(23; "Bill ME Token"; Text[1000])
        {
            Caption = 'Bill ME Token';
        }
        // field(24; "AggregatorID"; Text[250])
        // {

        // }
        // field(25; "MerchantID"; Text[250])
        // {

        // }
        // field(26; "posAppId"; Text[250])
        // {

        // }
        // field(27; "Agg SecretKey"; Text[250])
        // {

        // }
        // field(28; "Invoice creation API URL"; Text[250])
        // {

        // }
        // field(29; "Order Status API URL"; Text[250])
        // {

        // }
        //FBTS YM 041024 Promowallet Integration
        field(27; PromoWalletRedempAPIUrl; Text[150])
        {
            caption = 'PromoWalletAPI Url';
        }
        //FBTS YM 041024 Promowallet Integration

    }

    keys
    {
        key(Key1; "Primary Key")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
    }
}



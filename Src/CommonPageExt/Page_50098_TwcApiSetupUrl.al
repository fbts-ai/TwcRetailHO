
page 50098 TwcApiSetupUrl
{
    ApplicationArea = All;
    Caption = 'Twc Api Setup Configuration';
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = Card;
    SourceTable = TwcApiSetupUrl;
    UsageCategory = Documents;

    layout
    {
        area(content)
        {
            group(Pinelab)
            {
                Caption = 'Pinelab';
                field(PineLabSalesUploadUrl; Rec.PineLabSalesUploadUrl)
                {
                    Caption = 'Pinelab Sales Upload Api';
                }
                field(PineLabGetStatusUrl; Rec.PineLabGetStatusUrl)
                {
                    Caption = 'Pinelab Get status Api';
                }
                field(PineLabCancelUrl; Rec.PineLabCancelUrl)
                {
                    Caption = 'Pinelab Cancel Url';
                }


            }
            group(CustomerApp)
            {
                Caption = 'CustomerApp';
                field("X-API-KEY"; rec."X-API-KEY")
                {
                    ApplicationArea = all;
                }
                field("X-API-VERSION"; rec."X-API-VERSION")
                {
                    ApplicationArea = all;
                }
                field(VerifyAPIUrl; Rec.VerifyAPIUrl)
                {
                    ApplicationArea = all;
                }
                field(SubscriptionAPIUrl; rec.SubscriptionAPIUrl)
                {
                    ApplicationArea = all;
                }
                field(OffersAPIUrl; rec.OffersAPIUrl)
                {
                    ApplicationArea = all;
                }
                field(ReviewCartAPIUrl; rec.ReviewCartAPIUrl)
                {
                    ApplicationArea = all;
                }
                field(CheckOutAPIUrl; rec.CheckOutAPIUrl)
                {
                    ApplicationArea = all;
                }
                field(WalletLoadAPIUrl; rec.WalletLoadAPIUrl)
                {
                    ApplicationArea = all;
                }
                field(WalletRedempAPIUrl; rec.WalletRedempAPIUrl)
                {
                    ApplicationArea = all;
                }
                field(CancellationAPIUrl; rec.CancellationAPIUrl)
                {
                    ApplicationArea = all;
                }
                field(FoodLockAPIUrl; rec.FoodLockAPIUrl)
                {
                    ApplicationArea = all;
                }
                field(WaveCoinRedempAPIUrl; rec.WaveCoinRedempAPIUrl)
                {
                    ApplicationArea = all;
                }
                field("Min. Wave Coin Redemp"; rec."Min. Wave Coin Redemp")
                {
                    ApplicationArea = all;
                }
                field("Max Wallet Load"; rec."Max Wallet Load")
                {
                    ApplicationArea = all;
                }
                field("Tone 1 Pitch"; rec."Tone 1 Pitch")
                {
                    ApplicationArea = all;
                }
                field("Tone 1 Volume"; rec."Tone 1 Volume")
                {
                    ApplicationArea = all;
                }
                field("Tone 1 Duration"; rec."Tone 1 Duration")
                {
                    ApplicationArea = all;
                }
                field(PromoWalletRedempAPIUrl; PromoWalletRedempAPIUrl)
                {
                    ApplicationArea = All;
                }


            }
            //ALLENICK
            group("Bill Me")
            {
                field("Bill ME URL"; "Bill ME URL")
                {
                    ApplicationArea = all;
                }
                field("Bill ME Token"; "Bill ME Token")
                {
                    ApplicationArea = all;
                }
            }
            // group(PayPhi)
            // {
            //     field("Invoice creation API URL"; "Invoice creation API URL")
            //     {
            //         ApplicationArea = all;
            //     }
            //     field("Order Status API URL"; "Order Status API URL")
            //     {
            //         ApplicationArea = all;
            //     }
            //     field(AggregatorID; AggregatorID)
            //     {
            //         ApplicationArea = all;
            //     }
            //     field(MerchantID; MerchantID)
            //     {
            //         ApplicationArea = all;
            //     }
            //     field(posAppId; posAppId)
            //     {
            //         ApplicationArea = all;
            //     }
            //     field("Agg SecretKey"; "Agg SecretKey")
            //     {
            //         ApplicationArea = all;
            //     }


            // }


        }
    }

    actions
    {
    }

    trigger OnOpenPage()
    begin
        Reset();
        if not Get() then begin
            Init();
            Insert();
        end;
    end;
}


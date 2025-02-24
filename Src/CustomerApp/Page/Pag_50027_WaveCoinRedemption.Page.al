page 50027 "Wave Coin Redemption"
{
    PageType = Card;
    // SourceTable = "LSC POS Transaction";
    ApplicationArea = all;
    UsageCategory = Administration;
    InsertAllowed = false;
    DeleteAllowed = false;
    ModifyAllowed = false;

    layout
    {
        area(Content)
        {
            group("Wave Coin Redemption")
            {

                field("Wave Coin Balance"; POSTransaction."Wave Coin Balance")
                {
                    ApplicationArea = all;
                    Caption = 'Wave Coins Available';
                    Editable = false;
                }

                field(Redeemable; Redeemable)
                {
                    ApplicationArea = all;
                    Caption = 'To be Redeemed';
                    trigger OnValidate()
                    begin
                        apisetup.Get();
                        IF Redeemable < apisetup."Min. Wave Coin Redemp" then
                            Error('Redeemable should be more than %1', apisetup."Min. Wave Coin Redemp" - 1);

                        POSTransaction.CalcFields("Gross Amount");
                        IF Redeemable > Wavecoin then
                            Error('Redemable amount cannot be greater then wavecoin balance');

                        IF Redeemable > POSTransaction."Gross Amount" then
                            Error('Redemable amount cannot be greater than Amount payable');

                    end;
                }

            }

        }

    }
    actions
    {
        area(Processing)
        {
            action(Submit)
            {
                ApplicationArea = all;
                Promoted = true;
                PromotedCategory = Process;
                trigger OnAction()
                var
                    PS: Record "LSC POS Transaction";
                    PSLine: Record "LSC POS Trans. Line";
                    PSLine1: Record "LSC POS Trans. Line";
                    postrans: Codeunit "LSC POS Transaction";
                    lscposmenuline1: Record "LSC POS Menu Line";
                    taxcalc: Codeunit "LSCIN Calculate Tax";

                begin

                    lscposmenuline1.Reset();
                    lscposmenuline1.SetRange("Menu ID", '#APPCUSTOMER');
                    IF LSCPOSMenuLine1.FindFirst() then;

                    IF not POSTransaction."Cust App Order" then
                        Error('Please scan your App to continue');

                    IF POSTransaction."Cart Offer ID" <> '' then
                        Error('Cart Discount already applied!');


                    PSLine.Reset();
                    PSLine.SetRange("Receipt No.", POSTransaction."Receipt No.");
                    IF PSLine.FindFirst() then
                        repeat
                            PSLine.CalcTotalDiscAmt(true, Redeemable, true);
                            //  taxcalc.CalculateTaxOnSelectedLineV2(POSTransaction, PSLine, true);
                            taxcalc.RecalculateTaxForAllLinesV2(POSTransaction, PSLine);
                            PSLine.WaveCoinApplied := true;
                            PSLine.Modify();
                        until PSLine.Next() = 0;



                    POSTransaction.CalcFields("Gross Amount");

                    // IF POSTransaction."Gross Amount" = 0 then begin
                    //     postrans.SetPOSState('PAYMENT');
                    //     postrans.TenderKeyPressedEx('1', '0');
                    // end;

                    CurrPage.Close();

                end;

            }
        }
    }
    trigger OnOpenPage()

    begin
        IF apisetup.Get() then;

        Clear(Wavecoin);
        POSTransaction.Reset();
        POSTransaction.SetRange("Receipt No.", Postrans.GetReceiptNo());
        IF POSTransaction.FindFirst() then;

        IF POSTransaction."Wave Coin Balance" <> '' then
            Evaluate(Wavecoin, POSTransaction."Wave Coin Balance");


    end;

    var
        Redeemable: Decimal;
        //text001: Text[50];
        //  text1: TextConst ENU = 'Wave Coin Redemption - Min. %1 coins can be redeemed';

        Postrans: Codeunit "LSC POS Transaction";
        POSTransaction: Record "LSC POS Transaction";

        Wavecoin: Decimal;
        apisetup: Record TwcApiSetupUrl;
}
codeunit 50003 "Wave Coin Redemption"
{
    trigger OnRun()
    begin

    end;


    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Transaction Events", 'OnAfterRunCommand', '', false, false)]
    local procedure OnAfterRunCommand(var POSMenuLine: Record "LSC POS Menu Line"; var Command: Code[20]; var POSTransaction: Record "LSC POS Transaction"; var POSTransLine: Record "LSC POS Trans. Line"; var CurrInput: Text)
    var
        postrans: Codeunit "LSC POS Transaction";
        // posgui: Codeunit "LSC POS GUI";
        epos: Codeunit "LSC POS Controller";

        WavecoinText: Text;
        POSCtrl: Codeunit "LSC POS Control Interface";
    //  POSSession: Codeunit "LSC POS Session";
    //  CU50105: Codeunit 50105;
    begin
        /*
        IF POSMenuLine.Parameter = 'WAVECOIN' then begin

            WavecoinText := 'Enter WaveCoin' + '\' + 'WaveCoin Balance - ' + POSTransaction."Wave Coin Balance";
            postrans.OpenNumericKeyboard(WavecoinText, 9, '', 19);
            //epos.

            POSTransaction.WaveCoinApplied := true;
            POSTransaction.Modify();

            //POSCtrl.GetInputText(POSSession.POSNumpadInputID)
        end;
        */

    end;




    /*
        [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Transaction Events", 'OnAfterRunCommand', '', false, false)]
        local procedure OnAfterRunCommandWalletRedemp(var POSMenuLine: Record "LSC POS Menu Line"; var Command: Code[20]; var POSTransaction: Record "LSC POS Transaction"; var POSTransLine: Record "LSC POS Trans. Line"; var CurrInput: Text)
        var
            postrans: Codeunit "LSC POS Transaction";
            posgui: Codeunit "LSC POS GUI";
            POSTransactionLine: Record "LSC POS Trans. Line";
            totalTWCAPPAmount: Decimal;
            WalletTot: Decimal;
            WalletBal: Decimal;
            promo: Decimal;
            MaxRedemp: Decimal;
            WavecoinText: Text;
            redemptxt: Text;
        begin
            IF POSMenuLine.Description = 'TWC Wallet' then begin

                Clear(WalletBal);
                Clear(promo);
                Clear(totalTWCAPPAmount);
                Evaluate(WalletBal, POSTransaction."Wallet Balance");
                IF POSTransaction."Promo Balance" <> '' then
                    Evaluate(promo, POSTransaction."Promo Balance");

                POSTransactionLine.Reset();
                POSTransactionLine.SetRange("Entry Status", POSTransactionLine."Entry Status"::" ");
                POSTransactionLine.SetFilter("Receipt No.", POSTransaction."Receipt No.");
                IF POSTransactionLine.FindSet() then
                    repeat
                        totalTWCAPPAmount += POSTransactionLine.Amount;
                    until POSTransactionLine.Next = 0;

                WalletTot := WalletBal + promo;
                IF totalTWCAPPAmount <= wallettot then
                    redemptxt := 'Total Wallet Balance' + '\' + Format(WalletTot) + '\' + 'Max Redemable' + Format(totalTWCAPPAmount)
                else
                    redemptxt := 'Total Wallet Balance' + '\' + Format(WalletTot) + '\' + 'Max Redemable' + Format(WalletTot);
                // postrans.OpenNumericKeyboard(redemptxt, 9, '', 2);

                postrans.TenderKeyPressed('16');
            end;

        end;
    */
    var
        myInt: Integer;
}
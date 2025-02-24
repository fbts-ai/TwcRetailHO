page 50029 "TWC Wallet Load"
{
    PageType = Card;
    ApplicationArea = All;
    UsageCategory = Lists;

    layout
    {
        area(Content)
        {
            group("Wallet Load")
            {
                field(Amount; Amount)
                {
                    ApplicationArea = All;
                    Caption = 'Enter Amount to Load';

                    trigger OnValidate()
                    begin
                        APISetup.Get();
                        IF Amount > apisetup."Max Wallet Load" then
                            Error('Load Amount should be less than %1', apisetup."Max Wallet Load");
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
                // ApplicationArea = All;
                ApplicationArea = all;
                Promoted = true;
                PromotedCategory = Process;
                ShortcutKey = 'Enter';

                trigger OnAction();
                var
                    pl: Record "LSC POS Trans. Line";
                    pl1: Record "LSC POS Trans. Line";
                    lscposmenuline1: Record "LSC POS Menu Line";
                begin
                    lscposmenuline1.Reset();
                    lscposmenuline1.SetRange("Menu ID", '#APPCUSTOMER');
                    IF LSCPOSMenuLine1.FindFirst() then;
                    IF not LSCPOSMenuLine1."Cust App Order" then
                        Error('Please scan your App to continue');

                    pl1.Reset();
                    pl1.SetRange("Receipt No.", POSTransaction."Receipt No.");
                    //pl1.SetRange("POS Terminal No.", POSTransaction."POS Terminal No.");
                    IF pl1.FindLast() then;




                    pl.Init();
                    pl."Receipt No." := POSTransaction."Receipt No.";
                    pl.Validate("Store No.", POSTransaction."Store No.");
                    pl.Validate(Number, Format(1));
                    pl.Validate("Line No.", pl1."Line No." + 10000);
                    pl.Validate(Quantity, 1);
                    pl.Validate(Amount, Amount);
                    pl.Validate("Cust App Order", true);
                    //pl.Validate(CustAppUserId, lscposmenuline1.CustAppUserId); //AlleRSN 301023 commented
                    pl.Validate(CustAppUserId, POSTransaction.CustAppUserId); //AlleRSN 301023


                    pl.Insert(true);

                    //POSTransaction.CustAppUserId := lscposmenuline1.CustAppUserId; //AlleRSN 301023 commented
                    POSTransaction.CustAppUserId := POSTransaction.CustAppUserId; //AlleRSN 301023
                    POSTransaction.Modify();
                    CurrPage.Close();
                end;
            }
        }
    }
    trigger OnOpenPage()
    var

    begin
        POSTransaction.Reset();
        POSTransaction.SetRange("Receipt No.", Postrans.GetReceiptNo());
        // POSTransaction.SetRange("POS Terminal No.", Postrans.GetPOSTerminalNo());//To be remove
        IF POSTransaction.FindFirst() then;

        Transline.Reset();
        Transline.SetRange("Receipt No.", POSTransaction."Receipt No.");
        Transline.SetRange("Entry Status", Transline."Entry Status"::" ");
        Transline.SetFilter(Number, '<>%1', '1');
        IF Transline.FindFirst() then begin
            //  IF CurrInput = Format(1) then
            Error('Load wallet cannot be added with normal items');
        end;
    end;

    var
        Amount: Decimal;
        POSTransaction: Record "LSC POS Transaction";
        Postrans: Codeunit "LSC POS Transaction";
        APISetup: Record TwcApiSetupUrl;
        Transline: Record "LSC POS Trans. Line";
}
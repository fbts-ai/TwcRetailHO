tableextension 50012 LSCTransacLine extends "LSC POS Trans. Line"
{
    fields
    {
        field(50000; "Subscription ID"; Code[50])
        { }
        field(50001; "Offer ID"; Code[50])
        {
            trigger OnValidate()
            var
                posTransLine2: Record "LSC POS Trans. Line";
                desc: List of [Text];
            begin

                posTransLine2.Reset();
                posTransLine2.SetRange("Receipt No.", Rec."Receipt No.");
                posTransLine2.SetFilter("Offer ID", '<>%1', '');
                IF posTransLine2.FindFirst() then begin
                    desc := posTransLine2.Description.Split(' - ');
                    posTransLine2."Offer ID" := '';
                    posTransLine2.Description := desc.Get(1);
                    //posTransLine2.Modify()
                end;

                posTransLine2.Reset();
                posTransLine2.SetRange("Receipt No.", Rec."Receipt No.");
                posTransLine2.SetFilter("Cart Offer ID", '<>%1', '');
                IF posTransLine2.FindFirst() then begin
                    desc := posTransLine2.Description.Split(' - ');
                    posTransLine2."Cart Offer ID" := '';
                    posTransLine2.Description := desc.Get(1);
                    //  posTransLine2.Modify()
                end;
            end;
        }
        field(50002; "Subscription Qty"; Decimal)
        { }
        field(50003; "User Plan Id"; Code[20])
        { }
        field(50004; "CustAppUserId"; Code[20])
        { }
        field(50007; "Cust App Order"; Boolean)
        { }
        field(50008; "Cart Offer ID"; Code[50])
        {
            trigger OnValidate()
            var
                posTransLine2: Record "LSC POS Trans. Line";
                desc: List of [Text];
            begin
                //  desc := rec.Description.Split(' - ');
                posTransLine2.Reset();
                posTransLine2.SetRange("Receipt No.", Rec."Receipt No.");
                posTransLine2.SetFilter("Offer ID", '<>%1', '');
                IF posTransLine2.FindFirst() then begin
                    desc := posTransLine2.Description.Split(' - ');
                    posTransLine2."Offer ID" := '';
                    posTransLine2.Description := desc.Get(1);
                    posTransLine2.Modify();
                    Commit();
                end;

                posTransLine2.Reset();
                posTransLine2.SetRange("Receipt No.", Rec."Receipt No.");
                posTransLine2.SetFilter("Cart Offer ID", '<>%1', '');
                IF posTransLine2.FindFirst() then begin
                    desc := posTransLine2.Description.Split(' - ');
                    posTransLine2."Cart Offer ID" := '';
                    posTransLine2.Description := desc.Get(1);
                    posTransLine2.Modify();
                    Commit();
                end;
            end;
        }
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
        //added for pinelab
        field(50009; PlutusTransaction; Text[10])
        {
            caption = 'PlutusTransactionReferenceID';
        }
        field(50027; "Is wallet Error"; Boolean)
        { }
        //AlleRSN 041023 
        field(50028; "Parent BOM Line No"; Integer)
        { }
        field(50029; "Packaging BOM Applied"; Boolean)
        { }





    }

    var
        postransa: Record "LSC POS Transaction";
}
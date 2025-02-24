pageextension 50152 "LSC Transaction Register" extends "LSC Transaction Register"//PT-FBTS 19-06-2024
{
    layout
    {
        // Add changes to page layout here
        addafter(Payment)
        {
            field("Channel Name"; "Channel Name")  //FBTS SP
            {
                ApplicationArea = all;
            }
        }
    }

    actions
    {
        // Add changes to page actions here
    }

    var
        InformationRec: Code[50];

    // trigger OnAfterGetRecord() ///PT-FBTS-19-06-2024
    // var
    //     UPHraderRec: Record "UP Header";
    //     InfoCodeEntry: Record "LSC Trans. Infocode Entry";
    // begin
    //     Clear(Rec.Channel);
    //     //////case1
    //     if Rec."Sales Type" = 'TAKEAWAY' then begin
    //         if Rec."Customer No." = 'C00008' then
    //             Rec.Channel := 'Swiggy';
    //         rec.Modify()

    //     end;
    //     ///////////// Case1/2
    //     if Rec."Sales Type" = 'TAKEAWAY' then begin
    //         if Rec."Customer No." = 'C00007' then
    //             rec.Channel := 'Zomato';
    //         rec.Modify()
    //     end;
    //     ////////////////// Case2
    //     if Rec."Sales Type" = 'PRE-ORDER' then begin
    //         UPHraderRec.Reset();
    //         UPHraderRec.SetRange(receiptNo, Rec."Receipt No.");
    //         if UPHraderRec.FindSet() then
    //             repeat
    //                 Rec.Channel := UPHraderRec.order_details_order_type;
    //             until UPHraderRec.Next() = 0;
    //         Rec.Modify();
    //     end;
    //     Clear(InformationRec);
    //     ////////////////// Case3
    //     if Rec."Sales Type" = 'POS' then begin
    //         InfoCodeEntry.Reset();
    //         InfoCodeEntry.SetRange("Store No.", Rec."Store No.");
    //         InfoCodeEntry.SetRange("POS Terminal No.", Rec."POS Terminal No.");
    //         InfoCodeEntry.SetRange("Transaction No.", Rec."Transaction No.");
    //         InfoCodeEntry.SetFilter(Infocode, '%1', '#SALESTYPE');
    //         if InfoCodeEntry.FindSet() then begin
    //             repeat
    //                 InformationRec := InfoCodeEntry.Information;
    //                 if (Rec.CustAppUserId <> '') and (InformationRec = 'DINE-IN') then
    //                     Rec.Validate(Channel, 'AppScan Dine-In');
    //                 if (Rec.CustAppUserId <> '') and (InformationRec = 'TAKEAWAY') then
    //                     Rec.Validate(Channel, 'AppScan Pickup');
    //                 if (Rec.CustAppUserId = '') and (InformationRec = 'DINE-IN') then
    //                     Rec.Validate(Channel, 'Instore Dine-In');
    //                 if (Rec.CustAppUserId = '') and (InformationRec = 'TAKEAWAY') then
    //                     Rec.Validate(Channel, 'Instore Takeaway')
    //     until InfoCodeEntry.Next() = 0;
    //             Rec.Modify(true);
    //             ///PT-FBTS-28-05-24
    //         end;
    //end;

    // trigger OnAfterGetCurrRecord()
    // var
    //     UPHraderRec: Record "UP Header";
    // begin
    //     Clear(Channel);
    //     //////case1
    //     if Rec."Sales Type" = 'TAKEAWAY' then begin
    //         if Rec."Customer No." = 'C00008' then
    //             Rec.Channel := 'Swiggy';
    //         rec.Modify()

    //     end;
    //     ///////////// Case1/2
    //     if Rec."Sales Type" = 'TAKEAWAY' then begin
    //         if Rec."Customer No." = 'C00007' then
    //             rec.Channel := 'Zomato';
    //         rec.Modifyqq()
    //     end;
    //     ////////////////// Case2
    //     // if "Sales Type" = 'PRE-ORDER' then begin
    //     //     UPHraderRec.Reset();
    //     //     UPHraderRec.SetRange(receiptNo, Rec."Receipt No.");
    //     //     if UPHraderRec.FindSet() then
    //     //         repeat
    //     //             Rec.Channel := UPHraderRec.order_details_order_type;
    //     //         until UPHraderRec.Next() = 0;
    //     //     Rec.Modify();
    //     // end;
    //     ////////////////// Case2
    //     // if "Sales Type"='Pos'then begin

    //     // end;

    // end;

}
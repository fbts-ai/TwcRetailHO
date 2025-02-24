codeunit 50031 "TWC Configuration"
{
    procedure IsFeatureEnabled(feature: text): Boolean
    var
        config: Record "TWC Configuration";
    begin
        config.SetFilter(Key_, feature);
        config.SetFilter(Name, 'ENABLE_FEATURE');
        config.SetFilter(Value_, 'TRUE');

        if config.FindFirst() then
            exit(true)
        else
            exit(false);
    end;

    //AJ_ALLE_07122023

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Transaction Events", 'OnBeforeLogoff', '', false, false)]
    local procedure OnBeforeLogoff(var POSTransaction: Record "LSC POS Transaction")
    begin
        if POSTransaction."Retrieved from Suspended Trans" = true then Error('Please Settle the Transaction or Void Transaction');
    end;
    //AJ_ALLE_13122023
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Transaction Events", 'OnBeforeTotalPressed', '', false, false)]
    local procedure OnBeforeTotalPressed(var POSTransaction: Record "LSC POS Transaction"; var IsHandled: Boolean);
    var
        LscPosTrnline: Record "LSC POS Trans. Line";
        LscPosTrnline1: Record "LSC POS Trans. Line";
        Count: Integer;
        Count1: Integer;
    begin
        Count := 0;
        Count1 := 0;

        LscPosTrnline.SetRange("Receipt No.", POSTransaction."Receipt No.");
        // LscPosTrnline.SetRange("Entry Status", LscPosTrnline."Entry Status"::" ");
        if LscPosTrnline.FindSet() then begin
            repeat
                Count += 1;
            until LscPosTrnline.Next() = 0;
        end;
        LscPosTrnline1.SetRange("Receipt No.", POSTransaction."Receipt No.");
        LscPosTrnline1.SetRange("Entry Status", LscPosTrnline."Entry Status"::Voided);
        if LscPosTrnline1.FindSet() then begin
            repeat
                Count1 += 1;
            until LscPosTrnline1.Next() = 0;
        end;

        if Count = count1 then Error('No Item Lines for Sale to Proceed');
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Transaction Events", 'OnAfterTenderKeyPressed', '', false, false)]
    local procedure OnAfterTenderKeyPressed(var POSTransaction: Record "LSC POS Transaction"; var POSTransLine: Record "LSC POS Trans. Line"; var TenderTypeCode: Code[10]);
    var

    begin
        if (POSTransaction."Sale Is Return Sale" = true) and (POSTransaction."Sales Type" = 'POS') then begin
            if TenderTypeCode <> '5' then
                Error('Not Allowed as Sale type is Return Detected');
        end;
    end;


    //AJ_ALLE_13122023

    // [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Controller", 'OnButtonPressed', '', false, false)]
    // local procedure OnButtonPressed(var POSMenuLine: Record "LSC POS Menu Line"; var handled: Boolean)
    // var
    //     LSCPOSSESSION: Codeunit "LSC POS Session";
    //     StaffId: Code[20];
    //     ActiveonPos: Record "Active On Pos";
    //     // Postran: Record "LSC POS Transaction";
    //     CustApp: Record Cust_App_Offers;
    //     PosEvent: Codeunit "LSC POS Transaction";
    // begin

    //     POSMenuLine.SetRange("Profile ID", '##DEFAULT');
    //     POSMenuLine.SetRange("Menu ID", 'MANAGER MENU');
    //     if POSMenuLine.Find() then begin
    //         if POSMenuLine.Command = 'MENU2' then begin
    //             CustApp.SetRange("Receipt No", PosEvent.GetReceiptNo());
    //             IF CustApp.FindFirst() then Error('Test succsess');
    //         end;
    //     end;

    // end;
    //AJ_ALLE_07122023



}
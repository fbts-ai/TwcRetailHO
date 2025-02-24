codeunit 50029 "Shift Validations"
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Transaction Events", 'OnBeforeTDCommandPressed', '', false, false)]
    procedure OnBeforeTDCommandPressed(var POSTransaction: Record "LSC POS Transaction"; EndOfDay: Boolean; var IsHandled: Boolean)
    var
        shiftQuery: Query ActiveManagerShiftQuery;
        totalShifts: Integer;
        totalManagerShifts: Integer;
        managerShifts: Integer;
        closedmanagerShifts: Integer;
        isManagerShift: Boolean;
        cashierShifts: Integer;
        isCashierShift: Boolean;
        isTodaysDate: Boolean;
        cashierShiftStatus: Boolean;
        cuPosTransaction: codeunit "LSC POS Transaction";
        cuPosSession: Codeunit "LSC POS Session";
        shiftConfigurationQuery: Query "Shift Configuration";
        shiftValidationFeatureEnabled: Text[100];
        eodValidationEnabled: Text[100];

    begin
        shiftConfigurationQuery.Open();
        if shiftConfigurationQuery.Read() then begin
            shiftValidationFeatureEnabled := shiftConfigurationQuery.FeatureEnabled;
            eodValidationEnabled := shiftConfigurationQuery.EODValidation;

            if (shiftValidationFeatureEnabled = 'TRUE') and (eodValidationEnabled = 'TRUE') then begin
                if (EndOfDay) then begin
                    shiftQuery.SetFilter(filterStore, cuPosSession.StoreNo());
                    shiftQuery.SetFilter(shiftQuery.Status, '<2');
                    shiftQuery.Open();
                    while shiftQuery.Read() do begin
                        totalShifts += 1;
                        if shiftQuery.Permission_Group = 'MANAGER' then begin
                            managerShifts += 1;
                            if shiftQuery.ID = POSTransaction."Staff ID" then begin
                                isManagerShift := true;
                            end;
                        end;
                    end;
                    shiftQuery.Close();

                    Message('Total / Manager Shifts: ' + Format(totalShifts) + ' ' + Format(managerShifts));

                    if isManagerShift and (managerShifts = 1) and (totalShifts > 1) then begin
                        Message('Please close all cashier shifts before closing the last manager shift!');
                        IsHandled := true;
                        //Ashish cuPosTransaction.VoidTransaction();
                    end;
                end
            end;
            shiftConfigurationQuery.Close();
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Transaction Events", 'OnBeforeInsertItemLine', '', false, false)]
    procedure OnBeforeInsertItemLine(var POSTransaction: Record "LSC POS Transaction"; var POSTransLine: Record "LSC POS Trans. Line"; var CurrInput: Text; var CompressEntry: Boolean)
    var
        isLogOn: Boolean;

    begin
        if ((POSTransaction."Transaction Type" = 0) or (POSTransaction."Transaction Type" = 1)) then begin
            isLogOn := true;
        end;
        ShiftValidationEnableFeature(false);

    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Transaction Events", 'OnBeforeInsertPaymentLine', '', false, false)]
    procedure OnBeforeInsertPaymentLine(var POSTransaction: Record "LSC POS Transaction"; var POSTransLine: Record "LSC POS Trans. Line"; var CurrInput: Text; var TenderTypeCode: Code[10]; Balance: decimal; PaymentAmount: Decimal; STATE: Code[10]; var isHandled: Boolean)
    var
        isLogOn: Boolean;

    begin
        if ((POSTransaction."Transaction Type" = 0) or (POSTransaction."Transaction Type" = 1)) then begin
            isLogOn := true;
        end;
        ShiftValidationEnableFeature(false);
    end;

    procedure ShiftValidationEnableFeature(isLogon: Boolean)
    var
        shiftConfigurationQuery: Query "Shift Configuration";
        shiftValidationFeatureEnabled: Text[100];

    begin
        shiftConfigurationQuery.Open();
        if shiftConfigurationQuery.Read() then begin
            shiftValidationFeatureEnabled := shiftConfigurationQuery.FeatureEnabled;

            if (shiftValidationFeatureEnabled = 'TRUE') then begin
                StoreHoursValidation(isLogon);
            end;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Transaction Events", 'OnAfterLogin', '', false, false)]
    procedure OnAfterLogin(var POSTransaction: Record "LSC POS Transaction"; var POSTransLine: Record "LSC POS Trans. Line"; var CurrInput: Text)
    var
        shiftConfigurationQuery: Query "Shift Configuration";
        shiftValidationFeatureEnabled: Text[100];
        isLogOn: Boolean;

    begin
        if ((POSTransaction."Transaction Type" = 0) or (POSTransaction."Transaction Type" = 1)) then begin
            isLogOn := true;
        end;
        shiftConfigurationQuery.Open();
        if shiftConfigurationQuery.Read() then begin
            shiftValidationFeatureEnabled := shiftConfigurationQuery.FeatureEnabled;

            if (shiftValidationFeatureEnabled = 'TRUE') then begin
                StoreHoursValidation(true);
                ActiveShiftValidation();
            end;
        end;
    end;

    procedure StoreHoursValidation(isLogOn: Boolean)
    var
        shiftQuery: Query ActiveManagerShiftQuery;
        cuPosSession: Codeunit "LSC POS Session";
        retailCalenderTable: Record "LSC Retail Calendar Line";
        shiftStartTime: DateTime;
        storeStartTime: DateTime;
        storeEndTime: DateTime;
        shiftConfigurationQuery: Query "Shift Configuration";
        storeHoursValidationEnabled: Text[100];

    begin
        shiftConfigurationQuery.Open();

        if shiftConfigurationQuery.Read() then begin
            storeHoursValidationEnabled := shiftConfigurationQuery.StoreHoursValidationValue;
            if storeHoursValidationEnabled = 'TRUE' then begin
                shiftQuery.SetFilter(shiftQuery.ID, cuPosSession.StaffID());
                //shiftQuery.SetFilter(shiftQuery.ID, cuPosSession.TerminalNo()); //AlleRSN
                shiftQuery.SetFilter(shiftQuery.Store_No_, cuPosSession.StoreNo());
                shiftQuery.Open();

                retailCalenderTable.SetFilter(retailCalenderTable."Calendar ID", cuPosSession.StoreNo());
                retailCalenderTable.SetFilter(retailCalenderTable."Day No.", Format(Date2DWY(DT2Date(CurrentDateTime), 1)));
                retailCalenderTable.Init();

                if shiftQuery.Read() then begin

                    if retailCalenderTable.FindSet() then begin

                        shiftStartTime := CreateDateTime(shiftQuery.Date, shiftQuery.Time);
                        storeStartTime := CreateDateTime(shiftQuery.Date, retailCalenderTable."Time From");
                        if retailCalenderTable."Midnight Open" then begin
                            storeEndTime := CreateDateTime(shiftQuery.Date + 1, retailCalenderTable."Time To");
                        end
                        else begin
                            storeEndTime := CreateDateTime(shiftQuery.Date, retailCalenderTable."Time To");
                        end;

                        //if (shiftQuery.Status = 1) then begin
                        if (shiftStartTime > storeStartTime) and (shiftStartTime < storeEndTime) then begin
                            if (CurrentDateTime > storeStartTime) and (CurrentDateTime < storeEndTime) then begin


                            end
                            else begin
                                if not (isLogon) then begin
                                    Error('Please close the current shift and open a new one as store hours is closed');

                                end;
                                Message('Please close the current shift and open a new one as store hours is closed');
                                //Error('Please close the current shift and open a new one as store hours is closed');
                            end;
                        end

                        else begin
                            retailCalenderTable.Reset();
                            retailCalenderTable.SetFilter(retailCalenderTable."Calendar ID", cuPosSession.StoreNo());
                            if retailCalenderTable."Day No." = 1 then begin
                                retailCalenderTable.SetFilter(retailCalenderTable."Day No.", '7');
                            end
                            else begin
                                retailCalenderTable.SetFilter(retailCalenderTable."Day No.", Format(retailCalenderTable."Day No." - 1));
                            end;
                            if retailCalenderTable.FindSet() then begin
                                if retailCalenderTable."Midnight Open" = true then begin

                                    storeStartTime := CreateDateTime(shiftQuery.Date - 1, retailCalenderTable."Time From");
                                    storeEndTime := CreateDateTime(shiftQuery.Date, retailCalenderTable."Time To");

                                    if (shiftStartTime > storeStartTime) and (shiftStartTime < storeEndTime) then begin
                                        if (CurrentDateTime > storeStartTime) and (CurrentDateTime < storeEndTime) then begin

                                        end
                                        else begin
                                            if not (isLogon) then begin
                                                Error('Please close the current shift and open a new one as store hours is closed');

                                            end;
                                            Message('Please close the current shift and open a new one as store hours is closed');
                                            //Error('Please close the current shift and open a new one as store hours is closed');
                                        end;
                                    end
                                    else begin
                                        if not (isLogon) then begin
                                            Error('Please close the current shift and open a new one as store hours is closed');

                                        end;
                                        Message('Please close the current shift and open a new one as store hours is closed');
                                        //Error('Please close the current shift and open a new one as store hours is closed');
                                    end;
                                end
                                else begin
                                    if not (isLogon) then begin
                                        Error('Please close the current shift and open a new one as store hours is closed');
                                    end;
                                    Message('Please close the current shift and open a new one as store hours is closed');
                                    //Error('Please close the current shift and open a new one as store hours is closed');
                                end;

                            end;
                        end
                        //end
                    end;
                end;
                shiftQuery.Close();
            end;
        end;
        shiftConfigurationQuery.Close();
    end;

    procedure ActiveShiftValidation()
    var
        shiftQuery: Query ActiveManagerShiftQuery;
        cuPosSession: Codeunit "LSC POS Session";
        retailCalenderTable: Record "LSC Retail Calendar Line";

        totalManagerShifts: Integer;
        openManagerShifts: Integer;
        closedmanagerShifts: Integer;
        openCashierShift: Boolean;
        closedCashierShift: Boolean;
        isCashier: Boolean;
        isCurrentUserCashier: Boolean;
        shiftConfigurationQuery: Query "Shift Configuration";
        SODValidationEnabled: Text[100];
        posTransactionHeaderTable: Record "LSC Transaction Header";

        shiftStartDateTime: DateTime;
        shiftEndDateTime: DateTime;
        storeStartTime: DateTime;
        storeEndTime: DateTime;
        isNewCashierShift: Boolean;

    begin

        shiftConfigurationQuery.Open();
        while shiftConfigurationQuery.Read() do begin
            SODValidationEnabled := shiftConfigurationQuery.SODValue;
            if SODValidationEnabled = 'TRUE' then begin
                shiftQuery.SetFilter(shiftQuery.Store_No_, cuPosSession.StoreNo());
                shiftQuery.Open();
                while shiftQuery.Read() do begin
                    retailCalenderTable.SetFilter(retailCalenderTable."Calendar ID", cuPosSession.StoreNo());
                    retailCalenderTable.SetFilter(retailCalenderTable."Day No.", Format(Date2DWY(DT2Date(CurrentDateTime), 1)));
                    retailCalenderTable.Init();

                    if retailCalenderTable.FindSet() then begin

                        shiftStartDateTime := CreateDateTime(shiftQuery.Date, shiftQuery.Time);
                        storeStartTime := CreateDateTime(shiftQuery.Date, retailCalenderTable."Time From");
                        if retailCalenderTable."Midnight Open" then begin
                            storeEndTime := CreateDateTime(shiftQuery.Date + 1, retailCalenderTable."Time To");
                        end
                        else begin
                            storeEndTime := CreateDateTime(shiftQuery.Date, retailCalenderTable."Time To");
                        end;
                    end;

                    if (shiftStartDateTime > storeStartTime) and (shiftStartDateTime < storeEndTime) then begin
                        if (CurrentDateTime > storeStartTime) and (CurrentDateTime < storeEndTime) then begin
                            if (shiftQuery.Permission_Group = 'MANAGER') then begin
                                totalManagerShifts += 1;
                                if (shiftQuery.Status = 1) then begin
                                    openManagerShifts += 1;
                                end
                                else
                                    if (shiftQuery.Status = 2) then begin
                                        closedmanagerShifts += 1;
                                    end
                            end
                            else
                                if (shiftQuery.Permission_Group = 'CASHIER') then begin
                                    if (shiftQuery.ID = cuPosSession.StaffID()) then begin
                                        isCashier := true;
                                        if (shiftQuery.Status = 1) then begin
                                            openCashierShift := true
                                        end;

                                        if (shiftQuery.Status = 2) then begin
                                            closedCashierShift := true;
                                            posTransactionHeaderTable.Init();
                                            posTransactionHeaderTable.SetFilter(posTransactionHeaderTable."Store No.", cuPosSession.StoreNo());
                                            posTransactionHeaderTable.SetFilter(posTransactionHeaderTable."Staff ID", cuPosSession.StaffID());
                                            posTransactionHeaderTable.SetFilter(posTransactionHeaderTable."Transaction Type", '5');
                                            if posTransactionHeaderTable.FindLast() then begin
                                                shiftStartDateTime := CreateDateTime(posTransactionHeaderTable.Date, posTransactionHeaderTable.Time);
                                                //shiftEndDateTime := CreateDateTime(shiftQuery.Date, retailCalenderTable."Time To");
                                            end;
                                            posTransactionHeaderTable.SetFilter(posTransactionHeaderTable."Transaction Type", '7');
                                            if posTransactionHeaderTable.FindLast() then begin
                                                shiftEndDateTime := CreateDateTime(posTransactionHeaderTable.Date, posTransactionHeaderTable.Time);
                                            end;

                                            retailCalenderTable.Init();
                                            retailCalenderTable.SetFilter(retailCalenderTable."Calendar ID", cuPosSession.StoreNo());
                                            retailCalenderTable.SetFilter(retailCalenderTable."Day No.", Format(Date2DWY(DT2Date(CurrentDateTime), 1)));

                                            //shiftQuery.SetFilter(shiftQuery.ID, cuPosSession.StaffID());
                                            // shiftQuery.SetFilter(shiftQuery.Store_No_, cuPosSession.StoreNo());

                                            // shiftQuery.Open();

                                            //if shiftQuery.Read() then begin
                                            if retailCalenderTable.FindSet() then begin
                                                storeStartTime := CreateDateTime(shiftQuery.Date, retailCalenderTable."Time From");
                                                if retailCalenderTable."Midnight Open" then begin
                                                    storeEndTime := CreateDateTime(shiftQuery.Date + 1, retailCalenderTable."Time To");
                                                end
                                                else begin
                                                    storeEndTime := CreateDateTime(shiftQuery.Date, retailCalenderTable."Time To");
                                                end;


                                                //if (shiftStartDateTime > storeStartTime) and (shiftStartDateTime < storeEndTime) then begin
                                                // end
                                                // else begin
                                                //     isNewCashierShift := true;
                                                // end;

                                                if (shiftStartDateTime < storeStartTime) then begin
                                                    isNewCashierShift := true;
                                                end;


                                            end;
                                            //end;
                                            //shiftQuery.Close();
                                        end;
                                    end;
                                end;
                        end
                    end;


                end;

                if (isCashier) and (closedCashierShift) and (openManagerShifts < 1) and not (isNewCashierShift) then begin
                    Error('Cannot do start of the day, please reach out to manager');
                end;

                if (iscashier) and (openManagerShifts < 1) and (closedmanagerShifts > 0) and not (isNewCashierShift) then begin
                    Error('Cannot do start of the day, please reach out to manager');
                end;
            end;
        end;
        shiftConfigurationQuery.Close();

    end;
}

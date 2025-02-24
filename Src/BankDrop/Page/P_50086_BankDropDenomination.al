page 50086 "Bank Drop Denomination"
{
    ApplicationArea = All;
    Caption = 'Bank Drop Denomination';
    PageType = List;
    SourceTable = "Bank Drop Denomination Temp";
    UsageCategory = Administration;
    InsertAllowed = false;
    DeleteAllowed = false;
    // ModifyAllowed = false;

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                ShowCaption = false;
                // field(Id; Rec.ID)
                // {
                //     ApplicationArea = All;
                // }

                // field("Tender Type"; Rec."Tender Type")
                // {
                //     ApplicationArea = All;
                // }

                field(Type; Rec.Type)
                {
                    ApplicationArea = All;
                    Editable = false;
                }

                field(ID; Rec.BankDropID)
                {
                    Visible = false;
                }
                field(Amount; Rec.Amount)
                {
                    ApplicationArea = All;
                    Editable = false;
                }

                field("Qty."; Rec."Qty.")
                {
                    ApplicationArea = All;
                    //Editable = "Qty.Editable";

                    trigger OnValidate()
                    var
                        bankDropTempDenominationTable: Record "Bank Drop Denomination Temp";
                        paymentEntryTable: Record "LSC Trans. Payment Entry";
                        cashCollected: Decimal;
                        Rec_Store: Record "LSC Store";
                        TotalDenominationPostive: Decimal;
                        TotalDenominationNegitive: Decimal;
                        cashCollectedPostive: Decimal;
                        cashCollectedNegitive: Decimal;

                    begin
                        // QtyOnAfterValidate;
                        // //bankDropTempDenominationTable.TotalDenomination := 0;
                        // bankDropTempDenominationTable.Total := 0;
                        // totalCount := 0;

                        // bankDropTempDenominationTable.Init();
                        // bankDropTempDenominationTable.SetFilter(BankDropID, Format(Rec.BankDropID));
                        // if bankDropTempDenominationTable.FindSet() then begin
                        //     repeat
                        //         totalCount := bankDropTempDenominationTable.Total + totalCount;
                        //         bankDropTempDenominationTable.TotalDenomination := totalCount;
                        //         bankDropTempDenominationTable.Modify();
                        //     until bankDropTempDenominationTable.Next = 0;
                        //     // bankDropTempDenominationTable.TotalDenomination := totalCount;
                        //     // bankDropTempDenominationTable.Modify();
                        // end;
                        QtyOnAfterValidate;

                        //bankDropTempDenominationTable.TotalDenomination := 0;
                        //Clear(totalCount);
                        totalCount := 0;
                        //  bankDropTempDenominationTable.Init();
                        bankDropTempDenominationTable.Reset();//PTFBTS 26/0424
                        bankDropTempDenominationTable.SetFilter(BankDropID, Format(Rec.BankDropID));
                        bankDropTempDenominationTable.SetFilter(Store_No, '%1', rec.Store_No);//PTFBTS 26/0424
                                                                                              // bankDropTempDenominationTable.SetRange(id, Rec.id);
                        if bankDropTempDenominationTable.FindSet() then begin
                            // bankDropTempDenominationTable.Total := 0;
                            repeat
                                totalCount += bankDropTempDenominationTable.Total;
                                bankDropTempDenominationTable.TotalDenomination := totalCount;
                                bankDropTempDenominationTable.Modify();
                            until bankDropTempDenominationTable.Next = 0;//PTFBTS 26/0424
                                                                         //Message('%1', totalCount);

                        end;

                        // bankDropTempDenominationTable.TotalDenomination := totalCount;
                        // bankDropTempDenominationTable.Modify();



                        // Rec.Init();
                        // if Rec.FindFirst() then begin
                        //     repeat
                        //         bankDropTempTable.TotalDenomination := bankDropTempTable.Total + bankDropTempTable.TotalDenomination;
                        //         bankDropTempTable.Modify();
                        //     until Rec.Next = 0;
                        // end;
                    end;
                }

                field(Total; Rec.Total)
                {
                    ApplicationArea = All;
                    Editable = false;
                    trigger OnValidate()
                    begin
                        Message('On Validate ');
                    end;
                }
            }
            field(TotalDenomination; totalCount)
            {
                ApplicationArea = All;
                Editable = false;

            }
        }
    }

    actions
    {
        area(Processing)
        {
            action("Post")
            {
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                PromotedIsBig = true;
                ApplicationArea = All;

                trigger OnAction()
                var
                    bankDropTempDenominationTable: Record "Bank Drop Denomination Temp";
                    bankDropMainDenominationTable: Record "Bank Drop Denomination Main";
                    cuPOSSession: Codeunit "LSC POS Session";
                    bankDropMainTable: Record "Bank Drop Main";
                    bankDropDenPage: Page "Bank Drop Denomination";
                    bankDropMainID: Integer;
                    cashCollected: Decimal;
                    Rec_Store: Record "LSC Store";
                    TotalDenominationPostive: Decimal;
                    TotalDenominationNegitive: Decimal;
                    cashCollectedPostive: Decimal;
                    cashCollectedNegitive: Decimal;
                    paymentEntryTable: Record "LSC Trans. Payment Entry";

                begin
                    paymentEntryTable.SetFilter(paymentEntryTable."Tender Type", '1');
                    paymentEntryTable.SetFilter(paymentEntryTable."Store No.", rec.Store_No);
                    paymentEntryTable.SetFilter(paymentEntryTable.Date, Format(DT2Date(rec."Date/Time")));
                    paymentEntryTable.SetFilter(paymentEntryTable."Transaction Status", '<>%1', 1);
                    paymentEntryTable.SetFilter(paymentEntryTable."Safe type", '0');
                    cashCollected := 0;
                    if paymentEntryTable.FindSet() then begin
                        repeat
                            cashCollected := cashCollected + paymentEntryTable."Amount Tendered";
                        until paymentEntryTable.Next = 0;
                        // Message('%1', cashCollected);
                    end;
                    // if Rec_Store.Get(rec.Store_No) then;
                    // if rec.FindLast() then
                    //     cashCollectedPostive := cashCollected + Rec_Store."Bank Drop Cash Tolerance Limit";
                    // cashCollectedNegitive := cashCollected - Rec_Store."Bank Drop Cash Tolerance Limit";
                    // if not (rec.TotalDenomination >= cashCollectedNegitive) and (rec.TotalDenomination <= cashCollectedPostive) then begin
                    //     Error('You enter  denomination %1 but cash collected is %2', Rec.TotalDenomination, cashCollected);
                    // end
                    // else
                    //     IF Rec.TotalDenomination = 0 then Error('Total Denomination Amount is Zero');
                    if totalCount < cashCollected then
                        Error(' You cannot post because denomination amount is less than cash collected amount');
                    // Message('%1', totalCount);
                    bankDropMainTable.Init();
                    bankDropMainTable.SetRange(ID, Rec.BankDropID);
                    //bankDropMainTable.SetRange(StoreCode, bankDropTempDenominationTable.Store_No);
                    if bankDropMainTable.FindLast() then begin
                        bankDropMainID := bankDropMainTable.ID;
                        bankDropMainTable.Bankdropdate1 := DT2Date(Rec."Date/Time");
                        bankDropMainTable."Date/Time" := Rec."Date/Time";//AJ_ALLE_24112023
                        bankDropMainTable.StoreCode := Rec.Store_No;
                        bankDropMainTable.Remarks := '';
                        bankDropMainTable.ID := Rec.BankDropID;
                        bankDropMainTable.PostedStatus := true;
                        bankDropMainTable.Modify();
                    end;

                    bankDropMainDenominationTable.Init();
                    bankDropTempDenominationTable.Init();
                    bankDropTempDenominationTable.SetFilter(Store_No, Rec.Store_No);
                    bankDropTempDenominationTable.SetFilter("Date/Time", Format(Rec."Date/Time"));
                    bankDropTempDenominationTable.SetFilter(BankDropID, Format(bankDropMainID));
                    if (bankDropTempDenominationTable.FindSet()) then begin
                        bankDropMainDenominationTable.Init();
                        repeat
                            if bankDropTempDenominationTable.Amount > 0 then begin
                                bankDropMainDenominationTable.Amount := bankDropTempDenominationTable.Amount;
                                bankDropMainDenominationTable."Currency Code" := bankDropTempDenominationTable."Currency Code";
                                bankDropMainDenominationTable.Description := bankDropTempDenominationTable.Description;
                                bankDropMainDenominationTable."Qty." := bankDropTempDenominationTable."Qty.";
                                // bankDropMainDenominationTable.Store_No := bankDropTempDenominationTable.Store_No;
                                bankDropMainDenominationTable.Store_No := bankDropTempDenominationTable.Store_No;
                                bankDropMainDenominationTable."Tender Type" := bankDropTempDenominationTable."Tender Type";
                                bankDropMainDenominationTable.Total := bankDropTempDenominationTable.Total;
                                bankDropMainDenominationTable.Type := bankDropTempDenominationTable.Type;
                                bankDropMainDenominationTable.ID := bankDropTempDenominationTable.ID;
                                //bankDropMainDenominationTable.Date := bankDropTempDenominationTable."Date/Time";
                                bankDropMainDenominationTable.BankDropDate := DT2Date(Rec."Date/Time");
                                bankDropMainDenominationTable.Staff_ID := bankDropTempDenominationTable.Staff_ID;
                                bankDropMainDenominationTable.Terminal_No := bankDropTempDenominationTable.Terminal_No;
                                bankDropMainDenominationTable.BankDropID := Rec.BankDropID;
                                // bankDropMainTable.Date := bankDropDate;
                                bankDropMainDenominationTable.Insert();
                            end;

                            bankDropTempDenominationTable.Delete();

                        until bankDropTempDenominationTable.Next = 0;

                        Message('Bank Drop Posted Successfully');
                        CurrPage.Close();
                    end;
                end;
            }
        }
    }
    trigger OnAfterGetCurrRecord()
    var
        bankDropTempDenominationTable: Record "Bank Drop Denomination Temp";
    begin
        // bankDropTempDenominationTable.Reset();
        // bankDropTempDenominationTable.SetRange(ID, Rec.ID);
        // if bankDropTempDenominationTable.FindFirst() then begin
        //     repeat
        //         totalCount := Rec.Total;//+ totalCount; //PTFBTS


        //     until bankDropTempDenominationTable.Next = 0;
        //     bankDropTempDenominationTable.Validate(TotalDenomination, totalCount);
        //     bankDropTempDenominationTable.Modify();
        //     // bankDropTempDenominationTable.TotalDenomination := totalCount;
        //     // bankDropTempDenominationTable.Modify();
        //     //Message('%1', totalCount);
        //     //Count(Rec.ID);
    END;


    //end;

    // trigger OnAfterGetRecord()
    // var
    //     bankDropTempDenominationTable: Record "Bank Drop Denomination Temp";
    // begin
    //     bankDropTempDenominationTable.Reset();
    //     bankDropTempDenominationTable.SetRange(ID, Rec.ID);
    //     if bankDropTempDenominationTable.FindFirst() then begin
    //         repeat
    //             totalCount := Rec.Total;//+ totalCount; //PTFBTS


    //         until bankDropTempDenominationTable.Next = 0;
    //         bankDropTempDenominationTable.Validate(TotalDenomination, totalCount);
    //         bankDropTempDenominationTable.Modify();
    //         // bankDropTempDenominationTable.TotalDenomination := totalCount;
    //         // bankDropTempDenominationTable.Modify();
    //         Message('%1', totalCount);
    //         //Count(Rec.ID);
    //     END;
    //END;

    trigger OnOpenPage()
    var
        bankDropTempDenominationTable: Record "Bank Drop Denomination Temp";
        cuPOSSession: Codeunit "LSC POS Session";
        bankDropPage: Page BankDrop;

    begin
        // bankDropPage.GetInputDate(bankDropInputDate);
        //Message(Format(bankDropInputDate));

        //bankDropTempDenominationTable.Init();
        //bankDropTempDenominationTable.SetFilter(bankDropTempDenominationTable.Store_No, bankDropTempDenominationTable.Store_No);
        // bankDropTempDenominationTable.SetFilter(bankDropTempDenominationTable.Terminal_No, cuPOSSession.TerminalNo());
        // bankDropTempDenominationTable.SetFilter(bankDropTempDenominationTable.Staff_ID, cuPOSSession.StaffID());

    end;

    local procedure QtyOnAfterValidate()
    begin
        CurrPage.Update;
    end;

    // procedure SetBankDropDate(var bankDropDate: DateTime)
    // begin
    //     bankDropInputDate := bankDropDate;
    // end;

    procedure SetInputDate(var Idate: DateTime)
    begin
        bankDropInputDate := Idate;
    end;

    var
        bankDropInputDate: DateTime;
        totalCount: Decimal;
}
page 50084 BankDrop
{
    ApplicationArea = All;
    Caption = 'Bank Drop';
    PageType = Worksheet;
    SourceTable = "Bank Drop Main";
    SourceTableView = where("PostedStatus" = filter(= true));
    UsageCategory = Lists;
    InsertAllowed = false;
    DeleteAllowed = false;
    // ModifyAllowed = false;

    layout
    {
        area(Content)
        {
            field(StoreCode; store)
            {
                ApplicationArea = All;
                Caption = 'StoreCode';
                //TableRelation = "LSC Store";
                Editable = false;
                ShowMandatory = true;
                trigger OnValidate()
                begin
                    GetStoreCode();
                end;
            }

            field(storeName; storeName)
            {
                ApplicationArea = All;
                Caption = 'StoreName';
                //TableRelation = "LSC Store";
                Editable = false;
                ShowMandatory = true;
                trigger OnValidate()
                begin
                    GetStoreCode();
                end;
            }

            field("Date/Time"; bankDropDate)
            {
                Caption = 'Date';
                ApplicationArea = All;
                ShowMandatory = true;
                Editable = true;

                trigger OnValidate();
                var
                    bankDrop: Record "Bank Drop Main";
                    bankDrop1: Record "Bank Drop Main";
                    //inputDate: DateTime;
                    yesterdayBankDropDate: DateTime;
                    //cashSales: Page BankDrop;
                    salesAmountStatementPosting: Record "LSC Posted Statement Line";
                    posTransaction: Record "LSC POS Transaction";
                    salesStatementAmount: Decimal;
                    bankDropPage: Page "LSC Cash Declaration Setup";
                    paymentEntryTable: Record "LSC Trans. Payment Entry";
                    cuPOSSession: Codeunit "LSC POS Session";

                begin

                    if store = '' then begin
                        Error('Please select the store to continue');
                    end;

                    inputDate := bankDropDate;
                    bankDrop.Init();

                    bankDrop.SetFilter(bankDrop."Date/Time", Format(inputDate));
                    bankDrop.SetFilter(bankDrop.StoreCode, store);
                    bankDrop.SetFilter(PostedStatus, '1');
                    if bankDrop.FindFirst() then begin
                        Error('Bank Drop is already posted for the day');
                    end;

                    if inputDate > CreateDateTime(Today, Time) then begin
                        Error('Bank Drop is not allowed for future date');
                    end;

                    if bankDrop1.FindSet() then begin
                        bankDrop.Init();

                        yesterdayBankDropDate := (inputDate - 1);
                        bankDrop1.SetFilter(bankDrop1.StoreCode, store);
                        bankDrop1.SetFilter(bankDrop1.PostedStatus, '1');
                        if bankDrop1.FindFirst() then begin
                            bankDrop1.SetFilter(bankDrop1."Date/Time", Format(DT2Date(yesterdayBankDropDate)));
                            if bankDrop1.FindFirst() then begin
                            end
                            else
                                Error('Please do bank drop for yesterday');
                        end
                    end;
                    paymentEntryTable.Init();
                    paymentEntryTable.SetFilter(paymentEntryTable."Tender Type", '1');
                    paymentEntryTable.SetFilter(paymentEntryTable."Store No.", store);
                    paymentEntryTable.SetFilter(paymentEntryTable.Date, Format(DT2Date(inputDate)));
                    paymentEntryTable.SetFilter(paymentEntryTable."Transaction Status", '<>%1', 1);
                    paymentEntryTable.SetFilter(paymentEntryTable."Safe type", '0');

                    cashCollected := 0;
                    if paymentEntryTable.FindSet() then begin
                        repeat
                            cashCollected := cashCollected + paymentEntryTable."Amount Tendered";
                        until paymentEntryTable.Next = 0;
                    end;
                end;
            }

            field("Cash Collected"; cashCollected)
            {
                Caption = 'Cash Collected';
                ApplicationArea = All;
                Editable = false;

                trigger OnValidate();
                var
                    paymentEntryTable: Record "LSC Trans. Payment Entry";

                begin
                    paymentEntryTable.SetFilter(paymentEntryTable."Amount Tendered", '1');
                    paymentEntryTable.SetFilter(paymentEntryTable.Date, Format(inputDate));
                    paymentEntryTable.SetFilter(paymentEntryTable."Store No.", store);
                    paymentEntryTable.SetFilter(paymentEntryTable."Transaction Status", '<>%1', 1);
                    paymentEntryTable.SetFilter(paymentEntryTable."Safe type", '0');
                    paymentEntryTable.Init();
                    if paymentEntryTable.FindFirst() then begin
                        repeat
                            cashCollected := cashCollected + paymentEntryTable."Amount Tendered";
                        until paymentEntryTable.Next = 0
                    end;

                end;
            }

            repeater(Group)
            {
                field("Store1"; Rec.StoreCode)
                {
                    ApplicationArea = All;
                    Editable = false;
                    Caption = 'Store';
                }
                field("Date"; Rec."Date/Time")
                {
                    ApplicationArea = All;
                    Editable = false;

                }
                field("Remarks"; Rec.Remarks)
                {
                    ApplicationArea = All;
                    Editable = true;
                }
                field("Acknowlegement_No"; Rec.Acknowlegement_No)
                {
                    ApplicationArea = All;
                    Editable = true;
                }
                field("Posted Status"; Rec.PostedStatus)
                {
                    ApplicationArea = All;
                    Editable = false;
                    Visible = false;
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action("Bank Drop Denomination")
            {
                ApplicationArea = all;
                Promoted = true;
                PromotedIsBig = true;
                PromotedCategory = Process;

                trigger onAction()
                var
                    bankDropDenominationQuery: Query "Bank Drop Denomination";
                    cuPOSSession: Codeunit "LSC POS Session";
                    id: Integer;
                    bankDropPage: Page BankDrop;
                    bankDropDenominationTable: Record "Bank Drop Denomination Temp";
                    bankDropDenominationPage: Page "Bank Drop Denomination";
                    bankDropMainTable: Record "Bank Drop Main";
                    id1: Integer;
                    bankDropMainTable1: Record "Bank Drop Main";


                begin
                    if (inputDate = CreateDateTime(0D, 0T)) then begin
                        Error('Please enter the bank drop date');
                    end;
                    id1 := 1;
                    bankDropMainTable.Init();
                    bankDropMainTable.SetFilter("Date/Time", Format(bankDropDate));
                    bankDropMainTable.SetFilter(StoreCode, store);

                    if not bankDropMainTable.FindLast() then begin
                        bankDropMainTable1.Init();

                        if bankDropMainTable1.FindLast() then begin
                            id1 := bankDropMainTable1.ID + 1;
                        end;
                        bankDropMainTable.ID := id1;
                        bankDropMainTable."Date/Time" := bankDropDate;
                        bankDropMainTable.StoreCode := store;
                        bankDropMainTable.Insert();
                    end;


                    if bankDropDenominationQuery.Open() then begin

                        bankDropDenominationTable.SetFilter(bankDropDenominationTable."Date/Time", Format(inputDate));
                        bankDropDenominationTable.SetFilter(bankDropDenominationTable.Store_No, store);
                        bankDropDenominationQuery.SetFilter(bankDropDenominationQuery.Store_No_, store);
                        if bankDropDenominationTable.FindFirst() then begin

                        end
                        else begin
                            bankDropDenominationQuery.SetFilter(bankDropDenominationQuery.Store_No_, store);
                            bankDropDenominationQuery.Open();
                            while bankDropDenominationQuery.Read() do begin
                                bankDropDenominationTable.Init();
                                bankDropDenominationTable.ID := id;
                                bankDropDenominationTable."Currency Code" := '';
                                bankDropDenominationTable.Description := '';
                                bankDropDenominationTable."Tender Type" := bankDropDenominationQuery.Tender_Type;
                                bankDropDenominationTable.Amount := bankDropDenominationQuery.Amount;
                                bankDropDenominationTable.Type := bankDropDenominationQuery.Type;
                                bankDropDenominationTable."Date/Time" := inputDate;
                                bankDropDenominationTable.Store_No := store;
                                bankDropDenominationTable.Terminal_No := cuPOSSession.TerminalNo();
                                bankDropDenominationTable.Staff_ID := cuPOSSession.StaffID();
                                bankDropDenominationTable.BankDropID := id1;

                                bankDropDenominationTable.Insert();
                            end;
                        end;

                        bankDropDenominationQuery.Close();
                        //bankDropDenominationPage.SetInputDate(inputDate);
                        bankDropDenominationTable.SetFilter(bankDropDenominationTable."Date/Time", Format(inputDate));
                        // inputDate := CreateDateTime(0D, 0T);
                        // store := '';
                        bankDropDenominationPage.SetInputDate(inputDate);

                        //Clear(store);

                        bankDropDenominationTable.Init();

                        bankDropDenominationTable.SetRange(Store_No, store);
                        bankDropDenominationTable.SetRange("Date/Time", bankDropDate);
                        if bankDropDenominationTable.FindLast then begin
                            id1 := bankDropDenominationTable.BankDropID;
                        end;

                        bankDropDenominationTable.SetRange(bankDropDenominationTable.BankDropID, id1);
                        //bankDropDenominationPage.SetTableView(bankDropDenominationTable);
                        //bankDropDenominationPage.SetSelectionFilter(bankDropDenominationTable);
                        Page.Run(Page::"Bank Drop Denomination", (bankDropDenominationTable));
                        Clear(bankDropDate);
                        Clear(cashCollected);
                    end;
                end;
            }
            action("No Sale")
            {
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                PromotedIsBig = true;
                ApplicationArea = All;

                trigger OnAction()
                var
                    bankDropMainTable: Record "Bank Drop Main";
                    Selection: Integer;
                    DefaultOption: Integer;
                    twcConfiguration: Record "TWC Configuration";
                    reasonCode: Text[100];
                    totalReasonCode: Integer;
                    bankDropTempTable: Record "Bank Drop Denomination Temp";
                begin
                    bankDropMainTable.Init();
                    if (inputDate = CreateDateTime(0D, 0T)) or (store = '') then begin
                        Error('Please enter the bank drop date and store number');
                    end;

                    twcConfiguration.SetFilter(twcConfiguration.Key_, 'BANK DROP');
                    totalReasonCode := 1;
                    if twcConfiguration.FindSet() then begin
                        repeat
                            reasonCode := twcConfiguration.Name + ',' + reasonCode;
                            totalReasonCode := totalReasonCode + 1;
                        until twcConfiguration.Next = 0;
                        Selection := StrMenu(reasonCode, DefaultOption);
                        Selection := totalReasonCode - Selection;

                        if not (Selection = totalReasonCode) then begin
                            twcConfiguration.SetFilter(twcConfiguration.Value_, Format(Selection));
                            if twcConfiguration.FindFirst() then begin
                                reasonCode := twcConfiguration.Name;
                                bankDropMainTable.Remarks := reasonCode;
                            end;
                            bankDropMainTable."Date/Time" := inputDate;
                            bankDropMainTable.StoreCode := store;
                            bankDropMainTable.PostedStatus := true;
                            bankDropMainTable.Insert();
                        end;
                        bankDropTempTable.Init();
                        bankDropTempTable.SetFilter(bankDropTempTable."Date/Time", Format(inputDate));
                        bankDropTempTable.SetFilter(bankDropTempTable.Store_No, store);
                        if bankDropTempTable.FindSet() then begin
                            repeat
                                bankDropTempTable.Delete();
                            until bankDropTempTable.Next = 0;
                        end;

                        Clear(bankDropDate);
                        //Clear(store);
                    end;
                end;
            }
        }

    }

    trigger OnOpenPage()
    var
        bankDropMainTable1: Record "Bank Drop Main";
        store_code: Text;
    begin
        GetStoreCode();
        Rec.SetFilter(StoreCode, store);

    end;

    local procedure GetStoreCode() storeName2: Text
    var
        retailUser: Record "LSC Retail User";
        userID1: Text;
        storeTable: Record "LSC Store";

    begin

        userID1 := UserId;
        retailUser.Reset();
        retailUser.SetRange(ID, userID);
        if retailUser.FindFirst() then begin
            store := retailUser."Store No.";
            storeName2 := store;
        end;
        storeTable.Init();
        storeTable.SetFilter("No.", store);
        if storeTable.FindLast() then begin
            storeName := storeTable.Name;
        end;
    end;

    var
        denom: page "Bank Drop Denomination";
        inputDate: DateTime;
        bankDropDate: DateTime;
        store: Text[100];
        storeName: Text[100];

        cashCollected: Decimal;
}
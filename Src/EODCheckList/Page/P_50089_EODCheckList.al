page 50089 EODChecklist
{
    ApplicationArea = All;
    Caption = 'EOD CheckList';
    PageType = Worksheet;
    SourceTable = "EOD Main";
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
                Caption = 'StoreCode';
                ApplicationArea = All;
                //TableRelation = "LSC Store";
                Editable = false;
                //ShowMandatory = true;
            }
            field(StoreName; storeName)
            {
                ApplicationArea = All;
                Caption = 'StoreName';
                //TableRelation = "LSC Store";
                Editable = false;
                ShowMandatory = true;
            }


            field("Date/Time"; inputEODDate)
            {
                Caption = 'Date';
                ApplicationArea = All;
                ShowMandatory = true;
                Editable = true;

                trigger OnValidate();
                var
                    EODTable: Record "EOD Main";
                    EODTable1: Record "EOD Main";
                    yesterdayEODDate: DateTime;
                begin
                    if store = '' then begin
                        Error('Please select the store to continue');
                    end;

                    EODTable.Init();

                    EODTable.SetFilter("Date/Time", Format(inputEODDate));
                    EODTable.SetFilter(StoreCode, store);
                    EODTable.SetFilter(PostedStatus, '1');
                    if EODTable.FindFirst() then begin
                        Error('EOD checklist is already posted for the day');
                    end;

                    if inputEODDate > CreateDateTime(Today, Time) then begin
                        Error('EOD checklist is not allowed for future date');
                    end;

                    if EODTable1.FindSet() then begin
                        EODTable1.Init();

                        yesterdayEODDate := (inputEODDate - 1);
                        EODTable1.SetFilter(StoreCode, store);
                        EODTable1.SetFilter(PostedStatus, '1');
                        if EODTable1.FindFirst() then begin
                            EODTable1.SetFilter("Date/Time", Format(DT2Date(yesterdayEODDate)));
                            if EODTable1.FindFirst() then begin

                            end
                            else
                                Error('Please fill EOD checklist for yesterday');
                        end
                    end;
                end;
            }

            repeater(Group)
            {
                field("Store"; Rec.StoreCode)
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
                field(PostedStatus; Rec.PostedStatus)
                {

                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action("EOD CheckList")
            {
                ApplicationArea = all;
                Promoted = true;
                PromotedIsBig = true;
                PromotedCategory = Process;

                trigger onAction()
                var
                    eodChecklistQuery: Query "EOD CheckList Query";
                    id: Integer;
                    eodChecklistTempTable: Record EODCheckListTempTable;
                    eodChecklistDetailsPage: Page EODCheckListPage;
                    eodMainTab: Record "EOD Main";
                    eodMainTab1: Record "EOD Main";
                    id1: Integer;

                begin
                    if (inputEODDate = CreateDateTime(0D, 0T)) then begin
                        Error('Please enter the EOD drop date');
                    end;

                    id1 := 1;
                    eodMainTab.Init();
                    eodMainTab.SetFilter("Date/Time", Format(inputEODDate));
                    eodMainTab.SetFilter(StoreCode, store);

                    if not eodMainTab.FindLast() then begin
                        eodMainTab1.Init();

                        if eodMainTab1.FindLast() then begin
                            id1 := eodMainTab1.ID + 1;
                        end;
                        eodMainTab.ID := id1;
                        eodMainTab."Date/Time" := inputEODDate;
                        eodMainTab.StoreCode := store;
                        eodMainTab.Insert();
                    end;

                    if eodChecklistQuery.Open() then begin
                        eodChecklistTempTable.SetFilter(eodChecklistTempTable.Date, Format(inputEODDate));
                        eodChecklistTempTable.SetFilter(eodChecklistTempTable.Store_No, store);
                        eodChecklistTempTable.SetFilter(eodChecklistTempTable.EOD_ID, Format(id1));

                        if eodChecklistTempTable.FindFirst() then begin

                        end
                        else begin
                            while eodChecklistQuery.Read() do begin
                                eodChecklistTempTable.Init();
                                eodChecklistTempTable.ID := id;
                                eodChecklistTempTable.Tasks := eodChecklistQuery.EODCheckLists;
                                eodChecklistTempTable.Date := inputEODDate;
                                eodChecklistTempTable.Store_No := store;
                                eodChecklistTempTable.EOD_ID := id1;

                                eodChecklistTempTable.Insert();

                            end;

                        end;
                        eodChecklistTempTable.SetRange(EOD_ID, id1);
                        Page.Run(Page::EODCheckListPage, eodChecklistTempTable);
                        eodChecklistQuery.Close();
                        Clear(inputEODDate);

                    end;
                end;
            }
        }
    }


    trigger OnOpenPage()
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
        end;
        storeTable.Init();
        storeTable.SetFilter("No.", store);
        if storeTable.FindLast() then begin
            storeName := storeTable.Name;
        end;
        Rec.SetFilter(StoreCode, store);
        Rec.SetFilter(PostedStatus, '1');
    end;

    procedure GetInputDate() inputDate: Datetime
    begin
        //CurrPage.();
        inputDate := inputEODDate;
    end;

    var
        inputEODDate: DateTime;
        store: Text[100];
        storeName: Text[100];
}
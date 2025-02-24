page 50088 EODCheckListPage
{
    ApplicationArea = All;
    Caption = 'EOD Checklist Details';
    PageType = List;
    SourceTable = EODCheckListTempTable;
    UsageCategory = Administration;
    InsertAllowed = false;
    // ModifyAllowed = false;
    DeleteAllowed = false;

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field(Tasks; Rec.Tasks)
                {
                    ApplicationArea = All;
                }

                field(Status; Rec.Status)
                {

                    ApplicationArea = All;
                    trigger OnValidate()
                    begin
                        status := Rec.Status;
                        Rec.Modify();
                    end;
                }
                field(EOD_ID; Rec.EOD_ID)
                {
                    Visible = false;
                }

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
                    eodCheckListTempTable: Record EODCheckListTempTable;
                    eodCheckListTempTable1: Record EODCheckListTempTable;
                    eodCheckListMainTable: Record EODCheckListMainTable;
                    eodMainTable: Record "EOD Main";
                    eodMainID: Integer;
                    status1: Boolean;
                begin
                    if Confirm('Do you want to post the EOD checklist, once posted cannot be modified') then begin
                        eodCheckListMainTable.Init();
                        eodCheckListTempTable1.Init();
                        eodCheckListTempTable1.SetFilter(EOD_ID, Format(Rec.EOD_ID));
                        if (eodCheckListTempTable1.FindSet()) then begin
                            repeat
                                if eodCheckListTempTable1.Status = 0 then begin
                                    Error('Please mark the status for all the tasks');
                                end;

                                eodMainTable.Init();
                                eodMainTable.SetFilter(StoreCode, Rec.Store_No);
                                eodMainTable.SetFilter(ID, Format(Rec.EOD_ID));
                                eodMainTable.SetFilter("Date/Time", Format(Rec.Date));
                                if eodMainTable.FindLast() then begin
                                    eodMainTable.ID := Rec.EOD_ID;
                                    eodMainTable."Date/Time" := Rec.Date;
                                    eodMainTable.StoreCode := Rec.Store_No;
                                    eodMainTable.ID := Rec.EOD_ID;
                                    eodMainTable.PostedStatus := true;
                                    eodMainTable.Remarks := '';

                                    eodMainTable.Modify();
                                end;


                                eodCheckListMainTable.Init();
                                eodCheckListTempTable.Init();
                                eodCheckListTempTable.SetFilter(Store_No, Rec.Store_No);
                                eodCheckListTempTable.SetFilter(Date, Format(Rec.Date));
                                eodCheckListTempTable.SetFilter(EOD_ID, Format(Rec.EOD_ID));
                                if eodCheckListTempTable.FindSet() then begin
                                    repeat
                                        eodCheckListMainTable.Store_No := eodCheckListTempTable.Store_No;
                                        eodCheckListMainTable.ID := eodCheckListTempTable.ID;
                                        eodCheckListMainTable.Date := eodCheckListTempTable.Date;
                                        eodCheckListMainTable.EOD_ID := Rec.EOD_ID;
                                        //eodCheckListMainTable.Status := Evaluate(status1, Format(Rec.Status));
                                        if (Rec.Status = 1) then begin
                                            eodCheckListMainTable.status := true;
                                        end;
                                        eodCheckListMainTable.Insert();

                                        eodCheckListTempTable.Delete();
                                    until eodCheckListTempTable.Next = 0;
                                end;
                            until eodCheckListTempTable1.Next = 0;

                            Message('EOD CheckList Posted Successfully');
                            CurrPage.Close();
                        end;
                    end;
                end;
            }
        }
    }

    trigger OnOpenPage()
    var
        eodTestTable: Record EODCheckListTempTable;
        eodMainPage: Page EODChecklist;
    begin
        eodTestTable.Init();
        //eodTestTable.SetFilter(eodTestTable.Date, Format(inputEODDate));
        inputEODDate := eodMainPage.GetInputDate();
        eodTestTable.SetFilter(eodTestTable.Date, Format(inputEODDate));
    end;

    // procedure SetInputEODDate(var inputDate: DateTime)
    // begin
    //     inputEODDate := inputDate;
    // end;

    var
        status: Option;
        inputEODDate: DateTime;
}
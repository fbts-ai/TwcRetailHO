report 50040 FTPReportDatewise
{
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = All;
    ProcessingOnly = true;

    dataset
    {
        dataitem(Integer; Integer)
        {
            DataItemTableView = SORTING(Number)
                                WHERE(Number = CONST(1));
            trigger OnAfterGetRecord()
            var
                myInt: Integer;
            begin
                FTPIntegration;
            end;

        }
    }

    requestpage
    {
        layout
        {
            area(Content)
            {
                group(GroupName)
                {
                    field(FromDate; FromDate)
                    {
                        Caption = 'From Date';
                        ApplicationArea = all;

                    }
                    field(ToDate; ToDate)
                    {
                        Caption = 'To Date';
                        ApplicationArea = all;
                    }
                }
            }
        }

        actions
        {
            area(processing)
            {
                action(ActionName)
                {
                    ApplicationArea = All;

                }
            }
        }
    }
    procedure FTPIntegration()
    var
        TempBlob: Codeunit "Temp Blob";
        InS: InStream;
        OutS: OutStream;
        FileName: Text;
        TxtBuilder: TextBuilder;
        EmailItem: Record "Email Item" temporary;
        Body: Text;
        TransSalesEntry: Record "LSC Trans. Sales Entry";
        Transpaymententry: Record "LSC Trans. Payment Entry";
        Tendertype: Record "LSC Tender Type";
        Type: Text;
        Item: Record Item;
        TransactionHeaderFirst: Record "LSC Transaction Header";
        TransactionHeaderlast: Record "LSC Transaction Header";
        TransactionHeader: Record "LSC Transaction Header";
        TenderAmt: Decimal;
        RefundReceiptNo: Text;
        Training: text;
        GenLedSetup: Record "General Ledger Setup";
        FileVersion: text;
        TransactionHeaderVAl: Record "LSC Transaction Header";
        store: Record "LSC Store";
        TransactionType: text;
        Description: text[15];
    begin

        TransactionHeaderVAl.SetRange(Date, FromDate);
        TransactionHeaderVAl.SetFilter("Transaction Type", '%1', TransactionHeaderVAL."Transaction Type"::Sales);
        if TransactionHeaderVAl.FindFirst() then begin
            if store.Get(TransactionHeaderVAl."Store No.") then
                if store."FTP Integration" = true then begin
                    GenLedSetup.get;
                    GenLedSetup.Sno := GenLedSetup.Sno + 1;
                    if GenLedSetup.Sno = 9999 then
                        GenLedSetup.Sno := 0;
                    GenLedSetup.Modify();

                    if GenLedSetup.Sno > 9999 then
                        FileVersion := Format(GenLedSetup.Sno)
                    else
                        if GenLedSetup.Sno > 99 then
                            FileVersion := '0' + Format(GenLedSetup.Sno);
                    if GenLedSetup.Sno > 9 then
                        FileVersion := '00' + Format(GenLedSetup.Sno)
                    else
                        FileVersion := '000' + Format(GenLedSetup.Sno);
                    if GenLedSetup.Sno > 99 then
                        FileVersion := '0' + Format(GenLedSetup.Sno);
                    if GenLedSetup.Sno > 999 then
                        FileVersion := Format(GenLedSetup.Sno);

                    TransactionHeaderFirst.SetRange(Date, FromDate, ToDate);
                    TransactionHeaderFirst.SetFilter("Transaction Type", '%1', TransactionHeaderFirst."Transaction Type"::Sales);
                    if TransactionHeaderFirst.FindFirst() then begin
                        FileName := 't' + Store.TENANT_NO + '_' + TransactionHeaderFirst."Store No." + '_' + FileVersion + '_' + Format(CurrentDateTime, 6, '<Year><Month,2><Day,2>') + '.txt';
                        TxtBuilder.AppendLine('1' + '|' + 'OPENED' + '|' + store.TENANT_NO + '|' + TransactionHeaderFirst."Store No." + '|' + CopyStr(TransactionHeaderFirst."Receipt No.", 5, 20) + '|' + FileVersion + '|' + Format(Today, 8, '<Year4><Month,2><Day,2>') + '|' + Format(Time, 0, '<Hours24>:<Minutes,2>:<Seconds,2>') + '|' + TransactionHeaderFirst."Staff ID" + '|' + Format(TransactionHeaderFirst.Date, 8, '<Year4><Month,2><Day,2>'));
                    end;
                    // with TransactionHeader do begin
                    TransactionHeader.SetRange(Date, FromDate, ToDate);
                    TransactionHeader.SetFilter("Transaction Type", '%1', TransactionHeader."Transaction Type"::Sales);
                    if TransactionHeader.FindSet() then
                        repeat
                            // TransactionHeader.SetFilter(Date, '%1..%2',20240101D, Today);
                            //For101
                            if TransactionHeader."Refund Receipt No." = '' then
                                RefundReceiptNo := 'NULL'
                            else
                                RefundReceiptNo := TransactionHeader."Refund Receipt No.";
                            if TransactionHeader."Entry Status" = TransactionHeader."Entry Status"::Training then
                                Training := 'Y'
                            else
                                Training := 'N';
                            if TransactionHeader."Transaction Type" = TransactionHeader."Transaction Type"::Sales then
                                TransactionType := CopyStr(Format(TransactionHeader."Transaction Type"), 1, 4);
                            TxtBuilder.AppendLine('101' + '|' + CopyStr(TransactionHeader."Receipt No.", 5, 20) + '|' + '1' + '|' + Format(TransactionHeader.Date, 8, '<Year4><Month,2><Day,2>') + '|' + Format(TransactionHeader.Time, 0, '<Hours24>:<Minutes,2>:<Seconds,2>') + '|' + TransactionHeader."Staff ID" + '|' + '' + '|' + '' + '|' + '' + '|' + 'POSUSER' + '|' + Format(TransactionHeader."Table No.") + '|' + '' + '|' + Training + '|' + UpperCase(TransactionType));
                            //For111
                            TransSalesEntry.SetRange("Receipt No.", TransactionHeader."Receipt No.");
                            if TransSalesEntry.FindSet() then
                                repeat
                                    if Item.get(TransSalesEntry."Item No.") then;

                                    TxtBuilder.AppendLine('111' + '|' + Format(TransSalesEntry."Item No.") + '|' + Format(-1 * TransSalesEntry.Quantity) + '|' + DelChr((Format(TransSalesEntry.Price)), '=', ',') + '|' + Format(-1 * TransSalesEntry."Net Amount") + '|' + '' + '|' + 'GST' + '|' + '' + '|' + DelChr(Format(TransSalesEntry."Discount Amount"), '=', ',') + '|' + Format(Item."LSC Division Code") + '|' + Format(Item."Item Category Code") + '|' + '' + '|' + 'N' + '|' + Format(-1 * TransSalesEntry."Net Amount") + '|' + '' + '|' + '%' + '|' + Format(-1 * TransSalesEntry."LSCIN GST Amount") + '|' + '');
                                until TransSalesEntry.Next() = 0;
                            //For121
                            TxtBuilder.AppendLine('121' + '|' + DelChr(Format(-1 * TransactionHeader."Net Amount"), '=', ',') + '|' + DelChr(Format(TransactionHeader."Discount Amount"), '=', ',') + '|' + '' + '|' + '' + '|' + Format(-1 * TransactionHeader."LSCIN GST Amount") + '|' + 'E' + '|' + 'N' + '|' + '' + '|' + '' + '|' + '' + '|' + Format(TransactionHeader.Rounded));
                            //For131
                            Transpaymententry.SetRange("Receipt No.", TransactionHeader."Receipt No.");
                            if Transpaymententry.FindSet() then
                                repeat
                                    if Transpaymententry."Change Line" = true then begin
                                        Type := 'C';
                                        TenderAmt := ABS(Transpaymententry."Amount Tendered");
                                    end
                                    else begin
                                        TenderAmt := ABS(Transpaymententry."Amount Tendered");
                                        Type := 'T';
                                    end;

                                    Tendertype.SetRange(Code, Transpaymententry."Tender Type");
                                    if Tendertype.FindFirst() then;
                                    Description := CopyStr(Tendertype.Description, 1, MaxStrLen(Description));
                                    TxtBuilder.AppendLine('131' + '|' + TYPE + '|' + Format(Description) + '|' + 'INR' + '|' + '1' + '|' + DelChr(Format(TenderAmt), '=', ',') + '|' + '' + '|' + '' + '|' + DelChr(Format(TenderAmt), '=', ','));
                                until Transpaymententry.Next() = 0;
                        until TransactionHeader.next = 0;
                    //end;
                    //For1_CLOSED
                    //TransactionHeaderlast.SetRange("Store No.", TransactionHeader."Store No.");
                    TransactionHeaderlast.SetRange(Date, FromDate, ToDate);
                    TransactionHeaderlast.SetFilter("Transaction Type", '%1', TransactionHeaderLast."Transaction Type"::Sales);
                    if TransactionHeaderlast.FindLast() then begin
                        TxtBuilder.AppendLine('1' + '|' + 'CLOSED' + '|' + Store.TENANT_NO + '|' + TransactionHeaderlast."Store No." + '|' + CopyStr(TransactionHeaderlast."Receipt No.", 5, 20) + '|' + FileVersion + '|' + Format(Today, 8, '<Year4><Month,2><Day,2>') + '|' + Format(Time, 0, '<Hours24>:<Minutes,2>:<Seconds,2>') + '|' + 'POSUSER' + '|' + Format(TransactionHeaderlast.Date, 8, '<Year4><Month,2><Day,2>'));
                    end;
                    TempBlob.CreateOutStream(OutS);
                    OutS.WriteText(TxtBuilder.ToText());
                    TempBlob.CreateInStream(InS);
                    //For Send download
                    // DownloadFromStream(InS, '', '', '', FileName);
                    //For  Send Email
                    EmailItem."Send to" := store."TO E-mail";
                    EmailItem."Send CC" := store."CC E-mail";
                    EmailItem.Subject := Store."E-mail Subject" + Format(FromDate, 10, '<Day,2>/<Month,2>/<Year4>');
                    EmailItem.Validate("Plaintext Formatted", false);
                    Body := '<font face="arial" size ="2">' +
                                                   '<b><font face="arial" size="2" color="#1E90FF">  Kind Attention : ' + '</font></b>' + '<br>' +
                                       '<br>' + 'Dear Sir/Madam,' + '</br>' +
                                               '<br>' + 'Please find attached the ADSR file -' + '</br>' + '<br></font>' +
                                        '<br>' + '<b>' + 'Thanks,' + '</b>' + '</br>' +
                                                   '<b>' + 'Heisetasse Beverages Private Limited Bangalore, India' + '</b>' + '<br>' +
                                                   '<b>' + 'www.thirdwavecoffeeroasters.com' + '</b>' + '</br>' +
                                       '<br>' +
                                       '<b><b>' + '<br>' + '*This is a system generated mail from Microsoft Dynamics Business Central' + '</b></b>' + '</br>' + '</br>' + '<br>' + '</br>';
                    EmailItem.SetBodyText(Format(Body));
                    EmailItem.AddAttachment(InS, FileName);
                    EmailItem.Send(true, Enum::"Email Scenario"::Default);
                    Message('Email has been sent.');
                end;
        end;
    end;




    var
        myInt: Integer;
        FromDate: Date;
        ToDate: Date;
}
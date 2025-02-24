codeunit 50036 JobQueueStatusChangeCodeunit
{
    trigger OnRun()

    var
        TempJobQueueEntry: Record "Job Queue Entry";
        EmailCodeunit: Codeunit Email;
        Tempblob: Codeunit "Temp Blob";
        IsStream: InStream;
        OStream: OutStream;
        UserSetup: Record "User Setup";
        EmailMessage: Codeunit "Email Message";
        currentuser: Record "User Setup";
        MessageBody: Text;
        MailList: List of [text];
        RequestRunPage: text;

        RecRef: RecordRef;
        Subject: Text;

        parma: Text;
        RetailSetup: Record "LSC Retail Setup";
        TempTWCConfiguration: Record "TWC Configuration";
        TempStore: Record "LSC Store";
    begin
        //RetailSetup.get();
        TempJobQueueEntry.Reset();
        TempJobQueueEntry.SetRange(TempJobQueueEntry."Object ID to Run", 50014);
        TempJobQueueEntry.SetRange(TempJobQueueEntry."Object Type to Run", TempJobQueueEntry."Object Type to Run"::Codeunit);
        IF TempJobQueueEntry.FindFirst() then begin
            IF ((TempJobQueueEntry.Status <> TempJobQueueEntry.Status::Ready) and (TempJobQueueEntry.Status <> TempJobQueueEntry.Status::"In Process")) then begin
                // TempJobQueueEntry.Status := TempJobQueueEntry.Status::Ready;
                // TempJobQueueEntry.Modify();
                TempJobQueueEntry.SetStatus(TempJobQueueEntry.Status::Ready);
                /*
                //RetailSetup.TestField(RetailSetup.JobQueueNotification);
                TempTWCConfiguration.Reset();
                TempTWCConfiguration.SetRange(Key_, 'UP');
                TempTWCConfiguration.SetRange(Name, 'STORE_ID');
                IF TempTWCConfiguration.FindFirst() then;

                IF TempTWCConfiguration.Value_ <> '' then begin
                    IF TempStore.Get(TempTWCConfiguration.Value_) then;

                end;



                //MailList.Add('mahendra.patil@in.ey.com');
                Subject := 'Job Queue Failure - Store No. ' + TempStore."No.";
                MessageBody := 'Dear Team, ' + '<br><br>' + 'The Job Queue scheduler has been stopped for Store No. ' + TempStore."No." + ' Kinldy report the same to your system administrator if issue persists' + '<br><br>' + 'Regards' + '<br><br>' + 'IT - Team.';

                // Tempblob.CreateOutStream(OStream);

                // Report.SaveAs(Report::"Sub-Indent PO List", SubIndentPO1."PO NO.", ReportFormat::Pdf, OStream);
                //  Tempblob.CreateInStream(IsStream);

                EmailMessage.Create(TempStore.UPJobNotification, Subject, MessageBody, true);
                //   EmailMessage.AddAttachment('Indent Purchase Order.pdf', 'PDF', IsStream);
                EmailCodeunit.Send(EmailMessage);
                */

            end;
        end;

        TempJobQueueEntry.Reset();
        TempJobQueueEntry.SetRange(TempJobQueueEntry."Object ID to Run", 50015);
        TempJobQueueEntry.SetRange(TempJobQueueEntry."Object Type to Run", TempJobQueueEntry."Object Type to Run"::Codeunit);
        IF TempJobQueueEntry.FindFirst() then begin
            IF ((TempJobQueueEntry.Status <> TempJobQueueEntry.Status::Ready) and (TempJobQueueEntry.Status <> TempJobQueueEntry.Status::"In Process")) then begin
                // TempJobQueueEntry.Status := TempJobQueueEntry.Status::Ready;
                // TempJobQueueEntry.Modify();
                TempJobQueueEntry.SetStatus(TempJobQueueEntry.Status::Ready);

                /*
                //RetailSetup.TestField(RetailSetup.JobQueueNotification);
                TempTWCConfiguration.Reset();
                TempTWCConfiguration.SetRange(Key_, 'UP');
                TempTWCConfiguration.SetRange(Name, 'STORE_ID');
                IF TempTWCConfiguration.FindFirst() then;

                IF TempTWCConfiguration.Value_ <> '' then begin
                    IF TempStore.Get(TempTWCConfiguration.Value_) then;

                end;



                //MailList.Add('mahendra.patil@in.ey.com');
                Subject := 'Job Queue Failure - Store No. ' + TempStore."No.";
                MessageBody := 'Dear Team, ' + '<br><br>' + 'The Job Queue scheduler has been stopped for Store No. ' + TempStore."No." + ' Kinldy report the same to your system administrator if issue persists' + '<br><br>' + 'Regards' + '<br><br>' + 'IT - Team.';

                // Tempblob.CreateOutStream(OStream);

                // Report.SaveAs(Report::"Sub-Indent PO List", SubIndentPO1."PO NO.", ReportFormat::Pdf, OStream);
                //  Tempblob.CreateInStream(IsStream);

                EmailMessage.Create(TempStore.UPJobNotification, Subject, MessageBody, true);
                //   EmailMessage.AddAttachment('Indent Purchase Order.pdf', 'PDF', IsStream);
                EmailCodeunit.Send(EmailMessage);
                */

            end;
        end;
    end;

    var
        myInt: Integer;
}
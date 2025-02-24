pageextension 50105 CustomerListExt extends "Customer List"
{
    layout
    {
        // Add changes to page layout here
    }

    actions
    {
        // Add changes to page actions here
        addafter("&Customer")
        {
            action("Process Order")
            {
                ApplicationArea = All;
                PromotedCategory = Process;
                Promoted = true;
                Image = Process;
                trigger OnAction()
                var
                    Orderforsinglestore: Codeunit "UPQProcessOrderforSingle store";
                begin

                    Orderforsinglestore.Run();
                    Message('Done');
                end;
            }
            action("FTP Integration")
            {
                ApplicationArea = All;
                PromotedCategory = Process;
                Promoted = true;
                Image = Process;
                trigger OnAction()
                var
                    Orderforsinglestore: Codeunit "FTP Integration";

                begin

                    Orderforsinglestore.FTPIntegration();
                    Message('Done');
                end;
            }
            action("FTP Integration Report")
            {
                ApplicationArea = All;
                PromotedCategory = Process;
                Promoted = true;
                Image = Process;
                trigger OnAction()
                var
                    Orderforsinglestore: Codeunit "FTP Integration";
                    timr: Time;

                begin

                    // Orderforsinglestore.FTPIntegration();
                    Report.Run(50040);
                    // Timr := 000000T;

                    // Message(Format(Timr));
                    // Message(Format(Time - 1800000));
                end;
            }
        }
    }

    var
        myInt: Integer;
}
table 50021 "Bank Drop Denomination Temp"
{
    Caption = 'Bank Drop Denomination Temp';

    fields
    {
        field(1; "Tender Type"; Code[10])
        {
            Caption = 'Tender Type';
            TableRelation = "LSC Tender Type".Code;
            DataClassification = CustomerContent;
        }

        field(2; "Currency Code"; Code[10])
        {
            Caption = 'Currency Code';
            DataClassification = CustomerContent;
        }
        field(3; Type; Option)
        {
            Caption = 'Type';
            OptionCaption = 'Coin,Note,Roll,Total';
            OptionMembers = Coin,Note,Roll,Total;
            DataClassification = CustomerContent;
        }
        field(5; Amount; Decimal)
        {
            Caption = 'Amount';
            DataClassification = CustomerContent;
        }

        field(6; "Qty."; Integer)
        {
            Caption = 'Qty.';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                Total := Amount * "Qty.";
                // if Rec.FindFirst() then begin
                //     repeat
                //         TotalDenomination := Total + TotalDenomination;
                //     until Rec.Next = 0;
                // end;
            end;

        }

        field(7; "Date/Time"; DateTime)
        {
            Caption = 'Date/Time';
            DataClassification = CustomerContent;

            trigger OnLookup()
            begin
                Validate("Date/Time", LookupDateTime("Date/Time"));
            end;

        }

        field(8; Total; Decimal)
        {
            Caption = 'Total';
            DataClassification = CustomerContent;
        }

        field(14; TotalDenomination; Decimal)
        {
            Caption = 'TotalDenomination';
            DataClassification = CustomerContent;
        }

        field(9; Description; Text[30])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }

        field(10; Store_No; Text[30])
        {
            Caption = 'Store_No';
            DataClassification = CustomerContent;
            trigger OnValidate()
            var
                cuPOSSession: Codeunit "LSC POS Session";

            begin
                if not (cuPOSSession.StoreNo() = '') then begin
                    Store_No := cuPOSSession.StoreNo();
                end;
            end;
        }

        field(11; ID; Integer)
        {
            AutoIncrement = true;
        }

        field(12; Terminal_No; Text[30])
        {
            Caption = 'Terminal_No';
            DataClassification = CustomerContent;
        }

        field(13; Staff_ID; Text[30])
        {

        }

        field(15; BankDropID; Integer)
        {
            TableRelation = "Bank Drop Main".ID;
        }
    }

    keys
    {
        key(Key1; ID)
        {
            Clustered = true;
            SumIndexFields = Total, TotalDenomination;
        }
    }

    procedure LookupDateTime(InitialValue: DateTime): DateTime
    var
        DateTimeDialog: Page "Date-Time Dialog";
        NewValue: DateTime;
    begin
        DateTimeDialog.SetDateTime(InitialValue);

        if DateTimeDialog.RunModal() = Action::OK then
            NewValue := DateTimeDialog.GetDateTime();

        exit(NewValue);
    end;

    trigger OnModify()
    begin
        // Rec.TotalDenomination := Rec.Total + Rec.TotalDenomination;
    end;
    // begin
    //     if Rec.FindFirst() then begin
    //         repeat
    //             Rec.TotalDenomination := Rec.Total + Rec.TotalDenomination;
    //         until Rec.Next = 0;
    //     end;
    // end;

    var
        CashDeclaration: Record "Bank Drop Denomination Temp";
        CashDeclaration2: Record "Bank Drop Denomination Temp";
        GrandTotal: Decimal;
}


table 50015 PineLabTransactiondetails
{
    DataClassification = ToBeClassified;

    fields
    {

        field(1; "PlutusRefID"; Integer)
        {
            Caption = 'PlutusTransactionReferenceID';
            DataClassification = CustomerContent;
        }
        field(2; "Receipt No."; Code[20])
        {
            Caption = 'Receipt No.';
            DataClassification = CustomerContent;
        }
        field(3; "Store No."; Code[10])
        {
            Caption = 'Store No.';
            TableRelation = "LSC Store"."No.";
            DataClassification = CustomerContent;
        }
        field(4; "POS Terminal No."; Code[10])
        {
            Caption = 'POS Terminal No.';
            TableRelation = "LSC POS Terminal"."No.";
            ValidateTableRelation = false;
            DataClassification = CustomerContent;
        }
        field(5; "Trans. Date"; Date)
        {
            Caption = 'Trans. Date';
            DataClassification = CustomerContent;
        }
        field(6; "Original Date"; Date)
        {
            Caption = 'Original Date';
            DataClassification = CustomerContent;
        }
        field(7; "Trans Time"; Time)
        {
            Caption = 'Trans. Time';
            DataClassification = CustomerContent;
        }
        field(8; UploaTransactionStatus; text[20])
        {
            Caption = 'UploaTransactionStatus';
            DataClassification = CustomerContent;
        }
        field(9; UploadTransactionRequest; Text[2048])
        {
            Caption = 'UploadTransactionRequest';
            DataClassification = CustomerContent;
        }
        field(10; TransactionStatus; text[100])
        {
            Caption = 'TransactionStatus';
            DataClassification = CustomerContent;
        }
        field(11; "Line No."; Integer)
        {
            Caption = 'Line No.';
            DataClassification = CustomerContent;
        }
        field(12; CurrentTransaction; Boolean)
        {
            Caption = 'CurrentTransaction';
            DataClassification = CustomerContent;
        }
        field(13; AllowedPaymentMode; Text[10])
        {
            Caption = 'AllowedPaymentMode';
            DataClassification = CustomerContent;
        }
        field(14; TransactionStatusRequest; Text[2048])
        {
            Caption = 'TransactionStatusRequest';
            DataClassification = CustomerContent;
        }
        field(15; TID; Integer)
        {
            Caption = 'TID';
            DataClassification = CustomerContent;
        }
        field(16; PaymentMode; Code[20])
        {
            Caption = 'PaymentMode';
            DataClassification = CustomerContent;
        }
        field(17; Amount; Decimal)
        {
            Caption = 'Amount';
            DataClassification = CustomerContent;
        }
        field(18; BatchNumber; Code[20])
        {
            Caption = 'BatchNumber';
            DataClassification = CustomerContent;
        }
        field(19; RRN; Code[20])
        {
            Caption = 'RRN';
            DataClassification = CustomerContent;
        }
        field(20; InvoiceNumber; Code[20])
        {
            Caption = 'Invoice Number';
            DataClassification = CustomerContent;
        }
        field(21; CardNumber; Code[20])
        {
            Caption = 'Card Number';
            DataClassification = CustomerContent;
        }
        field(22; CardType; Code[20])
        {
            Caption = 'Card Type';
            DataClassification = CustomerContent;
        }
        field(23; AmountUploadedFortrans; Decimal)
        {
            Caption = 'Amount Uploaded';
            DataClassification = CustomerContent;
        }
        field(24; ApproveAmount; Decimal)
        {
            Caption = 'ApproveAmount';
            DataClassification = CustomerContent;
        }
        field(25; cardholdername; text[100])
        {
            Caption = 'cardholdername';
            DataClassification = CustomerContent;
        }
        field(26; txnstatusresponse; text[2048])
        {
            Caption = 'txnstatusresponse';
            DataClassification = CustomerContent;
        }

        field(27; AcquirerId; text[10])
        {
            Caption = 'AcquirerId';
            DataClassification = CustomerContent;
        }
        field(28; AcquirerName; text[50])
        {
            Caption = 'AcquirerName';
            DataClassification = CustomerContent;
        }

        field(29; TransactionDate; Date)
        {
            Caption = 'TransactionDate';
            DataClassification = CustomerContent;
        }
        field(30; Transactiontime; Time)
        {
            Caption = 'Transactiontime';
            DataClassification = CustomerContent;
        }
        field(31; AmountInPaisa; Decimal)
        {
            Caption = 'AmountInPaisa';
            DataClassification = CustomerContent;
        }
        field(32; OriginalAmount; Decimal)
        {
            Caption = 'OriginalAmount';
            DataClassification = CustomerContent;
        }
        field(33; FinalAmount; Decimal)
        {
            Caption = 'FinalAmount';
            DataClassification = CustomerContent;
        }
        field(34; SequenceNumber; Integer)
        {
            Caption = 'Sequence Number';
        }

        field(35; SaleReturnPlutusRefNo; Integer)
        {
            Caption = 'SaleReturnPlutusRefNo';
        }
        field(36; SalesReturnTransactionStatus; Text[100])
        {
            Caption = 'Sales Return Transaction Status';
        }
        field(37; SalesReturnPaymentMode; Code[20])
        {
            Caption = 'SalesReturnPaymentMode';
        }
        field(38; SalesReturnReceiptNo; Code[20])
        {
            Caption = 'SalesReturnReceiptNo';
        }
        field(39; SalesReturnUploaTransStatus; text[20])
        {
            Caption = 'SalesReturnUploaTransStatus';
            DataClassification = CustomerContent;
        }
        field(40; TenderTypeCodeID; Code[20])
        {
            Caption = 'TenderTypeCodeID';
            DataClassification = CustomerContent;
        }
        field(41; "Replication Counter"; Integer)
        {
            Caption = 'Replication Counter';
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                TempPinelabDetails: Record PineLabTransactiondetails;
            begin
                //if not ClientSessionUtility.UpdateReplicationCountersForTable(RecordId, "Replication Counter") then
                //    exit;
                TempPinelabDetails.SetCurrentKey("Replication Counter");
                if TempPinelabDetails.FindLast then
                    "Replication Counter" := TempPinelabDetails."Replication Counter" + 1
                else
                    "Replication Counter" := 1;
            end;
        }





    }

    keys
    {
        key(Key1; PlutusRefID, "Receipt No.", "Store No.", "POS Terminal No.")
        {
            Clustered = true;
        }
        key(Key2; "Replication Counter")
        {
        }
    }

    var
        myInt: Integer;

    trigger OnInsert()
    begin
        Validate("Replication Counter");
    end;

    trigger OnModify()
    begin
        Validate("Replication Counter");
    end;

    trigger OnDelete()
    begin

    end;

    trigger OnRename()
    begin

    end;

}
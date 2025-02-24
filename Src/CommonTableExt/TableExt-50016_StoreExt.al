tableextension 50016 "Store Card Ext" extends "LSC Store"
{
    fields
    {
        field(50003; "External Identity"; integer)
        { }

        //Mahendra
        field(50004; TwcStoreCode; Code[20])
        {

        }
        field(50005; "TWC Store Category"; Code[20])
        {
            Caption = 'TWC Store Category';
        }
        field(50006; "TWC Store Type"; Code[20])
        {
            Caption = 'TWC Store Type';
        }
        field(50007; "Agave Store ID"; Code[10])
        {
        }
        field(50010; UPJobNotification; Text[100])
        {
            Caption = 'UP Job Queue Notification';
        }
        //
        field(50241; "Event Store"; Boolean)
        {
            DataClassification = CustomerContent;
        }
        //Urban piper
        field(51000; DisablePackagingBom; Boolean)
        {
            Caption = 'Disable Packaging BOM';
        }
        field(51001; "FTP Integration"; Boolean)
        {
            Caption = 'FTP Integration';
        }//ALLE_NICK_020224
        field(51002; "TO E-mail"; Text[500])
        {

        }//ALLE_NICK_020224
        field(51003; "CC E-mail"; Text[500])
        {

        }//ALLE_NICK_020224
        field(51004; "E-mail Subject"; Text[500])
        {

        }//ALLE_NICK_020224
        field(51005; "TENANT_NO"; code[20])
        {
            DataClassification = ToBeClassified;
        }

    }
    var
        test: codeunit "LSC POS Transaction";
}
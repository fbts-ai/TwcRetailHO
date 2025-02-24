pageextension 50017 "Store Card Ext" extends "LSC Store Card"
{
    layout
    {
        addlast(General)
        {
            group("Event Store")
            {
                field("Is Event Store"; Rec."Event Store")
                {
                    ApplicationArea = All;
                }
            }
            group(Urbanpiper)
            {
                Caption = 'Delivery/Pickup';
                field(DisablePackagingBom; Rec.DisablePackagingBom) { }
            }
            field("External Identity"; rec."External Identity")
            {
                ApplicationArea = all;
            }
            field(TwcStoreCode; Rec.TwcStoreCode)
            {
                Caption = 'Twc Store Code';
            }
            field(TwcStoreCode1; rec."TWC Store Category")
            {
                //  Caption = 'Twc Store Code1';
            }
            field(TwcStoreCode2; Rec."TWC Store Type")
            {
                // Caption = 'Twc Store Code2';
            }
            field("Agave Store ID"; rec."Agave Store ID")
            {
                ApplicationArea = all;
            }
            field(UPJobNotification; Rec.UPJobNotification)
            {
                ApplicationArea = all;
                Caption = 'UP Job Queue Notification';
            }
        }
        //ALLE_NICK_020224
        addafter(Numbering)
        {
            group("ADSR Setup")
            {
                field("FTP Integration"; "FTP Integration")
                {
                    ApplicationArea = all;
                }
                field(TENANT_NO; TENANT_NO)
                {
                    ApplicationArea = all;
                    Caption = 'TENANT ID';
                }
                field("TO E-mail"; "TO E-mail")
                {
                    ApplicationArea = all;
                }
                field("CC E-mail"; "CC E-mail")
                {
                    ApplicationArea = all;
                }
                field("E-mail Subject"; "E-mail Subject")
                {
                    ApplicationArea = all;
                }
            }
        }
    }
}
pageextension 50061 PinelabtendertypesExt extends "LSC Tender Type Setup List"
{
    layout
    {
        // Add changes to page layout here
        addafter("Default Function")
        {
            field(PinelabCard; Rec.PinelabCard)
            {
                trigger OnValidate()
                var
                    TemptenderType: Record "LSC Tender Type Setup";
                begin
                    TemptenderType.Reset();
                    TemptenderType.SetRange(PinelabCard, true);
                    IF TemptenderType.FindFirst() then
                        Error('Only one pinelab card tender allow per company');
                end;

            }
            field(PineLabGiftCard; Rec.PineLabGiftCard)
            {
                trigger OnValidate()
                var
                    TemptenderType: Record "LSC Tender Type Setup";
                begin
                    TemptenderType.Reset();
                    TemptenderType.SetRange(PineLabGiftCard, true);
                    IF TemptenderType.FindFirst() then
                        Error('Only one pinelab gift card tender allow per company');
                end;
            }
            field(PineLabUPI; Rec.PineLabUPI)
            {
                trigger OnValidate()
                var
                    TemptenderType: Record "LSC Tender Type Setup";
                begin
                    TemptenderType.Reset();
                    TemptenderType.SetRange(PineLabUPI, true);
                    IF TemptenderType.FindFirst() then
                        Error('Only one pinelab UPI tender allow per company');
                end;
            }
            field(PineLabPaymentTender; rec.PineLabPaymentTender)
            {
                trigger OnValidate()
                var
                    TemptenderType: Record "LSC Tender Type Setup";
                begin
                    TemptenderType.Reset();
                    TemptenderType.SetRange(PineLabPaymentTender, true);
                    IF TemptenderType.FindFirst() then
                        Error('Only one PineLab PaymentTender tender allow per company');
                end;
            }
            field(PineLabReturn; rec.PineLabReturn)
            {
                trigger OnValidate()
                var
                    TemptenderType: Record "LSC Tender Type Setup";
                begin
                    TemptenderType.Reset();
                    TemptenderType.SetRange(PineLabReturn, true);
                    IF TemptenderType.FindFirst() then
                        Error('Only one  PineLab Return tender allow per company');
                end;
            }
        }
    }

    actions
    {
        // Add changes to page actions here
    }

    var
        myInt: Integer;
}
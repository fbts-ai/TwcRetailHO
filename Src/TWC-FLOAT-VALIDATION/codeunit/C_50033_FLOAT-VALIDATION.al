codeunit 50033 "Float Validation"
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC Tender Declaration", 'OnBeforePostTransaction', '', false, false)]
    local procedure OnBeforePostTransaction(PosTransaction: Record "LSC POS Transaction"; var ReturnValue: Boolean; var IsHandled: Boolean)
    var
        cashdecl: record "LSC POS Cash Declaration";
        floatconfig: query "Float Configuration";
        minamountstr: text;
        minamount: decimal;
    begin
        cashdecl.SetFilter("Receipt No.", PosTransaction."Receipt No.");
        if cashdecl.FindFirst() then begin
            if (PosTransaction."Transaction Type" = PosTransaction."Transaction Type"::"Float Entry")
            and (cashdecl."Tender Type" = '1') then begin
                floatconfig.Open();
                if (floatconfig.Read()) then begin

                    minamountstr := floatconfig.MinFloatValue;
                    Evaluate(minamount, floatconfig.MinFloatValue);

                    if (cashdecl.Amount < minamount)
                        and (floatconfig.FeatureEnabled = 'TRUE')
                     then begin
                        floatconfig.close();
                        Error('Float cannot be less than ' + Format(minamount));
                        IsHandled := true;
                    end;
                end;
                floatconfig.close();
            end;
        end;
    end;

}
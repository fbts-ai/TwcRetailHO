Table 60031 "FreeItem Offer Header"
{
    fields
    {
        field(1; "Offer No."; Code[20])
        {

        }
        field(2; "Offer Description"; Text[100])
        {

        }
        field(3; Status; Option)
        {
            OptionMembers = Disabled,Enabled;
        }
        field(4; "Validation Period ID"; Code[10])
        {
            TableRelation = "LSC Validation Period".ID;
        }
        field(5; "Validation Description"; Text[30])
        {
            FieldClass = FlowField;
            CalcFormula = Lookup("LSC Validation Period".Description WHERE(ID = FIELD("Validation Period ID")));
            Editable = false;
        }
        field(6; "Amount to Trigger"; Decimal)
        {

        }
        field(7; "Offer Applicable of N/G"; option)
        {
            OptionMembers = "Net Amount","Gross Amount";
        }
        field(8; "Sales Type filter"; code[250])
        {
            TableRelation = "LSC Sales Type".Code;
            ValidateTableRelation = false;

        }
        field(9; "DiscountOffer"; Boolean)
        {

        }
        field(10; "Tender Type"; Code[10])
        {
            TableRelation = "LSC Tender Type Setup";
        }
        field(11; CustomerNo; Code[20])
        {
            TableRelation = Customer;
        }
        field(12; "Discount %"; Decimal)
        {

        }
    }

    keys
    {
        key(Key1; "Offer No.")
        {
            Clustered = true;
        }
    }
    procedure ToggleEnabled()
    begin

        IF Status = Status::Disabled THEN
            Status := Status::Enabled
        ELSE
            Status := Status::Disabled;
    end;

}


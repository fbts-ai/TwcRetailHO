query 50005 "Float Configuration"
{
    QueryType = Normal;

    elements
    {
        dataitem(FLOAT_VALIDATION_ENABLED; "TWC Configuration")
        {
            column(FeatureEnabled; Value_)
            {
                Caption = 'Float Validaiton Enabled';
            }

            filter(Key_; Key_)
            {
                ColumnFilter = Key_ = const('FLOAT_VALIDATION');
            }

            filter(Name; Name)
            {
                ColumnFilter = Name = const('ENABLE_FEATURE');
            }

            dataitem(FloatMinAmount; "TWC Configuration")
            {
                DataItemLink = key_ = FLOAT_VALIDATION_ENABLED.Key_;

                filter(FloatValueName; Name)
                {
                    ColumnFilter = FloatValueName = const('FLOAT_MIN_AMOUNT');
                }

                column(MinFloatValue; Value_)
                {
                    Caption = 'Min Float Value';
                }
            }
        }
    }

    var
        myInt: Integer;

    trigger OnBeforeOpen()
    begin

    end;
}
query 50003 "Shift Configuration"
{
    QueryType = Normal;

    elements
    {
        dataitem(SHIFT_VALIDATION_ENABLED; "TWC Configuration")
        {
            column(FeatureEnabled; Value_)
            {
                Caption = 'Shift Validation Enabled';
            }

            filter(Key_; Key_)
            {
                ColumnFilter = Key_ = const('SHIFT_VALIDATION');
            }

            filter(Name; Name)
            {
                ColumnFilter = Name = const('ENABLE_FEATURE');
            }

            dataitem(EOD_Validation_Enabled; "TWC Configuration")
            {
                DataItemLink = key_ = SHIFT_VALIDATION_ENABLED.Key_;


                filter(ShiftValueName; Name)
                {
                    ColumnFilter = ShiftValueName = const('EOD_VALIDATION');
                }

                column(EODValidation; Value_)
                {
                    Caption = 'EOD Validation';
                }

                dataitem(Store_Hours_Validation; "TWC Configuration")
                {
                    DataItemLink = key_ = SHIFT_VALIDATION_ENABLED.Key_;

                    filter(StoreHoursName; Name)
                    {
                        ColumnFilter = StoreHoursName = const('STORE_HOURS_VALIDATION');
                    }

                    column(StoreHoursValidationValue; Value_)
                    {
                        Caption = 'Store Hours Validation';
                    }

                    dataitem(SOD_Validation; "TWC Configuration")
                    {
                        DataItemLink = key_ = SHIFT_VALIDATION_ENABLED.Key_;

                        filter(SODName; Name)
                        {
                            ColumnFilter = SODName = const('SOD_VALIDATION');
                        }

                        column(SODValue; Value_)
                        {
                            Caption = 'SOD Validation';
                        }
                    }
                }
            }
        }
    }
}
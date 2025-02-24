query 50001 "Bank Drop Denomination"
{
    QueryType = Normal;
    Caption = 'Bank Drop Denomination';



    elements
    {
        dataitem(LSC_Cash_Declaration_Setup; "LSC Cash Declaration Setup")
        {

            column(SystemId; SystemId)
            {

            }

            column(Tender_Type; "Tender Type")
            {

            }

            column(Currency_Code; "Currency Code")
            {

            }

            column(Type; Type)
            {

            }

            column(Amount; Amount)
            {

            }

            column(Description; Description)
            {

            }

            column(Store_No_; "Store No.")
            {

                //ColumnFilter = Store_No_ = filter('S0003');
            }
        }
    }

}

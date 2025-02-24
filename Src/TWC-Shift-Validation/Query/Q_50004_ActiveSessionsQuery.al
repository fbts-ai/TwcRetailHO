query 50004 "ActiveManagerShiftQuery"
{
    QueryType = Normal;
    Caption = 'Active Shifts';
    OrderBy = descending(Date, Time);

    elements
    {
        dataitem(LSC_POS_Start_Status; "LSC POS Start Status")
        {
            //DataItemTableFilter = Status = filter(< 2);

            column(ID; ID)
            {

            }
            column(Status; Status)
            {

            }
            column(Date; Date)
            {
                ColumnFilter = Date = filter(<> '');
            }
            column(Time; Time)
            {

            }
            column(Store_No_; "Store No.")
            {
                Caption = 'Store';
            }
            column(POS_Terminal_No_; "POS Terminal No.")
            {
                Caption = 'Terminal';
            }
            filter(filterStatus; Status)
            {

            }

            filter(filterStore; "Store No.")
            {

            }

            dataitem(LSC_Staff; "LSC Staff")
            {
                DataItemLink = ID = LSC_POS_Start_Status.ID;
                SqlJoinType = InnerJoin;

                column(Permission_Group; "Permission Group")
                {

                }

                filter(filterPermission_Group; "Permission Group")
                {

                }
            }
        }
    }
}
query 50002 "EOD CheckList Query"
{
    QueryType = Normal;
    Caption = 'EOD CheckList Query';

    elements
    {
        dataitem(EODCheckList; "TWC Configuration")
        {
            column(EODCheckLists; Name)
            {
                Caption = 'EODCheckList';
            }
            filter(Key_; Key_)
            {
                ColumnFilter = Key_ = const('EOD Checklist');
            }
        }
    }
}
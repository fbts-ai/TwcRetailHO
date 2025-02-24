table 50026 ActiveSessionsTable
{
    TableType = Temporary;
    DataClassification = CustomerContent;

    fields
    {
        field(1; ID; Text[10])
        {

        }
        field(2; Date; Date)
        {

        }
        field(3; Time; Time)
        {

        }
        field(4; Role; Text[20])
        {

        }
        field(5; Store; Text[20])
        {

        }
        field(6; Terminal; Text[20])
        {

        }
        field(7; Status; Option)
        {
            OptionCaption = ' ,Start of Day,End of Day';
            OptionMembers = " ","Start of Day","End of Day";
        }

    }
}
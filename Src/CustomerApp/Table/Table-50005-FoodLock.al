table 50005 FoodLock
{
    DataClassification = ToBeClassified;

    fields
    {
        field(1; StoreCode; Text[100])
        {
            TableRelation = "LSC Store";
            DataClassification = ToBeClassified;
        }
        field(2; POSItemId; Text[100])
        {
            TableRelation = Item;
            DataClassification = ToBeClassified;
        }
        field(3; FoodLockStatus; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(4; LastModifiedDate; Datetime)
        {
            DataClassification = ToBeClassified;
        }
        field(5; LastModifiedBy; Text[50])
        {
            DataClassification = ToBeClassified;
        }
    }

    keys
    {
        key(Key1; POSItemId, StoreCode, LastModifiedDate)
        {
            Clustered = true;
        }
    }

    var
        myInt: Integer;

    trigger OnInsert()
    begin
        LastModifiedDate := System.CurrentDateTime();
        LastModifiedBy := UserId;

        // getStoreCode();
    end;

    trigger OnModify()
    begin
        LastModifiedDate := System.CurrentDateTime();
        LastModifiedBy := UserId;

        //getStoreCode();
    end;

    trigger OnDelete()
    begin

    end;

    trigger OnRename()
    begin

    end;
    /*
        local procedure getStoreCode()
        var
            UserSetup: Record "User Setup";
        begin
            IF UserSetup.Get(UserId) then;
            StoreCode := UserSetup."Location Code";
        end;
        */

}
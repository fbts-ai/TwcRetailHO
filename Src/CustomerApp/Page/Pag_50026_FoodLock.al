page 50026 "Item - FoodLock"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = Item;
    // CardPageId = "Item Card";
    SourceTableView = where("Assembly BOM" = const(true), "Gen. Prod. Posting Group" = filter('FG'));
    InsertAllowed = false;
    DeleteAllowed = false;
    // ModifyAllowed = false;

    layout
    {
        area(Content)
        {
            repeater(group)
            {
                field("No."; rec."No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field(Description; rec.Description)
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field(FoodLockStatus; rec.FoodLockStatus)
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field(Select; rec.Select)
                {
                    ApplicationArea = All;
                }
                field("Store code"; rec."Store code")
                {
                    ApplicationArea = all;
                    Editable = false;
                    Visible = false;
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action("Select All")
            {
                ApplicationArea = All;
                Image = ChangeStatus;

                trigger OnAction();
                begin
                    select_unselectAll(1)
                end;
            }
            action("Unselect All")
            {
                ApplicationArea = All;
                Image = Cancel;

                trigger OnAction();
                begin
                    select_unselectAll(0);
                end;
            }
            action(Lock)
            {
                ApplicationArea = All;
                Image = Lock;

                trigger OnAction();
                begin
                    lock_unlock(1);
                end;
            }
            action(Unlock)
            {
                ApplicationArea = All;

                trigger OnAction();
                begin
                    lock_unlock(0);
                end;
            }
        }
    }

    local procedure select_unselectAll(OptionVal: Integer)
    var
        bool: Boolean;
        Item: Record Item;
    begin
        Rec.Reset();

        if OptionVal = 1 then
            bool := true
        else
            bool := false;

        Item.Reset();
        Item.SetRange("Gen. Prod. Posting Group", 'FG');
        IF Item.FindSet() then begin
            Item.ModifyAll(Select, bool);
        end;


    end;

    local procedure lock_unlock(OptionVal: Integer)
    var
        bool: Boolean;
        usersetup: Record "User Setup";
        jsonobject: JsonObject;
        Jarray: JsonArray;
        foodlock: Record FoodLock;
        valueobj: JsonObject;
        jsondata: Text;
        requrl: Text;
        users: Record "LSC Retail User";
        result: Boolean;

    begin
        Rec.Reset();


        if OptionVal = 1 then
            bool := true
        else
            bool := false;
        Clear(JsonObject);

        if users.Get(UserId) then;
        Rec.SetRange(Select, True);
        if Rec.FindSet() then
            //repeat
                Clear(Jarray);
        repeat
            Clear(valueobj);
            valueobj.Add('POSItemId', Rec."No.");
            valueobj.Add('Storecode', RetUser."Store No.");
            valueobj.Add('FoodLockStatus', bool);
            valueobj.Add('LastDateTimeModified', System.CurrentDateTime);
            valueobj.Add('SystemModifiedBy', UserId);
            Jarray.Add(valueobj);
            Rec.FoodLockStatus := bool;
            // Rec."Store code" := users."Store No.";
            Rec.Select := false;
            Rec.Modify(true);
            insertRecFoodlock(Rec);
        until Rec.Next() = 0;
        jsonobject.Add('value', Jarray);
        jsonobject.WriteTo(jsondata);
        // Message(jsondata);
        ReqUrl := apisetup.FoodLockAPIUrl;
        result := CallServiceStatus(ReqUrl, HTTPRequestTypeEnum::put, JsonData);

        IF result then begin
            Rec.SetRange(Select, True);
            if Rec.FindSet() then
                repeat
                    Rec.FoodLockStatus := bool;
                    // Rec."Store code" := users."Store No.";
                    Rec.Select := false;
                    Rec.Modify(true);
                    insertRecFoodlock(Rec);
                until Rec.Next() = 0;
        end;
        CurrPage.Close();

    end;

    procedure CallServiceStatus(RequestUrl: Text; RequestType: Enum HTTPRequestTypeEnum; Body: Text): Boolean
    var
        httpWebClient: HttpClient;
        RequestHeaders: HttpHeaders;
        ResponseMessage: HttpResponseMessage;
        RequestMessage: HttpRequestMessage;
        ResponseText: Text;
        contentHeaders: HttpHeaders;
        RequestContent: HttpContent;
        Xml: Text;
        Instr: InStream;
        OutStrm: OutStream;
        Convert: Codeunit "Base64 Convert";
        TempBlob: Codeunit "Temp Blob";
    begin
        apisetup.Get();
        RequestHeaders := httpWebClient.DefaultRequestHeaders();

        case RequestType of
            RequestType::Put:
                begin
                    RequestContent.WriteFrom(Body);
                    RequestContent.GetHeaders(contentHeaders);
                    contentHeaders.Clear();
                    contentHeaders.Add('Content-Type', 'application/json');
                    contentHeaders.Add('X-API-VERSION', Format(apisetup."X-API-VERSION"));
                    contentHeaders.Add('X-API-KEY', apisetup."X-API-KEY");
                    httpWebClient.SetBaseAddress(RequestUrl);
                    httpWebClient.Put(RequestUrl, RequestContent, ResponseMessage);
                end;
        end;

        ResponseMessage.Content().ReadAs(ResponseText);
        // Message(ResponseText);
        IF ResponseMessage.IsSuccessStatusCode then
            exit(true)
        else
            exit(false);
    end;



    local procedure insertRecFoodlock(ItemRec: Record Item)
    var
        FoodLock: Record FoodLock;
    begin

        FoodLock.Init();
        FoodLock.POSItemId := ItemRec."No.";
        FoodLock.FoodLockStatus := ItemRec.FoodLockStatus;
        FoodLock.StoreCode := RetUser."Store No.";
        FoodLock.Insert(True);
        //  end;
    end;

    trigger OnOpenPage()
    var
    begin
        IF RetUser.Get(UserId) then;

        IF apisetup.Get() then;

        //  Rec.SetFilter("Store code", '%1', RetUser."Store No.");
    end;

    var
        RetUser: Record "LSC Retail User";
        apisetup: Record TwcApiSetupUrl;

}
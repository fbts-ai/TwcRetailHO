page 50032 "Tran sales Entry API Page"
{
    APIGroup = 'apiGroup';
    APIPublisher = 'Fbts';
    APIVersion = 'v2.0';
    //ApplicationArea = All;
    Caption = 'ITEMAPIPAGE';
    DelayedInsert = true;
    EntityName = 'TransalesEntry';
    EntitySetName = 'TransalesEntry';
    PageType = API;
    SourceTable = "LSC Trans. Sales Entry";
    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field(StoreNo; Rec."Store No.")
                {
                    ApplicationArea = all;
                }
                field(receiptNo; Rec."Receipt No.")
                {
                    ApplicationArea = all;
                }
                field(itemNo; Rec."Item No.")
                {
                    ApplicationArea = all;
                }
                field(Itemdes; Itemdes)
                {
                    ApplicationArea = all;
                }

                field(divisionCode; Rec."Division Code")
                {
                    ApplicationArea = all;
                }
                field(itemCategoryCode; Rec."Item Category Code")
                {
                    ApplicationArea = all;
                }
                field(quantity; Rec.Quantity)
                {
                    ApplicationArea = all;
                }
                field(Time; Rec.Time)
                {
                    ApplicationArea = all;
                }
                field(Date; Rec.Date)
                {
                    ApplicationArea = all;
                }
                field(SalesType; SalesTtpe)
                {
                    ApplicationArea = all;

                }

            }
        }

    }
    trigger OnAfterGetRecord()
    var
        myInt: Integer;
        ItemRec: Record Item;
    begin
        ItemRec.Reset();
        ;
        Clear(Itemdes);
        ItemRec.SetRange("No.", Rec."Item No.");
        if ItemRec.FindFirst() then begin
            Itemdes := ItemRec.Description;
        end;
        TranHeader_Rec.Reset();
        Clear(SalesTtpe);
        IF TranHeader_Rec.Get("Receipt No.") then begin
            SalesTtpe := TranHeader_Rec."Channel Name";
        end;

    end;

    var

        date: Text;
        Itemdes: text[200];
        TranHeader_Rec: Record "LSC Transaction Header";
        SalesTtpe: Code[20];

}

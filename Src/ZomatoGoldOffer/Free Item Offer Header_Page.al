page 60122 "Free Item Offer Header"
{
    PageType = Document;
    ApplicationArea = All;
    UsageCategory = Documents;
    SourceTable = "FreeItem Offer Header";
    DelayedInsert = true;
    layout
    {
        area(Content)
        {
            group(GroupName)
            {

                field(Rec; Rec."Offer No.")
                {
                    ApplicationArea = All;
                }
                field("Offer Description"; Rec."Offer Description")
                {
                    ApplicationArea = All;
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = All;
                }
                field(DiscountOffer; Rec.DiscountOffer)
                {
                    ApplicationArea = All;
                }
                field("Tender Type"; Rec."Tender Type")
                {
                    ApplicationArea = All;
                }
                field(CustomerNo; Rec.CustomerNo)
                {
                    ApplicationArea = All;
                }
                field("Disocunt %"; Rec."Discount %")
                {
                    ApplicationArea = All;
                }
                field("Validation Period ID"; Rec."Validation Period ID")
                {
                    ApplicationArea = All;
                }
                field("Validation Description"; Rec."Validation Description")
                {
                    ApplicationArea = all;
                    Editable = false;
                }
                field("Offer Applicable of N/G"; Rec."Offer Applicable of N/G")
                {
                    ApplicationArea = All;
                }
                field("Amount to Trigger"; Rec."Amount to Trigger")
                {
                    ApplicationArea = All;
                }
                field("Sales Type filter"; Rec."Sales Type filter")
                {
                    ApplicationArea = All;
                }
            }

            part(OfferLines; "Free Item Offer Lines")
            {
                SubPageLink = "Offer No." = FIELD("Offer No.");
                Editable = OfferLinesEditable;
                ApplicationArea = All;
            }
            part(StoreGroupLines; "Store Group Distribution_1")
            {
                SubPageLink = "Offer No." = FIELD("Offer No.");
                Editable = StoreGroupLinesEditable;
                ApplicationArea = All;
            }

        }
        area(factboxes)
        {
            part(Validation; "LSC Validation Period FactBox")
            {
                ApplicationArea = All;
                SubPageLink = ID = FIELD("Validation Period ID");
            }

        }

    }

    actions
    {
        area(navigation)
        {
            group("O&rder")
            {
                Caption = 'ActionItems';
                action(DisableButton)
                {
                    ApplicationArea = All;
                    Caption = '&Disable';
                    Image = Reject;

                    trigger OnAction()
                    begin
                        Rec.ToggleEnabled;
                        UpdButtons;

                    end;
                }
                action(EnableButton)
                {
                    ApplicationArea = All;
                    Caption = '&Enable';
                    Image = Approve;

                    trigger OnAction()
                    begin
                        Rec.ToggleEnabled;
                        UpdButtons;

                    end;
                }

            }
        }
    }
    trigger OnOpenPage()
    begin
        EnableButtonVisible := TRUE;
        DisableButtonVisible := TRUE;
        CurrPage.EDITABLE := TRUE;

    end;

    trigger OnAfterGetRecord()
    begin
        IF Rec.Status <> Rec.Status::Disabled THEN BEGIN
            CurrPage.EDITABLE := FALSE;
            StoreGroupLinesEditable := FALSE;
            OfferLinesEditable := FALSE;
        END ELSE BEGIN
            CurrPage.EDITABLE := TRUE;
            StoreGroupLinesEditable := TRUE;
            OfferLinesEditable := TRUE;
        END;

        UpdTypeControls;

    end;

    procedure UpdButtons()
    begin
        DisableButtonVisible := (Rec.Status = Rec.Status::Enabled);
        EnableButtonVisible := (Rec.Status = Rec.Status::Disabled);

    end;

    procedure UpdTypeControls()
    begin
        DisableButtonVisible := (Rec.Status = Rec.Status::Enabled);
        EnableButtonVisible := (Rec.Status = Rec.Status::Disabled);
    end;

    var
        DisableButtonVisible: Boolean;
        EnableButtonVisible: Boolean;
        OfferLinesEditable: Boolean;
        StoreGroupLinesEditable: Boolean;
}
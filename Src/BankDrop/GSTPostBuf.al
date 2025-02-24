// codeunit 51244 MyCodeunit
// {
//     trigger OnRun()
//     begin

//     end;

//     [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Line", 'OnAfterRunWithCheck', '', false, false)]
//     local procedure OnAfterRunWithCheck(Sender: Codeunit "Gen. Jnl.-Post Line"; var GenJnlLine: Record "Gen. Journal Line")
//     var
//         TaxDocumentGLPosting: Codeunit "LSCIN Statement Tax GL Post V2";
//         StatementGSTPost: Codeunit "LSCIN Statement GST Post";
//     begin
//         if not (IsNullGuid(GenJnlLine."LSCIN Tax ID")) and (TaxpostingBufferMgt.GetPostingOccurence() = 0) then begin
//             TaxpostingBufferMgt.SetPostingDate(GenJnlLine."Posting Date");
//             TaxDocumentGLPosting.LSPostTaxJournal(sender, GenJnlLine);
//             StatementGSTPost.PostPosDetailedGSTLedgerEntry();
//             TaxpostingBufferMgt.SetPostingOccurence(1);
//         end;
//     end;

//     var
//         TaxpostingBufferMgt: Codeunit "LSCIN Tax Post Buffer Mgmt. V2";
// }
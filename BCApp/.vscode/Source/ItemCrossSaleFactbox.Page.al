page 50100 "Item Cross Sale Factbox"
{
    PageType = ListPart;
    SourceTable = "Sales Line";
    Caption = 'Items bought by others';
    SourceTableTemporary = true;
    Editable = false;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("No."; Rec."No.")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Item No.';
                    ToolTip = 'Specifies the item number.';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Description';
                    ToolTip = 'Specifies the description of the item.';
                }
            }
        }
    }
    trigger OnFindRecord(Which: Text): Boolean
    begin
        FillTempTable();
        EXIT(Rec.Find(Which));
    end;

    procedure FillTempTable()
    var
        LineNo: Integer;
        SalesLine: Record "Sales Line";
        RecommendationsImpl: Codeunit "Recommendations Impl.";
    begin
        //Set SalesLine3 based upon Minimum values of SalesLine:
        IF NOT
          SalesLine.GET(
            Rec.GETRANGEMIN("Document Type"),
            Rec.GETRANGEMIN("Document No."),
            Rec.GETRANGEMIN("Line No."))
        THEN
            EXIT;

        RecommendationsImpl.RequestItemRecommendationsFromAzureFunctionAndSaveResult(SalesLine, Rec);
    end;

}
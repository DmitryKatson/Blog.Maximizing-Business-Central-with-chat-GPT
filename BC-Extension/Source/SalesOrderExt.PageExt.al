pageextension 50100 "SalesOrderExt" extends "Sales Order"
{
    layout
    {
        // Add changes to page layout here
        addfirst(factboxes)
        {
            part(ItemCrossSaleFactbox; "Item Cross Sale Factbox")
            {
                ApplicationArea = All;
                Provider = SalesLines;
                SubPageLink = "Document Type" = field("Document Type")
                                , "Document No." = field("Document No.")
                                , "Line No." = field("Line No.");
            }
        }
    }
}
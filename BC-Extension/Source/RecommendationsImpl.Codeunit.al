codeunit 50100 "Recommendations Impl."
{
    procedure RequestItemRecommendationsFromAzureFunctionAndSaveResult(SalesLine: Record "Sales Line"; var RecommenationLine: Record "Sales Line" temporary)
    var
        AzureFunctionsAuthentication: Codeunit "Azure Functions Authentication";
        AzureFunctions: Codeunit "Azure Functions";
        Auth: Interface "Azure Functions Authentication";
        QueryDict: Dictionary of [Text, Text];
        Response: Codeunit "Azure Functions Response";
        ResponseText: Text;
    begin
        Auth := AzureFunctionsAuthentication.CreateCodeAuth('https://bc-recommend-sales-items.azurewebsites.net/api/recommend', '9D0S_jkgbVbD20rCe6nBl-9hOxCX6kZvadvaftelyyy3AzFu8Lk78Q==');
        Response := AzureFunctions.SendPostRequest(Auth, GetRequestJsonBody(SalesLine."No."), 'application/json');
        if not Response.IsSuccessful() then
            Error(Response.GetError());

        Response.GetResultAsText(ResponseText);
        SaveRecommendationsToTempTable(ResponseText, SalesLine, RecommenationLine);
    end;

    local procedure GetRequestJsonBody(ItemNo: Code[20]) Body: Text
    var
        JsonBody: JsonObject;
    begin
        JsonBody.Add('item', ItemNo);
        JsonBody.Add('sales_lines', ConvertSalesInvoiceLinesToJsonArray());
        jsonBody.WriteTo(Body);
    end;

    local procedure ConvertSalesInvoiceLinesToJsonArray() Result: JsonArray
    var
        SalesInvLine: Record "Sales Invoice Line";
        JsonObj: JsonObject;
    begin
        SalesInvLine.SetRange(Type, SalesInvLine.Type::Item);
        SalesInvLine.SetFilter(Quantity, '>0');
        if SalesInvLine.FindSet then
            repeat
                Clear(JsonObj);
                JsonObj.Add('customer', SalesInvLine."Bill-to Customer No.");
                JsonObj.Add('item', SalesInvLine."No.");
                JsonObj.Add('date', SalesInvLine."Posting Date");
                JsonObj.Add('quantity', SalesInvLine.Quantity);
                JsonObj.Add('price', SalesInvLine."Unit Price");
                Result.Add(JsonObj);
            until SalesInvLine.Next() = 0;
    end;

    local procedure SaveRecommendationsToTempTable(ResponseText: Text; SalesLine: Record "Sales Line"; var RecommenationLine: Record "Sales Line" temporary)
    var
        JArray: JsonArray;
        i: Integer;
        JToken: JsonToken;
        LineNo: integer;
    begin
        RecommenationLine.Reset;
        RecommenationLine.deleteAll();

        JArray.ReadFrom(ResponseText);
        for i := 0 to JArray.Count() - 1 do begin
            JArray.Get(i, JToken);
            RecommenationLine.Init();
            RecommenationLine."Document Type" := SalesLine."Document Type";
            RecommenationLine."Document No." := SalesLine."Document No.";
            RecommenationLine."Line No." := i + 1;
            RecommenationLine."No." := JToken.AsValue().AsText();
            RecommenationLine.Description := GetItemDescription(RecommenationLine."No.");
            RecommenationLine.Insert();
        end;
    end;

    local procedure GetItemDescription(ItemNo: Code[20]): Text
    var
        Item: Record Item;
    begin
        Item.Get(ItemNo);
        exit(Item.Description);
    end;
}
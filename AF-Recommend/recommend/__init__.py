import azure.functions as func
import json
import pandas as pd

# Define an Azure Function that accepts an HTTP request
# and returns a response in JSON format
def main(req: func.HttpRequest) -> func.HttpResponse:
    # Parse the request body to get the item and sales lines data
    body = req.get_json()
    item = body['item']
    sales_lines = body['sales_lines']

    # Read the sales line data from the request body
    sales_lines = pd.DataFrame(sales_lines)

    # Get a list of customers who purchased the given item
    customers = list(sales_lines[sales_lines['item'] == item]['customer'].unique())

    # Get a list of items purchased by the customers who also
    # purchased the given item
    recommended_items = list(sales_lines[sales_lines['customer'].isin(customers)]['item'].unique())

    # Return the list of recommended items as JSON
    return func.HttpResponse(json.dumps(recommended_items))

import os
from flask import Flask, jsonify, request, abort
import databricks.sql as dbsql
from databricks.sql.exc import OperationalError
import dotenv
dotenv.load_dotenv()

app = Flask(__name__)

def require_api_key():
    keys = os.environ.get("API_KEYS", "")
    valid_keys = [k.strip() for k in keys.split(",") if k.strip()]
    request_key = request.headers.get("x-api-key")
    if request_key not in valid_keys:
        abort(401, description="Invalid or missing API key")

def get_data(query):
    try:
        # Establish a connection to Databricks:
        with dbsql.connect(
            server_hostname=os.environ['DATABRICKS_SERVER_HOSTNAME'],
            http_path=os.environ['DATABRICKS_HTTP_PATH'],
            access_token=os.environ['DATABRICKS_ACCESS_TOKEN']
        ) as connection:

            # Create a cursor to execute the query
            with connection.cursor() as cursor:

                # Execute the SQL query
                cursor.execute(query)

                # Fetch the results
                result = cursor.fetchall()

                # Convert the result to a list of dictionaries
                columns = [column[0] for column in cursor.description]
                data = [dict(zip(columns, row)) for row in result]

                return data

    except OperationalError as e:
        return {"error": str(e)}

@app.route('/api/v1.0/<service>', methods=['GET'])
def fetch_service_details(service):
    require_api_key()
    page = int(request.args.get('page', 1))
    page_size = int(request.args.get('page_size', 10))
    offset = (page - 1) * page_size
    query = f"""select
                    s.*
                from `catalogue`.service_dataset.rpt_device s
                where lower(s.servicename) = "{service.lower()}"
                LIMIT {page_size} OFFSET {offset}
    """
    data = get_data(query)
    return jsonify(data)

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8080)

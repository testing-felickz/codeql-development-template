import os
from flask import Flask, request
import databricks.sql as dbsql

app = Flask(__name__)

@app.route('/api/v1.0/<service>', methods=['GET'])
def fetch_service_details(service):
    # User-controlled input from URL path parameter
    page = int(request.args.get('page', 1))
    page_size = int(request.args.get('page_size', 10))
    offset = (page - 1) * page_size
    
    # SQL query constructed with user input - vulnerable to SQL injection
    query = f"""select
                    s.*
                from catalogue.service_dataset.rpt_device s
                where lower(s.servicename) = "{service.lower()}"
                LIMIT {page_size} OFFSET {offset}
    """
    
    # Databricks connection and query execution
    with dbsql.connect(
        server_hostname=os.environ['DATABRICKS_SERVER_HOSTNAME'],
        http_path=os.environ['DATABRICKS_HTTP_PATH'],
        access_token=os.environ['DATABRICKS_ACCESS_TOKEN']
    ) as connection:
        with connection.cursor() as cursor:
            # Vulnerable: user-controlled query executed
            cursor.execute(query)
            result = cursor.fetchall()
            return str(result)

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8080)

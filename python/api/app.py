from chalice import Chalice
import datetime
import os
import io

app = Chalice(app_name="hca-logging-test")
#BLOB_STORE = S3BlobStore()
#BUCKET = os.environment["TEST_S3_BUCKET"]

@app.route("/message/{user}", methods=['GET'])
def put_word(user):
    timestamp = datetime.datetime.utcnow().strftime("%Y-%m-%dT%H%M%S.%fZ")
    payload = {
        "timestamp": timestamp,
        "user": f"messages/{user}",
        "message": app.current_request.json_body
    }
    return payload
    #BLOB_STORE.upload_file_handle(
    #    BUCKET,
    #    user,
    #    io.BytesIO(json.dumps(payload).encode("utf-8"))
    #)



from google.oauth2 import service_account
import google.auth.transport.requests

# Load your Firebase service account JSON file
SERVICE_ACCOUNT_FILE = "serviceAccountKey.json"

# Define the required scopes for Firebase Cloud Messaging
SCOPES = ["https://www.googleapis.com/auth/firebase.messaging"]

# Create credentials from the service account file
credentials = service_account.Credentials.from_service_account_file(
    SERVICE_ACCOUNT_FILE, scopes=SCOPES
)

# Refresh the credentials to get a fresh token
request = google.auth.transport.requests.Request()
credentials.refresh(request)

# Print the access token
print("Access Token:", credentials.token)

import ballerina/io;
import ballerina/http;
import ballerinax/http;

// Define a Ballerina service that listens for incoming HTTP requests.
service /currentCountry on new http:Listener(8080) {

    // Define a resource that responds to GET requests.
    @http:ResourceConfig {
        methods: ["GET"],
        path: "/getCountry"
    }
    resource function get getCurrentCountry(http:Caller caller, http:Request request) returns json {
        // Extract the client's IP address from the request.
        string clientIP = check request.remoteAddress.toString();
        
        // Define the URL of an IP geolocation API (example: ipinfo.io).
        string ipGeolocationApiUrl = "https://ipinfo.io/" + clientIP + "/json";
        
        // Make an HTTP GET request to the API.
        http:Request apiRequest = new;
        apiRequest.setUri(ipGeolocationApiUrl);
        
        http:Response apiResponse = check http:Client.get(apiRequest);
        
        // Check if the HTTP request was successful.
        if (apiResponse.statusCode == http:StatusOK) {
            var jsonPayload = check apiResponse.getJsonPayload();
            check caller->respond(jsonPayload);
        } else {
            // Handle the error case.
            http:Response errorResponse = new;
            errorResponse.statusCode = http:STATUS_INTERNAL_SERVER_ERROR;
            errorResponse.setJsonPayload({"error": "Failed to retrieve country information"});
            check caller->respond(errorResponse);
        }
    }
}

public function main() {
    http:Listener listener = new http:Listener(8080);
    listener.start();
    io:println("Server started on port 8080");
}

import ballerina/io;
import ballerina/http;

// Define a Ballerina service that listens for incoming HTTP requests.
service /iptocountryService on new http:Listener(8080) {

    // Define a resource that responds to POST requests.
    resource function post iptocountry(http:Caller caller, http:Request request) returns error? {
        // Extract the IP address from the request payload.
        string jsonString = check request.getTextPayload();
        json jsonObj = check value:fromJsonString(jsonString);
        string ip = <string> check jsonObj.ip;
        
        // Make a POST request to the IPstack API to get country information.
        http:Request postRequest = new;
        postRequest.setUri("http://api.ipstack.com");
        postRequest.setHeader("Content-Type", "application/json");
        postRequest.setPayload(jsonString);
        postRequest.addQueryParam("access_key", "f5087b960eb549c3a40d1555f59dfb4a");

        http:Response postResponse = check http:Client.post(postRequest);

        // Check if the HTTP request was successful.
        if (postResponse.statusCode == http:StatusOK) {
            var jsonPayload = check postResponse.getJsonPayload();
            string country = <string> check jsonPayload.country_name;
            
            // Create a response with the country information.
            http:Response response = new;
            response.statusCode = http:STATUS_OK;
            response.setJsonPayload({"country": country});
            check caller->respond(response);
        } else {
            // Handle the error case.
            http:Response errorResponse = new;
            errorResponse.statusCode = http:STATUS_INTERNAL_SERVER_ERROR;
            errorResponse.setJsonPayload({"error": "Failed to retrieve country information"});
            check caller->respond(errorResponse);
        }
    }
}

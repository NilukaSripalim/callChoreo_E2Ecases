import ballerina/http;
import ballerina/io;
import ballerina/lang.runtime;

# A service representing a network-accessible API
# bound to port `9090`.
service / on new http:Listener(9090) {

    # A resource for generating greetings
    # + name - the input string name
    # + return - string name with hello message or error
    resource function get greeting(string name) returns string|error {
        // Send a response back to the caller.
        if name is "" {
            return error("name should not be empty!");
        }
        return "Hello, " + name;
    }

    resource function post testEchoAPI(@http:Payload json jsonObj, http:Caller caller) returns error? {
       io:println(string:concat("testEchoAPI : ", jsonObj.toJsonString()));
       http:Response quickResponse = new;
       quickResponse.setJsonPayload({"status":"success"});
       quickResponse.statusCode = http:STATUS_OK;
       // Simulate a slow operation that takes longer than the specified timeout
       runtime:sleep(2);
       return caller->respond(quickResponse);
    }
}

/**
 * Artisan Assistance class to handle testing all callouts to the Artisan Production Org by mocking the response
 *
 * @author Richard Clarke
 * @date 15/07/2019
 */
@TestVisible
public class ArtisanRestApiCalloutsMock implements HttpCalloutMock {
	public class TestingException extends Exception {}

    // Map of mock responses is keyed by null for the default and by method-endpoint (without querystring parameters) if specific 
    // eg POST-https://assistdev-artisan-api.cs74.force.com/api/services/apexrest/ArtisanAssistanceApp/v1/
    protected Map<String,HttpResponse> mockedResponses = new Map<String,HttpResponse>();
    
    // This constructor starts up with no mock responses
    public ArtisanRestApiCalloutsMock() {
    }
    
    // This constructor saves the default response which will apply to any method/endpoint if no specific response is defined
    public ArtisanRestApiCalloutsMock(Integer statusCode, String responseBody, Map<String, String> responseHeaders) {
        // Setup default response
        HttpResponse defaultResponse = new HttpResponse();
        for (String key : responseHeaders.keySet()) {
            defaultResponse.setHeader(key, responseHeaders.get(key));
        }
        defaultResponse.setStatusCode(statusCode);
        defaultResponse.setBody(responseBody);
        
        // Add to responses map
        mockedResponses.put(null, defaultResponse);
    }
    
    // This constructor saves a response for a specific method/endpoint
    public ArtisanRestApiCalloutsMock(String method, String endpoint, Integer statusCode, String responseBody, Map<String, String> responseHeaders) {
        // Setup specific response
        HttpResponse specificResponse = new HttpResponse();
        for (String key : responseHeaders.keySet()) {
            specificResponse.setHeader(key, responseHeaders.get(key));
        }
        specificResponse.setStatusCode(statusCode);
        specificResponse.setBody(responseBody);
        
        // Add to responses map
        mockedResponses.put(method + '-' + endpoint, specificResponse);
    }
    
    // This method add a response for a specific method/endpoint
    public void AddMockResponse(String method, String endpoint, Integer statusCode, String responseBody, Map<String, String> responseHeaders) {
        // Setup specific response
        HttpResponse specificResponse = new HttpResponse();
        for (String key : responseHeaders.keySet()) {
            specificResponse.setHeader(key, responseHeaders.get(key));
        }
        specificResponse.setStatusCode(statusCode);
        specificResponse.setBody(responseBody);
        
        // Add to responses map
        mockedResponses.put(method + '-' + endpoint, specificResponse);
    }
    
    // This method add a response for a specific method/endpoint
    public void RemoveMockResponse(String method, String endpoint) {
        mockedResponses.remove(method + '-' + endpoint);
    }
        
    // Provide the mocked response
    public HTTPResponse respond(HTTPRequest req) {
        // To provide a response at least one mock response is needed
        if ( mockedResponses.size() == 0 ){
            throw new TestingException('No mock responses have been defined');
        }
        
        // Extract the endpoint discarding any querystring parameters
        String endPoint = req.getEndpoint();
        if ( endPoint.indexOf('?') != -1 ){
            // Strip querystring parameters
        	endPoint = endPoint.left(endPoint.indexOf('?'));
        }
        
        // See if there is a specific response for this endpoint and method
        HttpResponse response = mockedResponses.get(req.getMethod() + '-' + endPoint);
        if ( response == null ){
            // No specific response, see if a default response is defined
            response = mockedResponses.get(null);
            if ( response == null ){
                throw new TestingException('No specific or default mock response is available for method ' + req.getMethod() + '] and endpoint [' + endPoint + ']');
            }
        }
// system.debug('*** ArtisanRestApiCalloutsMock method [' + req.getMethod() + '] and endpoint [' + endPoint + '] is returning status [' + response.getStatusCode() + '] and body [' + response.getBody() + ']');
        return response;
    }
}
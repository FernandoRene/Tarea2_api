package runner;

import factoryRequest.FactoryRequest;
import factoryRequest.RequestInfo;
import io.cucumber.java.en.And;
import io.cucumber.java.en.Given;
import io.cucumber.java.en.Then;
import io.cucumber.java.en.When;
import io.restassured.response.Response;
import util.ConfigurationEnv;

import java.util.Base64;
import java.util.HashMap;
import java.util.Map;

import static org.hamcrest.Matchers.equalTo;
import static org.hamcrest.Matchers.is;
import static org.hamcrest.core.StringContains.containsString;

public class RequestStepClean {
    Response response;
    RequestInfo info = new RequestInfo();
    Map<String,String> varMap=  new HashMap<>();

    @Given("I created a user in todo.ly")
    public void iCreatedUserTodoLy() {
        //String credential = Base64.getEncoder().encodeToString((ConfigurationEnv.user+":"+ConfigurationEnv.pwd).getBytes());
        //info.setHeaders("Authorization","Basic "+credential);
        //info.setUrl(ConfigurationEnv.host +replaceValueVariable(url)).setBody(body);
    }


    @Given("I have access todo.ly")
    public void iHaveAccessTodoLy() {
        String credential = Base64.getEncoder().encodeToString((ConfigurationEnv.email+":"+ConfigurationEnv.pwd).getBytes());
        info.setHeaders("Authorization","Basic "+credential);
    }

    @When("I send {word} {} with body")
    public void iSendPOSTApiProjectsJsonWithBody(String method,String url, String body) {
        info.setUrl(ConfigurationEnv.host +replaceValueVariable(url)).setBody(body);
        response = FactoryRequest.make(method).send(info);
    }

    @Then("response code should be {int}")
    public void responseCodeShouldBe(int expectedResult) {
        response.then().statusCode(expectedResult);
    }

    @And("the attribute {word} {string} should be {string}")
    public void theAttributeShouldBe(String type, String attribute, String expectedResult) {
        expectedResult = replaceValueVariable(expectedResult);

        if (type.equals("number")) {
            int expectedInt = Integer.parseInt(expectedResult);
            response.then().body(attribute, is(expectedInt));
        } else if (type.equals("boolean")) {
            boolean expectedBool = Boolean.parseBoolean(expectedResult);
            response.then().body(attribute, is(expectedBool));
        } else {
            expectedResult = expectedResult.replaceAll("^\"|\"$", "");
            response.then().body(attribute, containsString(expectedResult));
        }
    }

    @And("save {string} in the variable {string}")
    public void saveInTheVariable(String attribute, String variable) {
        varMap.put(variable,response.then().extract().path(attribute)+"");
        System.out.println("Atributo: "+attribute);
        System.out.println("Variable: "+variable);
    }
    @And("print the {string} value from the variable")
    public void printValueFromVariable(String variable) {
        String value = varMap.get(variable);
        System.out.println("Value of " + variable + ": " + value);
    }

    @And("print the replaced value of {string}")
    public void printReplacedValue(String value) {
        String replacedValue = replaceValueVariable(value);
        System.out.println("Original value: " + value);
        System.out.println("Replaced value: " + replacedValue);
    }

    @When("I send {word} request to {string} with basic auth")
    public void iSendRequestWithBasicAuth(String method, String url) {
        info.setUrl(ConfigurationEnv.host + replaceValueVariable(url));
        info.setHeaders("Authorization", "Basic " + Base64.getEncoder().encodeToString((ConfigurationEnv.email + ":" + ConfigurationEnv.pwd).getBytes()));
        response = FactoryRequest.make(method).send(info);
    }

    @When("I send {word} request to {string} with token and body:")
    public void iSendRequestWithTokenAndBody(String method, String url, String body) {
        info.setUrl(ConfigurationEnv.host + replaceValueVariable(url));
        info.setHeaders("Token", varMap.get("TOKEN"));
        info.setBody(body);
        response = FactoryRequest.make(method).send(info);
    }

    @When("I send {word} request to {string} with token")
    public void iSendRequestWithToken(String method, String url) {
        info.setUrl(ConfigurationEnv.host + replaceValueVariable(url));
        info.setHeaders("Token", varMap.get("TOKEN"));
        response = FactoryRequest.make(method).send(info);
    }

    private String replaceValueVariable(String value){
        for (String key:varMap.keySet()){
            value= value.replace(key,varMap.get(key));
        }
        return value;
    }

}
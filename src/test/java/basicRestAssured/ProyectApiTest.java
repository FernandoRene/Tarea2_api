package basicRestAssured;

import com.github.fge.jsonschema.SchemaVersion;
import com.github.fge.jsonschema.cfg.ValidationConfiguration;
import com.github.fge.jsonschema.main.JsonSchemaFactory;
import io.restassured.http.ContentType;
import io.restassured.module.jsv.JsonSchemaValidator;
import io.restassured.path.json.JsonPath;
import io.restassured.response.Response;
import org.apache.http.NameValuePair;
import org.apache.http.client.utils.URLEncodedUtils;
import org.junit.jupiter.api.Test;
import util.ConfigurationEnv;

import java.nio.charset.StandardCharsets;
import java.util.List;

import static io.restassured.RestAssured.given;
import static org.hamcrest.core.IsEqual.equalTo;

public class ProyectApiTest {

    @Test
    public void verifyCreateReadUpdateDelete(){

        JsonSchemaFactory schemaFactory = JsonSchemaFactory.newBuilder()
                .setValidationConfiguration(
                        ValidationConfiguration.newBuilder()
                                .setDefaultVersion(SchemaVersion.DRAFTV4)
                                .freeze()
                )
                .freeze();
        // create project
        Response response = given()
                .body("{\n" +
                        "   \"Email\":\"fllusco@catov5.com\",\n" +
                        "   \"FullName\":\"Fernando Llusco\",\n" +
                        "   \"Password\":\"12345\"\n" +
                        "}")
                .log()
                .all().
                when()
                .post("https://todo.ly/api/user.json");

        response.then()
                .statusCode(200)
                .body(JsonSchemaValidator.matchesJsonSchemaInClasspath("expectedSchema2.json")
                        .using( schemaFactory  )
                )
                .body("Email",equalTo(ConfigurationEnv.email))
                .log()
                .all();

        int idUser = response.then().extract().path("Id");

        // get Token User
        Response responseToken = given()
                .auth()
                .preemptive()
                .basic("fllusco@catov5.com", "12345")
                .log()
                .all()
                .when()
                .get("https://todo.ly/api/authentication/token.json")
                .then()
                .statusCode(200)  // Asegúrate de que la respuesta sea exitosa
                .body(JsonSchemaValidator.matchesJsonSchemaInClasspath("expectedSchemaToken.json")
                        .using( schemaFactory  )
                )
                .extract()
                .response();

        // Ahora vamos a extraer el token
        String tokenValue = responseToken.jsonPath().getString("TokenString");

        System.out.println("Token: " + tokenValue);

        // update
        given()
                .header("Token", tokenValue)
                .body("{\n" +
                        "   \"FullName\":\"Fernando Llusco Blanco\"\n" +
                        "}")
                .log()
                .all().
                when()
                .put("https://todo.ly/api/user/0.json")
                .then()
                .statusCode(200)
                .body(JsonSchemaValidator.matchesJsonSchemaInClasspath("expectedSchema2.json")
                        .using( schemaFactory  )
                )
                .body("FullName",equalTo("Fernando Llusco Blanco"))
                .body("Id",equalTo(idUser))
                .log()
                .all();

        // read
        given()
                .header("Token", tokenValue)
                .log()
                .all().
                when()
                .get("https://todo.ly/api/user.json")
                .then()
                .statusCode(200)
                .body("FullName",equalTo("Fernando Llusco Blanco"))
                .log()
                .all();

        // delete
        given()
                .header("Token", tokenValue)
                .log()
                .all().
                when()
                .delete("https://todo.ly/api/user/0.json")
                .then()
                .statusCode(200)
                .body("FullName",equalTo("Fernando Llusco Blanco"))
                .body("Id",equalTo(idUser))
                .log()
                .all();
    }
}

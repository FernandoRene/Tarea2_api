Feature: Project API
  Scenario: CRUD Project

    Given I created a user in todo.ly
    When I send POST /api/user.json with body
    """
    {
      "Email": "fllusco@catov5.com",
      "FullName": "Fernando Llusco",
      "Password": "12345"
    }
    """
    Then response code should be 200
    And the attribute string "Email" should be "fllusco@catov5.com"
    And save "Id" in the variable "USER_ID"
    And print the "USER_ID" value from the variable
    And print the replaced value of "USER_ID"

    When I send GET request to "/api/authentication/token.json" with basic auth
    Then response code should be 200
    And save "TokenString" in the variable "TOKEN"

    When I send PUT request to "/api/user/0.json" with token and body:
      """
      {
        "FullName":"Fernando Llusco Blanco"
      }
      """
    Then response code should be 200
    And the attribute string "FullName" should be "Fernando Llusco Blanco"
    #And the attribute string "Id" should be "<USER_ID>"

    When I send GET request to "/api/user.json" with token
    Then response code should be 200
    And the attribute string "FullName" should be "Fernando Llusco Blanco"

    When I send DELETE request to "/api/user/0.json" with token
    Then response code should be 200
    And the attribute string "FullName" should be "Fernando Llusco Blanco"
    #And the attribute string "Id" should be "<USER_ID>"
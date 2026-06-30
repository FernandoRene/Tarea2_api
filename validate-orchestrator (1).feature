@allure.label.epic:RemesasPayout
@allure.label.parentSuite:Business_Remittance_Payout
@allure.label.suite:Validate
Feature: YAPE Business Remittance Payout – validate

  Background:
    * def uuid             = Java.type('qa.tools.id.UuidUtil')
    * def apiName          = 'payout-validate'

    # Nota: read() de un JSON plano NO usa callonce — callonce solo aplica a
    # feature files o funciones JS invocables. Leer un JSON local es rápido,
    # así que se relee en cada fila del Scenario Outline sin impacto real.

    # Rules (HP y UP en el mismo JSON, secciones 'funcional' / 'unhappy')
    * def rulesPath    = resolveJsonIntranet('remittance', 'payout', 'rules', 'validate')
    * def rules        = read(rulesPath)

    # Auth: Basic + PublicToken + AppUserId (credenciales estáticas gestionadas por Seguridad BCP)
    # Si rotan las credenciales, actualizar únicamente qa.properties – sin tocar este feature
    * def authBasic    = props['headers.intranet.remittance.payout.authorization']
    * def publicToken  = props['headers.intranet.remittance.payout.public-token']
    * def appUserId    = props['headers.intranet.remittance.payout.app-user-id']

    # Payload base del request (estructura real del endpoint, no la del doc)
    * def basicRequestPath = resolveJsonIntranet('remittance', 'payout', '', 'validateDataRequest')
    * def basicRequest     = read(basicRequestPath)


  # ──────────────────────────────────────────────────────────────────────────
  # HAPPY PATH
  # ──────────────────────────────────────────────────────────────────────────
  @allure.label.story:Validate_HP
  @allure.label.subSuite:Happy_Path
  @intranet @remesas @payout @validate @happyPath
  Scenario Outline: Validate exitoso – <ruleName>
    * def logData = buildTestDataLog({ 'payout-validate HP': ruleName })
    * karate.log('[REMESAS][EJECUTANDO]', logData)

    # Construcción del payload con overrides del rule
    * def built       = call read('classpath:intranet/remittance/payout/feature/build/validate-build.feature') { basicRequest: #(basicRequest), rulesJson: #(rules), ruleType: 'funcional', ruleName: '<ruleName>' }
    * def requestData = built.validate.data

    # Inyección de endToEndId único por ejecución (requerido por la API)
    * set requestData.additionalInfo.endToEndId = uuid.getUuid().substring(0, 18)

    * karate.log('[DEBUG] ' + apiName + ' request:', requestData)

    # Ejecución del endpoint
    * def apiExecution = call read('classpath:intranet/remittance/payout/feature/endpoints/validate.feature') { bodyRequest: #(requestData) }
    * def apiResponse  = apiExecution.response

    * karate.log('[DEBUG] ' + apiName + ' response:', apiResponse)

    # Validaciones Happy Path
    * match apiExecution.responseStatus == 200
    * match apiResponse.paymentInfo.bankReferenceNumber == '#present'
    * match apiResponse.paymentInfo.bankReferenceNumber == '#notnull'

    Examples:
      | ruleName                         |
      | hp_ria_online_remesa_estandar |


  # ──────────────────────────────────────────────────────────────────────────
  # UNHAPPY PATH – Headers inválidos / faltantes
  # ──────────────────────────────────────────────────────────────────────────
  @ignore
  @allure.label.story:Validate_UP_Headers
  @allure.label.subSuite:Unhappy_Path_Headers
  @intranet @remesas @payout @validate @unhappyPath @upHeaders
  Scenario Outline: Validate fallido (headers) – <ruleName>
    * def logData = buildTestDataLog({ 'payout-validate UP headers': ruleName })
    * karate.log('[REMESAS][EJECUTANDO]', logData)

    * def built       = call read('classpath:intranet/remittance/payout/feature/build/validate-build.feature') { basicRequest: #(basicRequest), rulesJson: #(rules), ruleType: 'unhappy', ruleName: '<ruleName>' }
    * def requestData = built.validate.data

    * def apiExecution = call read('classpath:intranet/remittance/payout/feature/endpoints/validate.feature') { bodyRequest: #(requestData) }
    * def apiResponse  = apiExecution.response

    * match apiExecution.responseStatus == <expectedStatus>
    * match apiResponse.type    == '<expectedCode>'
    * match apiResponse.status  == <expectedStatus>

    Examples:
      | ruleName | expectedStatus | expectedCode |
      # Completar con los rules del validate.json > "unhappy" > grupo headers


  # ──────────────────────────────────────────────────────────────────────────
  # UNHAPPY PATH – Campos obligatorios faltantes (YP-RM-0004)
  # ──────────────────────────────────────────────────────────────────────────
  @ignore
  @allure.label.story:Validate_UP_CamposFaltantes
  @allure.label.subSuite:Unhappy_Path_Campos
  @intranet @remesas @payout @validate @unhappyPath @upCampos
  Scenario Outline: Validate fallido (campo faltante) – <ruleName>
    * def logData = buildTestDataLog({ 'payout-validate UP campo': ruleName })
    * karate.log('[REMESAS][EJECUTANDO]', logData)

    * def built       = call read('classpath:intranet/remittance/payout/feature/build/validate-build.feature') { basicRequest: #(basicRequest), rulesJson: #(rules), ruleType: 'unhappy', ruleName: '<ruleName>' }
    * def requestData = built.validate.data

    * def apiExecution = call read('classpath:intranet/remittance/payout/feature/endpoints/validate.feature') { bodyRequest: #(requestData) }
    * def apiResponse  = apiExecution.response

    * match apiExecution.responseStatus == 400
    * match apiResponse.type   == 'YP-RM-0004'
    * match apiResponse.status == 400

    Examples:
      | ruleName |
      # Completar: un rule por campo mandatorio faltante
      # Ejemplo: | validate_up_sin_account_number |
      #          | validate_up_sin_real_amount    |
      #          | validate_up_sin_currency       |
      #          | validate_up_sin_end_to_end_id  |


  # ──────────────────────────────────────────────────────────────────────────
  # UNHAPPY PATH – Validaciones de beneficiario (YP-RM-0002 / YP-RM-0003)
  # ──────────────────────────────────────────────────────────────────────────
  @ignore
  @allure.label.story:Validate_UP_Beneficiario
  @allure.label.subSuite:Unhappy_Path_Beneficiario
  @intranet @remesas @payout @validate @unhappyPath @upBeneficiario
  Scenario Outline: Validate fallido (beneficiario) – <ruleName>
    * def logData = buildTestDataLog({ 'payout-validate UP beneficiario': ruleName })
    * karate.log('[REMESAS][EJECUTANDO]', logData)

    * def built       = call read('classpath:intranet/remittance/payout/feature/build/validate-build.feature') { basicRequest: #(basicRequest), rulesJson: #(rules), ruleType: 'unhappy', ruleName: '<ruleName>' }
    * def requestData = built.validate.data

    * def apiExecution = call read('classpath:intranet/remittance/payout/feature/endpoints/validate.feature') { bodyRequest: #(requestData) }
    * def apiResponse  = apiExecution.response

    * match apiExecution.responseStatus == 400
    * match apiResponse.type   == '<expectedCode>'
    * match apiResponse.status == 400

    Examples:
      | ruleName | expectedCode |
      # Ejemplos: YP-RM-0002 (datos no coinciden), YP-RM-0003 (wallet inválida)


  # ──────────────────────────────────────────────────────────────────────────
  # UNHAPPY PATH – Moneda / monto (YP-RM-0005 / YP-RM-0006)
  # ──────────────────────────────────────────────────────────────────────────
  @ignore
  @allure.label.story:Validate_UP_MontoMoneda
  @allure.label.subSuite:Unhappy_Path_MontoMoneda
  @intranet @remesas @payout @validate @unhappyPath @upMonto
  Scenario Outline: Validate fallido (monto/moneda) – <ruleName>
    * def logData = buildTestDataLog({ 'payout-validate UP monto': ruleName })
    * karate.log('[REMESAS][EJECUTANDO]', logData)

    * def built       = call read('classpath:intranet/remittance/payout/feature/build/validate-build.feature') { basicRequest: #(basicRequest), rulesJson: #(rules), ruleType: 'unhappy', ruleName: '<ruleName>' }
    * def requestData = built.validate.data

    * def apiExecution = call read('classpath:intranet/remittance/payout/feature/endpoints/validate.feature') { bodyRequest: #(requestData) }
    * def apiResponse  = apiExecution.response

    * match apiExecution.responseStatus == 400
    * match apiResponse.type   == '<expectedCode>'
    * match apiResponse.status == 400

    Examples:
      | ruleName | expectedCode |
      # YP-RM-0005 (límite por transacción), YP-RM-0006 (moneda no soportada)


  # ──────────────────────────────────────────────────────────────────────────
  # UNHAPPY PATH – Límites diarios / mensuales (YP-RM-0008 al 0011)
  # ──────────────────────────────────────────────────────────────────────────
  @ignore
  @allure.label.story:Validate_UP_Limites
  @allure.label.subSuite:Unhappy_Path_Limites
  @intranet @remesas @payout @validate @unhappyPath @upLimites
  Scenario Outline: Validate fallido (límites) – <ruleName>
    * def logData = buildTestDataLog({ 'payout-validate UP limites': ruleName })
    * karate.log('[REMESAS][EJECUTANDO]', logData)

    * def built       = call read('classpath:intranet/remittance/payout/feature/build/validate-build.feature') { basicRequest: #(basicRequest), rulesJson: #(rules), ruleType: 'unhappy', ruleName: '<ruleName>' }
    * def requestData = built.validate.data

    * def apiExecution = call read('classpath:intranet/remittance/payout/feature/endpoints/validate.feature') { bodyRequest: #(requestData) }
    * def apiResponse  = apiExecution.response

    * match apiExecution.responseStatus == 400
    * match apiResponse.type   == '<expectedCode>'
    * match apiResponse.status == 400

    Examples:
      | ruleName | expectedCode |
      # YP-RM-0008 (límite diario), YP-RM-0009 (límite mensual)
      # YP-RM-0010 (límite diario sender), YP-RM-0011 (límite mensual sender)


  # ──────────────────────────────────────────────────────────────────────────
  # UNHAPPY PATH – Error de sistema (YP-RM-9999)
  # ──────────────────────────────────────────────────────────────────────────
  @ignore
  @allure.label.story:Validate_UP_Sistema
  @allure.label.subSuite:Unhappy_Path_Sistema
  @intranet @remesas @payout @validate @unhappyPath @upSistema
  Scenario Outline: Validate fallido (sistema) – <ruleName>
    * def logData = buildTestDataLog({ 'payout-validate UP sistema': ruleName })
    * karate.log('[REMESAS][EJECUTANDO]', logData)

    * def built       = call read('classpath:intranet/remittance/payout/feature/build/validate-build.feature') { basicRequest: #(basicRequest), rulesJson: #(rules), ruleType: 'unhappy', ruleName: '<ruleName>' }
    * def requestData = built.validate.data

    * def apiExecution = call read('classpath:intranet/remittance/payout/feature/endpoints/validate.feature') { bodyRequest: #(requestData) }
    * def apiResponse  = apiExecution.response

    * match apiExecution.responseStatus == 500
    * match apiResponse.type   == 'YP-RM-9999'
    * match apiResponse.status == 500

    Examples:
      | ruleName |
      # Escenarios que simulan error interno (requiere mock o condición de error en cert)

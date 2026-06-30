@allure.label.quiteallure:true
Feature: Constructor dinámico de payload – validate

  Background:
    * configure report = false

    # IMPORTANTE: deepMerge va ANIDADA dentro de buildValidatePayload (no como
    # un * def separado). Dos funciones JS definidas en líneas `* def` distintas
    # no siempre pueden referenciarse entre sí en el motor GraalVM de Karate.
    # Anidarlas en una sola función autocontenida evita ese problema de scope.
    * def buildValidatePayload =
      """
      function(basicRequest, rulesJson, ruleType, ruleName) {

        function deepMerge(base, overrides) {
          if (!overrides) return base;
          var result = JSON.parse(JSON.stringify(base));

          function mergeObjects(target, source) {
            for (var key in source) {
              var val = source[key];
              if (val !== null && typeof val === 'object' && !Array.isArray(val)
                  && target[key] !== null && typeof target[key] === 'object') {
                mergeObjects(target[key], val);
              } else if (val === null) {
                delete target[key];
              } else {
                target[key] = val;
              }
            }
          }

          mergeObjects(result, overrides);
          return result;
        }

        var overrides = rulesJson[ruleType] && rulesJson[ruleType][ruleName]
          ? rulesJson[ruleType][ruleName]
          : {};

        return { data: deepMerge(basicRequest, overrides) };
      }
      """

  Scenario: Construcción de payload validate dinámico
    * def validate = buildValidatePayload(basicRequest, rulesJson, ruleType, ruleName)

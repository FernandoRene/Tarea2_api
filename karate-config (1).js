function fn() {

    function readProperties(filePath) {
        var content = karate.readAsString(filePath);

        var props = {}
        var lines = content.split('\n');

        for (var i = 0; i < lines.length; i++) {
            var line = lines[i].trim();

            if (line && !line.startsWith('#')) {
                var separatorIndex = line.indexOf('=');
                if (separatorIndex > 0) {
                    var key = line.substring(0, separatorIndex).trim();
                    var value = line.substring(separatorIndex + 1).trim();
                    props[key] = value;
                }
            }
        }
        return props;
    };
    function buildTestDataLog(data){
        var safeData = data || {};
        return karate.merge({}, safeData);
    }
    function parseMockList(mockType) {
        if(!mockType) return [];

        return mockType
            .split(',')
            .map(function(x) {
                 return x.trim().toLowerCase();
            })
            .filter(function (x){
                return x.length > 0;
            });
    }
    function getServiceUrl(service, version, props) {

        if(service === 'extranet') {
            return props[version + '.urls.extranet'];
        }

        return props['urls.' + service];
    }
    function resolvePath(module, endpoint) {
        var key = version + '.paths.' + module + '.' + endpoint;
        var value = karate.get('props')[key];

        if(!value) {
            karate.fail('Path no configurado: ' + key);
        }

        return value;
    }

    // ─── INTRANET (función genérica para todos los productos) ──────────────
    // resolvePathIntranet: resuelve paths de cualquier módulo intranet.
    // Clave en qa.properties: {product}.paths.{module}.{endpoint}
    // Ejemplo: remittance.paths.payout.validate
    // Uso:     resolvePathIntranet('remittance', 'payout', 'validate')
    function resolvePathIntranet(product, module, endpoint) {
        var key = product + '.paths.' + module + '.' + endpoint;
        var value = karate.get('props')[key];

        if(!value) {
            karate.fail('[INTRANET] Path no configurado: ' + key);
        }

        return value;
    }
    // ─────────────────────────────────────────────────────────────────────────

    function resolveJson(module, relativePath, fileName) {

        if(!env || env.trim() === '') {
            karate.fail(
                '\nEnvironment no configurado\n' +
                'Valor actual => [' + env + ']'
            );
        }

        if(!version || version.trim() === '') {
            karate.fail(
                '\nVersion no configurada\n' +
                'Valor actual => [' + version + ']'
            );
        }

        if(!module || module.trim() === '') {
            karate.fail(
                '\nModule no configurado\n' +
                'Valor actual => [' + module + ']'
            );
        }

        if(!fileName || fileName.trim() === '') {
            karate.fail(
                '\nFileName no configurado\n' +
                'Valor actual => [' + fileName + ']'
            );
        }

        var basePath =
            'src/test/java/extranet/' +
            version +
            '/' +
            module;

        var File = Java.type('java.io.File');

        /*
         * VALIDAR VERSION
         */
        var versionFolder =
            new File(
                'src/test/java/extranet/' + version
            );

        if(!versionFolder.exists()) {

            karate.fail(
                '\nVersion no encontrada\n' +
                'Version : ' + version + '\n' +
                'Path    : ' + versionFolder.getPath()
            );
        }

        /*
         * VALIDAR MODULE
         */
        var moduleFolder =
            new File(basePath);

        if(!moduleFolder.exists()) {

            karate.fail(
                '\nModule no encontrado\n' +
                'Module : ' + module + '\n' +
                'Path   : ' + moduleFolder.getPath()
            );
        }

        /*
         * VALIDAR ENV
         */
        var envFolder =
            new File(
                basePath +
                '/input/' +
                env
            );

        if(!envFolder.exists()) {

            karate.fail(
                '\nEnvironment no encontrado\n' +
                'Environment : ' + env + '\n' +
                'Path        : ' + envFolder.getPath()
            );
        }

        /*
         * CONSTRUIR PATH FINAL
         */
        var path =
            basePath +
            '/input/' +
            env;

        if(relativePath && relativePath.trim() !== '') {
            path += '/' + relativePath;
        }

        path += '/' + fileName + '.json';

        /*
         * VALIDAR ARCHIVO
         */
        var jsonFile =
            new File(path);

        if(!jsonFile.exists()) {

            karate.fail(
                '\nJSON no encontrado\n' +
                'Environment : ' + env + '\n' +
                'Version    : ' + version + '\n' +
                'Module     : ' + module + '\n' +
                'Relative   : ' + relativePath + '\n' +
                'FileName   : ' + fileName + '.json\n' +
                'Path       : ' + path
            );
        }

        return 'file:' + path;
    }

    // ─── INTRANET (función genérica para todos los productos) ──────────────
    // resolveJsonIntranet: resuelve paths de JSON para cualquier módulo intranet.
    // Base path: src/test/java/intranet/{product}/{module}/input/{env}/
    // Uso en feature: resolveJsonIntranet('remittance', 'payout', 'rules', 'validate')
    function resolveJsonIntranet(product, module, relativePath, fileName) {

        if(!env || env.trim() === '') {
            karate.fail(
                '\n[INTRANET] Environment no configurado\n' +
                'Valor actual => [' + env + ']'
            );
        }

        if(!module || module.trim() === '') {
            karate.fail(
                '\n[INTRANET] Module no configurado\n' +
                'Valor actual => [' + module + ']'
            );
        }

        if(!fileName || fileName.trim() === '') {
            karate.fail(
                '\n[INTRANET] FileName no configurado\n' +
                'Valor actual => [' + fileName + ']'
            );
        }

        var basePath = 'src/test/java/intranet/' + product + '/' + module;

        var File = Java.type('java.io.File');

        /*
         * VALIDAR MODULE
         */
        var moduleFolder = new File(basePath);

        if(!moduleFolder.exists()) {
            karate.fail(
                '\n[INTRANET] Module no encontrado\n' +
                'Module : ' + module + '\n' +
                'Path   : ' + moduleFolder.getPath()
            );
        }

        /*
         * VALIDAR ENV
         */
        var envFolder = new File(basePath + '/input/' + env);

        if(!envFolder.exists()) {
            karate.fail(
                '\n[INTRANET] Environment no encontrado\n' +
                'Environment : ' + env + '\n' +
                'Path        : ' + basePath + '/input/' + env
            );
        }

        /*
         * CONSTRUIR PATH FINAL
         */
        var path = basePath + '/input/' + env;

        if(relativePath && relativePath.trim() !== '') {
            path += '/' + relativePath;
        }

        path += '/' + fileName + '.json';

        /*
         * VALIDAR ARCHIVO
         */
        var jsonFile = new File(path);

        if(!jsonFile.exists()) {
            karate.fail(
                '\n[INTRANET] JSON no encontrado\n' +
                'Environment : ' + env + '\n' +
                'Module     : ' + module + '\n' +
                'Relative   : ' + relativePath + '\n' +
                'FileName   : ' + fileName + '.json\n' +
                'Path       : ' + path
            );
        }

        return 'file:' + path;
    }
    // ─────────────────────────────────────────────────────────────────────────

    karate.configure('connectTimeout', 120000);
    karate.configure('readTimeout', 120000);
    karate.configure('ssl', true);
    karate.configure('report', {
        showLog: true,
        showAllSteps: true
    });

    var env = (karate.env || 'qa').toLowerCase();
    var itTest = (karate.properties['it.test'] || 'runners.extranet.net8.OnboardingLocalRunnerIT').toLowerCase();
    var version = (karate.properties['extranet_version'] || 'net8').toLowerCase();
    var mockType = (karate.properties['mock_type'] || '').toLowerCase();
    var keepHistory = String(karate.properties['keep_history'] || 'false').toLowerCase() === 'true';
    var PrepareDataTest = String(karate.properties['prepare_DataTest'] || 'true').toLowerCase() === 'true';
    var tagType = (karate.properties['tag_type'] || '').toLowerCase();

    var mockList = parseMockList(mockType);
    var globalProps = readProperties('classpath:global.properties');
    var envProps = readProperties('classpath:' + env + '.properties');
    var props = Object.assign({}, globalProps, envProps);

    var urls = {
        extranet: getServiceUrl('extranet', version, props)
        // ─── INTRANET ───────────────────────────────────────────────────────
        // Las URLs de servicios intranet se leen directamente desde props
        // en cada endpoint feature: props['urls.intranet.remittance.payout']
        // Esto evita tener que actualizar este archivo al agregar microservicios.
        // ────────────────────────────────────────────────────────────────────
    };

    var config = {
        env: env,
        version: version,
        urls: urls,
        resolvePath: resolvePath,
        resolveJson: resolveJson,
        // ─── INTRANET (funciones genéricas, disponibles para cualquier equipo) ─
        resolvePathIntranet: resolvePathIntranet,
        resolveJsonIntranet: resolveJsonIntranet,
        // ───────────────────────────────────────────────────────────────────
        mockList: mockList,
        keepHistory: keepHistory,
        PrepareDataTest: PrepareDataTest,
        props: props,
        buildTestDataLog: buildTestDataLog
    };

    return config;
}

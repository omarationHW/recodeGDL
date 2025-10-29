<?php
// Habilitar logging de errores
ini_set('log_errors', 1);
ini_set('error_log', __DIR__ . '/../error.log');
error_reporting(E_ALL);

header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization, X-Requested-With');

if ($_SERVER['REQUEST_METHOD'] == 'OPTIONS') {
    http_response_code(200);
    exit();
}

// Routing para /api/generic
$path = parse_url($_SERVER['REQUEST_URI'], PHP_URL_PATH);
error_log("🌐 REQUEST: " . $_SERVER['REQUEST_METHOD'] . " " . $path);
error_log("🌐 HEADERS: " . print_r(getallheaders(), true));

if ($path === '/api/generic' && $_SERVER['REQUEST_METHOD'] === 'POST') {
    error_log("✅ Entering /api/generic endpoint");
    
    // Capturar el input raw para debugging
    $rawInput = file_get_contents('php://input');
    error_log("🔍 RAW INPUT: " . $rawInput);
    
    $input = json_decode($rawInput, true);
    error_log("🔍 PARSED INPUT: " . print_r($input, true));
    
    if (!isset($input['eRequest'])) {
        error_log("❌ ERROR: No eRequest found in input");
        http_response_code(400);
        echo json_encode(['eResponse' => ['success' => false, 'message' => 'Invalid eRequest']]);
        exit();
    }
    
    $eRequest = $input['eRequest'];
    
    try {
        // Validar formato eRequest correcto
        error_log("🔍 Validando eRequest...");
        if (empty($eRequest['Operacion'])) {
            throw new Exception('eRequest.Operacion is required');
        }
        if (empty($eRequest['Base'])) {
            throw new Exception('eRequest.Base is required');
        }
        
        $operacion = $eRequest['Operacion'];
        $base = $eRequest['Base'];
        $parametros = $eRequest['Parametros'] ?? [];
        $tenant = $eRequest['Tenant'] ?? '';
        
        error_log("🔍 Variables extraídas: operacion={$operacion}, base={$base}, parametros=" . count($parametros) . ", tenant={$tenant}");
        
        // LEER CONFIGURACIÓN DE .env
        error_log("🔍 Leyendo configuración .env...");
        $envFile = __DIR__ . '/../.env';
        $envVars = [];
        if (file_exists($envFile)) {
            $lines = file($envFile, FILE_IGNORE_NEW_LINES | FILE_SKIP_EMPTY_LINES);
            foreach ($lines as $line) {
                if (strpos($line, '=') !== false && !str_starts_with($line, '#')) {
                    list($key, $value) = explode('=', $line, 2);
                    $envVars[trim($key)] = trim($value);
                }
            }
        }
        error_log("🔍 Configuración leída. Variables encontradas: " . count($envVars));
        
        // CONFIGURACIÓN MULTI-BASE DE DATOS POR MÓDULO
        $host = $envVars['DB_HOST'] ?? '192.168.6.146';
        $port = $envVars['DB_PORT'] ?? 5432;
        $username = $envVars['DB_USERNAME'] ?? 'refact';
        $password = $envVars['DB_PASSWORD'] ?? 'FF)-BQk2';
        
        // Mapeo de módulos a bases de datos y esquemas
        $moduleDbConfig = [
            'licencias' => [
                'database' => 'padron_licencias',
                'schema' => 'catastro_gdl'
            ],
            'aseo' => [
                'database' => 'padron_aseo', 
                'schema' => 'informix'
            ],
            'cementerios' => [
                'database' => 'padron_cementerios',
                'schema' => 'informix'
            ],
            'convenios' => [
                'database' => 'padron_convenios',
                'schema' => 'informix'
            ],
            'estacionamientos' => [
                'database' => 'padron_estacionamientos',
                'schema' => 'informix'
            ],
            'otras-oblig' => [
                'database' => 'padron_otras_oblig',
                'schema' => 'informix'
            ],
            'recaudadora' => [
                'database' => 'padron_recaudadora',
                'schema' => 'informix'
            ],
            'tramite-trunk' => [
                'database' => 'padron_tramite_trunk',
                'schema' => 'informix'
            ],
            'apremiossvn' => [
                'database' => 'padron_apremiossvn',
                'schema' => 'informix'
            ],
            'mercados' => [
                'database' => 'padron_mercados',
                'schema' => 'informix'
            ],
            // Fallback para módulos no especificados
            'default' => [
                'database' => $envVars['DB_DATABASE'] ?? 'postgres',
                'schema' => $envVars['DB_SCHEMA'] ?? 'informix'
            ]
        ];
        
        // Obtener configuración según el módulo
        $config = $moduleDbConfig[$base] ?? $moduleDbConfig['default'];
        $dbname = $config['database'];
        $schema = $config['schema'];
        
        error_log("🔍 Módulo: {$base} -> Base: {$dbname}, Esquema: {$schema}");

        // Construir nombre del stored procedure
        $procedure = $operacion;
        // NO agregar prefijo SP_ automáticamente - usar el nombre exacto del SP
        if (!str_contains($procedure, '.')) {
            $procedure = $schema . '.' . $procedure;
        }

        // Conectar a la base de datos desde .env
        error_log("🔍 Conectando a la base de datos: host={$host}, port={$port}, dbname={$dbname}");
        $dsn = "pgsql:host={$host};port={$port};dbname={$dbname}";
        $pdo = new PDO($dsn, $username, $password);
        $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
        error_log("✅ Conexión a DB exitosa");

        // Preparar parámetros para el stored procedure
        $spParams = [];
        foreach ($parametros as $param) {
            $spParams[] = $param['valor'] ?? null;
        }
        
        // EJECUTAR STORED PROCEDURE GENÉRICO
        try {
            // Verificar conexión
            $testConnection = $pdo->query('SELECT current_database(), current_user, version()');
            $connectionInfo = $testConnection->fetch(PDO::FETCH_ASSOC);
            
            // Construir nombre completo del stored procedure
            $spFullName = $schema . '.' . $operacion;
            
            // Verificar que el SP existe (case insensitive)
            $checkSP = $pdo->prepare("
                SELECT routine_name, routine_definition, routine_schema
                FROM information_schema.routines 
                WHERE routine_schema = ? AND UPPER(routine_name) = UPPER(?)
            ");
            $checkSP->execute([$schema, $operacion]);
            $spInfo = $checkSP->fetch(PDO::FETCH_ASSOC);
            
            if (!$spInfo) {
                // Buscar en todos los esquemas para debug
                $findSP = $pdo->prepare("
                    SELECT routine_name, routine_schema
                    FROM information_schema.routines 
                    WHERE UPPER(routine_name) = UPPER(?)
                ");
                $findSP->execute([$operacion]);
                $allSPs = $findSP->fetchAll(PDO::FETCH_ASSOC);
                
                // Buscar todos los esquemas disponibles
                $schemas = $pdo->query("
                    SELECT schema_name 
                    FROM information_schema.schemata 
                    WHERE schema_name NOT IN ('information_schema', 'pg_catalog', 'pg_toast')
                    ORDER BY schema_name
                ")->fetchAll(PDO::FETCH_COLUMN);
                
                $debugMsg = "Stored Procedure '{$operacion}' no existe en el esquema '{$schema}'. ";
                $debugMsg .= "Esquemas disponibles: " . implode(', ', $schemas) . ". ";
                
                if ($allSPs) {
                    $debugMsg .= "El SP existe en: ";
                    foreach ($allSPs as $sp) {
                        $debugMsg .= "{$sp['routine_schema']}.{$sp['routine_name']} ";
                    }
                } else {
                    $debugMsg .= "El SP no existe en ningún esquema.";
                }
                
                throw new Exception($debugMsg);
            }
            
            // SP existe - ejecutarlo con parámetros estructurados
            $spParametros = [];
            
            // Crear mapa de parámetros recibidos
            $paramMap = [];
            foreach ($parametros as $param) {
                if (isset($param['nombre']) && array_key_exists('valor', $param)) {
                    $valor = $param['valor'];
                    
                    // Convertir tipos de datos (manejar NULL values)
                    if ($valor !== null) {
                        switch ($param['tipo'] ?? 'string') {
                            case 'integer':
                            case 'int':
                                $valor = intval($valor);
                                break;
                            case 'numeric':
                            case 'decimal':
                                $valor = floatval($valor);
                                break;
                            case 'boolean':
                            case 'bool':
                                $valor = boolval($valor);
                                break;
                            case 'json':
                                $valor = is_string($valor) ? $valor : json_encode($valor);
                                break;
                            default: // string
                                $valor = strval($valor);
                        }
                    }
                    
                    $paramMap[$param['nombre']] = $valor;
                }
            }
            
            // Organizar parámetros genéricamente
            // El cliente debe enviar parámetros en el orden correcto del SP
            foreach ($parametros as $param) {
                if (isset($param['nombre'])) {
                    $spParametros[] = $paramMap[$param['nombre']];
                }
            }
            
            // Construir placeholders para el SP
            $placeholders = str_repeat('?,', count($spParametros));
            $placeholders = rtrim($placeholders, ',');
            $sql = "SELECT * FROM {$spFullName}({$placeholders})";

            error_log("🔍 Ejecutando SP: {$sql}");
            error_log("🔍 Parámetros: " . json_encode($spParametros));

            $stmt = $pdo->prepare($sql);
            $stmt->execute($spParametros);

            error_log("🔍 SP ejecutado, obteniendo resultados...");
            $result = $stmt->fetchAll(PDO::FETCH_ASSOC);
            error_log("✅ SP completado. Resultados: " . count($result) . " registros");
            
            $debugInfo = [
                'connection' => $connectionInfo,
                'sp_name' => $spFullName,
                'sp_exists' => true,
                'sql_executed' => $sql,
                'parameters_sent' => $spParametros,
                'parameters_original' => $parametros,
                'parameters_count' => count($spParametros)
            ];
            
        } catch (Exception $e) {
            throw new Exception('Error ejecutando SP: ' . $e->getMessage());
        }

        // eResponse
        error_log("✅ Devolviendo respuesta exitosa con " . count($result) . " registros");
        echo json_encode([
            'eResponse' => [
                'success' => true,
                'message' => 'Operation completed successfully',
                'data' => [
                    'result' => $result,
                    'count' => count($result),
                    'debug' => $debugInfo
                ],
                'timestamp' => date('c')
            ]
        ]);
        
    } catch (Exception $e) {
        // Log del error para debug
        error_log("API Error: " . $e->getMessage());
        error_log("API Error Trace: " . $e->getTraceAsString());
        
        http_response_code(500);
        echo json_encode([
            'eResponse' => [
                'success' => false,
                'message' => $e->getMessage(),
                'data' => null,
                'timestamp' => date('c'),
                'debug_error' => $e->getTraceAsString()
            ]
        ]);
    }
    
} else {
    http_response_code(404);
    echo json_encode([
        'eResponse' => [
            'success' => false,
            'message' => 'Route not found'
        ]
    ]);
}
?>
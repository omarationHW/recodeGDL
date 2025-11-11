<?php

namespace App\Http\Controllers\Api;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Log;
use Exception;
use PDO;

class GenericController
{
    private function getModuleDbConfig()
    {
        return [
            'padron_licencias' => [
                'database' => 'padron_licencias',
                'schema' => 'public',
                'allowed_schemas' => ['public', 'comun'] // Solo estos esquemas
            ],
            'licencias' => [
                'database' => 'padron_licencias',
                'schema' => 'public',
                'allowed_schemas' => ['public', 'comun']
            ],
            'aseo_contratado' => [
                'database' => 'aseo_contratado',
                'schema' => 'public',
                'allowed_schemas' => ['public']
            ],
            'aseo' => [
                'database' => 'aseo_contratado',
                'schema' => 'public',
                'allowed_schemas' => ['public']
            ],
            'cementerio' => [
                'database' => 'padron_licencias',
                'schema' => 'public',
                'allowed_schemas' => ['public', 'comun']
            ],
            'cementerios' => [
                'database' => 'padron_licencias',
                'schema' => 'public',
                'allowed_schemas' => ['public', 'comun']
            ],
            'estacionamiento_exclusivo' => [
                'database' => 'estacionamiento_exclusivo',
                'schema' => 'public',
                'allowed_schemas' => ['public']
            ],
            'estacionamiento_publico' => [
                'database' => 'padron_licencias',
                'schema' => 'public',
                'allowed_schemas' => ['public', 'comun']
            ],
            'estacionamientos' => [
                'database' => 'padron_licencias',
                'schema' => 'public',
                'allowed_schemas' => ['public', 'comun']
            ],
            'mercados' => [
                'database' => 'mercados',
                'schema' => 'public',
                'allowed_schemas' => ['public']
            ],
            'multas_reglamentos' => [
                'database' => 'multas_reglamentos',
                'schema' => 'public',
                'allowed_schemas' => ['public']
            ],
            'multas' => [
                'database' => 'multas_reglamentos',
                'schema' => 'public',
                'allowed_schemas' => ['public']
            ],
            'otras_obligaciones' => [
                'database' => 'otras_obligaciones',
                'schema' => 'public',
                'allowed_schemas' => ['public']
            ],
            'otras-oblig' => [
                'database' => 'otras_obligaciones',
                'schema' => 'public',
                'allowed_schemas' => ['public']
            ],
            'distribucion' => [
                'database' => 'distribucion',
                'schema' => 'public',
                'allowed_schemas' => ['public']
            ],
            'default' => [
                'database' => config('database.connections.pgsql.database', 'postgres'),
                'schema' => 'public',
                'allowed_schemas' => ['public']
            ]
        ];
    }

    /**
     * Endpoint genérico para ejecutar stored procedures
     *
     * @OA\Post(
     *     path="/api/generic",
     *     summary="Ejecutar stored procedure genérico",
     *     description="Endpoint genérico para ejecutar stored procedures en diferentes módulos y bases de datos. El esquema por defecto es 'public'. Solo la base 'padron_licencias' puede usar también el esquema 'comun'.",
     *     tags={"Generic API"},
     *     @OA\RequestBody(
     *         required=true,
     *         @OA\JsonContent(
     *             required={"eRequest"},
     *             @OA\Property(
     *                 property="eRequest",
     *                 type="object",
     *                 @OA\Property(property="Operacion", type="string", example="select", description="Nombre del stored procedure a ejecutar"),
     *                 @OA\Property(property="Base", type="string", example="padron_licencias", description="Nombre del módulo/base de datos"),
     *                 @OA\Property(property="Esquema", type="string", example="public", description="Esquema de la base de datos (opcional). Por defecto: 'public'. Solo 'padron_licencias' puede usar 'comun'"),
     *                 @OA\Property(property="Parametros", type="object", description="Parámetros del stored procedure")
     *             )
     *         )
     *     ),
     *     @OA\Response(
     *         response=200,
     *         description="Operación exitosa",
     *         @OA\JsonContent(
     *             @OA\Property(property="eResponse", type="object",
     *                 @OA\Property(property="success", type="boolean", example=true),
     *                 @OA\Property(property="message", type="string"),
     *                 @OA\Property(property="data", type="object")
     *             )
     *         )
     *     ),
     *     @OA\Response(
     *         response=400,
     *         description="Petición inválida",
     *         @OA\JsonContent(
     *             @OA\Property(property="eResponse", type="object",
     *                 @OA\Property(property="success", type="boolean", example=false),
     *                 @OA\Property(property="message", type="string")
     *             )
     *         )
     *     ),
     *     @OA\Response(
     *         response=500,
     *         description="Error del servidor",
     *         @OA\JsonContent(
     *             @OA\Property(property="eResponse", type="object",
     *                 @OA\Property(property="success", type="boolean", example=false),
     *                 @OA\Property(property="message", type="string")
     *             )
     *         )
     *     )
     * )
     */
    public function execute(Request $request)
    {
        try {
            Log::info("🌐 REQUEST: " . $request->method() . " " . $request->path());
            Log::info("🔍 RAW INPUT: " . $request->getContent());

            if (!$request->has('eRequest')) {
                Log::error("❌ ERROR: No se encontró eRequest en la petición");
                return response()->json([
                    'eResponse' => [
                        'success' => false,
                        'message' => 'Petición inválida: No se encontró eRequest',
                    ]
                ], 400);
            }

            $eRequest = $request->input('eRequest');
            Log::info("🔍 PARSED INPUT: " . json_encode($eRequest));

            if (empty($eRequest['Operacion'])) {
                throw new Exception('El campo eRequest.Operacion es requerido');
            }
            if (empty($eRequest['Base'])) {
                throw new Exception('El campo eRequest.Base es requerido');
            }

            $operacion = strtolower($eRequest['Operacion']); // Convertir a minúsculas
            $base = strtolower($eRequest['Base']); // Convertir a minúsculas
            $parametros = $eRequest['Parametros'] ?? [];
            $paginacion = $eRequest['Paginacion'] ?? null;
            $tenant = $eRequest['Tenant'] ?? '';
            $esquemaRequest = $eRequest['Esquema'] ?? null; // Esquema opcional desde el request

            Log::info("🔍 Variables extraídas: operacion={$operacion}, base={$base}, parametros=" . count($parametros) . ", tenant={$tenant}, esquema={$esquemaRequest}");

            $moduleDbConfig = $this->getModuleDbConfig();
            $config = $moduleDbConfig[$base] ?? $moduleDbConfig['default'];
            $dbname = $config['database'];
            $schemaDefault = $config['schema']; // Esquema por defecto (public)
            $allowedSchemas = $config['allowed_schemas'] ?? ['public'];

            // Si viene esquema en el request, validar que sea permitido
            if ($esquemaRequest) {
                $esquemaRequest = strtolower($esquemaRequest);
                if (!in_array($esquemaRequest, $allowedSchemas)) {
                    throw new Exception("El esquema '{$esquemaRequest}' no es permitido para la base '{$base}'. Esquemas permitidos: " . implode(', ', $allowedSchemas));
                }
                $schema = $esquemaRequest; // Usar el esquema del request
            } else {
                $schema = $schemaDefault; // Usar esquema por defecto (public)
            }

            Log::info("🔍 Módulo: {$base} -> Base: {$dbname}, Esquema: {$schema} (default: {$schemaDefault}, allowed: " . implode(', ', $allowedSchemas) . ")");

            $host = config('database.connections.pgsql.host');
            $port = config('database.connections.pgsql.port');
            $username = config('database.connections.pgsql.username');
            $password = config('database.connections.pgsql.password');

            Log::info("🔍 Conectando a la base de datos: host={$host}, port={$port}, dbname={$dbname}");
            $dsn = "pgsql:host={$host};port={$port};dbname={$dbname}";
            $pdo = new PDO($dsn, $username, $password);
            $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
            Log::info("✅ Conexión a DB exitosa");

            $spFullName = $schema . '.' . $operacion;

            $checkSP = $pdo->prepare("
                SELECT routine_name, routine_definition, routine_schema
                FROM information_schema.routines
                WHERE routine_schema = ? AND UPPER(routine_name) = UPPER(?)
            ");
            $checkSP->execute([$schema, $operacion]);
            $spInfo = $checkSP->fetch(PDO::FETCH_ASSOC);

            if (!$spInfo) {
                $findSP = $pdo->prepare("
                    SELECT routine_name, routine_schema
                    FROM information_schema.routines
                    WHERE UPPER(routine_name) = UPPER(?)
                ");
                $findSP->execute([$operacion]);
                $allSPs = $findSP->fetchAll(PDO::FETCH_ASSOC);

                $schemas = $pdo->query("
                    SELECT schema_name
                    FROM information_schema.schemata
                    WHERE schema_name NOT IN ('information_schema', 'pg_catalog', 'pg_toast')
                    ORDER BY schema_name
                ")->fetchAll(PDO::FETCH_COLUMN);

                $debugMsg = "El Stored Procedure '{$operacion}' no existe en el esquema '{$schema}'. ";
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

            $spParametros = [];
            $paramMap = [];

            foreach ($parametros as $param) {
                if (isset($param['nombre']) && array_key_exists('valor', $param)) {
                    $valor = $param['valor'];
                    $tipo = $param['tipo'] ?? 'string';

                    if ($valor !== null) {
                        switch ($tipo) {
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
                            case 'integer_array':
                            case 'int_array':
                                // Convertir array JSON a formato PostgreSQL array {1,2,3}
                                if (is_string($valor)) {
                                    $decoded = json_decode($valor, true);
                                    if (is_array($decoded)) {
                                        $valor = '{' . implode(',', array_map('intval', $decoded)) . '}';
                                    } else {
                                        $valor = '{}'; // Array vacío si no se puede decodificar
                                    }
                                } elseif (is_array($valor)) {
                                    $valor = '{' . implode(',', array_map('intval', $valor)) . '}';
                                } else {
                                    $valor = '{}';
                                }
                                break;
                            default:
                                $valor = strval($valor);
                        }
                    }
                    // Mantener null como null para que el SP pueda usar sus valores por defecto

                    $paramMap[$param['nombre']] = $valor;
                }
            }

            foreach ($parametros as $param) {
                if (isset($param['nombre'])) {
                    $spParametros[] = $paramMap[$param['nombre']];
                }
            }

            $placeholders = str_repeat('?,', count($spParametros));
            $placeholders = rtrim($placeholders, ',');
            $sql = "SELECT * FROM {$spFullName}({$placeholders})";

            $appendLimit = false;
            $limit = null; $offset = null;
            if (is_array($paginacion)) {
                if (isset($paginacion['limit']) && $paginacion['limit'] !== null && $paginacion['limit'] !== '') {
                    $appendLimit = true;
                    $limit = (int)$paginacion['limit'];
                    $offset = isset($paginacion['offset']) ? (int)$paginacion['offset'] : 0;
                }
            }

            if ($appendLimit) {
                $sql .= " LIMIT ? OFFSET ?";
            }

            Log::info("🔍 Ejecutando SP: {$sql}");
            Log::info("🔍 Parámetros: " . json_encode($spParametros));

            $stmt = $pdo->prepare($sql);
            $execParams = $spParametros;
            if ($appendLimit) {
                $execParams[] = $limit;
                $execParams[] = $offset;
            }
            $stmt->execute($execParams);

            Log::info("🔍 SP ejecutado, obteniendo resultados...");
            $result = $stmt->fetchAll(PDO::FETCH_ASSOC);

            // Convertir booleanos de PostgreSQL ('t'/'f') a booleanos de PHP (true/false)
            foreach ($result as &$row) {
                foreach ($row as $key => &$value) {
                    if ($value === 't') {
                        $value = true;
                    } elseif ($value === 'f') {
                        $value = false;
                    }
                }
            }

            Log::info("✅ SP completado. Resultados: " . count($result) . " registros");

            $testConnection = $pdo->query('SELECT current_database(), current_user, version()');
            $connectionInfo = $testConnection->fetch(PDO::FETCH_ASSOC);

            $debugInfo = [
                'connection' => $connectionInfo,
                'sp_name' => $spFullName,
                'sp_exists' => true,
                'sql_executed' => $sql,
                'parameters_sent' => $execParams,
                'parameters_original' => $parametros,
                'parameters_count' => count($spParametros)
            ];

            Log::info("✅ Devolviendo respuesta exitosa con " . count($result) . " registros");
            return response()->json([
                'eResponse' => [
                    'success' => true,
                    'message' => 'Operación completada exitosamente',
                    'data' => [
                        'result' => $result,
                        'count' => count($result),
                        'debug' => $debugInfo
                    ],
                    'timestamp' => now()->toIso8601String()
                ]
            ]);

        } catch (Exception $e) {
            Log::error("Error API: " . $e->getMessage());
            Log::error("Error Trace: " . $e->getTraceAsString());

            return response()->json([
                'eResponse' => [
                    'success' => false,
                    'message' => $e->getMessage(),
                    'data' => null,
                    'timestamp' => now()->toIso8601String(),
                    'debug_error' => $e->getTraceAsString()
                ]
            ], 500);
        }
    }
}

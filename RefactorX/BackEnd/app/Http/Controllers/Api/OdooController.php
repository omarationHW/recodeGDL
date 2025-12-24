<?php

namespace App\Http\Controllers\Api;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\Validator;
use App\Services\JwtService;
use Exception;
use PDO;

/**
 * @OA\Tag(
 *     name="Odoo Integration",
 *     description="API de integración con Odoo - Servicios de consulta y pagos"
 * )
 */
class OdooController
{
    private $jwtService;

    public function __construct(JwtService $jwtService)
    {
        $this->jwtService = $jwtService;
    }

    /**
     * Configuración de bases de datos por interfaz
     */
    private function getInterfazDbConfig()
    {
        return [
            8 => ['database' => 'padron_licencias', 'schema' => 'informix', 'modulo' => 'Informix'],
            9 => ['database' => 'padron_licencias', 'schema' => 'informix', 'modulo' => 'Informix'],
            10 => ['database' => 'padron_licencias', 'schema' => 'informix', 'modulo' => 'Informix'],
            11 => ['database' => 'padron_licencias', 'schema' => 'informix', 'modulo' => 'Informix'],
            12 => ['database' => 'padron_licencias', 'schema' => 'informix', 'modulo' => 'Informix'],
            13 => ['database' => 'padron_licencias', 'schema' => 'informix', 'modulo' => 'Informix'],
            14 => ['database' => 'padron_licencias', 'schema' => 'informix', 'modulo' => 'Informix'],
            15 => ['database' => 'padron_licencias', 'schema' => 'informix', 'modulo' => 'Informix'],
            16 => ['database' => 'padron_movilidad', 'schema' => 'informix', 'modulo' => 'Movilidad'],
            17 => ['database' => 'padron_obras', 'schema' => 'informix', 'modulo' => 'Obras'],
            18 => ['database' => 'padron_licencias', 'schema' => 'informix', 'modulo' => 'Informix'],
            19 => ['database' => 'padron_licencias', 'schema' => 'informix', 'modulo' => 'Informix'],
            22 => ['database' => 'padron_licencias', 'schema' => 'informix', 'modulo' => 'Informix'],
            23 => ['database' => 'padron_licencias', 'schema' => 'informix', 'modulo' => 'Informix'],
            25 => ['database' => 'padron_licencias', 'schema' => 'informix', 'modulo' => 'Informix'],
            30 => ['database' => 'padron_licencias', 'schema' => 'informix', 'modulo' => 'Informix'],
            32 => ['database' => 'padron_infracciones', 'schema' => 'informix', 'modulo' => 'Infracciones'],
            88 => ['database' => 'padron_sicam', 'schema' => 'informix', 'modulo' => 'SICAM'],
        ];
    }

    /**
     * @OA\Post(
     *     path="/api/odoo",
     *     summary="Endpoint único para servicios de Odoo",
     *     description="Endpoint unificado que maneja todos los servicios de integración con Odoo. Funciones disponibles: Consulta, DatosVarios, AdeudoDetalle, Pago, Cancelacion, ConsCuenta, CatDescuentos, ListDescuentos, AltaDescuentos, CancelDescuentos, y más. Interfaces soportadas: 8-15, 18-19, 22-23, 25, 30 (Informix), 16 (Movilidad), 17 (Obras), 32 (Infracciones), 88 (SICAM). Autenticación: Header Authorization Bearer o campo Token en eRequest.",
     *     tags={"Odoo Integration"},
     *     security={{"bearerAuth": {}}},
     *     @OA\RequestBody(
     *         required=true,
     *         description="Request con estructura eRequest que contiene Funcion, Token y Parametros.",
     *         @OA\JsonContent(
     *             required={"eRequest"},
     *             @OA\Property(
     *                 property="eRequest",
     *                 type="object",
     *                 required={"Funcion", "Token"},
     *                 @OA\Property(property="Funcion", type="string", example="Consulta", description="Nombre de la función a ejecutar"),
     *                 @OA\Property(property="Token", type="string", example="eyJ0eXAiOiJKV1QiLCJhbGc...", description="Token JWT"),
     *                 @OA\Property(
     *                     property="Parametros",
     *                     type="object",
     *                     description="Parámetros específicos de cada función",
     *                     @OA\Property(property="Idinterfaz", type="integer", example=8),
     *                     @OA\Property(property="cta_01", type="string", example="12345678"),
     *                     @OA\Property(property="referencia_pago", type="string", example="REF123")
     *                 )
     *             )
     *         )
     *     ),
     *     @OA\Response(
     *         response=200,
     *         description="Operación exitosa - Consulta",
     *         @OA\JsonContent(
     *             @OA\Property(property="eResponse", type="object",
     *                 @OA\Property(property="success", type="boolean", example=true),
     *                 @OA\Property(property="message", type="string", example="Operación completada exitosamente"),
     *                 @OA\Property(
     *                     property="data",
     *                     type="object",
     *                     @OA\Property(property="nombre", type="string", example="JUAN PEREZ GARCIA"),
     *                     @OA\Property(property="domicilio", type="string", example="AV REVOLUCION 123"),
     *                     @OA\Property(property="colonia", type="string", example="CENTRO"),
     *                     @OA\Property(property="municipio", type="string", example="GUADALAJARA"),
     *                     @OA\Property(property="estado", type="string", example="JALISCO"),
     *                     @OA\Property(property="rfc", type="string", example="PEGJ800101XXX"),
     *                     @OA\Property(property="estatus", type="integer", example=0),
     *                     @OA\Property(property="mensaje_est", type="string", example="OK")
     *                 ),
     *                 @OA\Property(property="timestamp", type="string", format="date-time", example="2025-02-11T10:30:00Z")
     *             )
     *         )
     *     ),
     *     @OA\Response(
     *         response=400,
     *         description="Petición inválida",
     *         @OA\JsonContent(
     *             @OA\Property(property="eResponse", type="object",
     *                 @OA\Property(property="success", type="boolean", example=false),
     *                 @OA\Property(property="message", type="string", example="Validación fallida: El campo Funcion es requerido"),
     *                 @OA\Property(property="data", type="null"),
     *                 @OA\Property(property="timestamp", type="string", example="2025-02-11T10:30:00Z")
     *             )
     *         )
     *     ),
     *     @OA\Response(
     *         response=401,
     *         description="Token inválido o expirado",
     *         @OA\JsonContent(
     *             @OA\Property(property="eResponse", type="object",
     *                 @OA\Property(property="success", type="boolean", example=false),
     *                 @OA\Property(property="message", type="string", example="Token inválido o expirado"),
     *                 @OA\Property(property="data", type="null"),
     *                 @OA\Property(property="timestamp", type="string", example="2025-02-11T10:30:00Z")
     *             )
     *         )
     *     ),
     *     @OA\Response(
     *         response=500,
     *         description="Error del servidor",
     *         @OA\JsonContent(
     *             @OA\Property(property="eResponse", type="object",
     *                 @OA\Property(property="success", type="boolean", example=false),
     *                 @OA\Property(property="message", type="string", example="Error en la base de datos: Connection refused"),
     *                 @OA\Property(property="data", type="null"),
     *                 @OA\Property(property="timestamp", type="string", example="2025-02-11T10:30:00Z")
     *             )
     *         )
     *     )
     * )
     */
    public function execute(Request $request)
    {
        try {
            Log::info("🌐 ODOO REQUEST: " . $request->method() . " " . $request->path());
            Log::info("🔍 RAW INPUT: " . $request->getContent());

            // Validar que existe eRequest
            if (!$request->has('eRequest')) {
                return $this->errorResponse('Petición inválida: No se encontró eRequest', 400);
            }

            $eRequest = $request->input('eRequest');
            Log::info("🔍 PARSED INPUT: " . json_encode($eRequest));

            // Validar campos obligatorios
            $validator = Validator::make($eRequest, [
                'Funcion' => 'required|string',
                'Token' => 'required|string',
                'Parametros' => 'array'
            ]);

            if ($validator->fails()) {
                return $this->errorResponse('Validación fallida: ' . $validator->errors()->first(), 400);
            }

            // Validar token
            if (!$this->validateToken($eRequest['Token'])) {
                return $this->errorResponse('Token inválido o expirado', 401);
            }

            $funcion = $eRequest['Funcion'];
            $parametros = $eRequest['Parametros'] ?? [];

            Log::info("🔍 Ejecutando función: {$funcion}");

            // Enrutar a la función correspondiente
            $resultado = $this->routeFunction($funcion, $parametros);

            return $this->successResponse($resultado);

        } catch (Exception $e) {
            Log::error("❌ Error ODOO API: " . $e->getMessage());
            Log::error("Error Trace: " . $e->getTraceAsString());
            return $this->errorResponse($e->getMessage(), 500);
        }
    }

    /**
     * Validar token de autenticación (JWT)
     */
    private function validateToken($token)
    {
        // Intentar validar como JWT primero
        $clientData = $this->jwtService->getClientFromToken($token);

        if ($clientData) {
            Log::info('✅ Token JWT válido', [
                'client_id' => $clientData['client_id'],
                'expires_at' => $clientData['expires_at'],
                'time_left' => $clientData['time_left']
            ]);
            return true;
        }

        // Fallback: validar tokens estáticos (para retrocompatibilidad)
        $validTokens = config('odoo.valid_tokens', []);
        if (in_array($token, $validTokens)) {
            Log::warning('⚠️ Usando token estático (deprecated)', [
                'token_preview' => substr($token, 0, 10) . '...'
            ]);
            return true;
        }

        Log::error('❌ Token inválido o expirado');
        return false;
    }

    /**
     * Enrutar a la función correspondiente
     */
    private function routeFunction($funcion, $parametros)
    {
        $funciones = [
            'Consulta' => 'consulta',
            'DatosVarios' => 'datosVarios',
            'AdeudoDetalle' => 'adeudoDetalle',
            'AdeudoDetalleInmovilizadores' => 'adeudoDetalleInmovilizadores',
            'Pago' => 'pago',
            'Cancelacion' => 'cancelacion',
            'ConsCuenta' => 'consCuenta',
            'CatDescuentos' => 'catDescuentos',
            'ListDescuentos' => 'listDescuentos',
            'AltaDescuentos' => 'altaDescuentos',
            'CancelDescuentos' => 'cancelDescuentos',
            'ConsDesctoTablet' => 'consDesctoTablet',
            'AltaDesctoTablet' => 'altaDesctoTablet',
            'FechasPendientesEl' => 'fechasPendientesEl',
            'PendientesXIntegrar' => 'pendientesXIntegrar',
            'DetallesXIntegrar' => 'detallesXIntegrar',
            'ActualizarPendientes' => 'actualizarPendientes',
            'LicenciaVisor' => 'licenciaVisor',
        ];

        if (!isset($funciones[$funcion])) {
            throw new Exception("Función '{$funcion}' no encontrada. Funciones disponibles: " . implode(', ', array_keys($funciones)));
        }

        $metodo = $funciones[$funcion];
        return $this->$metodo($parametros);
    }

    /**
     * Función: Consulta
     * Consulta al origen de datos por medio de una llave de referencia
     */
    private function consulta($params)
    {
        // Validación
        $validator = Validator::make($params, [
            'Idinterfaz' => 'required|integer',
            'cta_01' => 'nullable|string',
            'cta_02' => 'nullable|string',
            'cta_03' => 'nullable|string',
            'cta_04' => 'nullable|string',
            'cta_05' => 'nullable|string',
            'cta_06' => 'nullable|string',
            'referencia_pago' => 'nullable|string',
        ]);

        if ($validator->fails()) {
            throw new Exception('Parámetros inválidos: ' . $validator->errors()->first());
        }

        $idInterfaz = $params['Idinterfaz'];

        // Mapear interfaz a función específica
        $interfazNormalizada = $this->normalizarInterfaz($idInterfaz);

        switch ($interfazNormalizada) {
            case 8:
                return $this->consultaIfx($params);
            case 16:
                return $this->consultaMovilidad($params);
            case 17:
                return $this->consultaObras($params);
            case 32:
                return $this->consultaInfracc($params);
            case 88:
                return $this->consultaPredialSICAM($params);
            default:
                return [
                    'nombre' => '',
                    'domicilio' => '',
                    'no_ext' => '',
                    'no_int' => '',
                    'colonia' => '',
                    'municipio' => '',
                    'estado' => '',
                    'rfc' => '',
                    'curp' => '',
                    'observacion' => 'Interfaz no existente',
                    'estatus' => 1001,
                    'mensaje_est' => 'ERROR'
                ];
        }
    }

    /**
     * Función: DatosVarios
     * Consulta datos complementarios
     */
    private function datosVarios($params)
    {
        $validator = Validator::make($params, [
            'Idinterfaz' => 'required|integer',
            'cta_01' => 'nullable|string',
            'cta_02' => 'nullable|string',
            'referencia_pago' => 'nullable|string',
        ]);

        if ($validator->fails()) {
            throw new Exception('Parámetros inválidos: ' . $validator->errors()->first());
        }

        $interfazNormalizada = $this->normalizarInterfaz($params['Idinterfaz']);

        switch ($interfazNormalizada) {
            case 8:
                return $this->datosIfx($params);
            case 16:
                return $this->datosMovilidad($params);
            case 17:
                return $this->datosObras($params);
            case 32:
                return $this->datosInfracc($params);
            default:
                throw new Exception('Interfaz no soportada para DatosVarios');
        }
    }

    /**
     * Función: AdeudoDetalle
     * Detalle de adeudos por concepto
     */
    private function adeudoDetalle($params)
    {
        $validator = Validator::make($params, [
            'Idinterfaz' => 'required|integer',
            'cta_01' => 'nullable|string',
            'referencia_pago' => 'nullable|string',
        ]);

        if ($validator->fails()) {
            throw new Exception('Parámetros inválidos: ' . $validator->errors()->first());
        }

        $interfazNormalizada = $this->normalizarInterfaz($params['Idinterfaz']);

        switch ($interfazNormalizada) {
            case 8:
                return $this->detalleIfx($params);
            case 16:
                return $this->detalleMovilidad($params);
            case 17:
                return $this->detalleObras($params);
            case 32:
                return $this->detalleInfracc($params);
            case 88:
                return $this->detallePredialSICAM($params);
            default:
                throw new Exception('Interfaz no soportada para AdeudoDetalle');
        }
    }

    /**
     * Función: AdeudoDetalleInmovilizadores
     * Específico para infracciones de movilidad
     */
    private function adeudoDetalleInmovilizadores($params)
    {
        $validator = Validator::make($params, [
            'Idinterfaz' => 'required|integer',
            'cta_01' => 'required|string',
            'referencia_pago' => 'nullable|string',
        ]);

        if ($validator->fails()) {
            throw new Exception('Parámetros inválidos: ' . $validator->errors()->first());
        }

        if ($params['Idinterfaz'] != 16) {
            throw new Exception('Esta función solo está disponible para interfaz 16 (Movilidad)');
        }

        return $this->detalleMovilidadInmovilizadores($params);
    }

    /**
     * Función: Pago
     * Registra un pago realizado
     */
    private function pago($params)
    {
        $validator = Validator::make($params, [
            'Idinterfaz' => 'required|integer',
            'cta_01' => 'nullable|string',
            'referencia_pago' => 'required|string',
            'monto_certificado' => 'required|numeric',
            'monto_cartera' => 'required|numeric',
            'monto_redondeo' => 'nullable|numeric',
            'id_cobro' => 'required|integer',
            'folio_recibo' => 'required|string',
            'fecha_pago' => 'required|string',
            'recaudadora' => 'required|integer',
            'centro' => 'required|integer',
            'caja' => 'required|string',
        ]);

        if ($validator->fails()) {
            throw new Exception('Parámetros inválidos para Pago: ' . $validator->errors()->first());
        }

        $interfazNormalizada = $this->normalizarInterfaz($params['Idinterfaz']);

        switch ($interfazNormalizada) {
            case 8:
                return $this->pagoIfx($params);
            case 16:
                return $this->pagoMovilidad($params);
            case 17:
                return $this->pagoObras($params);
            case 32:
                return $this->pagoInfraccion($params);
            case 88:
                return $this->pagoPredialSICAM($params);
            default:
                return ['codigo' => 1001, 'mensaje' => 'REFERENCIA INVALIDA'];
        }
    }

    /**
     * Función: Cancelacion
     * Cancela un pago registrado
     */
    private function cancelacion($params)
    {
        $validator = Validator::make($params, [
            'Idinterfaz' => 'required|integer',
            'id_cobro' => 'required|integer',
            'folio_recibo' => 'required|string',
        ]);

        if ($validator->fails()) {
            throw new Exception('Parámetros inválidos: ' . $validator->errors()->first());
        }

        $interfazNormalizada = $this->normalizarInterfaz($params['Idinterfaz']);

        switch ($interfazNormalizada) {
            case 8:
                return $this->cancelacionIfx($params);
            case 16:
                return $this->cancelacionMovilidad($params);
            case 17:
                return $this->cancelacionObras($params);
            case 32:
                return $this->cancelacionInfraccion($params);
            case 88:
                return $this->cancelacionPredialSICAM($params);
            default:
                return ['codigo' => 1001, 'mensaje' => 'REFERENCIA INVALIDA'];
        }
    }

    /**
     * Función: ConsCuenta
     * Consulta cuenta predial por ID
     */
    private function consCuenta($params)
    {
        $validator = Validator::make($params, [
            'Idcuenta' => 'required|integer',
        ]);

        if ($validator->fails()) {
            throw new Exception('Parámetros inválidos: ' . $validator->errors()->first());
        }

        return $this->ejecutarSP('consultascuentas', [
            ['nombre' => 'p_idcuenta', 'valor' => $params['Idcuenta'], 'tipo' => 'integer']
        ], 'padron_licencias');
    }

    /**
     * Función: CatDescuentos
     * Obtiene catálogo de descuentos disponibles
     */
    private function catDescuentos($params)
    {
        $validator = Validator::make($params, [
            'Idcuenta' => 'required|integer',
        ]);

        if ($validator->fails()) {
            throw new Exception('Parámetros inválidos: ' . $validator->errors()->first());
        }

        return $this->ejecutarSP('catalogodescuentos', [
            ['nombre' => 'p_idcuenta', 'valor' => $params['Idcuenta'], 'tipo' => 'integer']
        ], 'padron_licencias');
    }

    /**
     * Función: ListDescuentos
     * Lista descuentos de ley aplicados
     */
    private function listDescuentos($params)
    {
        $validator = Validator::make($params, [
            'Idcuenta' => 'required|integer',
        ]);

        if ($validator->fails()) {
            throw new Exception('Parámetros inválidos: ' . $validator->errors()->first());
        }

        return $this->ejecutarSP('listadescuentos', [
            ['nombre' => 'p_idcuenta', 'valor' => $params['Idcuenta'], 'tipo' => 'integer']
        ], 'padron_licencias');
    }

    /**
     * Función: AltaDescuentos
     * Registra un nuevo descuento
     */
    private function altaDescuentos($params)
    {
        $validator = Validator::make($params, [
            'Idcuenta' => 'required|integer',
            'IdDescuento' => 'required|integer',
            'bimini' => 'required|string',
            'bimfin' => 'required|string',
            'propietario' => 'nullable|string',
            'solicitante' => 'nullable|string',
            'recaudadora' => 'nullable|string',
            'folioDescto' => 'nullable|string',
            'identificacion' => 'nullable|string',
            'fechaNacimiento' => 'nullable|string',
        ]);

        if ($validator->fails()) {
            throw new Exception('Parámetros inválidos: ' . $validator->errors()->first());
        }

        return $this->ejecutarSP('altasdescuentos', [
            ['nombre' => 'p_idcuenta', 'valor' => $params['Idcuenta'], 'tipo' => 'integer'],
            ['nombre' => 'p_iddescuento', 'valor' => $params['IdDescuento'], 'tipo' => 'integer'],
            ['nombre' => 'p_bimini', 'valor' => $params['bimini'], 'tipo' => 'string'],
            ['nombre' => 'p_bimfin', 'valor' => $params['bimfin'], 'tipo' => 'string'],
            ['nombre' => 'p_propietario', 'valor' => $params['propietario'] ?? '', 'tipo' => 'string'],
            ['nombre' => 'p_solicitante', 'valor' => $params['solicitante'] ?? '', 'tipo' => 'string'],
            ['nombre' => 'p_recaudadora', 'valor' => $params['recaudadora'] ?? '', 'tipo' => 'string'],
            ['nombre' => 'p_foliodescto', 'valor' => $params['folioDescto'] ?? '', 'tipo' => 'string'],
            ['nombre' => 'p_identificacion', 'valor' => $params['identificacion'] ?? '', 'tipo' => 'string'],
            ['nombre' => 'p_fechanacimiento', 'valor' => $params['fechaNacimiento'] ?? '', 'tipo' => 'string'],
        ], 'padron_licencias');
    }

    /**
     * Normalizar interfaz (8-15, 18-19, 22-23, 25, 30 se mapean a 8)
     */
    private function normalizarInterfaz($idInterfaz)
    {
        $interfacesIfx = [8, 9, 10, 11, 12, 13, 14, 15, 18, 19, 22, 23, 25, 30];

        if (in_array($idInterfaz, $interfacesIfx)) {
            return 8;
        }

        return $idInterfaz;
    }

    /**
     * Ejecutar Stored Procedure genérico
     */
    private function ejecutarSP($spName, $parametros, $database = 'padron_licencias', $schema = 'informix')
    {
        $host = config('database.connections.pgsql.host');
        $port = config('database.connections.pgsql.port');
        $username = config('database.connections.pgsql.username');
        $password = config('database.connections.pgsql.password');

        $dsn = "pgsql:host={$host};port={$port};dbname={$database}";
        $pdo = new PDO($dsn, $username, $password);
        $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

        $spFullName = $schema . '.' . $spName;

        $spParametros = [];
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
                        default:
                            $valor = strval($valor);
                    }
                }

                $spParametros[] = $valor;
            }
        }

        $placeholders = str_repeat('?,', count($spParametros));
        $placeholders = rtrim($placeholders, ',');
        $sql = "SELECT * FROM {$spFullName}({$placeholders})";

        Log::info("🔍 Ejecutando SP: {$sql}");
        Log::info("🔍 Parámetros: " . json_encode($spParametros));

        $stmt = $pdo->prepare($sql);
        $stmt->execute($spParametros);

        $result = $stmt->fetchAll(PDO::FETCH_ASSOC);

        return $result;
    }

    // ========== Funciones específicas por interfaz ==========

    private function consultaIfx($params)
    {
        return $this->ejecutarSP('consultaifx', [
            ['nombre' => 'p_idinterfaz', 'valor' => $params['Idinterfaz'], 'tipo' => 'integer'],
            ['nombre' => 'p_cta_01', 'valor' => $params['cta_01'] ?? '', 'tipo' => 'string'],
            ['nombre' => 'p_cta_02', 'valor' => $params['cta_02'] ?? '', 'tipo' => 'string'],
            ['nombre' => 'p_cta_03', 'valor' => $params['cta_03'] ?? '', 'tipo' => 'string'],
            ['nombre' => 'p_cta_04', 'valor' => $params['cta_04'] ?? '', 'tipo' => 'string'],
            ['nombre' => 'p_cta_05', 'valor' => $params['cta_05'] ?? '', 'tipo' => 'string'],
            ['nombre' => 'p_cta_06', 'valor' => $params['cta_06'] ?? '', 'tipo' => 'string'],
            ['nombre' => 'p_referencia_pago', 'valor' => $params['referencia_pago'] ?? '', 'tipo' => 'string'],
        ], 'padron_licencias');
    }

    private function consultaMovilidad($params)
    {
        return $this->ejecutarSP('consultamovilidad', [
            ['nombre' => 'p_cta_01', 'valor' => $params['cta_01'] ?? '', 'tipo' => 'string'],
            ['nombre' => 'p_cta_02', 'valor' => $params['cta_02'] ?? '', 'tipo' => 'string'],
            ['nombre' => 'p_referencia_pago', 'valor' => $params['referencia_pago'] ?? '', 'tipo' => 'string'],
        ], 'padron_movilidad');
    }

    private function consultaObras($params)
    {
        return $this->ejecutarSP('consultaobras', [
            ['nombre' => 'p_idinterfaz', 'valor' => $params['Idinterfaz'], 'tipo' => 'integer'],
            ['nombre' => 'p_cta_01', 'valor' => $params['cta_01'] ?? '', 'tipo' => 'string'],
            ['nombre' => 'p_referencia_pago', 'valor' => $params['referencia_pago'] ?? '', 'tipo' => 'string'],
        ], 'padron_obras');
    }

    private function consultaInfracc($params)
    {
        return $this->ejecutarSP('consultainfracc', [
            ['nombre' => 'p_idinterfaz', 'valor' => $params['Idinterfaz'], 'tipo' => 'integer'],
            ['nombre' => 'p_cta_01', 'valor' => $params['cta_01'] ?? '', 'tipo' => 'string'],
            ['nombre' => 'p_referencia_pago', 'valor' => $params['referencia_pago'] ?? '', 'tipo' => 'string'],
        ], 'padron_infracciones');
    }

    private function consultaPredialSICAM($params)
    {
        return $this->ejecutarSP('consultapredialsicam', [
            ['nombre' => 'p_cta_01', 'valor' => $params['cta_01'] ?? '', 'tipo' => 'string'],
            ['nombre' => 'p_referencia_pago', 'valor' => $params['referencia_pago'] ?? '', 'tipo' => 'string'],
        ], 'padron_sicam');
    }

    private function datosIfx($params)
    {
        return $this->ejecutarSP('datosifx', [
            ['nombre' => 'p_idinterfaz', 'valor' => $params['Idinterfaz'], 'tipo' => 'integer'],
            ['nombre' => 'p_cta_01', 'valor' => $params['cta_01'] ?? '', 'tipo' => 'string'],
            ['nombre' => 'p_referencia_pago', 'valor' => $params['referencia_pago'] ?? '', 'tipo' => 'string'],
        ], 'padron_licencias');
    }

    private function datosMovilidad($params)
    {
        return $this->ejecutarSP('datosmovilidad', [
            ['nombre' => 'p_cta_01', 'valor' => $params['cta_01'] ?? '', 'tipo' => 'string'],
            ['nombre' => 'p_referencia_pago', 'valor' => $params['referencia_pago'] ?? '', 'tipo' => 'string'],
        ], 'padron_movilidad');
    }

    private function datosObras($params)
    {
        return $this->ejecutarSP('datosobras', [
            ['nombre' => 'p_cta_01', 'valor' => $params['cta_01'] ?? '', 'tipo' => 'string'],
            ['nombre' => 'p_referencia_pago', 'valor' => $params['referencia_pago'] ?? '', 'tipo' => 'string'],
        ], 'padron_obras');
    }

    private function datosInfracc($params)
    {
        return $this->ejecutarSP('datosinfracc', [
            ['nombre' => 'p_cta_01', 'valor' => $params['cta_01'] ?? '', 'tipo' => 'string'],
            ['nombre' => 'p_referencia_pago', 'valor' => $params['referencia_pago'] ?? '', 'tipo' => 'string'],
        ], 'padron_infracciones');
    }

    private function detalleIfx($params)
    {
        return $this->ejecutarSP('detalleifx', [
            ['nombre' => 'p_idinterfaz', 'valor' => $params['Idinterfaz'], 'tipo' => 'integer'],
            ['nombre' => 'p_cta_01', 'valor' => $params['cta_01'] ?? '', 'tipo' => 'string'],
            ['nombre' => 'p_referencia_pago', 'valor' => $params['referencia_pago'] ?? '', 'tipo' => 'string'],
        ], 'padron_licencias');
    }

    private function detalleMovilidad($params)
    {
        return $this->ejecutarSP('detallemovilidad', [
            ['nombre' => 'p_cta_01', 'valor' => $params['cta_01'] ?? '', 'tipo' => 'string'],
            ['nombre' => 'p_referencia_pago', 'valor' => $params['referencia_pago'] ?? '', 'tipo' => 'string'],
        ], 'padron_movilidad');
    }

    private function detalleMovilidadInmovilizadores($params)
    {
        return $this->ejecutarSP('detallemovilidadinmovilizadores', [
            ['nombre' => 'p_cta_01', 'valor' => $params['cta_01'], 'tipo' => 'string'],
            ['nombre' => 'p_referencia_pago', 'valor' => $params['referencia_pago'] ?? '', 'tipo' => 'string'],
        ], 'padron_movilidad');
    }

    private function detalleObras($params)
    {
        return $this->ejecutarSP('detalleobras', [
            ['nombre' => 'p_cta_01', 'valor' => $params['cta_01'] ?? '', 'tipo' => 'string'],
            ['nombre' => 'p_referencia_pago', 'valor' => $params['referencia_pago'] ?? '', 'tipo' => 'string'],
        ], 'padron_obras');
    }

    private function detalleInfracc($params)
    {
        return $this->ejecutarSP('detalleinfracc', [
            ['nombre' => 'p_cta_01', 'valor' => $params['cta_01'] ?? '', 'tipo' => 'string'],
            ['nombre' => 'p_referencia_pago', 'valor' => $params['referencia_pago'] ?? '', 'tipo' => 'string'],
        ], 'padron_infracciones');
    }

    private function detallePredialSICAM($params)
    {
        return $this->ejecutarSP('detallepredialsicam', [
            ['nombre' => 'p_cta_01', 'valor' => $params['cta_01'] ?? '', 'tipo' => 'string'],
            ['nombre' => 'p_referencia_pago', 'valor' => $params['referencia_pago'] ?? '', 'tipo' => 'string'],
        ], 'padron_sicam');
    }

    private function pagoIfx($params)
    {
        return $this->ejecutarSP('pagoifx', [
            ['nombre' => 'p_idinterfaz', 'valor' => $params['Idinterfaz'], 'tipo' => 'integer'],
            ['nombre' => 'p_cta_01', 'valor' => $params['cta_01'] ?? '', 'tipo' => 'string'],
            ['nombre' => 'p_referencia_pago', 'valor' => $params['referencia_pago'], 'tipo' => 'string'],
            ['nombre' => 'p_monto_certificado', 'valor' => $params['monto_certificado'], 'tipo' => 'numeric'],
            ['nombre' => 'p_monto_cartera', 'valor' => $params['monto_cartera'], 'tipo' => 'numeric'],
            ['nombre' => 'p_id_cobro', 'valor' => $params['id_cobro'], 'tipo' => 'integer'],
            ['nombre' => 'p_folio_recibo', 'valor' => $params['folio_recibo'], 'tipo' => 'string'],
            ['nombre' => 'p_fecha_pago', 'valor' => $params['fecha_pago'], 'tipo' => 'string'],
            ['nombre' => 'p_recaudadora', 'valor' => $params['recaudadora'], 'tipo' => 'integer'],
        ], 'padron_licencias');
    }

    private function pagoMovilidad($params)
    {
        return $this->ejecutarSP('pagomovilidad', [
            ['nombre' => 'p_cta_01', 'valor' => $params['cta_01'] ?? '', 'tipo' => 'string'],
            ['nombre' => 'p_referencia_pago', 'valor' => $params['referencia_pago'], 'tipo' => 'string'],
            ['nombre' => 'p_monto_certificado', 'valor' => $params['monto_certificado'], 'tipo' => 'numeric'],
            ['nombre' => 'p_id_cobro', 'valor' => $params['id_cobro'], 'tipo' => 'integer'],
            ['nombre' => 'p_folio_recibo', 'valor' => $params['folio_recibo'], 'tipo' => 'string'],
        ], 'padron_movilidad');
    }

    private function pagoObras($params)
    {
        return $this->ejecutarSP('pagoobras', [
            ['nombre' => 'p_referencia_pago', 'valor' => $params['referencia_pago'], 'tipo' => 'string'],
            ['nombre' => 'p_monto_certificado', 'valor' => $params['monto_certificado'], 'tipo' => 'numeric'],
            ['nombre' => 'p_id_cobro', 'valor' => $params['id_cobro'], 'tipo' => 'integer'],
        ], 'padron_obras');
    }

    private function pagoInfraccion($params)
    {
        return $this->ejecutarSP('pagoinfraccion', [
            ['nombre' => 'p_referencia_pago', 'valor' => $params['referencia_pago'], 'tipo' => 'string'],
            ['nombre' => 'p_monto_certificado', 'valor' => $params['monto_certificado'], 'tipo' => 'numeric'],
            ['nombre' => 'p_id_cobro', 'valor' => $params['id_cobro'], 'tipo' => 'integer'],
        ], 'padron_infracciones');
    }

    private function pagoPredialSICAM($params)
    {
        return $this->ejecutarSP('pagopredialsicam', [
            ['nombre' => 'p_referencia_pago', 'valor' => $params['referencia_pago'], 'tipo' => 'string'],
            ['nombre' => 'p_monto_certificado', 'valor' => $params['monto_certificado'], 'tipo' => 'numeric'],
            ['nombre' => 'p_id_cobro', 'valor' => $params['id_cobro'], 'tipo' => 'integer'],
        ], 'padron_sicam');
    }

    private function cancelacionIfx($params)
    {
        return $this->ejecutarSP('cancelacionifx', [
            ['nombre' => 'p_id_cobro', 'valor' => $params['id_cobro'], 'tipo' => 'integer'],
            ['nombre' => 'p_folio_recibo', 'valor' => $params['folio_recibo'], 'tipo' => 'string'],
        ], 'padron_licencias');
    }

    private function cancelacionMovilidad($params)
    {
        return $this->ejecutarSP('cancelacionmovilidad', [
            ['nombre' => 'p_id_cobro', 'valor' => $params['id_cobro'], 'tipo' => 'integer'],
            ['nombre' => 'p_folio_recibo', 'valor' => $params['folio_recibo'], 'tipo' => 'string'],
        ], 'padron_movilidad');
    }

    private function cancelacionObras($params)
    {
        return $this->ejecutarSP('cancelacionobras', [
            ['nombre' => 'p_id_cobro', 'valor' => $params['id_cobro'], 'tipo' => 'integer'],
            ['nombre' => 'p_folio_recibo', 'valor' => $params['folio_recibo'], 'tipo' => 'string'],
        ], 'padron_obras');
    }

    private function cancelacionInfraccion($params)
    {
        return $this->ejecutarSP('cancelacioninfraccion', [
            ['nombre' => 'p_id_cobro', 'valor' => $params['id_cobro'], 'tipo' => 'integer'],
            ['nombre' => 'p_folio_recibo', 'valor' => $params['folio_recibo'], 'tipo' => 'string'],
        ], 'padron_infracciones');
    }

    private function cancelacionPredialSICAM($params)
    {
        return $this->ejecutarSP('cancelacionpredialsicam', [
            ['nombre' => 'p_id_cobro', 'valor' => $params['id_cobro'], 'tipo' => 'integer'],
            ['nombre' => 'p_folio_recibo', 'valor' => $params['folio_recibo'], 'tipo' => 'string'],
        ], 'padron_sicam');
    }

    // Funciones restantes (simplificadas - retornan mock data)
    private function consDesctoTablet($params) { return ['mensaje' => 'Implementar SP']; }
    private function altaDesctoTablet($params) { return ['codigo' => 0, 'mensaje' => 'Implementar SP']; }
    private function cancelDescuentos($params) { return ['codigo' => 0, 'mensaje' => 'Implementar SP']; }
    private function fechasPendientesEl($params) { return []; }
    private function pendientesXIntegrar($params) { return []; }
    private function detallesXIntegrar($params) { return []; }
    private function actualizarPendientes($params) { return ['codigo' => 0, 'mensaje' => 'OK']; }
    private function licenciaVisor($params) { return ['licencia_codificada' => 'XXXX']; }

    // ========== Respuestas estandarizadas ==========

    private function successResponse($data)
    {
        return response()->json([
            'eResponse' => [
                'success' => true,
                'message' => 'Operación completada exitosamente',
                'data' => $data,
                'timestamp' => now()->toIso8601String()
            ]
        ]);
    }

    private function errorResponse($message, $code = 500)
    {
        return response()->json([
            'eResponse' => [
                'success' => false,
                'message' => $message,
                'data' => null,
                'timestamp' => now()->toIso8601String()
            ]
        ], $code);
    }
}

<?php

namespace App\Http\Controllers\Api;

/**
 * ==================== SCHEMAS DE REQUEST ====================
 */

/**
 * @OA\Schema(
 *     schema="OdooRequest",
 *     type="object",
 *     required={"eRequest"},
 *     @OA\Property(
 *         property="eRequest",
 *         type="object",
 *         required={"Funcion"},
 *         @OA\Property(property="Funcion", type="string", example="Consulta", description="Nombre de la función a ejecutar"),
 *         @OA\Property(property="Token", type="string", example="eyJ0eXAiOiJKV1QiLCJhbGc...", description="Token JWT (opcional si se usa Authorization header)"),
 *         @OA\Property(
 *             property="Parametros",
 *             type="object",
 *             description="Parámetros específicos de cada función"
 *         )
 *     )
 * )
 */

/**
 * @OA\Schema(
 *     schema="ConsultaRequest",
 *     type="object",
 *     @OA\Property(property="Idinterfaz", type="integer", example=8),
 *     @OA\Property(property="cta_01", type="string", example="12345678"),
 *     @OA\Property(property="cta_02", type="string", example=""),
 *     @OA\Property(property="cta_03", type="string", example=""),
 *     @OA\Property(property="cta_04", type="string", example=""),
 *     @OA\Property(property="cta_05", type="string", example=""),
 *     @OA\Property(property="cta_06", type="string", example=""),
 *     @OA\Property(property="referencia_pago", type="string", example="REF123456789")
 * )
 */

/**
 * @OA\Schema(
 *     schema="PagoRequest",
 *     type="object",
 *     required={"Idinterfaz", "referencia_pago", "monto_certificado", "monto_cartera", "id_cobro", "folio_recibo", "fecha_pago", "recaudadora", "centro", "caja"},
 *     @OA\Property(property="Idinterfaz", type="integer", example=8),
 *     @OA\Property(property="cta_01", type="string", example="12345678"),
 *     @OA\Property(property="referencia_pago", type="string", example="REF123456789"),
 *     @OA\Property(property="pago_tarjeta", type="string", example="1234567890123456"),
 *     @OA\Property(property="monto_certificado", type="number", format="double", example=5250.75),
 *     @OA\Property(property="monto_cartera", type="number", format="double", example=5250.75),
 *     @OA\Property(property="monto_redondeo", type="number", format="double", example=0.25),
 *     @OA\Property(property="id_cobro", type="integer", example=123456),
 *     @OA\Property(property="folio_recibo", type="string", example="REC-2025-001234"),
 *     @OA\Property(property="fecha_pago", type="string", format="date", example="2025-02-11"),
 *     @OA\Property(property="recaudadora", type="integer", example=1),
 *     @OA\Property(property="centro", type="integer", example=1),
 *     @OA\Property(property="caja", type="string", example="CAJA01"),
 *     @OA\Property(property="cc_lugar_pago", type="string", example="GUADALAJARA"),
 *     @OA\Property(property="cc_fecha_pago", type="string", example="2025-02-11 10:30:00"),
 *     @OA\Property(property="cc_referencia", type="string", example="REF-BANCO-001"),
 *     @OA\Property(property="cc_forma_pago", type="string", example="EFECTIVO"),
 *     @OA\Property(property="adicional_1", type="string", example="")
 * )
 */

/**
 * @OA\Schema(
 *     schema="CancelacionRequest",
 *     type="object",
 *     required={"Idinterfaz", "id_cobro", "folio_recibo"},
 *     @OA\Property(property="Idinterfaz", type="integer", example=8),
 *     @OA\Property(property="id_cobro", type="integer", example=123456),
 *     @OA\Property(property="folio_recibo", type="string", example="REC-2025-001234")
 * )
 */

/**
 * @OA\Schema(
 *     schema="JwtTokenRequest",
 *     type="object",
 *     required={"client_id", "client_secret"},
 *     @OA\Property(property="client_id", type="string", example="odoo-client-001", description="ID del cliente autorizado"),
 *     @OA\Property(property="client_secret", type="string", example="mi-super-secreto-produccion-2025", description="Secreto del cliente"),
 *     @OA\Property(property="client_name", type="string", example="Odoo Production", description="Nombre descriptivo del cliente"),
 *     @OA\Property(
 *         property="permissions",
 *         type="array",
 *         description="Permisos del cliente",
 *         @OA\Items(type="string", example="consulta")
 *     )
 * )
 */

/**
 * @OA\Schema(
 *     schema="JwtValidateRequest",
 *     type="object",
 *     required={"token"},
 *     @OA\Property(property="token", type="string", example="eyJ0eXAiOiJKV1QiLCJhbGc...")
 * )
 */

/**
 * ==================== SCHEMAS DE RESPONSE ====================
 */

/**
 * @OA\Schema(
 *     schema="OdooResponse",
 *     type="object",
 *     @OA\Property(
 *         property="eResponse",
 *         type="object",
 *         @OA\Property(property="success", type="boolean", example=true),
 *         @OA\Property(property="message", type="string", example="Operación completada exitosamente"),
 *         @OA\Property(property="data", type="object"),
 *         @OA\Property(property="timestamp", type="string", format="date-time", example="2025-02-11T10:30:00Z")
 *     )
 * )
 */

/**
 * @OA\Schema(
 *     schema="ConsultaResponse",
 *     type="object",
 *     @OA\Property(property="nombre", type="string", example="JUAN PEREZ GARCIA"),
 *     @OA\Property(property="domicilio", type="string", example="AV REVOLUCION 123"),
 *     @OA\Property(property="no_ext", type="string", example="123"),
 *     @OA\Property(property="no_int", type="string", example="A"),
 *     @OA\Property(property="colonia", type="string", example="CENTRO"),
 *     @OA\Property(property="municipio", type="string", example="GUADALAJARA"),
 *     @OA\Property(property="estado", type="string", example="JALISCO"),
 *     @OA\Property(property="rfc", type="string", example="PEGJ800101XXX"),
 *     @OA\Property(property="curp", type="string", example="PEGJ800101HJCRNS01"),
 *     @OA\Property(property="observacion", type="string", example="Cuenta activa"),
 *     @OA\Property(property="estatus", type="integer", example=0),
 *     @OA\Property(property="mensaje_est", type="string", example="OK")
 * )
 */

/**
 * @OA\Schema(
 *     schema="AdeudoDetalle",
 *     type="object",
 *     @OA\Property(property="cta_aplicacion", type="integer", example=1),
 *     @OA\Property(property="referencia_pago", type="string", example="REF123456789"),
 *     @OA\Property(property="descripcion", type="string", example="IMPUESTO PREDIAL 2024"),
 *     @OA\Property(property="importe", type="number", format="double", example=5000.50),
 *     @OA\Property(property="acumulado", type="number", format="double", example=5000.50)
 * )
 */

/**
 * @OA\Schema(
 *     schema="AdeudoDetalleResponse",
 *     type="array",
 *     @OA\Items(ref="#/components/schemas/AdeudoDetalle")
 * )
 */

/**
 * @OA\Schema(
 *     schema="PagoResponse",
 *     type="object",
 *     @OA\Property(property="codigo", type="integer", example=0),
 *     @OA\Property(property="mensaje", type="string", example="PAGO REGISTRADO EXITOSAMENTE")
 * )
 */

/**
 * @OA\Schema(
 *     schema="CancelacionResponse",
 *     type="object",
 *     @OA\Property(property="codigo", type="integer", example=0),
 *     @OA\Property(property="mensaje", type="string", example="PAGO CANCELADO EXITOSAMENTE")
 * )
 */

/**
 * @OA\Schema(
 *     schema="JwtTokenResponse",
 *     type="object",
 *     @OA\Property(property="success", type="boolean", example=true),
 *     @OA\Property(property="message", type="string", example="Token generado exitosamente"),
 *     @OA\Property(property="token", type="string", example="eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9..."),
 *     @OA\Property(property="type", type="string", example="Bearer"),
 *     @OA\Property(property="expires_in", type="integer", example=86400),
 *     @OA\Property(property="expires_at", type="string", example="2025-02-12 10:30:00"),
 *     @OA\Property(property="issued_at", type="string", example="2025-02-11 10:30:00"),
 *     @OA\Property(
 *         property="instructions",
 *         type="object",
 *         @OA\Property(property="use_header", type="string", example="Authorization: Bearer {token}"),
 *         @OA\Property(property="or_use_body", type="string", example="eRequest.Token: {token}")
 *     )
 * )
 */

/**
 * @OA\Schema(
 *     schema="JwtValidateResponse",
 *     type="object",
 *     @OA\Property(property="success", type="boolean", example=true),
 *     @OA\Property(property="message", type="string", example="Token válido"),
 *     @OA\Property(property="client_id", type="string", example="odoo-client-001"),
 *     @OA\Property(property="client_name", type="string", example="Odoo Production"),
 *     @OA\Property(
 *         property="permissions",
 *         type="array",
 *         @OA\Items(type="string", example="consulta")
 *     ),
 *     @OA\Property(property="expires_at", type="string", example="2025-02-12 10:30:00"),
 *     @OA\Property(property="time_left", type="string", example="23h 45m")
 * )
 */

/**
 * @OA\Schema(
 *     schema="ErrorResponse",
 *     type="object",
 *     @OA\Property(
 *         property="eResponse",
 *         type="object",
 *         @OA\Property(property="success", type="boolean", example=false),
 *         @OA\Property(property="message", type="string", example="Error en la operación"),
 *         @OA\Property(property="data", type="object", nullable=true),
 *         @OA\Property(property="timestamp", type="string", format="date-time", example="2025-02-11T10:30:00Z")
 *     )
 * )
 */

/**
 * @OA\Schema(
 *     schema="DatosVarios",
 *     type="object",
 *     @OA\Property(property="campo", type="string", example="tipo_predio"),
 *     @OA\Property(property="valor", type="string", example="CASA HABITACION")
 * )
 */

/**
 * @OA\Schema(
 *     schema="DatosVariosResponse",
 *     type="array",
 *     @OA\Items(ref="#/components/schemas/DatosVarios")
 * )
 */

/**
 * @OA\Info(
 *     title="API de Integración Odoo",
 *     version="1.0.0",
 *     description="API REST para integración con Odoo - Servicios de consulta, pagos y autenticación JWT",
 *     @OA\Contact(
 *         email="soporte@guadalajara.gob.mx",
 *         name="Soporte API Odoo"
 *     )
 * )
 *
 * @OA\Server(
 *     url="http://localhost:8000/api",
 *     description="Servidor Local"
 * )
 *
 * @OA\Server(
 *     url="https://api.guadalajara.gob.mx/api",
 *     description="Servidor Producción"
 * )
 *
 * @OA\SecurityScheme(
 *     securityScheme="bearerAuth",
 *     type="http",
 *     scheme="bearer",
 *     bearerFormat="JWT",
 *     description="Ingrese el token JWT generado desde /odoo/auth/token"
 * )
 */
class OdooSchemas
{
    // Esta clase solo contiene las anotaciones de Swagger
    // No tiene lógica, solo documentación
}

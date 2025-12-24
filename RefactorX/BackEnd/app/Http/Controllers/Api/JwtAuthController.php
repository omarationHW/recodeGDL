<?php

namespace App\Http\Controllers\Api;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\Validator;
use App\Services\JwtService;
use Exception;

/**
 * @OA\Tag(
 *     name="JWT Authentication",
 *     description="Autenticación JWT para API de Odoo"
 * )
 */
class JwtAuthController
{
    private $jwtService;

    public function __construct(JwtService $jwtService)
    {
        $this->jwtService = $jwtService;
    }

    /**
     * @OA\Post(
     *     path="/api/odoo/auth/token",
     *     summary="Generar token JWT",
     *     description="Genera un token JWT para autenticación en el API de Odoo",
     *     tags={"JWT Authentication"},
     *     @OA\RequestBody(
     *         required=true,
     *         @OA\JsonContent(
     *             required={"client_id", "client_secret"},
     *             @OA\Property(property="client_id", type="string", example="odoo-client-001"),
     *             @OA\Property(property="client_secret", type="string", example="super-secret-password"),
     *             @OA\Property(property="client_name", type="string", example="Odoo Production"),
     *             @OA\Property(property="permissions", type="array", @OA\Items(type="string"), example={"consulta", "pago"})
     *         )
     *     ),
     *     @OA\Response(
     *         response=200,
     *         description="Token generado exitosamente",
     *         @OA\JsonContent(
     *             @OA\Property(property="success", type="boolean", example=true),
     *             @OA\Property(property="message", type="string", example="Token generado exitosamente"),
     *             @OA\Property(property="token", type="string", example="eyJ0eXAiOiJKV1QiLCJhbGc..."),
     *             @OA\Property(property="type", type="string", example="Bearer"),
     *             @OA\Property(property="expires_in", type="integer", example=86400),
     *             @OA\Property(property="expires_at", type="string", example="2025-02-12 10:30:00")
     *         )
     *     ),
     *     @OA\Response(response=400, description="Credenciales inválidas"),
     *     @OA\Response(response=500, description="Error generando token")
     * )
     */
    public function generateToken(Request $request)
    {
        try {
            Log::info("🔐 Solicitud de generación de token JWT");

            // Validar request
            $validator = Validator::make($request->all(), [
                'client_id' => 'required|string',
                'client_secret' => 'required|string',
                'client_name' => 'nullable|string',
                'permissions' => 'nullable|array'
            ]);

            if ($validator->fails()) {
                return response()->json([
                    'success' => false,
                    'message' => 'Validación fallida: ' . $validator->errors()->first(),
                    'errors' => $validator->errors()
                ], 400);
            }

            $clientId = $request->input('client_id');
            $clientSecret = $request->input('client_secret');
            $clientName = $request->input('client_name', '');
            $permissions = $request->input('permissions', []);

            // Validar credenciales del cliente
            if (!$this->validateClientCredentials($clientId, $clientSecret)) {
                Log::warning("🚫 Credenciales inválidas", [
                    'client_id' => $clientId,
                    'ip' => $request->ip()
                ]);

                return response()->json([
                    'success' => false,
                    'message' => 'Credenciales inválidas',
                ], 401);
            }

            // Generar token JWT
            $tokenData = $this->jwtService->generateOdooToken(
                $clientId,
                $clientName,
                $permissions
            );

            Log::info("✅ Token JWT generado exitosamente", [
                'client_id' => $clientId,
                'expires_at' => $tokenData['expires_at'],
                'ip' => $request->ip()
            ]);

            return response()->json([
                'success' => true,
                'message' => 'Token generado exitosamente',
                'token' => $tokenData['token'],
                'type' => $tokenData['type'],
                'expires_in' => $tokenData['expires_in'],
                'expires_at' => $tokenData['expires_at'],
                'issued_at' => $tokenData['issued_at'],
                'instructions' => [
                    'use_header' => 'Authorization: Bearer {token}',
                    'or_use_body' => 'eRequest.Token: {token}'
                ]
            ]);

        } catch (Exception $e) {
            Log::error("❌ Error generando token JWT: " . $e->getMessage());

            return response()->json([
                'success' => false,
                'message' => 'Error generando token: ' . $e->getMessage()
            ], 500);
        }
    }

    /**
     * @OA\Post(
     *     path="/api/odoo/auth/validate",
     *     summary="Validar token JWT",
     *     description="Valida un token JWT y retorna su información",
     *     tags={"JWT Authentication"},
     *     @OA\RequestBody(
     *         required=true,
     *         @OA\JsonContent(
     *             required={"token"},
     *             @OA\Property(property="token", type="string", example="eyJ0eXAiOiJKV1QiLCJhbGc...")
     *         )
     *     ),
     *     @OA\Response(
     *         response=200,
     *         description="Token válido",
     *         @OA\JsonContent(
     *             @OA\Property(property="success", type="boolean", example=true),
     *             @OA\Property(property="message", type="string", example="Token válido"),
     *             @OA\Property(property="client_id", type="string", example="odoo-client-001"),
     *             @OA\Property(property="expires_at", type="string", example="2025-02-12 10:30:00")
     *         )
     *     ),
     *     @OA\Response(response=401, description="Token inválido o expirado")
     * )
     */
    public function validateToken(Request $request)
    {
        try {
            $token = $request->input('token') ?? $request->bearerToken();

            if (!$token) {
                return response()->json([
                    'success' => false,
                    'message' => 'Token no proporcionado'
                ], 400);
            }

            $clientData = $this->jwtService->getClientFromToken($token);

            if (!$clientData) {
                return response()->json([
                    'success' => false,
                    'message' => 'Token inválido o expirado'
                ], 401);
            }

            return response()->json([
                'success' => true,
                'message' => 'Token válido',
                'client_id' => $clientData['client_id'],
                'client_name' => $clientData['client_name'],
                'permissions' => $clientData['permissions'],
                'expires_at' => $clientData['expires_at'],
                'time_left' => $clientData['time_left']
            ]);

        } catch (Exception $e) {
            Log::error("❌ Error validando token: " . $e->getMessage());

            return response()->json([
                'success' => false,
                'message' => 'Error validando token: ' . $e->getMessage()
            ], 500);
        }
    }

    /**
     * @OA\Post(
     *     path="/api/odoo/auth/refresh",
     *     summary="Refrescar token JWT",
     *     description="Genera un nuevo token JWT basado en uno válido existente. Útil para renovar tokens antes de que expiren sin necesidad de volver a autenticar con credenciales.",
     *     tags={"JWT Authentication"},
     *     @OA\RequestBody(
     *         required=true,
     *         @OA\JsonContent(
     *             required={"token"},
     *             @OA\Property(property="token", type="string", example="eyJ0eXAiOiJKV1QiLCJhbGc...", description="Token JWT actual (aún válido)")
     *         )
     *     ),
     *     @OA\Response(
     *         response=200,
     *         description="Token refrescado exitosamente",
     *         @OA\JsonContent(
     *             @OA\Property(property="success", type="boolean", example=true),
     *             @OA\Property(property="message", type="string", example="Token refrescado exitosamente"),
     *             @OA\Property(property="token", type="string", example="eyJ0eXAiOiJKV1QiLCJhbGc... (nuevo token)"),
     *             @OA\Property(property="type", type="string", example="Bearer"),
     *             @OA\Property(property="expires_in", type="integer", example=86400, description="Tiempo de expiración en segundos"),
     *             @OA\Property(property="expires_at", type="string", example="2025-02-12 10:30:00", description="Fecha/hora de expiración")
     *         )
     *     ),
     *     @OA\Response(
     *         response=400,
     *         description="Token no proporcionado",
     *         @OA\JsonContent(
     *             @OA\Property(property="success", type="boolean", example=false),
     *             @OA\Property(property="message", type="string", example="Token no proporcionado")
     *         )
     *     ),
     *     @OA\Response(
     *         response=401,
     *         description="Token inválido o expirado",
     *         @OA\JsonContent(
     *             @OA\Property(property="success", type="boolean", example=false),
     *             @OA\Property(property="message", type="string", example="Token inválido, no se puede refrescar")
     *         )
     *     )
     * )
     */
    public function refreshToken(Request $request)
    {
        try {
            $token = $request->input('token') ?? $request->bearerToken();

            if (!$token) {
                return response()->json([
                    'success' => false,
                    'message' => 'Token no proporcionado'
                ], 400);
            }

            $clientData = $this->jwtService->getClientFromToken($token);

            if (!$clientData) {
                return response()->json([
                    'success' => false,
                    'message' => 'Token inválido, no se puede refrescar'
                ], 401);
            }

            // Generar nuevo token con los mismos datos
            $newTokenData = $this->jwtService->generateOdooToken(
                $clientData['client_id'],
                $clientData['client_name'],
                $clientData['permissions']
            );

            Log::info("🔄 Token refrescado", [
                'client_id' => $clientData['client_id'],
                'new_expires_at' => $newTokenData['expires_at']
            ]);

            return response()->json([
                'success' => true,
                'message' => 'Token refrescado exitosamente',
                'token' => $newTokenData['token'],
                'type' => $newTokenData['type'],
                'expires_in' => $newTokenData['expires_in'],
                'expires_at' => $newTokenData['expires_at']
            ]);

        } catch (Exception $e) {
            Log::error("❌ Error refrescando token: " . $e->getMessage());

            return response()->json([
                'success' => false,
                'message' => 'Error refrescando token: ' . $e->getMessage()
            ], 500);
        }
    }

    /**
     * Validar credenciales del cliente
     *
     * @param string $clientId ID del cliente
     * @param string $clientSecret Secreto del cliente
     * @return bool True si las credenciales son válidas
     */
    private function validateClientCredentials($clientId, $clientSecret)
    {
        // Obtener clientes válidos desde configuración
        $validClients = config('odoo.jwt_clients', []);

        // Verificar si el cliente existe
        if (!isset($validClients[$clientId])) {
            return false;
        }

        // Verificar el secreto
        $storedSecret = $validClients[$clientId]['secret'];

        // Comparar secretos de forma segura
        return hash_equals($storedSecret, $clientSecret);
    }

    /**
     * @OA\Get(
     *     path="/api/odoo/auth/info",
     *     summary="Información de autenticación JWT",
     *     description="Retorna información sobre la configuración JWT y endpoints disponibles. No requiere autenticación.",
     *     tags={"JWT Authentication"},
     *     @OA\Response(
     *         response=200,
     *         description="Información de JWT",
     *         @OA\JsonContent(
     *             @OA\Property(property="success", type="boolean", example=true),
     *             @OA\Property(
     *                 property="jwt_info",
     *                 type="object",
     *                 @OA\Property(property="algorithm", type="string", example="HS256", description="Algoritmo de firma JWT"),
     *                 @OA\Property(property="expiration_hours", type="integer", example=24, description="Horas de expiración"),
     *                 @OA\Property(property="expiration_seconds", type="integer", example=86400, description="Segundos de expiración"),
     *                 @OA\Property(property="issuer", type="string", example="http://localhost:8000", description="Emisor del token")
     *             ),
     *             @OA\Property(
     *                 property="endpoints",
     *                 type="object",
     *                 @OA\Property(property="generate_token", type="string", example="http://localhost:8000/api/odoo/auth/token"),
     *                 @OA\Property(property="validate_token", type="string", example="http://localhost:8000/api/odoo/auth/validate"),
     *                 @OA\Property(property="refresh_token", type="string", example="http://localhost:8000/api/odoo/auth/refresh")
     *             ),
     *             @OA\Property(
     *                 property="usage",
     *                 type="object",
     *                 @OA\Property(property="step_1", type="string", example="POST /api/odoo/auth/token con client_id y client_secret"),
     *                 @OA\Property(property="step_2", type="string", example="Usar el token en Authorization: Bearer {token}"),
     *                 @OA\Property(property="step_3", type="string", example="Refrescar antes de que expire con /api/odoo/auth/refresh")
     *             )
     *         )
     *     )
     * )
     */
    public function info()
    {
        return response()->json([
            'success' => true,
            'jwt_info' => [
                'algorithm' => config('odoo.jwt_algorithm', 'HS256'),
                'expiration_hours' => config('odoo.jwt_expiration_hours', 24),
                'expiration_seconds' => config('odoo.jwt_expiration_hours', 24) * 3600,
                'issuer' => config('app.url')
            ],
            'endpoints' => [
                'generate_token' => url('/api/odoo/auth/token'),
                'validate_token' => url('/api/odoo/auth/validate'),
                'refresh_token' => url('/api/odoo/auth/refresh')
            ],
            'usage' => [
                'step_1' => 'POST /api/odoo/auth/token con client_id y client_secret',
                'step_2' => 'Usar el token en Authorization: Bearer {token}',
                'step_3' => 'Refrescar antes de que expire con /api/odoo/auth/refresh'
            ]
        ]);
    }
}

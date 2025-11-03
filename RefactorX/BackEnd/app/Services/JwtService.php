<?php

namespace App\Services;

use Exception;
use Firebase\JWT\JWT;
use Firebase\JWT\Key;
use Illuminate\Support\Facades\Log;

/**
 * Servicio para manejar JSON Web Tokens (JWT)
 *
 * Permite generar y validar tokens JWT con expiración configurable
 */
class JwtService
{
    private $secret;
    private $algorithm;
    private $expirationHours;

    public function __construct()
    {
        $this->secret = config('odoo.jwt_secret');
        $this->algorithm = config('odoo.jwt_algorithm', 'HS256');
        $this->expirationHours = config('odoo.jwt_expiration_hours', 24);

        if (empty($this->secret)) {
            throw new Exception('JWT_SECRET no está configurado. Agregar en .env');
        }
    }

    /**
     * Generar un nuevo token JWT
     *
     * @param array $payload Datos a incluir en el token (usuario, cliente, etc.)
     * @return array Token generado y metadata
     */
    public function generateToken(array $payload = [])
    {
        $issuedAt = time();
        $expirationTime = $issuedAt + ($this->expirationHours * 3600); // Convertir horas a segundos

        $token = [
            'iat' => $issuedAt,                    // Issued at: tiempo de creación
            'exp' => $expirationTime,              // Expiration time: tiempo de expiración
            'iss' => config('app.url'),            // Issuer: quien emitió el token
            'data' => $payload                     // Datos personalizados
        ];

        $jwt = JWT::encode($token, $this->secret, $this->algorithm);

        Log::info('🔑 JWT generado', [
            'issued_at' => date('Y-m-d H:i:s', $issuedAt),
            'expires_at' => date('Y-m-d H:i:s', $expirationTime),
            'expiration_hours' => $this->expirationHours,
            'payload' => $payload
        ]);

        return [
            'token' => $jwt,
            'type' => 'Bearer',
            'expires_in' => $this->expirationHours * 3600, // En segundos
            'expires_at' => date('Y-m-d H:i:s', $expirationTime),
            'issued_at' => date('Y-m-d H:i:s', $issuedAt)
        ];
    }

    /**
     * Validar y decodificar un token JWT
     *
     * @param string $token Token JWT a validar
     * @return object|false Datos del token o false si es inválido
     */
    public function validateToken($token)
    {
        try {
            // Limpiar el token (quitar "Bearer " si existe)
            $token = $this->cleanToken($token);

            // Decodificar y validar el token
            $decoded = JWT::decode($token, new Key($this->secret, $this->algorithm));

            Log::info('✅ JWT validado exitosamente', [
                'issued_at' => date('Y-m-d H:i:s', $decoded->iat),
                'expires_at' => date('Y-m-d H:i:s', $decoded->exp),
                'time_left' => $this->getTimeLeft($decoded->exp)
            ]);

            return $decoded;

        } catch (\Firebase\JWT\ExpiredException $e) {
            Log::warning('⏰ JWT expirado', [
                'error' => $e->getMessage(),
                'token_preview' => substr($token, 0, 20) . '...'
            ]);
            return false;

        } catch (\Firebase\JWT\SignatureInvalidException $e) {
            Log::error('🚫 JWT con firma inválida', [
                'error' => $e->getMessage(),
                'token_preview' => substr($token, 0, 20) . '...'
            ]);
            return false;

        } catch (Exception $e) {
            Log::error('❌ Error validando JWT', [
                'error' => $e->getMessage(),
                'token_preview' => substr($token, 0, 20) . '...'
            ]);
            return false;
        }
    }

    /**
     * Verificar si un token está expirado
     *
     * @param string $token Token JWT
     * @return bool True si está expirado
     */
    public function isExpired($token)
    {
        $decoded = $this->validateToken($token);

        if (!$decoded) {
            return true;
        }

        return time() >= $decoded->exp;
    }

    /**
     * Obtener tiempo restante del token en segundos
     *
     * @param int $expirationTime Tiempo de expiración del token
     * @return string Tiempo restante formateado
     */
    private function getTimeLeft($expirationTime)
    {
        $secondsLeft = $expirationTime - time();

        if ($secondsLeft <= 0) {
            return 'Expirado';
        }

        $hours = floor($secondsLeft / 3600);
        $minutes = floor(($secondsLeft % 3600) / 60);

        return "{$hours}h {$minutes}m";
    }

    /**
     * Limpiar token (quitar "Bearer " si existe)
     *
     * @param string $token Token JWT
     * @return string Token limpio
     */
    private function cleanToken($token)
    {
        if (stripos($token, 'Bearer ') === 0) {
            return substr($token, 7);
        }

        return $token;
    }

    /**
     * Extraer payload sin validar (útil para debugging)
     * ADVERTENCIA: No usar para autenticación, solo para debug
     *
     * @param string $token Token JWT
     * @return array|null Payload del token
     */
    public function decodeWithoutValidation($token)
    {
        try {
            $token = $this->cleanToken($token);
            $parts = explode('.', $token);

            if (count($parts) !== 3) {
                return null;
            }

            $payload = json_decode(base64_decode($parts[1]), true);
            return $payload;

        } catch (Exception $e) {
            Log::error('Error decodificando token sin validación', ['error' => $e->getMessage()]);
            return null;
        }
    }

    /**
     * Generar token para cliente de Odoo
     *
     * @param string $clientId ID del cliente
     * @param string $clientName Nombre del cliente
     * @param array $permissions Permisos del cliente
     * @return array Token generado
     */
    public function generateOdooToken($clientId, $clientName = '', $permissions = [])
    {
        $payload = [
            'client_id' => $clientId,
            'client_name' => $clientName,
            'permissions' => $permissions,
            'type' => 'odoo_integration'
        ];

        return $this->generateToken($payload);
    }

    /**
     * Validar token y extraer información del cliente
     *
     * @param string $token Token JWT
     * @return array|false Datos del cliente o false
     */
    public function getClientFromToken($token)
    {
        $decoded = $this->validateToken($token);

        if (!$decoded || !isset($decoded->data)) {
            return false;
        }

        return [
            'client_id' => $decoded->data->client_id ?? null,
            'client_name' => $decoded->data->client_name ?? null,
            'permissions' => $decoded->data->permissions ?? [],
            'expires_at' => date('Y-m-d H:i:s', $decoded->exp),
            'time_left' => $this->getTimeLeft($decoded->exp)
        ];
    }
}

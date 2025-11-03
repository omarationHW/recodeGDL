<?php

return [
    /*
    |--------------------------------------------------------------------------
    | JWT - Autenticación por Token
    |--------------------------------------------------------------------------
    */

    /**
     * Secreto para firmar tokens JWT
     * IMPORTANTE: Cambiar en producción a un valor único y seguro
     */
    'jwt_secret' => env('JWT_SECRET', 'your-super-secret-key-change-in-production-min-32-chars'),

    /**
     * Algoritmo para firmar JWT
     * Opciones: HS256, HS384, HS512, RS256, RS384, RS512
     */
    'jwt_algorithm' => env('JWT_ALGORITHM', 'HS256'),

    /**
     * Tiempo de expiración del token en horas
     * Por defecto: 24 horas
     */
    'jwt_expiration_hours' => env('JWT_EXPIRATION_HOURS', 24),

    /**
     * Clientes autorizados para generar tokens JWT
     * Formato: 'client_id' => ['secret' => 'password', 'name' => 'Nombre']
     */
    'jwt_clients' => [
        'odoo-client-001' => [
            'secret' => env('ODOO_CLIENT_001_SECRET', 'change-this-secret-in-production'),
            'name' => 'Odoo Production',
            'permissions' => ['*'] // Todos los permisos
        ],
        'odoo-client-dev' => [
            'secret' => env('ODOO_CLIENT_DEV_SECRET', 'dev-secret-change-me'),
            'name' => 'Odoo Development',
            'permissions' => ['consulta', 'adeudo']
        ],
        'odoo-client-test' => [
            'secret' => env('ODOO_CLIENT_TEST_SECRET', 'test-secret-change-me'),
            'name' => 'Odoo Testing',
            'permissions' => ['*']
        ],
    ],

    /*
    |--------------------------------------------------------------------------
    | Tokens estáticos (Deprecated - usar JWT)
    |--------------------------------------------------------------------------
    |
    | Lista de tokens estáticos válidos (legacy)
    | ADVERTENCIA: Usar solo para migración, se recomienda usar JWT
    |
    */
    'valid_tokens' => explode(',', env('ODOO_VALID_TOKENS', 'odoo-token-2025,odoo-prod-token')),

    /*
    |--------------------------------------------------------------------------
    | Logging de peticiones
    |--------------------------------------------------------------------------
    |
    | Habilitar logging detallado de todas las peticiones
    |
    */
    'enable_logging' => env('ODOO_ENABLE_LOGGING', true),

    /*
    |--------------------------------------------------------------------------
    | Timeout de conexión
    |--------------------------------------------------------------------------
    |
    | Timeout en segundos para las consultas a la base de datos
    |
    */
    'db_timeout' => env('ODOO_DB_TIMEOUT', 30),

    /*
    |--------------------------------------------------------------------------
    | Modo mantenimiento
    |--------------------------------------------------------------------------
    |
    | Activar modo mantenimiento para bloquear temporalmente el servicio
    |
    */
    'maintenance_mode' => env('ODOO_MAINTENANCE_MODE', false),

    /*
    |--------------------------------------------------------------------------
    | Configuración de interfaces
    |--------------------------------------------------------------------------
    |
    | Mapeo de interfaces a módulos y bases de datos
    |
    */
    'interfaces' => [
        8 => ['modulo' => 'Informix', 'descripcion' => 'Predial, Licencias, Aseo, etc.'],
        16 => ['modulo' => 'Movilidad', 'descripcion' => 'Infracciones de tránsito'],
        17 => ['modulo' => 'Obras', 'descripcion' => 'Licencias de obra'],
        32 => ['modulo' => 'Infracciones', 'descripcion' => 'Reglamentos municipales'],
        88 => ['modulo' => 'SICAM', 'descripcion' => 'Predial SICAM'],
    ],
];

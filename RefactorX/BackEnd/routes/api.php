<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Api\GenericController;
use App\Http\Controllers\Api\OdooController;
use App\Http\Controllers\Api\JwtAuthController;

// Endpoint genérico para ejecutar stored procedures
Route::post('/generic', [GenericController::class, 'execute']);

// ========== JWT Authentication ==========
Route::prefix('odoo/auth')->group(function () {
    Route::post('/token', [JwtAuthController::class, 'generateToken']);
    Route::post('/validate', [JwtAuthController::class, 'validateToken']);
    Route::post('/refresh', [JwtAuthController::class, 'refreshToken']);
    Route::get('/info', [JwtAuthController::class, 'info']);
});

// Endpoint para integración con Odoo
Route::post('/odoo', [OdooController::class, 'execute']);

// Mensaje informativo para peticiones GET
Route::get('/generic', function () {
    return response()->json([
        'eResponse' => [
            'success' => false,
            'message' => 'The GET method is not supported for this route. Please use POST method.',
            'usage' => [
                'method' => 'POST',
                'url' => url('/api/generic'),
                'headers' => [
                    'Content-Type' => 'application/json'
                ],
                'body_example' => [
                    'eRequest' => [
                        'Operacion' => 'stored_procedure_name',
                        'Base' => 'module_name',
                        'Parametros' => [
                            [
                                'nombre' => 'param_name',
                                'valor' => 'param_value',
                                'tipo' => 'string|integer|numeric|boolean|json'
                            ]
                        ]
                    ]
                ]
            ]
        ]
    ], 405);
});

// Mensaje informativo para peticiones GET del endpoint de Odoo
Route::get('/odoo', function () {
    return response()->json([
        'eResponse' => [
            'success' => false,
            'message' => 'The GET method is not supported for this route. Please use POST method.',
            'usage' => [
                'method' => 'POST',
                'url' => url('/api/odoo'),
                'headers' => [
                    'Content-Type' => 'application/json',
                    'Authorization' => 'Bearer your-token-here (opcional)'
                ],
                'body_example' => [
                    'eRequest' => [
                        'Funcion' => 'Consulta|DatosVarios|Pago|Cancelacion|etc',
                        'Token' => 'odoo-token-2025',
                        'Parametros' => [
                            'Idinterfaz' => 8,
                            'cta_01' => '12345678',
                            'referencia_pago' => 'REF123456789'
                        ]
                    ]
                ],
                'funciones_disponibles' => [
                    'Consulta', 'DatosVarios', 'AdeudoDetalle', 'AdeudoDetalleInmovilizadores',
                    'Pago', 'Cancelacion', 'ConsCuenta', 'CatDescuentos', 'ListDescuentos',
                    'AltaDescuentos', 'CancelDescuentos', 'ConsDesctoTablet', 'AltaDesctoTablet',
                    'FechasPendientesEl', 'PendientesXIntegrar', 'DetallesXIntegrar',
                    'ActualizarPendientes', 'LicenciaVisor'
                ],
                'documentacion' => url('/api/documentation')
            ]
        ]
    ], 405);
});

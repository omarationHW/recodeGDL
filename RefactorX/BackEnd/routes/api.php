<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Api\GenericController;

// Endpoint genérico para ejecutar stored procedures
Route::post('/generic', [GenericController::class, 'execute']);

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

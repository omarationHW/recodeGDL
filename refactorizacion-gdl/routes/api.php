<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Api\ProyectoObraController;
use App\Http\Controllers\Api\AdeudoController;
use App\Http\Controllers\Api\ReporteController;
use App\Http\Controllers\Api\EstadisticasController;

Route::prefix('v1')->group(function () {
    // Proyectos - Export route must come before apiResource
    Route::get('proyectos/export/excel', [ProyectoObraController::class, 'exportExcel']);
    Route::get('proyectos/{id}/resumen-adeudos', [ProyectoObraController::class, 'resumenAdeudos']);
    Route::apiResource('proyectos', ProyectoObraController::class);
    
    // Adeudos
    Route::get('adeudos/proyecto/{idControl}', [AdeudoController::class, 'adeudosPorProyecto']);
    Route::post('adeudos/{id}/pagar', [AdeudoController::class, 'registrarPago']);
    
    // Estadísticas
    Route::get('estadisticas', [EstadisticasController::class, 'index']);
    
    // Reportes
    Route::post('reportes/pdf', [ReporteController::class, 'generarPDF']);
});
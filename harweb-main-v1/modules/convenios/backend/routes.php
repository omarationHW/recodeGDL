<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Modules\convenios\{
    AltaConvDiversosController,
    AltaConveniosController,
    AltaPagosPrediosController,
    AmpliacionesMttoController,
    CallesController,
    IndividualDiversosController,
    ListadoConvDiversosController,
    ModifConvDiversosController,
    ModuloBDController
};

/*
|--------------------------------------------------------------------------  
| CONVENIOS Module Routes
|--------------------------------------------------------------------------
|
| Rutas del módulo convenios migrado desde Delphi
| Generado automáticamente el 2025-08-27 20:53:53
|
*/

Route::prefix('convenios')->group(function () {
    Route::resource('altaconvdiversos', AltaConvDiversosController::class);
    Route::resource('altaconvenios', AltaConveniosController::class);
    Route::resource('altapagospredios', AltaPagosPrediosController::class);
    Route::resource('ampliacionesmtto', AmpliacionesMttoController::class);
    Route::resource('calles', CallesController::class);
    Route::resource('individualdiversos', IndividualDiversosController::class);
    Route::resource('listadoconvdiversos', ListadoConvDiversosController::class);
    Route::resource('modifconvdiversos', ModifConvDiversosController::class);
    Route::resource('modulobd', ModuloBDController::class);
});

<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Modules\cementerios\{
    ConsultaNombreController,
    ConsultaRCMController,
    DuplicadosController
};

/*
|--------------------------------------------------------------------------  
| CEMENTERIOS Module Routes
|--------------------------------------------------------------------------
|
| Rutas del módulo cementerios migrado desde Delphi
| Generado automáticamente el 2025-08-27 20:56:09
|
*/

Route::prefix('cementerios')->group(function () {
    Route::resource('consultanombre', ConsultaNombreController::class);
    Route::resource('consultarcm', ConsultaRCMController::class);
    Route::resource('duplicados', DuplicadosController::class);
});

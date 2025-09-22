<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Modules\mercados\{
    AltaPagosController,
    AltaPagosEnergiaController,
    ConsultaGeneralController,
    ModuloBDController,
    RptEmisionLaserController
};

/*
|--------------------------------------------------------------------------  
| MERCADOS Module Routes
|--------------------------------------------------------------------------
|
| Rutas del módulo mercados migrado desde Delphi
| Generado automáticamente el 2025-08-27 20:48:45
|
*/

Route::prefix('mercados')->group(function () {
    Route::resource('altapagos', AltaPagosController::class);
    Route::resource('altapagosenergia', AltaPagosEnergiaController::class);
    Route::resource('consultageneral', ConsultaGeneralController::class);
    Route::resource('modulobd', ModuloBDController::class);
    Route::resource('rptemisionlaser', RptEmisionLaserController::class);
});

<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Modules\estacionamientos\{
    Gen_ArcDiarioController
};

/*
|--------------------------------------------------------------------------  
| ESTACIONAMIENTOS Module Routes
|--------------------------------------------------------------------------
|
| Rutas del módulo estacionamientos migrado desde Delphi
| Generado automáticamente el 2025-08-27 20:40:43
|
*/

Route::prefix('estacionamientos')->group(function () {
    Route::resource('gen_arcdiario', Gen_ArcDiarioController::class);
});

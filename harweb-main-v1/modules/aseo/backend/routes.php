<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Modules\aseo\{
    Adeudos_OpcMultController,
    Adeudos_PagUpdPerController,
    Contratos_CancelaController,
    ReqsConsController
};

/*
|--------------------------------------------------------------------------  
| ASEO Module Routes
|--------------------------------------------------------------------------
|
| Rutas del módulo aseo migrado desde Delphi
| Generado automáticamente el 2025-08-27 20:45:14
|
*/

Route::prefix('aseo')->group(function () {
    Route::resource('adeudos_opcmult', Adeudos_OpcMultController::class);
    Route::resource('adeudos_pagupdper', Adeudos_PagUpdPerController::class);
    Route::resource('contratos_cancela', Contratos_CancelaController::class);
    Route::resource('reqscons', ReqsConsController::class);
});

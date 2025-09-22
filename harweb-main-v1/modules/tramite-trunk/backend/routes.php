<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Modules\tramitetrunk\{
    busqueController,
    catastrodmController,
    conduenosfrmoldController,
    consultapredialController
};

/*
|--------------------------------------------------------------------------  
| TRAMITE-TRUNK Module Routes
|--------------------------------------------------------------------------
|
| Rutas del módulo tramite-trunk migrado desde Delphi
| Generado automáticamente el 2025-08-27 20:47:33
|
*/

Route::prefix('tramite-trunk')->group(function () {
    Route::resource('busque', busqueController::class);
    Route::resource('catastrodm', catastrodmController::class);
    Route::resource('conduenosfrmold', conduenosfrmoldController::class);
    Route::resource('consultapredial', consultapredialController::class);
});

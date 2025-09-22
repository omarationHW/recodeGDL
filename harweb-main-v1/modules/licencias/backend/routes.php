<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Modules\licencias2\{
    busqueController,
    catalogogirosfrmController,
    CatastroDMController,
    consultapredialController
};

/*
|--------------------------------------------------------------------------  
| LICENCIAS2 Module Routes
|--------------------------------------------------------------------------
|
| Rutas del módulo licencias2 migrado desde Delphi
| Generado automáticamente el 2025-08-27 21:01:57
|
*/

Route::prefix('licencias2')->group(function () {
    Route::resource('busque', busqueController::class);
    Route::resource('catalogogirosfrm', catalogogirosfrmController::class);
    Route::resource('catastrodm', CatastroDMController::class);
    Route::resource('consultapredial', consultapredialController::class);
});

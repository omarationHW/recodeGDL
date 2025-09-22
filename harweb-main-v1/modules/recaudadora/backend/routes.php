<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Modules\recaudadora\{
    busqueController,
    CapturaDifController,
    CartaInvitacionController,
    CatastroDMController,
    consultapredialController,
    descpredfrmController,
    desctorecController,
    EjeController,
    impreqCvecatController,
    leyesfrmController,
    listanotificacionesfrmController,
    sfrm_prescrip_sec01Controller
};

/*
|--------------------------------------------------------------------------  
| RECAUDADORA Module Routes
|--------------------------------------------------------------------------
|
| Rutas del módulo recaudadora migrado desde Delphi
| Generado automáticamente el 2025-08-27 21:29:49
|
*/

Route::prefix('recaudadora')->group(function () {
    Route::resource('busque', busqueController::class);
    Route::resource('capturadif', CapturaDifController::class);
    Route::resource('cartainvitacion', CartaInvitacionController::class);
    Route::resource('catastrodm', CatastroDMController::class);
    Route::resource('consultapredial', consultapredialController::class);
    Route::resource('descpredfrm', descpredfrmController::class);
    Route::resource('desctorec', desctorecController::class);
    Route::resource('frmeje', EjeController::class);
    Route::resource('impreqcvecat', impreqCvecatController::class);
    Route::resource('leyesfrm', leyesfrmController::class);
    Route::resource('listanotificacionesfrm', listanotificacionesfrmController::class);
    Route::resource('sfrm_prescrip_sec01', sfrm_prescrip_sec01Controller::class);
});

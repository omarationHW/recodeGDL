<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Modules\apremiossvn\{
    CartaInvitacionController,
    Lista_EjeController,
    Lista_GastosCobController,
    ListxFecController,
    ListxRegController,
    MenuController,
    ModifcarController,
    Modificar_bienController,
    Modif_MasivaController,
    ModuloDbController,
    NotificacionesController,
    RecuperacionController
};

/*
|--------------------------------------------------------------------------  
| APREMIOSSVN Module Routes
|--------------------------------------------------------------------------
|
| Rutas del módulo apremiossvn migrado desde Delphi
| Generado automáticamente el 2025-08-27 20:59:09
|
*/

Route::prefix('apremiossvn')->group(function () {
    Route::resource('cartainvitacion', CartaInvitacionController::class);
    Route::resource('lista_eje', Lista_EjeController::class);
    Route::resource('lista_gastoscob', Lista_GastosCobController::class);
    Route::resource('listxfec', ListxFecController::class);
    Route::resource('listxreg', ListxRegController::class);
    Route::resource('menu', MenuController::class);
    Route::resource('modifcar', ModifcarController::class);
    Route::resource('modificar_bien', Modificar_bienController::class);
    Route::resource('modif_masiva', Modif_MasivaController::class);
    Route::resource('modulodb', ModuloDbController::class);
    Route::resource('notificaciones', NotificacionesController::class);
    Route::resource('recuperacion', RecuperacionController::class);
});

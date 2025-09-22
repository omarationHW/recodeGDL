<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Modules\otrasoblig\{
    ApremiosController,
    AuxRepController,
    CargaCarteraController,
    CargaValoresController,
    EtiquetasController,
    GActualizaController,
    GAdeudosController,
    GAdeudosGralController,
    GAdeudos_OpcMultController,
    GAdeudos_OpcMult_RAController,
    GBajaController,
    GConsultaController,
    GConsulta2Controller,
    GFacturacionController,
    GNuevosController,
    GRep_PadronController,
    MenuController,
    RActualizaController,
    RAdeudosController,
    RAdeudos_OpcMultController,
    RBajaController,
    RConsultaController,
    RFacturacionController,
    RNuevosController,
    RPagadosController,
    RRep_PadronController,
    RubrosController
};

/*
|--------------------------------------------------------------------------  
| OTRAS-OBLIG Module Routes
|--------------------------------------------------------------------------
|
| Rutas del módulo otras-oblig migrado desde Delphi
| Generado automáticamente el 2025-08-28 13:48:30
|
*/

Route::prefix('otras-oblig')->group(function () {
    Route::resource('apremios', ApremiosController::class);
    Route::resource('auxrep', AuxRepController::class);
    Route::resource('cargacartera', CargaCarteraController::class);
    Route::resource('cargavalores', CargaValoresController::class);
    Route::resource('etiquetas', EtiquetasController::class);
    Route::resource('gactualiza', GActualizaController::class);
    Route::resource('gadeudos', GAdeudosController::class);
    Route::resource('gadeudosgral', GAdeudosGralController::class);
    Route::resource('gadeudos_opcmult', GAdeudos_OpcMultController::class);
    Route::resource('gadeudos_opcmult_ra', GAdeudos_OpcMult_RAController::class);
    Route::resource('gbaja', GBajaController::class);
    Route::resource('gconsulta', GConsultaController::class);
    Route::resource('gconsulta2', GConsulta2Controller::class);
    Route::resource('gfacturacion', GFacturacionController::class);
    Route::resource('gnuevos', GNuevosController::class);
    Route::resource('grep_padron', GRep_PadronController::class);
    Route::resource('menu', MenuController::class);
    Route::resource('ractualiza', RActualizaController::class);
    Route::resource('radeudos', RAdeudosController::class);
    Route::resource('radeudos_opcmult', RAdeudos_OpcMultController::class);
    Route::resource('rbaja', RBajaController::class);
    Route::resource('rconsulta', RConsultaController::class);
    Route::resource('rfacturacion', RFacturacionController::class);
    Route::resource('rnuevos', RNuevosController::class);
    Route::resource('rpagados', RPagadosController::class);
    Route::resource('rrep_padron', RRep_PadronController::class);
    Route::resource('rubros', RubrosController::class);
});

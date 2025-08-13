<?php

use Illuminate\Support\Facades\Route;
use Inertia\Inertia;
use App\Http\Controllers\PavimentacionController;

Route::get('/', function () {
    return redirect()->route('pavimentacion.index');
});

Route::get('/pavimentacion', [PavimentacionController::class, 'index'])->name('pavimentacion.index');
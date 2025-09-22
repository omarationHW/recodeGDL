<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Api\UnifiedController;

Route::post('/execute', [UnifiedController::class, 'execute']);
Route::get('/health', [UnifiedController::class, 'health']);
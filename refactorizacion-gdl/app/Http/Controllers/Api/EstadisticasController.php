<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Services\ProyectoObraService;
use Illuminate\Http\JsonResponse;

class EstadisticasController extends Controller
{
    public function __construct(
        private ProyectoObraService $service
    ) {}

    public function index(): JsonResponse
    {
        $estadisticas = $this->service->obtenerEstadisticas();

        return response()->json([
            'success' => true,
            'data' => $estadisticas
        ]);
    }
}
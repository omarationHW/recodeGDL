<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\ProyectoObra;
use App\Services\ProyectoObraService;
use App\Exports\ProyectosExport;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\DB;
use Illuminate\Validation\Rule;
use Maatwebsite\Excel\Facades\Excel;

class ProyectoObraController extends Controller
{
    public function __construct(
        private ProyectoObraService $service
    ) {}

    public function index(): JsonResponse
    {
        // Usar la vista optimizada para mejor performance
        $proyectos = $this->service->obtenerProyectosOptimizado();

        return response()->json([
            'success' => true,
            'data' => $proyectos
        ]);
    }

    public function store(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'contrato' => 'required|integer',
            'nombre' => 'required|string|max:100',
            'calle' => 'required|string|max:100',
            'metros' => 'required|numeric|min:0.01|max:999.99',
            'costomtr' => 'required|numeric|min:0.01',
            'tipo_pavimento' => ['required', Rule::in(['A', 'H'])]
        ]);

        try {
            $resultado = $this->service->crearProyecto($validated);
            
            return response()->json([
                'success' => true,
                'message' => $resultado['mensaje'],
                'data' => $resultado['proyecto']
            ], 201);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => $e->getMessage()
            ], 400);
        }
    }

    public function show($id): JsonResponse
    {
        $proyecto = ProyectoObra::with('adeudos')->findOrFail($id);
        
        return response()->json([
            'success' => true,
            'data' => $proyecto
        ]);
    }

    public function update(Request $request, $id): JsonResponse
    {
        $proyecto = ProyectoObra::findOrFail($id);

        $validated = $request->validate([
            'contrato' => 'required|integer',
            'nombre' => 'required|string|max:100',
            'calle' => 'required|string|max:100',
            'metros' => 'required|numeric|min:0.01|max:999.99',
            'costomtr' => 'required|numeric|min:0.01',
            'tipo_pavimento' => ['required', Rule::in(['A', 'H'])]
        ]);

        try {
            $resultado = $this->service->actualizarProyecto($id, $validated);
            
            return response()->json([
                'success' => true,
                'message' => $resultado['mensaje'],
                'data' => $resultado['proyecto']
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => $e->getMessage()
            ], 400);
        }
    }

    public function resumenAdeudos($id): JsonResponse
    {
        $resumen = $this->service->obtenerResumenAdeudos($id);
        
        return response()->json([
            'success' => true,
            'data' => $resumen
        ]);
    }

    public function exportExcel()
    {
        $filename = 'proyectos_pavimentacion_' . date('Y-m-d_H-i-s') . '.xlsx';
        
        return Excel::download(new ProyectosExport, $filename, \Maatwebsite\Excel\Excel::XLSX, [
            'Content-Type' => 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
        ]);
    }
}
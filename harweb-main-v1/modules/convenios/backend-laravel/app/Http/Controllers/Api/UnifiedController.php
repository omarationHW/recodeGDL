<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\eRequest;
use App\Models\eResponse;
use App\Services\DatabaseService;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;

class UnifiedController extends Controller
{
    private DatabaseService $dbService;
    
    public function __construct(DatabaseService $dbService)
    {
        $this->dbService = $dbService;
    }
    
    public function execute(Request $request)
    {
        try {
            $validator = Validator::make($request->all(), [
                'Tipo' => 'required|integer|in:0,1',
                'Base' => 'required|string',
                'Operacion' => 'required|string',
                'Parametros' => 'nullable|array',
                'Tiempo' => 'nullable|integer'
            ]);
            
            if ($validator->fails()) {
                return response()->json(
                    eResponse::error(400, 'Parámetros inválidos'),
                    400
                );
            }
            
            $eRequest = new eRequest($request->all());
            
            // Construir automáticamente el nombre del stored procedure
            $storedProcedure = $this->buildStoredProcedureName($eRequest->Operacion);
            
            // Validar que la operación sea válida (seguridad)
            if (!$this->isValidOperation($eRequest->Operacion)) {
                return response()->json(
                    eResponse::error(404, 'Operación no encontrada: ' . $eRequest->Operacion),
                    404
                );
            }
            
            $result = $this->dbService->executeProcedure($eRequest, $storedProcedure);
            
            if ($eRequest->Tipo === 0) {
                return response()->json(eResponse::success(0, $result));
            } else {
                $id = $result['id'] ?? 0;
                return response()->json(eResponse::success($id));
            }
            
        } catch (\Exception $e) {
            return response()->json(
                eResponse::error(500, 'Error interno: ' . $e->getMessage()),
                500
            );
        }
    }
    
    public function health()
    {
        return response()->json([
            'status' => 'healthy',
            'timestamp' => now(),
            'service' => 'Unified API'
        ]);
    }
    
    /**
     * Construye automáticamente el nombre del stored procedure basado en la operación
     */
    private function buildStoredProcedureName(string $operacion): string
    {
        return 'sp_' . strtolower($operacion);
    }
    
    /**
     * Valida que la operación solicitada sea permitida (lista blanca para seguridad)
     */
    private function isValidOperation(string $operacion): bool
    {
        $validOperations = [
            'individual_diversos_resumen',
            'individual_diversos_adeudos',
            'individual_diversos_pagos',
            'individual_diversos_referencias',
            'buscar_convenio_diversos',
            'modificar_datos_generales_convenio_diversos',
            'bloquear_convenio_diversos',
            'desbloquear_convenio_diversos',
            'dar_pagado_convenio_diversos',
            'dar_baja_convenio_diversos',
            'listar_tipos_convenio_diversos',
            'listar_subtipos_convenio_diversos',
            'get_tipos',
            'add_tipo',
            'update_tipo',
            'delete_tipo'
        ];
        
        return in_array(strtolower($operacion), $validOperations);
    }
}
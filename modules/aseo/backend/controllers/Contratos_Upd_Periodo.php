<?php

namespace App\Http\Controllers\Contratos;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use App\Http\Controllers\Controller;

class ContratosUpdPeriodoController extends Controller
{
    /**
     * Endpoint único para eRequest/eResponse
     */
    public function execute(Request $request)
    {
        $action = $request->input('action');
        $params = $request->input('params', []);
        $userId = $request->user() ? $request->user()->id : null;
        
        switch ($action) {
            case 'buscarContrato':
                return $this->buscarContrato($params);
            case 'actualizarPeriodoObligacion':
                return $this->actualizarPeriodoObligacion($params, $userId);
            case 'catalogoTipoAseo':
                return $this->catalogoTipoAseo();
            default:
                return response()->json([
                    'success' => false,
                    'message' => 'Acción no soportada'
                ], 400);
        }
    }

    /**
     * Buscar contrato por número y tipo de aseo
     */
    private function buscarContrato($params)
    {
        $numContrato = $params['num_contrato'] ?? null;
        $ctrolAseo = $params['ctrol_aseo'] ?? null;
        if (!$numContrato || !$ctrolAseo) {
            return response()->json([
                'success' => false,
                'message' => 'Faltan parámetros requeridos'
            ], 422);
        }
        $result = DB::select('SELECT * FROM sp_contratos_buscar(:num_contrato, :ctrol_aseo)', [
            'num_contrato' => $numContrato,
            'ctrol_aseo' => $ctrolAseo
        ]);
        if (empty($result)) {
            return response()->json([
                'success' => false,
                'message' => 'No existe contrato con esos datos'
            ]);
        }
        return response()->json([
            'success' => true,
            'data' => $result[0]
        ]);
    }

    /**
     * Actualizar periodo de inicio de obligación
     */
    private function actualizarPeriodoObligacion($params, $userId)
    {
        $controlContrato = $params['control_contrato'] ?? null;
        $anio = $params['anio'] ?? null;
        $mes = $params['mes'] ?? null;
        $documento = $params['documento'] ?? null;
        $descripcion = $params['descripcion'] ?? null;
        if (!$controlContrato || !$anio || !$mes || !$documento) {
            return response()->json([
                'success' => false,
                'message' => 'Faltan parámetros requeridos'
            ], 422);
        }
        try {
            $result = DB::select('SELECT * FROM sp_contratos_actualizar_periodo_obligacion(:control_contrato, :anio, :mes, :documento, :descripcion, :usuario)', [
                'control_contrato' => $controlContrato,
                'anio' => $anio,
                'mes' => $mes,
                'documento' => $documento,
                'descripcion' => $descripcion,
                'usuario' => $userId
            ]);
            return response()->json([
                'success' => true,
                'message' => $result[0]->leyenda ?? 'Actualización realizada',
                'status' => $result[0]->status ?? 0
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Error al actualizar: ' . $e->getMessage()
            ], 500);
        }
    }

    /**
     * Catálogo de tipos de aseo
     */
    private function catalogoTipoAseo()
    {
        $result = DB::select('SELECT * FROM ta_16_tipo_aseo ORDER BY ctrol_aseo');
        return response()->json([
            'success' => true,
            'data' => $result
        ]);
    }
}

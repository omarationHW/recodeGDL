<?php

namespace App\Http\Controllers\Contratos;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use App\Http\Controllers\Controller;

class ContratosUpdUndCController extends Controller
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
            case 'listarTiposAseo':
                return $this->listarTiposAseo();
            case 'actualizarUnidades':
                return $this->actualizarUnidades($params, $userId);
            default:
                return response()->json([
                    'success' => false,
                    'message' => 'Acción no soportada.'
                ], 400);
        }
    }

    /**
     * Buscar contrato vigente por número y tipo de aseo
     */
    private function buscarContrato($params)
    {
        $contrato = $params['contrato'] ?? null;
        $ctrol_aseo = $params['ctrol_aseo'] ?? null;
        if (!$contrato || !$ctrol_aseo) {
            return response()->json([
                'success' => false,
                'message' => 'Faltan parámetros requeridos.'
            ], 422);
        }
        $result = DB::select('SELECT * FROM sp_contratos_upd_undc_buscar(?, ?)', [$contrato, $ctrol_aseo]);
        if (empty($result)) {
            return response()->json([
                'success' => false,
                'message' => 'No existe contrato vigente con esos datos.'
            ], 404);
        }
        return response()->json([
            'success' => true,
            'data' => $result[0]
        ]);
    }

    /**
     * Listar tipos de aseo
     */
    private function listarTiposAseo()
    {
        $tipos = DB::select('SELECT * FROM sp_contratos_upd_undc_listar_tipos_aseo()');
        return response()->json([
            'success' => true,
            'data' => $tipos
        ]);
    }

    /**
     * Actualizar unidades de recolección en contrato
     */
    private function actualizarUnidades($params, $userId)
    {
        $contrato_id = $params['contrato_id'] ?? null;
        $nueva_cantidad = $params['nueva_cantidad'] ?? null;
        $ejercicio = $params['ejercicio'] ?? null;
        $mes = $params['mes'] ?? null;
        $documento = $params['documento'] ?? null;
        $descripcion_docto = $params['descripcion_docto'] ?? null;
        if (!$contrato_id || !$nueva_cantidad || !$ejercicio || !$mes || !$documento || !$descripcion_docto) {
            return response()->json([
                'success' => false,
                'message' => 'Faltan parámetros requeridos.'
            ], 422);
        }
        $result = DB::select('SELECT * FROM sp_contratos_upd_undc_actualizar_unidades(?, ?, ?, ?, ?, ?, ?)', [
            $contrato_id,
            $nueva_cantidad,
            $ejercicio,
            $mes,
            $documento,
            $descripcion_docto,
            $userId
        ]);
        $row = $result[0] ?? null;
        if ($row && $row->success) {
            return response()->json([
                'success' => true,
                'message' => $row->message
            ]);
        } else {
            return response()->json([
                'success' => false,
                'message' => $row ? $row->message : 'Error desconocido.'
            ], 500);
        }
    }
}

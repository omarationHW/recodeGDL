<?php
namespace App\Http\Controllers\Api;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use App\Http\Controllers\Controller;

class ContratosUpdUndController extends Controller
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
            case 'buscar_contrato':
                return $this->buscarContrato($params);
            case 'actualizar_unidades':
                return $this->actualizarUnidades($params, $userId);
            case 'catalogo_tipo_aseo':
                return $this->catalogoTipoAseo();
            case 'catalogo_unidades':
                return $this->catalogoUnidades($params);
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
        $numContrato = $params['num_contrato'] ?? null;
        $ctrolAseo = $params['ctrol_aseo'] ?? null;
        if (!$numContrato || !$ctrolAseo) {
            return response()->json([
                'success' => false,
                'message' => 'Faltan parámetros requeridos.'
            ], 422);
        }
        $contrato = DB::selectOne('SELECT * FROM buscar_contrato_upd_und(:num_contrato, :ctrol_aseo)', [
            'num_contrato' => $numContrato,
            'ctrol_aseo' => $ctrolAseo
        ]);
        if (!$contrato) {
            return response()->json([
                'success' => false,
                'message' => 'No existe contrato vigente con esos datos.'
            ], 404);
        }
        // Unidades disponibles para el ejercicio actual
        $ejercicio = $params['ejercicio'] ?? date('Y');
        $unidades = DB::select('SELECT * FROM catalogo_unidades(:ejercicio)', [
            'ejercicio' => $ejercicio
        ]);
        return response()->json([
            'success' => true,
            'contrato' => $contrato,
            'unidades' => $unidades
        ]);
    }

    /**
     * Actualizar unidades de recolección en contrato
     */
    private function actualizarUnidades($params, $userId)
    {
        $contratoId = $params['control_contrato'] ?? null;
        $ctrolRecolec = $params['ctrol_recolec'] ?? null;
        $cantidad = $params['cantidad'] ?? null;
        $ejercicio = $params['ejercicio'] ?? null;
        $mes = $params['mes'] ?? null;
        $documento = $params['documento'] ?? null;
        $descripcion = $params['descripcion'] ?? null;
        if (!$contratoId || !$ctrolRecolec || !$cantidad || !$ejercicio || !$mes || !$documento) {
            return response()->json([
                'success' => false,
                'message' => 'Faltan parámetros requeridos.'
            ], 422);
        }
        try {
            $result = DB::selectOne('SELECT * FROM actualizar_unidades_contrato(:contrato_id, :ctrol_recolec, :cantidad, :ejercicio, :mes, :documento, :descripcion, :user_id)', [
                'contrato_id' => $contratoId,
                'ctrol_recolec' => $ctrolRecolec,
                'cantidad' => $cantidad,
                'ejercicio' => $ejercicio,
                'mes' => $mes,
                'documento' => $documento,
                'descripcion' => $descripcion,
                'user_id' => $userId
            ]);
            if ($result && $result->status == 0) {
                return response()->json([
                    'success' => true,
                    'message' => $result->leyenda
                ]);
            } else {
                return response()->json([
                    'success' => false,
                    'message' => $result ? $result->leyenda : 'Error desconocido.'
                ], 400);
            }
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * Catálogo de tipos de aseo
     */
    private function catalogoTipoAseo()
    {
        $tipos = DB::select('SELECT * FROM catalogo_tipo_aseo()');
        return response()->json([
            'success' => true,
            'tipos' => $tipos
        ]);
    }

    /**
     * Catálogo de unidades de recolección para un ejercicio
     */
    private function catalogoUnidades($params)
    {
        $ejercicio = $params['ejercicio'] ?? date('Y');
        $unidades = DB::select('SELECT * FROM catalogo_unidades(:ejercicio)', [
            'ejercicio' => $ejercicio
        ]);
        return response()->json([
            'success' => true,
            'unidades' => $unidades
        ]);
    }
}

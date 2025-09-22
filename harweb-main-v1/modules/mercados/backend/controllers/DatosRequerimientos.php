<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;

class DatosRequerimientosController extends Controller
{
    // Endpoint único para eRequest/eResponse
    public function execute(Request $request)
    {
        $action = $request->input('action');
        $params = $request->input('params', []);
        $userId = $request->user() ? $request->user()->id : null;

        switch ($action) {
            case 'getLocales':
                return $this->getLocales($params);
            case 'getMercado':
                return $this->getMercado($params);
            case 'getRequerimientos':
                return $this->getRequerimientos($params);
            case 'getPeriodos':
                return $this->getPeriodos($params);
            default:
                return response()->json([
                    'success' => false,
                    'message' => 'Acción no soportada',
                    'data' => null
                ], 400);
        }
    }

    // Obtener datos del local
    private function getLocales($params)
    {
        $id_local = $params['id_local'] ?? null;
        if (!$id_local) {
            return response()->json(['success' => false, 'message' => 'id_local requerido', 'data' => null], 422);
        }
        $result = DB::select('SELECT * FROM ta_11_locales WHERE id_local = ?', [$id_local]);
        return response()->json(['success' => true, 'data' => $result]);
    }

    // Obtener datos del mercado
    private function getMercado($params)
    {
        $oficina = $params['oficina'] ?? null;
        $num_mercado = $params['num_mercado'] ?? null;
        if (!$oficina || !$num_mercado) {
            return response()->json(['success' => false, 'message' => 'oficina y num_mercado requeridos', 'data' => null], 422);
        }
        $result = DB::select('SELECT * FROM ta_11_mercados WHERE oficina = ? AND num_mercado_nvo = ?', [$oficina, $num_mercado]);
        return response()->json(['success' => true, 'data' => $result]);
    }

    // Obtener requerimientos por folio
    private function getRequerimientos($params)
    {
        $modulo = $params['modulo'] ?? null;
        $folio = $params['folio'] ?? null;
        $control_otr = $params['control_otr'] ?? null;
        if (!$modulo || !$folio || !$control_otr) {
            return response()->json(['success' => false, 'message' => 'modulo, folio y control_otr requeridos', 'data' => null], 422);
        }
        $result = DB::select('SELECT a.*, b.usuario as usuario_1, b.nombre, b.estado, b.id_rec, b.nivel FROM ta_15_apremios a JOIN ta_12_passwords b ON a.usuario = b.id_usuario WHERE a.modulo = ? AND a.folio = ? AND a.control_otr = ?', [$modulo, $folio, $control_otr]);
        return response()->json(['success' => true, 'data' => $result]);
    }

    // Obtener periodos de requerimiento
    private function getPeriodos($params)
    {
        $control_otr = $params['control_otr'] ?? null;
        if (!$control_otr) {
            return response()->json(['success' => false, 'message' => 'control_otr requerido', 'data' => null], 422);
        }
        $result = DB::select('SELECT * FROM ta_15_periodos WHERE control_otr = ?', [$control_otr]);
        return response()->json(['success' => true, 'data' => $result]);
    }
}

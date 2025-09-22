<?php

namespace App\Http\Controllers\Api;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;
use App\Http\Controllers\Controller;

class FacturacionController extends Controller
{
    /**
     * Endpoint unificado para eRequest/eResponse
     * POST /api/execute
     */
    public function execute(Request $request)
    {
        $action = $request->input('action');
        $params = $request->input('params', []);
        $user = $request->user(); // Si hay autenticación

        switch ($action) {
            case 'getRecaudadoras':
                $data = DB::select('SELECT id_rec, recaudadora FROM ta_12_recaudadoras ORDER BY id_rec');
                return response()->json(['success' => true, 'data' => $data]);

            case 'facturacionList':
                $validator = Validator::make($params, [
                    'modulo' => 'required|integer',
                    'rec' => 'required|integer',
                    'fol1' => 'required|integer',
                    'fol2' => 'required|integer',
                ]);
                if ($validator->fails()) {
                    return response()->json(['success' => false, 'errors' => $validator->errors()], 422);
                }
                $result = DB::select('CALL sp_facturacion_list(?, ?, ?, ?)', [
                    $params['modulo'],
                    $params['rec'],
                    $params['fol1'],
                    $params['fol2']
                ]);
                return response()->json(['success' => true, 'data' => $result]);

            case 'facturacionReport':
                $validator = Validator::make($params, [
                    'modulo' => 'required|integer',
                    'rec' => 'required|integer',
                    'fol1' => 'required|integer',
                    'fol2' => 'required|integer',
                ]);
                if ($validator->fails()) {
                    return response()->json(['success' => false, 'errors' => $validator->errors()], 422);
                }
                $result = DB::select('CALL sp_facturacion_report(?, ?, ?, ?)', [
                    $params['modulo'],
                    $params['rec'],
                    $params['fol1'],
                    $params['fol2']
                ]);
                // Aquí podrías generar PDF/Excel si se requiere
                return response()->json(['success' => true, 'data' => $result]);

            default:
                return response()->json(['success' => false, 'error' => 'Acción no soportada'], 400);
        }
    }
}

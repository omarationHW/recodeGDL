<?php
namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\Validator;

class ListadosSinAdereqController extends Controller
{
    /**
     * Endpoint unificado para eRequest/eResponse
     */
    public function execute(Request $request)
    {
        $action = $request->input('action');
        $params = $request->input('params', []);
        $user = $request->user(); // Si hay auth
        try {
            switch ($action) {
                case 'getRecaudadoras':
                    $result = DB::select('SELECT * FROM ta_12_recaudadoras ORDER BY id_rec');
                    return response()->json(['success' => true, 'data' => $result]);
                case 'getMercados':
                    $id_rec = $params['id_rec'] ?? null;
                    $result = DB::select('SELECT * FROM ta_11_mercados WHERE oficina = ? ORDER BY num_mercado_nvo', [$id_rec]);
                    return response()->json(['success' => true, 'data' => $result]);
                case 'getSecciones':
                    $num_mercado = $params['num_mercado_nvo'] ?? null;
                    $result = DB::select('SELECT * FROM ta_11_secciones WHERE num_mercado_nvo = ? ORDER BY seccion', [$num_mercado]);
                    return response()->json(['success' => true, 'data' => $result]);
                case 'getListadosSinAdereq':
                    // Parámetros esperados: tipo, id_rec, num_mercado, seccion, local1, local2
                    $tipo = $params['tipo'] ?? 'todos';
                    $id_rec = $params['id_rec'] ?? null;
                    $num_mercado = $params['num_mercado'] ?? null;
                    $seccion = $params['seccion'] ?? null;
                    $local1 = $params['local1'] ?? 1;
                    $local2 = $params['local2'] ?? 9999;
                    $result = DB::select('CALL sp_listados_sin_adereq(?,?,?,?,?,?)', [
                        $tipo, $id_rec, $num_mercado, $seccion, $local1, $local2
                    ]);
                    return response()->json(['success' => true, 'data' => $result]);
                case 'getBloqueos':
                    $id_local = $params['id_local'] ?? null;
                    $result = DB::select('SELECT * FROM ta_11_bloqueo WHERE id_local = ?', [$id_local]);
                    return response()->json(['success' => true, 'data' => $result]);
                case 'getUltimoMovimiento':
                    $id_local = $params['id_local'] ?? null;
                    $result = DB::select('CALL sp_ultimo_movimiento_local(?)', [$id_local]);
                    return response()->json(['success' => true, 'data' => $result]);
                default:
                    return response()->json(['success' => false, 'error' => 'Acción no soportada'], 400);
            }
        } catch (\Exception $e) {
            Log::error('ListadosSinAdereqController error: ' . $e->getMessage());
            return response()->json(['success' => false, 'error' => $e->getMessage()], 500);
        }
    }
}

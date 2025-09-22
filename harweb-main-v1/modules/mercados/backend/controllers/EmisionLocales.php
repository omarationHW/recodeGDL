<?php
namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;

class EmisionLocalesController extends Controller
{
    /**
     * Endpoint único para ejecutar acciones del formulario EmisionLocales
     * Entrada: {
     *   "eRequest": {
     *     "action": "listarMercados|emitirRecibos|grabarEmision|facturacion|...",
     *     ... parámetros ...
     *   }
     * }
     * Salida: {
     *   "eResponse": { ... }
     * }
     */
    public function execute(Request $request)
    {
        $input = $request->input('eRequest');
        $action = $input['action'] ?? null;
        $response = [];
        try {
            switch ($action) {
                case 'listarMercados':
                    $oficina = $input['oficina'];
                    $result = DB::select('CALL sp_emisionlocales_listar_mercados(?)', [$oficina]);
                    $response = ['mercados' => $result];
                    break;
                case 'emitirRecibos':
                    $params = [
                        $input['oficina'],
                        $input['mercado'],
                        $input['axo'],
                        $input['periodo'],
                        $input['usuario_id']
                    ];
                    $result = DB::select('CALL sp_emisionlocales_emitir_recibos(?,?,?,?,?)', $params);
                    $response = ['recibos' => $result];
                    break;
                case 'grabarEmision':
                    $params = [
                        $input['oficina'],
                        $input['mercado'],
                        $input['axo'],
                        $input['periodo'],
                        $input['usuario_id']
                    ];
                    $result = DB::select('CALL sp_emisionlocales_grabar_emision(?,?,?,?,?)', $params);
                    $response = ['status' => 'ok', 'message' => 'Emisión grabada correctamente', 'detalles' => $result];
                    break;
                case 'facturacion':
                    $params = [
                        $input['oficina'],
                        $input['mercado'],
                        $input['axo'],
                        $input['periodo'],
                        $input['solo_mercado'] ?? true
                    ];
                    $result = DB::select('CALL sp_emisionlocales_facturacion(?,?,?,?,?)', $params);
                    $response = ['facturacion' => $result];
                    break;
                case 'detalleLocal':
                    $id_local = $input['id_local'];
                    $result = DB::select('CALL sp_emisionlocales_detalle_local(?)', [$id_local]);
                    $response = ['local' => $result];
                    break;
                default:
                    return response()->json(['eResponse' => ['error' => 'Acción no soportada']], 400);
            }
        } catch (\Exception $e) {
            return response()->json(['eResponse' => ['error' => $e->getMessage()]], 500);
        }
        return response()->json(['eResponse' => $response]);
    }
}

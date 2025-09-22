<?php

namespace App\Http\Controllers\Api;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;
use App\Http\Controllers\Controller;

class ExecuteController extends Controller
{
    /**
     * Endpoint único para ejecutar acciones del sistema (eRequest/eResponse)
     */
    public function execute(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'action' => 'required|string',
            'params' => 'nullable|array',
        ]);
        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'errors' => $validator->errors(),
            ], 422);
        }

        $action = $request->input('action');
        $params = $request->input('params', []);
        $response = null;

        try {
            switch ($action) {
                case 'buscar_persona_rfc':
                    $rfc = $params['rfc'] ?? '';
                    $response = DB::select('SELECT id_esta_persona, rfc, TRIM(COALESCE(nombre, \'\')) || \' \' || TRIM(COALESCE(ap_pater, \'\')) || \' \' || TRIM(COALESCE(ap_mater, \'\')) AS nombre FROM ta14_personas WHERE rfc ILIKE ? ORDER BY rfc', [$rfc.'%']);
                    break;
                case 'listar_categorias':
                    $response = DB::select('SELECT id, tipo, categoria, descripcion FROM pubcategoria WHERE tipo = ? ORDER BY descripcion', ['N']);
                    break;
                case 'ultimo_num_estacionamiento':
                    $row = DB::selectOne('SELECT COALESCE(MAX(numesta),0) AS numesta FROM pubmain');
                    $response = $row;
                    break;
                case 'consultar_predio':
                    $dato = $params['dato'] ?? '';
                    $result = DB::selectOne('SELECT * FROM cons_predio(?, ?)', [2, $dato]);
                    $response = $result;
                    break;
                case 'costo_forma':
                    $row = DB::selectOne('SELECT costo_forma FROM pubparametros LIMIT 1');
                    $response = $row;
                    break;
                case 'alta_estacionamiento':
                    $result = DB::selectOne('SELECT * FROM sppubalta(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)', [
                        $params['pubcategoria_id'],
                        $params['numesta'],
                        $params['sector'],
                        $params['zona'],
                        $params['subzona'],
                        $params['numlicencia'],
                        $params['axolicencias'],
                        $params['cvecuenta'],
                        $params['nombre'],
                        $params['calle'],
                        $params['numext'],
                        $params['telefono'],
                        $params['cupo'],
                        $params['fecha_at'],
                        $params['fecha_inicial'],
                        $params['fecha_vencimiento'],
                        $params['rfc'],
                        $params['movtos_no'],
                        $params['movto_cve'],
                        $params['movto_usr'],
                        $params['solicitud'],
                        $params['control']
                    ]);
                    $response = $result;
                    break;
                case 'alta_adeudo_forma':
                    $result = DB::selectOne('SELECT * FROM sp_pubadeudo_forma(?,?,?,?,?,?)', [
                        $params['pubmain_id'],
                        $params['axo'],
                        $params['mes'],
                        $params['concepto'],
                        $params['ade_importe'],
                        $params['id_usuario']
                    ]);
                    $response = $result;
                    break;
                default:
                    return response()->json([
                        'success' => false,
                        'error' => 'Acción no soportada: ' . $action
                    ], 400);
            }
            return response()->json([
                'success' => true,
                'data' => $response
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'error' => $e->getMessage(),
                'trace' => config('app.debug') ? $e->getTraceAsString() : null
            ], 500);
        }
    }
}

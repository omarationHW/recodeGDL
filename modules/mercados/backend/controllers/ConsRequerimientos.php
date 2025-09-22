<?php
namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;

class ConsRequerimientosController extends Controller
{
    /**
     * Endpoint unificado para eRequest/eResponse
     */
    public function execute(Request $request)
    {
        $action = $request->input('action');
        $params = $request->input('params', []);
        $response = [
            'success' => false,
            'data' => null,
            'message' => ''
        ];
        try {
            switch ($action) {
                case 'getMercados':
                    $response['data'] = DB::select('SELECT * FROM sp_get_mercados()');
                    $response['success'] = true;
                    break;
                case 'getLocalesByMercado':
                    $validator = Validator::make($params, [
                        'oficina' => 'required|integer',
                        'num_mercado' => 'required|integer',
                        'categoria' => 'required|integer',
                        'seccion' => 'required|string',
                        'local' => 'required|integer',
                        'letra_local' => 'nullable|string',
                        'bloque' => 'nullable|string'
                    ]);
                    if ($validator->fails()) {
                        $response['message'] = $validator->errors()->first();
                        break;
                    }
                    $result = DB::select('SELECT * FROM sp_get_locales_by_mercado(?,?,?,?,?,?,?)', [
                        $params['oficina'],
                        $params['num_mercado'],
                        $params['categoria'],
                        $params['seccion'],
                        $params['local'],
                        $params['letra_local'],
                        $params['bloque']
                    ]);
                    $response['data'] = $result;
                    $response['success'] = true;
                    break;
                case 'getRequerimientosByLocal':
                    $validator = Validator::make($params, [
                        'modulo' => 'required|integer',
                        'control_otr' => 'required|integer'
                    ]);
                    if ($validator->fails()) {
                        $response['message'] = $validator->errors()->first();
                        break;
                    }
                    $result = DB::select('SELECT * FROM sp_get_requerimientos_by_local(?,?)', [
                        $params['modulo'],
                        $params['control_otr']
                    ]);
                    $response['data'] = $result;
                    $response['success'] = true;
                    break;
                case 'getPeriodosByRequerimiento':
                    $validator = Validator::make($params, [
                        'control_otr' => 'required|integer'
                    ]);
                    if ($validator->fails()) {
                        $response['message'] = $validator->errors()->first();
                        break;
                    }
                    $result = DB::select('SELECT * FROM sp_get_periodos_by_requerimiento(?)', [
                        $params['control_otr']
                    ]);
                    $response['data'] = $result;
                    $response['success'] = true;
                    break;
                case 'getEjecutorById':
                    $validator = Validator::make($params, [
                        'ejecutor' => 'required|integer'
                    ]);
                    if ($validator->fails()) {
                        $response['message'] = $validator->errors()->first();
                        break;
                    }
                    $result = DB::select('SELECT * FROM sp_get_ejecutor_by_id(?)', [
                        $params['ejecutor']
                    ]);
                    $response['data'] = $result;
                    $response['success'] = true;
                    break;
                case 'getClaveByVigencia':
                    $validator = Validator::make($params, [
                        'vigencia' => 'required|string'
                    ]);
                    if ($validator->fails()) {
                        $response['message'] = $validator->errors()->first();
                        break;
                    }
                    $result = DB::select('SELECT * FROM sp_get_clave_by_vigencia(?)', [
                        $params['vigencia']
                    ]);
                    $response['data'] = $result;
                    $response['success'] = true;
                    break;
                case 'getClaveByDiligencia':
                    $validator = Validator::make($params, [
                        'diligencia' => 'required|string'
                    ]);
                    if ($validator->fails()) {
                        $response['message'] = $validator->errors()->first();
                        break;
                    }
                    $result = DB::select('SELECT * FROM sp_get_clave_by_diligencia(?)', [
                        $params['diligencia']
                    ]);
                    $response['data'] = $result;
                    $response['success'] = true;
                    break;
                case 'getClaveByPracticado':
                    $validator = Validator::make($params, [
                        'clave_practicado' => 'required|string'
                    ]);
                    if ($validator->fails()) {
                        $response['message'] = $validator->errors()->first();
                        break;
                    }
                    $result = DB::select('SELECT * FROM sp_get_clave_by_practicado(?)', [
                        $params['clave_practicado']
                    ]);
                    $response['data'] = $result;
                    $response['success'] = true;
                    break;
                default:
                    $response['message'] = 'Acción no soportada';
            }
        } catch (\Exception $e) {
            $response['message'] = $e->getMessage();
        }
        return response()->json($response);
    }
}

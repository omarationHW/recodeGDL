<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;

class RecargosController extends Controller
{
    /**
     * Endpoint unificado para eRequest/eResponse
     * POST /api/execute
     */
    public function execute(Request $request)
    {
        $action = $request->input('action');
        $params = $request->input('params', []);
        $userId = $request->user() ? $request->user()->id : null;
        $response = [
            'success' => false,
            'data' => null,
            'message' => ''
        ];

        try {
            switch ($action) {
                case 'recargos.list':
                    $mes = $params['mes'] ?? null;
                    $result = DB::select('CALL sp_recargos_list(?)', [$mes]);
                    $response['success'] = true;
                    $response['data'] = $result;
                    break;
                case 'recargos.get':
                    $axo = $params['axo'] ?? null;
                    $mes = $params['mes'] ?? null;
                    $result = DB::select('CALL sp_recargos_get(?, ?)', [$axo, $mes]);
                    $response['success'] = true;
                    $response['data'] = $result;
                    break;
                case 'recargos.create':
                    $validator = Validator::make($params, [
                        'axo' => 'required|integer',
                        'mes' => 'required|integer',
                        'porcentaje_parcial' => 'required|numeric|min:0.01|max:100',
                        'usuario' => 'required|integer',
                    ]);
                    if ($validator->fails()) {
                        $response['message'] = $validator->errors()->first();
                        break;
                    }
                    $result = DB::select('SELECT * FROM sp_recargos_create(?, ?, ?, ?)', [
                        $params['axo'],
                        $params['mes'],
                        $params['porcentaje_parcial'],
                        $params['usuario']
                    ]);
                    $response['success'] = true;
                    $response['data'] = $result;
                    break;
                case 'recargos.update':
                    $validator = Validator::make($params, [
                        'axo' => 'required|integer',
                        'mes' => 'required|integer',
                        'porcentaje_parcial' => 'required|numeric|min:0.01|max:100',
                        'usuario' => 'required|integer',
                    ]);
                    if ($validator->fails()) {
                        $response['message'] = $validator->errors()->first();
                        break;
                    }
                    $result = DB::select('SELECT * FROM sp_recargos_update(?, ?, ?, ?)', [
                        $params['axo'],
                        $params['mes'],
                        $params['porcentaje_parcial'],
                        $params['usuario']
                    ]);
                    $response['success'] = true;
                    $response['data'] = $result;
                    break;
                case 'recargos.acumulado':
                    $axo = $params['axo'] ?? null;
                    $mes = $params['mes'] ?? null;
                    $result = DB::select('SELECT * FROM sp_recargos_acumulado(?, ?)', [$axo, $mes]);
                    $response['success'] = true;
                    $response['data'] = $result;
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

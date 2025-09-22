<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;

class CatalogoMnttoController extends Controller
{
    /**
     * Endpoint único para eRequest/eResponse
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
                case 'getCatalogoList':
                    $response['data'] = DB::select('SELECT * FROM sp_catalogo_mntto_list()');
                    $response['success'] = true;
                    break;
                case 'getCatalogoById':
                    $id = $params['id'] ?? null;
                    $response['data'] = DB::select('SELECT * FROM sp_catalogo_mntto_get(?)', [$id]);
                    $response['success'] = true;
                    break;
                case 'insertCatalogo':
                    $validator = Validator::make($params, [
                        'oficina' => 'required|integer',
                        'num_mercado_nvo' => 'required|integer',
                        'categoria' => 'required|integer',
                        'descripcion' => 'required|string',
                        'cuenta_ingreso' => 'required|integer',
                        'pregunta' => 'required|string',
                        'cuenta_energia' => 'nullable|integer',
                        'zona' => 'required|integer',
                        'emision' => 'required|string'
                    ]);
                    if ($validator->fails()) {
                        $response['message'] = $validator->errors()->first();
                        break;
                    }
                    $result = DB::select('SELECT * FROM sp_catalogo_mntto_insert(?,?,?,?,?,?,?,?,?)', [
                        $params['oficina'],
                        $params['num_mercado_nvo'],
                        $params['categoria'],
                        $params['descripcion'],
                        $params['cuenta_ingreso'],
                        $params['pregunta'],
                        $params['cuenta_energia'],
                        $params['zona'],
                        $params['emision']
                    ]);
                    $response['success'] = $result[0]->success;
                    $response['message'] = $result[0]->message;
                    break;
                case 'updateCatalogo':
                    $validator = Validator::make($params, [
                        'oficina' => 'required|integer',
                        'num_mercado_nvo' => 'required|integer',
                        'categoria' => 'required|integer',
                        'descripcion' => 'required|string',
                        'cuenta_ingreso' => 'required|integer',
                        'pregunta' => 'required|string',
                        'cuenta_energia' => 'nullable|integer',
                        'zona' => 'required|integer',
                        'emision' => 'required|string'
                    ]);
                    if ($validator->fails()) {
                        $response['message'] = $validator->errors()->first();
                        break;
                    }
                    $result = DB::select('SELECT * FROM sp_catalogo_mntto_update(?,?,?,?,?,?,?,?,?)', [
                        $params['oficina'],
                        $params['num_mercado_nvo'],
                        $params['categoria'],
                        $params['descripcion'],
                        $params['cuenta_ingreso'],
                        $params['pregunta'],
                        $params['cuenta_energia'],
                        $params['zona'],
                        $params['emision']
                    ]);
                    $response['success'] = $result[0]->success;
                    $response['message'] = $result[0]->message;
                    break;
                case 'getRecaudadoras':
                    $response['data'] = DB::select('SELECT * FROM sp_recaudadoras_list()');
                    $response['success'] = true;
                    break;
                case 'getCategorias':
                    $response['data'] = DB::select('SELECT * FROM sp_categorias_list()');
                    $response['success'] = true;
                    break;
                case 'getZonas':
                    $response['data'] = DB::select('SELECT * FROM sp_zonas_list()');
                    $response['success'] = true;
                    break;
                case 'getCuentas':
                    $response['data'] = DB::select('SELECT * FROM sp_cuentas_list()');
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

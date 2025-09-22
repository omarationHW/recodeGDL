<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;

class BusqueController extends Controller
{
    /**
     * Endpoint único para ejecutar acciones de búsqueda.
     * Entrada: eRequest con action y parámetros
     * Salida: eResponse con status, data, message
     */
    public function execute(Request $request)
    {
        $action = $request->input('action');
        $params = $request->input('params', []);
        $response = [
            'status' => 'error',
            'data' => null,
            'message' => 'Acción no reconocida'
        ];

        try {
            switch ($action) {
                case 'searchByName':
                    $validator = Validator::make($params, [
                        'nombre' => 'required|string|min:3'
                    ]);
                    if ($validator->fails()) {
                        $response['message'] = $validator->errors()->first();
                        break;
                    }
                    $data = DB::select('SELECT * FROM sp_busque_search_by_name(?)', [$params['nombre']]);
                    $response = [
                        'status' => 'success',
                        'data' => $data,
                        'message' => 'Resultados por nombre obtenidos'
                    ];
                    break;
                case 'searchByLocation':
                    $validator = Validator::make($params, [
                        'calle' => 'required|string',
                        'exterior' => 'nullable|string'
                    ]);
                    if ($validator->fails()) {
                        $response['message'] = $validator->errors()->first();
                        break;
                    }
                    $data = DB::select('SELECT * FROM sp_busque_search_by_location(?, ?)', [
                        $params['calle'],
                        $params['exterior'] ?? ''
                    ]);
                    $response = [
                        'status' => 'success',
                        'data' => $data,
                        'message' => 'Resultados por ubicación obtenidos'
                    ];
                    break;
                case 'searchByClaveCatastral':
                    $validator = Validator::make($params, [
                        'zona' => 'required|string',
                        'manzana' => 'required|string',
                        'predio' => 'nullable|string',
                        'subpredio' => 'nullable|string'
                    ]);
                    if ($validator->fails()) {
                        $response['message'] = $validator->errors()->first();
                        break;
                    }
                    $data = DB::select('SELECT * FROM sp_busque_search_by_clave_catastral(?, ?, ?, ?)', [
                        $params['zona'],
                        $params['manzana'],
                        $params['predio'] ?? '',
                        $params['subpredio'] ?? ''
                    ]);
                    $response = [
                        'status' => 'success',
                        'data' => $data,
                        'message' => 'Resultados por clave catastral obtenidos'
                    ];
                    break;
                case 'searchByRFC':
                    $validator = Validator::make($params, [
                        'rfc' => 'required|string|min:10'
                    ]);
                    if ($validator->fails()) {
                        $response['message'] = $validator->errors()->first();
                        break;
                    }
                    $data = DB::select('SELECT * FROM sp_busque_search_by_rfc(?)', [$params['rfc']]);
                    $response = [
                        'status' => 'success',
                        'data' => $data,
                        'message' => 'Resultados por RFC obtenidos'
                    ];
                    break;
                case 'searchByCuenta':
                    $validator = Validator::make($params, [
                        'recaudadora' => 'required|integer',
                        'urbrus' => 'required|string',
                        'cuenta' => 'required|integer'
                    ]);
                    if ($validator->fails()) {
                        $response['message'] = $validator->errors()->first();
                        break;
                    }
                    $data = DB::select('SELECT * FROM sp_busque_search_by_cuenta(?, ?, ?)', [
                        $params['recaudadora'],
                        $params['urbrus'],
                        $params['cuenta']
                    ]);
                    $response = [
                        'status' => 'success',
                        'data' => $data,
                        'message' => 'Resultados por cuenta obtenidos'
                    ];
                    break;
                default:
                    $response['message'] = 'Acción no soportada';
            }
        } catch (\Exception $e) {
            $response['status'] = 'error';
            $response['message'] = $e->getMessage();
        }
        return response()->json($response);
    }
}

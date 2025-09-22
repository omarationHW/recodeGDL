<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;

class FirmasController extends Controller
{
    /**
     * Endpoint unificado para ejecutar acciones sobre Firmas
     * Entrada: eRequest con action, data
     * Salida: eResponse con status, data, message
     */
    public function execute(Request $request)
    {
        $action = $request->input('action');
        $data = $request->input('data', []);
        $response = [
            'status' => 'error',
            'data' => null,
            'message' => 'Acción no válida'
        ];

        try {
            switch ($action) {
                case 'list':
                    $result = DB::select('SELECT * FROM sp_firmas_list()');
                    $response = [
                        'status' => 'success',
                        'data' => $result,
                        'message' => 'Listado obtenido correctamente'
                    ];
                    break;
                case 'create':
                    $validator = Validator::make($data, [
                        'recaudadora' => 'required|integer',
                        'titular' => 'required|string',
                        'cargotitular' => 'required|string',
                        'recaudador' => 'required|string',
                        'cargorecaudador' => 'required|string',
                        'testigo1' => 'required|string',
                        'testigo2' => 'required|string',
                        'letras' => 'required|string|max:3'
                    ]);
                    if ($validator->fails()) {
                        $response['message'] = $validator->errors()->first();
                        break;
                    }
                    $result = DB::select('SELECT * FROM sp_firmas_create(?,?,?,?,?,?,?,?)', [
                        $data['recaudadora'],
                        $data['titular'],
                        $data['cargotitular'],
                        $data['recaudador'],
                        $data['cargorecaudador'],
                        $data['testigo1'],
                        $data['testigo2'],
                        $data['letras']
                    ]);
                    $response = [
                        'status' => 'success',
                        'data' => $result,
                        'message' => 'Firma creada correctamente'
                    ];
                    break;
                case 'update':
                    $validator = Validator::make($data, [
                        'recaudadora' => 'required|integer',
                        'titular' => 'required|string',
                        'cargotitular' => 'required|string',
                        'recaudador' => 'required|string',
                        'cargorecaudador' => 'required|string',
                        'testigo1' => 'required|string',
                        'testigo2' => 'required|string',
                        'letras' => 'required|string|max:3'
                    ]);
                    if ($validator->fails()) {
                        $response['message'] = $validator->errors()->first();
                        break;
                    }
                    $result = DB::select('SELECT * FROM sp_firmas_update(?,?,?,?,?,?,?,?)', [
                        $data['recaudadora'],
                        $data['titular'],
                        $data['cargotitular'],
                        $data['recaudador'],
                        $data['cargorecaudador'],
                        $data['testigo1'],
                        $data['testigo2'],
                        $data['letras']
                    ]);
                    $response = [
                        'status' => 'success',
                        'data' => $result,
                        'message' => 'Firma actualizada correctamente'
                    ];
                    break;
                case 'delete':
                    $validator = Validator::make($data, [
                        'recaudadora' => 'required|integer'
                    ]);
                    if ($validator->fails()) {
                        $response['message'] = $validator->errors()->first();
                        break;
                    }
                    $result = DB::select('SELECT * FROM sp_firmas_delete(?)', [
                        $data['recaudadora']
                    ]);
                    $response = [
                        'status' => 'success',
                        'data' => $result,
                        'message' => 'Firma eliminada correctamente'
                    ];
                    break;
                case 'get':
                    $validator = Validator::make($data, [
                        'recaudadora' => 'required|integer'
                    ]);
                    if ($validator->fails()) {
                        $response['message'] = $validator->errors()->first();
                        break;
                    }
                    $result = DB::select('SELECT * FROM sp_firmas_get(?)', [
                        $data['recaudadora']
                    ]);
                    $response = [
                        'status' => 'success',
                        'data' => $result,
                        'message' => 'Firma obtenida correctamente'
                    ];
                    break;
                default:
                    $response['message'] = 'Acción no soportada';
            }
        } catch (\Exception $e) {
            $response = [
                'status' => 'error',
                'data' => null,
                'message' => $e->getMessage()
            ];
        }
        return response()->json($response);
    }
}

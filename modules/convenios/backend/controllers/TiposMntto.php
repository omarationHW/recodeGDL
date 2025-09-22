<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;

class TiposMnttoController extends Controller
{
    /**
     * Endpoint único para ejecutar acciones sobre Tipos (alta, modificación, consulta)
     * Entrada: eRequest con action, data
     * Salida: eResponse con status, data, message
     */
    public function execute(Request $request)
    {
        $eRequest = $request->input('eRequest');
        $action = $eRequest['action'] ?? null;
        $data = $eRequest['data'] ?? [];
        $eResponse = [
            'status' => 'error',
            'data' => null,
            'message' => 'Acción no válida'
        ];

        try {
            switch ($action) {
                case 'list':
                    $result = DB::select('SELECT * FROM sp_tipos_list()');
                    $eResponse = [
                        'status' => 'success',
                        'data' => $result,
                        'message' => 'Tipos obtenidos correctamente'
                    ];
                    break;
                case 'create':
                    $validator = Validator::make($data, [
                        'tipo' => 'required|integer',
                        'descripcion' => 'required|string|max:50'
                    ]);
                    if ($validator->fails()) {
                        $eResponse['message'] = $validator->errors()->first();
                        break;
                    }
                    $result = DB::select('SELECT * FROM sp_tipos_create(?, ?)', [
                        $data['tipo'],
                        $data['descripcion']
                    ]);
                    $eResponse = [
                        'status' => 'success',
                        'data' => $result[0],
                        'message' => 'Tipo creado correctamente'
                    ];
                    break;
                case 'update':
                    $validator = Validator::make($data, [
                        'tipo' => 'required|integer',
                        'descripcion' => 'required|string|max:50'
                    ]);
                    if ($validator->fails()) {
                        $eResponse['message'] = $validator->errors()->first();
                        break;
                    }
                    $result = DB::select('SELECT * FROM sp_tipos_update(?, ?)', [
                        $data['tipo'],
                        $data['descripcion']
                    ]);
                    $eResponse = [
                        'status' => 'success',
                        'data' => $result[0],
                        'message' => 'Tipo actualizado correctamente'
                    ];
                    break;
                case 'get':
                    $tipo = $data['tipo'] ?? null;
                    if (!$tipo) {
                        $eResponse['message'] = 'Falta el parámetro tipo';
                        break;
                    }
                    $result = DB::select('SELECT * FROM sp_tipos_get(?)', [$tipo]);
                    $eResponse = [
                        'status' => 'success',
                        'data' => $result[0] ?? null,
                        'message' => 'Tipo obtenido correctamente'
                    ];
                    break;
                default:
                    $eResponse['message'] = 'Acción no soportada';
            }
        } catch (\Exception $ex) {
            $eResponse['status'] = 'error';
            $eResponse['message'] = $ex->getMessage();
        }
        return response()->json(['eResponse' => $eResponse]);
    }
}

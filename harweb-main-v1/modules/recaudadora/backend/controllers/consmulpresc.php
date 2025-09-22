<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;

class ConsMulprescController extends Controller
{
    /**
     * Endpoint único para ejecutar acciones sobre prescripciones de multas.
     * Entrada: eRequest con acción, parámetros, usuario, etc.
     * Salida: eResponse con status, data, mensajes, errores.
     */
    public function execute(Request $request)
    {
        $input = $request->all();
        $action = $input['action'] ?? null;
        $params = $input['params'] ?? [];
        $user = $input['user'] ?? null;
        $response = [
            'status' => 'error',
            'data' => null,
            'message' => '',
            'errors' => []
        ];

        try {
            switch ($action) {
                case 'list_prescriptions':
                    $response['data'] = DB::select('SELECT * FROM sp_list_presc_multas()');
                    $response['status'] = 'success';
                    break;
                case 'get_prescription':
                    $id = $params['id_prescri'] ?? null;
                    if (!$id) {
                        $response['message'] = 'id_prescri requerido';
                        break;
                    }
                    $result = DB::select('SELECT * FROM sp_get_presc_multa(?)', [$id]);
                    $response['data'] = $result ? $result[0] : null;
                    $response['status'] = $result ? 'success' : 'not_found';
                    break;
                case 'create_prescription':
                    $validator = Validator::make($params, [
                        'fecaut' => 'required|date',
                        'fecha_prescri' => 'required|date',
                        'oficio' => 'required|string',
                        'capturista' => 'required|string',
                        'dependencia' => 'required|string',
                        'observaciones' => 'required|string',
                        'id_multa' => 'required|integer'
                    ]);
                    if ($validator->fails()) {
                        $response['errors'] = $validator->errors();
                        $response['message'] = 'Datos inválidos';
                        break;
                    }
                    $result = DB::select('SELECT * FROM sp_create_presc_multa(?,?,?,?,?,?,?)', [
                        $params['fecaut'],
                        $params['fecha_prescri'],
                        $params['oficio'],
                        $params['capturista'],
                        $params['dependencia'],
                        $params['observaciones'],
                        $params['id_multa']
                    ]);
                    $response['data'] = $result ? $result[0] : null;
                    $response['status'] = $result ? 'success' : 'error';
                    break;
                case 'update_prescription':
                    $validator = Validator::make($params, [
                        'id_prescri' => 'required|integer',
                        'fecaut' => 'required|date',
                        'fecha_prescri' => 'required|date',
                        'oficio' => 'required|string',
                        'capturista' => 'required|string',
                        'dependencia' => 'required|string',
                        'observaciones' => 'required|string'
                    ]);
                    if ($validator->fails()) {
                        $response['errors'] = $validator->errors();
                        $response['message'] = 'Datos inválidos';
                        break;
                    }
                    $result = DB::select('SELECT * FROM sp_update_presc_multa(?,?,?,?,?,?,?)', [
                        $params['id_prescri'],
                        $params['fecaut'],
                        $params['fecha_prescri'],
                        $params['oficio'],
                        $params['capturista'],
                        $params['dependencia'],
                        $params['observaciones']
                    ]);
                    $response['data'] = $result ? $result[0] : null;
                    $response['status'] = $result ? 'success' : 'error';
                    break;
                case 'delete_prescription':
                    $id = $params['id_prescri'] ?? null;
                    if (!$id) {
                        $response['message'] = 'id_prescri requerido';
                        break;
                    }
                    $result = DB::select('SELECT * FROM sp_delete_presc_multa(?)', [$id]);
                    $response['data'] = $result ? $result[0] : null;
                    $response['status'] = $result ? 'success' : 'error';
                    break;
                default:
                    $response['message'] = 'Acción no soportada';
            }
        } catch (\Exception $e) {
            $response['message'] = $e->getMessage();
            $response['errors'] = [$e->getTraceAsString()];
        }
        return response()->json($response);
    }
}

<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;

class SeccionesMnttoController extends Controller
{
    /**
     * Endpoint unificado para eRequest/eResponse
     */
    public function execute(Request $request)
    {
        $action = $request->input('action');
        $data = $request->input('data', []);
        $response = [
            'success' => false,
            'message' => '',
            'data' => null
        ];

        try {
            switch ($action) {
                case 'getAllSecciones':
                    $result = DB::select('SELECT * FROM ta_11_secciones ORDER BY seccion ASC');
                    $response['success'] = true;
                    $response['data'] = $result;
                    break;
                case 'getSeccion':
                    $validator = Validator::make($data, [
                        'seccion' => 'required|string|max:2'
                    ]);
                    if ($validator->fails()) {
                        $response['message'] = $validator->errors()->first();
                        break;
                    }
                    $result = DB::select('SELECT * FROM ta_11_secciones WHERE seccion = ?', [$data['seccion']]);
                    $response['success'] = true;
                    $response['data'] = $result ? $result[0] : null;
                    break;
                case 'insertSeccion':
                    $validator = Validator::make($data, [
                        'seccion' => 'required|string|max:2',
                        'descripcion' => 'required|string|max:30'
                    ]);
                    if ($validator->fails()) {
                        $response['message'] = $validator->errors()->first();
                        break;
                    }
                    $result = DB::select('SELECT * FROM sp_insert_seccion(?, ?)', [
                        strtoupper($data['seccion']),
                        strtoupper($data['descripcion'])
                    ]);
                    $response['success'] = $result[0]->success;
                    $response['message'] = $result[0]->msg;
                    break;
                case 'updateSeccion':
                    $validator = Validator::make($data, [
                        'seccion' => 'required|string|max:2',
                        'descripcion' => 'required|string|max:30'
                    ]);
                    if ($validator->fails()) {
                        $response['message'] = $validator->errors()->first();
                        break;
                    }
                    $result = DB::select('SELECT * FROM sp_update_seccion(?, ?)', [
                        strtoupper($data['seccion']),
                        strtoupper($data['descripcion'])
                    ]);
                    $response['success'] = $result[0]->success;
                    $response['message'] = $result[0]->msg;
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

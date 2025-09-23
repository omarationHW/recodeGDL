<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;

class CveCuotaController extends Controller
{
    // API Unificada: /api/execute
    public function execute(Request $request)
    {
        $action = $request->input('eRequest.action');
        $params = $request->input('eRequest.params', []);
        $response = [
            'success' => false,
            'message' => '',
            'data' => null
        ];

        try {
            switch ($action) {
                case 'listCveCuota':
                    $result = DB::select('CALL sp_cvecuota_list()');
                    $response['success'] = true;
                    $response['data'] = $result;
                    break;
                case 'createCveCuota':
                    $validator = Validator::make($params, [
                        'clave_cuota' => 'required|integer',
                        'descripcion' => 'required|string|max:50'
                    ]);
                    if ($validator->fails()) {
                        $response['message'] = $validator->errors()->first();
                        break;
                    }
                    $result = DB::select('CALL sp_cvecuota_create(?, ?)', [
                        $params['clave_cuota'],
                        $params['descripcion']
                    ]);
                    $response['success'] = true;
                    $response['message'] = 'Clave de cuota creada correctamente';
                    break;
                case 'updateCveCuota':
                    $validator = Validator::make($params, [
                        'clave_cuota' => 'required|integer',
                        'descripcion' => 'required|string|max:50'
                    ]);
                    if ($validator->fails()) {
                        $response['message'] = $validator->errors()->first();
                        break;
                    }
                    $result = DB::select('CALL sp_cvecuota_update(?, ?)', [
                        $params['clave_cuota'],
                        $params['descripcion']
                    ]);
                    $response['success'] = true;
                    $response['message'] = 'Clave de cuota actualizada correctamente';
                    break;
                case 'deleteCveCuota':
                    $validator = Validator::make($params, [
                        'clave_cuota' => 'required|integer'
                    ]);
                    if ($validator->fails()) {
                        $response['message'] = $validator->errors()->first();
                        break;
                    }
                    $result = DB::select('CALL sp_cvecuota_delete(?)', [
                        $params['clave_cuota']
                    ]);
                    $response['success'] = true;
                    $response['message'] = 'Clave de cuota eliminada correctamente';
                    break;
                case 'getCveCuota':
                    $validator = Validator::make($params, [
                        'clave_cuota' => 'required|integer'
                    ]);
                    if ($validator->fails()) {
                        $response['message'] = $validator->errors()->first();
                        break;
                    }
                    $result = DB::select('CALL sp_cvecuota_get(?)', [
                        $params['clave_cuota']
                    ]);
                    $response['success'] = true;
                    $response['data'] = $result ? $result[0] : null;
                    break;
                default:
                    $response['message'] = 'Acción no soportada';
            }
        } catch (\Exception $e) {
            $response['message'] = $e->getMessage();
        }

        return response()->json(['eResponse' => $response]);
    }
}

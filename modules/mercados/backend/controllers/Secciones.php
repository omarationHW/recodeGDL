<?php
namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;

class SeccionesController extends Controller
{
    // API Unificada: /api/execute
    public function execute(Request $request)
    {
        $action = $request->input('eRequest.action');
        $params = $request->input('eRequest.params', []);
        $response = [
            'success' => false,
            'data' => null,
            'message' => ''
        ];
        try {
            switch ($action) {
                case 'secciones.list':
                    $result = DB::select('SELECT * FROM sp_secciones_list()');
                    $response['success'] = true;
                    $response['data'] = $result;
                    break;
                case 'secciones.create':
                    $validator = Validator::make($params, [
                        'seccion' => 'required|string|max:2',
                        'descripcion' => 'required|string|max:30',
                    ]);
                    if ($validator->fails()) {
                        $response['message'] = $validator->errors()->first();
                        break;
                    }
                    $result = DB::select('SELECT * FROM sp_secciones_create(?, ?)', [
                        $params['seccion'],
                        $params['descripcion']
                    ]);
                    $response['success'] = true;
                    $response['data'] = $result;
                    break;
                case 'secciones.update':
                    $validator = Validator::make($params, [
                        'seccion' => 'required|string|max:2',
                        'descripcion' => 'required|string|max:30',
                    ]);
                    if ($validator->fails()) {
                        $response['message'] = $validator->errors()->first();
                        break;
                    }
                    $result = DB::select('SELECT * FROM sp_secciones_update(?, ?)', [
                        $params['seccion'],
                        $params['descripcion']
                    ]);
                    $response['success'] = true;
                    $response['data'] = $result;
                    break;
                case 'secciones.delete':
                    $validator = Validator::make($params, [
                        'seccion' => 'required|string|max:2',
                    ]);
                    if ($validator->fails()) {
                        $response['message'] = $validator->errors()->first();
                        break;
                    }
                    $result = DB::select('SELECT * FROM sp_secciones_delete(?)', [
                        $params['seccion']
                    ]);
                    $response['success'] = true;
                    $response['data'] = $result;
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

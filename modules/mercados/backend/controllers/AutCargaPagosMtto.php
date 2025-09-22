<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;

class AutCargaPagosMttoController extends Controller
{
    /**
     * Endpoint único para eRequest/eResponse
     */
    public function execute(Request $request)
    {
        $action = $request->input('action');
        $params = $request->input('params', []);
        $userId = $request->user() ? $request->user()->id : null;
        $response = ["success" => false, "data" => null, "message" => ""];

        try {
            switch ($action) {
                case 'get_users_with_permission':
                    $response['data'] = DB::select('SELECT * FROM sp_get_users_with_permission(?)', [$params['oficina']]);
                    $response['success'] = true;
                    break;
                case 'get_autcargapag_by_fecha':
                    $response['data'] = DB::select('SELECT * FROM sp_get_autcargapag_by_fecha(?)', [$params['fecha_ingreso']]);
                    $response['success'] = true;
                    break;
                case 'insert_autcargapag':
                    $result = DB::select('SELECT * FROM sp_insert_autcargapag(?,?,?,?,?,?,?,?)', [
                        $params['fecha_ingreso'],
                        $params['oficina'],
                        $params['autorizar'],
                        $params['fecha_limite'],
                        $params['id_usupermiso'],
                        $params['comentarios'],
                        $userId,
                        $params['actualizacion']
                    ]);
                    $response['data'] = $result;
                    $response['success'] = true;
                    break;
                case 'update_autcargapag':
                    $result = DB::select('SELECT * FROM sp_update_autcargapag(?,?,?,?,?,?,?,?)', [
                        $params['fecha_ingreso'],
                        $params['oficina'],
                        $params['autorizar'],
                        $params['fecha_limite'],
                        $params['id_usupermiso'],
                        $params['comentarios'],
                        $userId,
                        $params['actualizacion']
                    ]);
                    $response['data'] = $result;
                    $response['success'] = true;
                    break;
                case 'list_autcargapag':
                    $response['data'] = DB::select('SELECT * FROM sp_list_autcargapag(?)', [$params['oficina']]);
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

<?php
namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;

class CveDiferMnttoController extends Controller
{
    /**
     * Endpoint unificado para eRequest/eResponse
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
                case 'list_cve_diferencias':
                    $result = DB::select('SELECT * FROM ta_11_catalogo_dif ORDER BY clave_diferencia ASC');
                    $response['success'] = true;
                    $response['data'] = $result;
                    break;
                case 'get_cve_diferencia':
                    $id = $params['clave_diferencia'] ?? null;
                    $result = DB::select('SELECT * FROM ta_11_catalogo_dif WHERE clave_diferencia = ?', [$id]);
                    $response['success'] = true;
                    $response['data'] = $result ? $result[0] : null;
                    break;
                case 'insert_cve_diferencia':
                    $validator = Validator::make($params, [
                        'clave_diferencia' => 'required|integer',
                        'descripcion' => 'required|string',
                        'cuenta_ingreso' => 'required|integer',
                        'id_usuario' => 'required|integer'
                    ]);
                    if ($validator->fails()) {
                        $response['message'] = $validator->errors()->first();
                        break;
                    }
                    $result = DB::select('SELECT * FROM sp_insert_cve_diferencia(?, ?, ?, ?)', [
                        $params['clave_diferencia'],
                        $params['descripcion'],
                        $params['cuenta_ingreso'],
                        $params['id_usuario']
                    ]);
                    $response['success'] = $result[0]->success;
                    $response['message'] = $result[0]->msg;
                    break;
                case 'update_cve_diferencia':
                    $validator = Validator::make($params, [
                        'clave_diferencia' => 'required|integer',
                        'descripcion' => 'required|string',
                        'cuenta_ingreso' => 'required|integer',
                        'id_usuario' => 'required|integer'
                    ]);
                    if ($validator->fails()) {
                        $response['message'] = $validator->errors()->first();
                        break;
                    }
                    $result = DB::select('SELECT * FROM sp_update_cve_diferencia(?, ?, ?, ?)', [
                        $params['clave_diferencia'],
                        $params['descripcion'],
                        $params['cuenta_ingreso'],
                        $params['id_usuario']
                    ]);
                    $response['success'] = $result[0]->success;
                    $response['message'] = $result[0]->msg;
                    break;
                case 'list_cuentas':
                    $result = DB::select('SELECT cta_aplicacion, descripcion FROM ta_12_cuentas ORDER BY cta_aplicacion ASC');
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

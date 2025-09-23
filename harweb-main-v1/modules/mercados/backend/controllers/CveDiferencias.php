<?php
namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;

class CveDiferenciasController extends Controller
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
                case 'getCveDiferencias':
                    $response['data'] = DB::select('CALL sp_get_cve_diferencias()');
                    $response['success'] = true;
                    break;
                case 'addCveDiferencia':
                    $validator = Validator::make($params, [
                        'descripcion' => 'required|string|max:60',
                        'cuenta_ingreso' => 'required|integer',
                        'id_usuario' => 'required|integer'
                    ]);
                    if ($validator->fails()) {
                        $response['message'] = $validator->errors()->first();
                        break;
                    }
                    $result = DB::select('CALL sp_add_cve_diferencia(?, ?, ?)', [
                        $params['descripcion'],
                        $params['cuenta_ingreso'],
                        $params['id_usuario']
                    ]);
                    $response['success'] = true;
                    $response['data'] = $result;
                    break;
                case 'updateCveDiferencia':
                    $validator = Validator::make($params, [
                        'clave_diferencia' => 'required|integer',
                        'descripcion' => 'required|string|max:60',
                        'cuenta_ingreso' => 'required|integer',
                        'id_usuario' => 'required|integer'
                    ]);
                    if ($validator->fails()) {
                        $response['message'] = $validator->errors()->first();
                        break;
                    }
                    $result = DB::select('CALL sp_update_cve_diferencia(?, ?, ?, ?)', [
                        $params['clave_diferencia'],
                        $params['descripcion'],
                        $params['cuenta_ingreso'],
                        $params['id_usuario']
                    ]);
                    $response['success'] = true;
                    $response['data'] = $result;
                    break;
                case 'getCuentasIngreso':
                    $response['data'] = DB::select('CALL sp_get_cuentas_ingreso()');
                    $response['success'] = true;
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

<?php
namespace App\Http\Controllers\Api;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use App\Http\Controllers\Controller;

class TiposEmpController extends Controller
{
    /**
     * Endpoint unificado para eRequest/eResponse
     */
    public function execute(Request $request)
    {
        $action = $request->input('action');
        $payload = $request->input('payload', []);
        $response = [
            'success' => false,
            'data' => null,
            'message' => ''
        ];
        try {
            switch ($action) {
                case 'list_tipos_emp':
                    $result = DB::select('SELECT * FROM sp_tipos_emp_list()');
                    $response['success'] = true;
                    $response['data'] = $result;
                    break;
                case 'create_tipos_emp':
                    $ctrol_emp = $payload['ctrol_emp'] ?? null;
                    $tipo_empresa = $payload['tipo_empresa'] ?? null;
                    $descripcion = $payload['descripcion'] ?? null;
                    $result = DB::select('SELECT * FROM sp_tipos_emp_create(?, ?, ?)', [
                        $ctrol_emp, $tipo_empresa, $descripcion
                    ]);
                    $response['success'] = true;
                    $response['data'] = $result;
                    break;
                case 'update_tipos_emp':
                    $ctrol_emp = $payload['ctrol_emp'] ?? null;
                    $tipo_empresa = $payload['tipo_empresa'] ?? null;
                    $descripcion = $payload['descripcion'] ?? null;
                    $result = DB::select('SELECT * FROM sp_tipos_emp_update(?, ?, ?)', [
                        $ctrol_emp, $tipo_empresa, $descripcion
                    ]);
                    $response['success'] = true;
                    $response['data'] = $result;
                    break;
                case 'delete_tipos_emp':
                    $ctrol_emp = $payload['ctrol_emp'] ?? null;
                    $result = DB::select('SELECT * FROM sp_tipos_emp_delete(?)', [
                        $ctrol_emp
                    ]);
                    $response['success'] = true;
                    $response['data'] = $result;
                    break;
                case 'get_tipos_emp':
                    $ctrol_emp = $payload['ctrol_emp'] ?? null;
                    $result = DB::select('SELECT * FROM sp_tipos_emp_get(?)', [
                        $ctrol_emp
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
        return response()->json($response);
    }
}

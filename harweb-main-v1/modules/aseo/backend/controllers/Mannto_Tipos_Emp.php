<?php

namespace App\Http\Controllers\Api;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use App\Http\Controllers\Controller;

class ExecuteController extends Controller
{
    /**
     * Endpoint único para manejar todas las operaciones eRequest/eResponse
     */
    public function execute(Request $request)
    {
        $eRequest = $request->input('eRequest');
        $params = $request->input('params', []);
        $eResponse = [
            'success' => false,
            'message' => '',
            'data' => null
        ];

        try {
            switch ($eRequest) {
                case 'TiposEmp.list':
                    $result = DB::select('SELECT * FROM ta_16_tipos_emp ORDER BY ctrol_emp');
                    $eResponse['success'] = true;
                    $eResponse['data'] = $result;
                    break;
                case 'TiposEmp.get':
                    $tipo = $params['tipo_empresa'] ?? null;
                    $result = DB::select('SELECT * FROM ta_16_tipos_emp WHERE tipo_empresa = ?', [$tipo]);
                    $eResponse['success'] = true;
                    $eResponse['data'] = $result;
                    break;
                case 'TiposEmp.create':
                    $tipo = $params['tipo_empresa'] ?? null;
                    $descripcion = $params['descripcion'] ?? null;
                    $result = DB::select('SELECT * FROM sp_tipos_emp_create(?, ?)', [$tipo, $descripcion]);
                    $eResponse['success'] = $result[0]->success;
                    $eResponse['message'] = $result[0]->message;
                    break;
                case 'TiposEmp.update':
                    $tipo = $params['tipo_empresa'] ?? null;
                    $descripcion = $params['descripcion'] ?? null;
                    $result = DB::select('SELECT * FROM sp_tipos_emp_update(?, ?)', [$tipo, $descripcion]);
                    $eResponse['success'] = $result[0]->success;
                    $eResponse['message'] = $result[0]->message;
                    break;
                case 'TiposEmp.delete':
                    $ctrol_emp = $params['ctrol_emp'] ?? null;
                    $result = DB::select('SELECT * FROM sp_tipos_emp_delete(?)', [$ctrol_emp]);
                    $eResponse['success'] = $result[0]->success;
                    $eResponse['message'] = $result[0]->message;
                    break;
                case 'TiposEmp.canDelete':
                    $ctrol_emp = $params['ctrol_emp'] ?? null;
                    $result = DB::select('SELECT * FROM sp_tipos_emp_can_delete(?)', [$ctrol_emp]);
                    $eResponse['success'] = true;
                    $eResponse['data'] = $result[0];
                    break;
                default:
                    $eResponse['message'] = 'eRequest no soportado';
            }
        } catch (\Exception $ex) {
            $eResponse['success'] = false;
            $eResponse['message'] = $ex->getMessage();
        }

        return response()->json(['eResponse' => $eResponse]);
    }
}

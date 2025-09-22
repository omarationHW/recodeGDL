<?php
namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;

class ConsTiposEmpController extends Controller
{
    /**
     * Endpoint único para eRequest/eResponse
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
                case 'list':
                    $order = $params['order'] ?? 'ctrol_emp';
                    $result = DB::select('SELECT * FROM ta_16_tipos_emp ORDER BY ' . $this->sanitizeOrder($order));
                    $response['success'] = true;
                    $response['data'] = $result;
                    break;
                case 'create':
                    $validator = Validator::make($params, [
                        'tipo_empresa' => 'required|string|max:1',
                        'descripcion' => 'required|string|max:80'
                    ]);
                    if ($validator->fails()) {
                        $response['message'] = $validator->errors()->first();
                        break;
                    }
                    $sp = DB::select('SELECT * FROM sp16_tipos_emp_create(?, ?)', [
                        $params['tipo_empresa'],
                        $params['descripcion']
                    ]);
                    $response['success'] = true;
                    $response['data'] = $sp[0] ?? null;
                    break;
                case 'update':
                    $validator = Validator::make($params, [
                        'ctrol_emp' => 'required|integer',
                        'tipo_empresa' => 'required|string|max:1',
                        'descripcion' => 'required|string|max:80'
                    ]);
                    if ($validator->fails()) {
                        $response['message'] = $validator->errors()->first();
                        break;
                    }
                    $sp = DB::select('SELECT * FROM sp16_tipos_emp_update(?, ?, ?)', [
                        $params['ctrol_emp'],
                        $params['tipo_empresa'],
                        $params['descripcion']
                    ]);
                    $response['success'] = true;
                    $response['data'] = $sp[0] ?? null;
                    break;
                case 'delete':
                    $validator = Validator::make($params, [
                        'ctrol_emp' => 'required|integer'
                    ]);
                    if ($validator->fails()) {
                        $response['message'] = $validator->errors()->first();
                        break;
                    }
                    $sp = DB::select('SELECT * FROM sp16_tipos_emp_delete(?)', [
                        $params['ctrol_emp']
                    ]);
                    $response['success'] = true;
                    $response['data'] = $sp[0] ?? null;
                    break;
                case 'export':
                    $order = $params['order'] ?? 'ctrol_emp';
                    $result = DB::select('SELECT * FROM ta_16_tipos_emp ORDER BY ' . $this->sanitizeOrder($order));
                    // Export logic here (CSV/Excel)
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

    /**
     * Sanitize order by field
     */
    private function sanitizeOrder($order)
    {
        $allowed = ['ctrol_emp', 'tipo_empresa', 'descripcion'];
        return in_array($order, $allowed) ? $order : 'ctrol_emp';
    }
}

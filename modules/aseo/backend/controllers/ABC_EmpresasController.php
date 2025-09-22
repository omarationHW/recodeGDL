<?php
namespace App\Http\Controllers\Api;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use App\Http\Controllers\Controller;

class EmpresasController extends Controller
{
    /**
     * Endpoint único para ejecutar acciones sobre empresas (ABC_Empresas)
     * Entrada: {
     *   "eRequest": {
     *     "action": "list|create|update|delete|export",
     *     "data": { ... }
     *   }
     * }
     * Salida: {
     *   "eResponse": { ... }
     * }
     */
    public function execute(Request $request)
    {
        $req = $request->input('eRequest');
        $action = $req['action'] ?? '';
        $data = $req['data'] ?? [];
        $response = [
            'success' => false,
            'message' => '',
            'data' => null
        ];
        try {
            switch ($action) {
                case 'list':
                    $result = DB::select('SELECT * FROM sp_empresas_list()');
                    $response['success'] = true;
                    $response['data'] = $result;
                    break;
                case 'create':
                    $r = DB::select('SELECT * FROM sp_empresas_create(?, ?, ?, ?)', [
                        $data['ctrol_emp'],
                        $data['tipo_empresa'],
                        $data['descripcion'],
                        $data['representante']
                    ]);
                    $response['success'] = $r[0]->success;
                    $response['message'] = $r[0]->message;
                    $response['data'] = $r[0];
                    break;
                case 'update':
                    $r = DB::select('SELECT * FROM sp_empresas_update(?, ?, ?, ?, ?)', [
                        $data['num_empresa'],
                        $data['ctrol_emp'],
                        $data['tipo_empresa'],
                        $data['descripcion'],
                        $data['representante']
                    ]);
                    $response['success'] = $r[0]->success;
                    $response['message'] = $r[0]->message;
                    $response['data'] = $r[0];
                    break;
                case 'delete':
                    $r = DB::select('SELECT * FROM sp_empresas_delete(?, ?)', [
                        $data['num_empresa'],
                        $data['ctrol_emp']
                    ]);
                    $response['success'] = $r[0]->success;
                    $response['message'] = $r[0]->message;
                    break;
                case 'export':
                    $result = DB::select('SELECT * FROM sp_empresas_list()');
                    // Aquí podrías generar un archivo Excel y devolver la URL, pero para demo solo datos
                    $response['success'] = true;
                    $response['data'] = $result;
                    break;
                default:
                    $response['message'] = 'Acción no soportada';
            }
        } catch (\Exception $e) {
            $response['success'] = false;
            $response['message'] = $e->getMessage();
        }
        return response()->json(['eResponse' => $response]);
    }
}

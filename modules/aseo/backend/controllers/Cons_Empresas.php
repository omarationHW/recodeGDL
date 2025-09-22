<?php

namespace App\Http\Controllers\Api;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use App\Http\Controllers\Controller;

class EmpresasController extends Controller
{
    /**
     * Endpoint unificado para ejecutar acciones sobre Empresas
     * Entrada: {
     *   "eRequest": {
     *     "action": "list|search|byNumber|byName|all|export",
     *     "params": { ... }
     *   }
     * }
     * Salida: {
     *   "eResponse": { ... }
     * }
     */
    public function execute(Request $request)
    {
        $eRequest = $request->input('eRequest');
        $action = $eRequest['action'] ?? '';
        $params = $eRequest['params'] ?? [];
        $eResponse = [
            'success' => false,
            'data' => null,
            'message' => ''
        ];

        try {
            switch ($action) {
                case 'list':
                case 'all':
                    $result = DB::select('CALL sp_empresas_list()');
                    $eResponse['success'] = true;
                    $eResponse['data'] = $result;
                    break;
                case 'byNumber':
                    $num_empresa = $params['num_empresa'] ?? null;
                    $ctrol_emp = $params['ctrol_emp'] ?? null;
                    $result = DB::select('CALL sp_empresas_by_number(?, ?)', [$num_empresa, $ctrol_emp]);
                    $eResponse['success'] = true;
                    $eResponse['data'] = $result;
                    break;
                case 'byName':
                    $nombre = $params['nombre'] ?? '';
                    $result = DB::select('CALL sp_empresas_by_name(?)', [$nombre]);
                    $eResponse['success'] = true;
                    $eResponse['data'] = $result;
                    break;
                case 'search':
                    $opcion = $params['opcion'] ?? 3;
                    $num_empresa = $params['num_empresa'] ?? null;
                    $ctrol_emp = $params['ctrol_emp'] ?? null;
                    $nombre = $params['nombre'] ?? null;
                    $result = DB::select('CALL sp_empresas_search(?, ?, ?, ?)', [$opcion, $num_empresa, $ctrol_emp, $nombre]);
                    $eResponse['success'] = true;
                    $eResponse['data'] = $result;
                    break;
                case 'export':
                    // Exportar a Excel (devolver datos, frontend hace export)
                    $result = DB::select('CALL sp_empresas_list()');
                    $eResponse['success'] = true;
                    $eResponse['data'] = $result;
                    $eResponse['export'] = true;
                    break;
                default:
                    $eResponse['message'] = 'Acción no soportada';
            }
        } catch (\Exception $ex) {
            $eResponse['message'] = $ex->getMessage();
        }

        return response()->json(['eResponse' => $eResponse]);
    }
}

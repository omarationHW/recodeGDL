<?php

namespace App\Http\Controllers\Api;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use App\Http\Controllers\Controller;

class ExecuteController extends Controller
{
    /**
     * Handle unified API requests (eRequest/eResponse pattern)
     * Endpoint: /api/execute
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
                case 'RNuevos.create':
                    // Call stored procedure for creating new local/concession
                    $result = DB::select('SELECT * FROM sp_ins34_rastro_01(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)', [
                        $params['par_tabla'],
                        $params['par_control'],
                        $params['par_conces'],
                        $params['par_ubica'],
                        $params['par_sup'],
                        $params['par_Axo_Ini'],
                        $params['par_Mes_Ini'],
                        $params['par_ofna'],
                        $params['par_sector'],
                        $params['par_zona'],
                        $params['par_lic'],
                        $params['par_Descrip']
                    ]);
                    $response['success'] = true;
                    $response['data'] = $result;
                    break;
                case 'RNuevos.check_control':
                    // Check if control exists
                    $row = DB::selectOne('SELECT COUNT(*) as cnt FROM t34_datos WHERE control = ?', [$params['control']]);
                    $response['success'] = true;
                    $response['data'] = $row;
                    break;
                case 'RNuevos.get_tipo_local':
                    // Get available types of local
                    $rows = DB::select('SELECT descripcion FROM t34_unidades WHERE cve_tab = 3');
                    $response['success'] = true;
                    $response['data'] = $rows;
                    break;
                default:
                    $response['message'] = 'Unknown action';
            }
        } catch (\Exception $e) {
            $response['success'] = false;
            $response['message'] = $e->getMessage();
        }

        return response()->json($response);
    }
}

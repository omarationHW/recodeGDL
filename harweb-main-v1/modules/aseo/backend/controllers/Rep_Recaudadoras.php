<?php
namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;

class RepRecaudadorasController extends Controller
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
                case 'getRecaudadorasReport':
                    $order = isset($params['order']) ? intval($params['order']) : 1;
                    $result = DB::select('CALL sp_rep_recaudadoras_report(?)', [$order]);
                    $response['success'] = true;
                    $response['data'] = $result;
                    break;
                case 'getRecaudadorasCatalog':
                    $result = DB::select('SELECT * FROM ta_12_recaudadoras ORDER BY id_rec');
                    $response['success'] = true;
                    $response['data'] = $result;
                    break;
                default:
                    $response['message'] = 'Acción no soportada';
            }
        } catch (\Exception $e) {
            Log::error('RepRecaudadorasController error: ' . $e->getMessage());
            $response['message'] = $e->getMessage();
        }
        return response()->json($response);
    }
}

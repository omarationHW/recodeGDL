<?php
namespace App\Http\Controllers\Api;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use App\Http\Controllers\Controller;

class UndRecolecController extends Controller
{
    /**
     * Endpoint unificado para eRequest/eResponse
     * POST /api/execute
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
                case 'und_recolec_list':
                    $order = $params['order'] ?? 1;
                    $ejercicio = $params['ejercicio'] ?? date('Y');
                    $result = DB::select('CALL sp_und_recolec_list(?, ?)', [$ejercicio, $order]);
                    $response['success'] = true;
                    $response['data'] = $result;
                    break;
                case 'und_recolec_report':
                    $order = $params['order'] ?? 1;
                    $ejercicio = $params['ejercicio'] ?? date('Y');
                    $result = DB::select('CALL sp_und_recolec_report(?, ?)', [$ejercicio, $order]);
                    $response['success'] = true;
                    $response['data'] = $result;
                    break;
                case 'und_recolec_create':
                    $ejercicio = $params['ejercicio'];
                    $cve = $params['cve'];
                    $descripcion = $params['descripcion'];
                    $costo_unidad = $params['costo_unidad'];
                    $costo_exed = $params['costo_exed'];
                    $result = DB::select('CALL sp_und_recolec_create(?, ?, ?, ?, ?)', [
                        $ejercicio, $cve, $descripcion, $costo_unidad, $costo_exed
                    ]);
                    $response['success'] = true;
                    $response['data'] = $result;
                    break;
                case 'und_recolec_update':
                    $ctrol = $params['ctrol'];
                    $descripcion = $params['descripcion'];
                    $costo_unidad = $params['costo_unidad'];
                    $costo_exed = $params['costo_exed'];
                    $result = DB::select('CALL sp_und_recolec_update(?, ?, ?, ?)', [
                        $ctrol, $descripcion, $costo_unidad, $costo_exed
                    ]);
                    $response['success'] = true;
                    $response['data'] = $result;
                    break;
                case 'und_recolec_delete':
                    $ctrol = $params['ctrol'];
                    $result = DB::select('CALL sp_und_recolec_delete(?)', [$ctrol]);
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

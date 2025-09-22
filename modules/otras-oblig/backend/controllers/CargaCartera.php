<?php

namespace App\Http\Controllers\Api;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use App\Http\Controllers\Controller;

class ExecuteController extends Controller
{
    /**
     * Endpoint unificado para ejecutar acciones vía eRequest/eResponse
     */
    public function execute(Request $request)
    {
        $action = $request->input('eRequest.action');
        $params = $request->input('eRequest.params', []);
        $response = [
            'eResponse' => [
                'success' => false,
                'message' => '',
                'data' => null
            ]
        ];

        try {
            switch ($action) {
                case 'getTablas':
                    $data = DB::select('SELECT id_34_tab, cve_tab, nombre FROM t34_tablas WHERE auto_tab > 0 ORDER BY auto_tab');
                    $response['eResponse']['success'] = true;
                    $response['eResponse']['data'] = $data;
                    break;
                case 'getEjercicios':
                    $cve_tab = $params['cve_tab'] ?? null;
                    $data = DB::select('SELECT ejercicio FROM t34_unidades WHERE cve_tab = ? GROUP BY ejercicio ORDER BY ejercicio', [$cve_tab]);
                    $response['eResponse']['success'] = true;
                    $response['eResponse']['data'] = $data;
                    break;
                case 'getUnidades':
                    $cve_tab = $params['cve_tab'] ?? null;
                    $ejer = $params['ejer'] ?? null;
                    $data = DB::select('SELECT ejercicio, cve_unidad, cve_operatividad, descripcion, costo FROM t34_unidades WHERE cve_tab = ? AND ejercicio = ?', [$cve_tab, $ejer]);
                    $response['eResponse']['success'] = true;
                    $response['eResponse']['data'] = $data;
                    break;
                case 'cargaCartera':
                    $cve_tab = $params['cve_tab'] ?? null;
                    $ejer = $params['ejer'] ?? null;
                    $result = DB::select('SELECT * FROM con34_cgacart_01(?, ?)', [$cve_tab, $ejer]);
                    $response['eResponse']['success'] = true;
                    $response['eResponse']['data'] = $result;
                    break;
                default:
                    $response['eResponse']['message'] = 'Acción no soportada';
            }
        } catch (\Exception $e) {
            $response['eResponse']['message'] = $e->getMessage();
        }

        return response()->json($response);
    }
}

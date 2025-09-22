<?php

namespace App\Http\Controllers\Api;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use App\Http\Controllers\Controller;

class MultipleRCMController extends Controller
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
                case 'getCementerios':
                    $response['data'] = DB::select('SELECT * FROM tc_13_cementerios ORDER BY nombre');
                    $response['success'] = true;
                    break;
                case 'searchRCM':
                    $cem = $params['cementerio'] ?? '';
                    $clase = $params['clase'] ?? 0;
                    $clase_alfa = $params['clase_alfa'] ?? '';
                    $seccion = $params['seccion'] ?? 0;
                    $seccion_alfa = $params['seccion_alfa'] ?? '';
                    $linea = $params['linea'] ?? 0;
                    $linea_alfa = $params['linea_alfa'] ?? '';
                    $fosa = $params['fosa'] ?? 0;
                    $fosa_alfa = $params['fosa_alfa'] ?? '';
                    $cuenta = $params['cuenta'] ?? 0;
                    $result = DB::select('CALL sp_multiple_rcm_search(?,?,?,?,?,?,?,?,?,?)', [
                        $cem, $clase, $clase_alfa, $seccion, $seccion_alfa, $linea, $linea_alfa, $fosa, $fosa_alfa, $cuenta
                    ]);
                    $response['data'] = $result;
                    $response['success'] = true;
                    break;
                case 'getRCMById':
                    $control_rcm = $params['control_rcm'] ?? 0;
                    $result = DB::select('SELECT * FROM ta_13_datosrcm WHERE control_rcm = ?', [$control_rcm]);
                    $response['data'] = $result;
                    $response['success'] = true;
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

<?php
namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;

class RptCaratulaDatosController extends Controller
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
                case 'getLocalesById':
                    $response['data'] = DB::select('CALL sp_get_locales_by_id(?)', [$params['id_local']]);
                    $response['success'] = true;
                    break;
                case 'getAdeudosByLocal':
                    $response['data'] = DB::select('CALL sp_get_adeudos_by_local(?)', [$params['id_local']]);
                    $response['success'] = true;
                    break;
                case 'getVencimientoRec':
                    $response['data'] = DB::select('CALL sp_get_vencimiento_rec(?)', [$params['mes']]);
                    $response['success'] = true;
                    break;
                case 'getRecargos':
                    $response['data'] = DB::select('CALL sp_get_recargos(?,?,?,?)', [
                        $params['axo_adeudo'], $params['periodo_adeudo'], $params['axo_actual'], $params['mes_actual']
                    ]);
                    $response['success'] = true;
                    break;
                case 'getRptCaratulaDatos':
                    $response['data'] = DB::select('CALL sp_rpt_caratula_datos(?, ?, ?, ?, ?, ?, ?, ?, ?)', [
                        $params['id_local'],
                        $params['renta'],
                        $params['adeudo'],
                        $params['recargos'],
                        $params['gastos'],
                        $params['multa'],
                        $params['total'],
                        $params['folios'],
                        $params['leyenda']
                    ]);
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

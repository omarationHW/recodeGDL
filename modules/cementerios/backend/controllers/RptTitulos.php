<?php

namespace App\Http\Controllers\Api;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use App\Http\Controllers\Controller;
use Carbon\Carbon;

class ExecuteController extends Controller
{
    /**
     * Handle unified API requests via /api/execute
     */
    public function execute(Request $request)
    {
        $eRequest = $request->input('eRequest');
        $params = $request->input('params', []);
        $eResponse = [
            'success' => false,
            'data' => null,
            'message' => ''
        ];

        try {
            switch ($eRequest) {
                case 'RptTitulos.getReport':
                    $fecha = $params['fecha'] ?? null;
                    $folio = $params['folio'] ?? null;
                    if (!$fecha || !$folio) {
                        throw new \Exception('Parámetros requeridos: fecha, folio');
                    }
                    $result = DB::select('SELECT * FROM rpt_titulos_get_report(?, ?)', [$fecha, $folio]);
                    $eResponse['success'] = true;
                    $eResponse['data'] = $result;
                    break;
                case 'RptTitulos.getRecaudadora':
                    $id_rec = $params['id_rec'] ?? null;
                    if (!$id_rec) {
                        throw new \Exception('Parámetro requerido: id_rec');
                    }
                    $result = DB::select('SELECT * FROM rpt_titulos_get_recaudadora(?)', [$id_rec]);
                    $eResponse['success'] = true;
                    $eResponse['data'] = $result;
                    break;
                case 'RptTitulos.fechaAletrasCorta':
                    $fecha = $params['fecha'] ?? null;
                    if (!$fecha) {
                        throw new \Exception('Parámetro requerido: fecha');
                    }
                    $result = DB::select('SELECT rpt_titulos_fecha_aletras_corta(?) AS fecha_aletras_corta', [$fecha]);
                    $eResponse['success'] = true;
                    $eResponse['data'] = $result[0]->fecha_aletras_corta;
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

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
        $eRequest = $request->input('eRequest');
        $params = $request->input('params', []);
        $eResponse = [
            'success' => false,
            'data' => null,
            'message' => ''
        ];

        try {
            switch ($eRequest) {
                case 'RptRecup_Merc.getReport':
                    $folio1 = $params['folio1'] ?? null;
                    $folio2 = $params['folio2'] ?? null;
                    $ofna = $params['ofna'] ?? null;
                    if (is_null($folio1) || is_null($folio2) || is_null($ofna)) {
                        throw new \Exception('Parámetros requeridos: folio1, folio2, ofna');
                    }
                    $result = DB::select('SELECT * FROM rptrecup_merc_report(:ofna, :folio1, :folio2)', [
                        'ofna' => $ofna,
                        'folio1' => $folio1,
                        'folio2' => $folio2
                    ]);
                    $eResponse['success'] = true;
                    $eResponse['data'] = $result;
                    break;
                case 'RptRecup_Merc.getRecaudadora':
                    $reca = $params['reca'] ?? null;
                    if (is_null($reca)) {
                        throw new \Exception('Parámetro requerido: reca');
                    }
                    $result = DB::select('SELECT * FROM rptrecup_merc_recaudadora(:reca)', [
                        'reca' => $reca
                    ]);
                    $eResponse['success'] = true;
                    $eResponse['data'] = $result;
                    break;
                case 'RptRecup_Merc.fechaAletras':
                    $fecha = $params['fecha'] ?? null;
                    if (is_null($fecha)) {
                        throw new \Exception('Parámetro requerido: fecha');
                    }
                    $result = DB::select('SELECT fecha_aletras(:fecha) as fecha_letras', [
                        'fecha' => $fecha
                    ]);
                    $eResponse['success'] = true;
                    $eResponse['data'] = $result[0]->fecha_letras ?? '';
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

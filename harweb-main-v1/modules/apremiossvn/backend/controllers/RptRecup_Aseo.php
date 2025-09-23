<?php

namespace App\Http\Controllers\Api;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use App\Http\Controllers\Controller;

class ExecuteController extends Controller
{
    /**
     * Endpoint unificado para ejecutar acciones (eRequest/eResponse)
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
                case 'RptRecup_Aseo.getReport':
                    $folio1 = $params['folio1'] ?? null;
                    $folio2 = $params['folio2'] ?? null;
                    $ofna = $params['ofna'] ?? null;
                    if (!$folio1 || !$folio2 || !$ofna) {
                        throw new \Exception('Parámetros requeridos: folio1, folio2, ofna');
                    }
                    $result = DB::select('SELECT * FROM rptrecup_aseo_report(:ofna, :folio1, :folio2)', [
                        'ofna' => $ofna,
                        'folio1' => $folio1,
                        'folio2' => $folio2
                    ]);
                    $rec = DB::select('SELECT * FROM rptrecup_aseo_recaudadora(:ofna)', [
                        'ofna' => $ofna
                    ]);
                    $eResponse['success'] = true;
                    $eResponse['data'] = [
                        'adeudos' => $result,
                        'recaudadora' => $rec
                    ];
                    break;
                case 'RptRecup_Aseo.getFechaLetras':
                    $fecha = $params['fecha'] ?? null;
                    if (!$fecha) {
                        throw new \Exception('Parámetro requerido: fecha');
                    }
                    $result = DB::select('SELECT fecha_a_letras(:fecha) as fecha_letras', [
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

<?php

namespace App\Http\Controllers\Api;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use App\Http\Controllers\Controller;

class RptReqMercController extends Controller
{
    /**
     * Endpoint único para eRequest/eResponse
     */
    public function execute(Request $request)
    {
        $eRequest = $request->input('eRequest');
        $eResponse = [
            'success' => false,
            'data' => null,
            'error' => null
        ];

        try {
            switch ($eRequest['action']) {
                case 'getRptReqMerc':
                    $data = $this->getRptReqMerc($eRequest['params']);
                    $eResponse['success'] = true;
                    $eResponse['data'] = $data;
                    break;
                case 'getRecaudadoraInfo':
                    $data = $this->getRecaudadoraInfo($eRequest['params']);
                    $eResponse['success'] = true;
                    $eResponse['data'] = $data;
                    break;
                case 'getFechaActual':
                    $data = $this->getFechaActual();
                    $eResponse['success'] = true;
                    $eResponse['data'] = $data;
                    break;
                default:
                    $eResponse['error'] = 'Acción no soportada';
            }
        } catch (\Exception $ex) {
            $eResponse['error'] = $ex->getMessage();
        }

        return response()->json(['eResponse' => $eResponse]);
    }

    /**
     * Obtiene los datos del reporte de requerimiento de mercado
     * params: [ofna, folio1, folio2]
     */
    private function getRptReqMerc($params)
    {
        $ofna = $params['ofna'];
        $folio1 = $params['folio1'];
        $folio2 = $params['folio2'];
        $result = DB::select('SELECT * FROM rptreq_merc_reporte(:ofna, :folio1, :folio2)', [
            'ofna' => $ofna,
            'folio1' => $folio1,
            'folio2' => $folio2
        ]);
        return $result;
    }

    /**
     * Obtiene la información de la recaudadora
     * params: [reca]
     */
    private function getRecaudadoraInfo($params)
    {
        $reca = $params['reca'];
        $result = DB::select('SELECT * FROM rptreq_merc_recaudadora(:reca)', [
            'reca' => $reca
        ]);
        return $result;
    }

    /**
     * Obtiene la fecha actual del sistema (simula QryFecha)
     */
    private function getFechaActual()
    {
        $result = DB::select('SELECT NOW() as fecha_actual');
        return $result[0];
    }
}

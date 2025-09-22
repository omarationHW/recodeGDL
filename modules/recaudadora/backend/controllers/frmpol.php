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
                case 'getPolizaReporte':
                    // params: fecha (YYYY-MM-DD), recaud (string)
                    $fecha = $params['fecha'] ?? null;
                    $recaud = $params['recaud'] ?? null;
                    if (!$fecha || !$recaud) {
                        throw new \Exception('Parámetros requeridos: fecha, recaud');
                    }
                    $result = DB::select('SELECT * FROM reporte_poliza_por_recaudadora(?, ?)', [$fecha, $recaud]);
                    $eResponse['success'] = true;
                    $eResponse['data'] = $result;
                    break;
                case 'getRecaudadoras':
                    // Devuelve catálogo de recaudadoras
                    $result = DB::select('SELECT * FROM catalogo_recaudadoras()');
                    $eResponse['success'] = true;
                    $eResponse['data'] = $result;
                    break;
                default:
                    $eResponse['message'] = 'eRequest no soportado';
            }
        } catch (\Exception $ex) {
            $eResponse['message'] = $ex->getMessage();
        }
        return response()->json(['eResponse' => $eResponse]);
    }
}

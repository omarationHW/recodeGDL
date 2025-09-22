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
        $action = $request->input('action');
        $params = $request->input('params', []);
        $response = [
            'success' => false,
            'data' => null,
            'message' => ''
        ];

        try {
            switch ($action) {
                case 'consescrit400_search':
                    $result = $this->searchEscrituras400($params);
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

    /**
     * Search in escrituras_400 table using stored procedure
     * @param array $params
     * @return array
     */
    private function searchEscrituras400($params)
    {
        // If mpio, notario, escritura are all 0 or null, search by folio and fecha
        $mpio = isset($params['mpio']) ? (int)$params['mpio'] : 0;
        $notario = isset($params['notario']) ? (int)$params['notario'] : 0;
        $escritura = isset($params['escritura']) ? (int)$params['escritura'] : 0;
        $folio = isset($params['folio']) ? (int)$params['folio'] : 0;
        $fecha = isset($params['fecha']) ? (int)$params['fecha'] : 0;

        if ($mpio === 0 && $notario === 0 && $escritura === 0) {
            // Call stored procedure for folio/fecha
            $result = DB::select('SELECT * FROM sp_consescrit400_search_by_folio_fecha(?, ?)', [$folio, $fecha]);
        } else {
            // Call stored procedure for mpio/notario/escritura
            $result = DB::select('SELECT * FROM sp_consescrit400_search_by_mpio_notario_escritura(?, ?, ?)', [$mpio, $notario, $escritura]);
        }
        return $result;
    }
}

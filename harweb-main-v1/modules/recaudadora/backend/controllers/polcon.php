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
        $eResponse = [
            'success' => false,
            'data' => null,
            'message' => ''
        ];

        try {
            switch ($eRequest['action']) {
                case 'polcon_report':
                    // Validate input
                    $date_from = $eRequest['params']['date_from'] ?? null;
                    $date_to = $eRequest['params']['date_to'] ?? null;
                    if (!$date_from || !$date_to) {
                        throw new \Exception('Parámetros de fecha requeridos.');
                    }
                    // Call stored procedure
                    $result = DB::select('SELECT * FROM report_polcon(:date_from, :date_to)', [
                        'date_from' => $date_from,
                        'date_to' => $date_to
                    ]);
                    $eResponse['success'] = true;
                    $eResponse['data'] = $result;
                    break;
                default:
                    $eResponse['message'] = 'Acción no soportada: ' . $eRequest['action'];
            }
        } catch (\Exception $ex) {
            $eResponse['success'] = false;
            $eResponse['message'] = $ex->getMessage();
        }

        return response()->json(['eResponse' => $eResponse]);
    }
}

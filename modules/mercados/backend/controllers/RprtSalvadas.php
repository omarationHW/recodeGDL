<?php

namespace App\Http\Controllers\Api;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use App\Http\Controllers\Controller;
use Illuminate\Support\Facades\Log;

class RprtSalvadasController extends Controller
{
    /**
     * Handle unified API requests (eRequest/eResponse pattern)
     * Endpoint: /api/execute
     */
    public function execute(Request $request)
    {
        $eRequest = $request->input('eRequest');
        $operation = $eRequest['operation'] ?? null;
        $params = $eRequest['params'] ?? [];
        $eResponse = [
            'success' => false,
            'data' => null,
            'message' => ''
        ];

        try {
            switch ($operation) {
                case 'getSalvadasReport':
                    // Call stored procedure for report
                    $result = DB::select('SELECT * FROM report_salvadas(:start_date, :end_date)', [
                        'start_date' => $params['start_date'] ?? null,
                        'end_date' => $params['end_date'] ?? null
                    ]);
                    $eResponse['success'] = true;
                    $eResponse['data'] = $result;
                    break;
                default:
                    $eResponse['message'] = 'Operación no soportada';
            }
        } catch (\Exception $e) {
            Log::error('RprtSalvadasController Error: ' . $e->getMessage());
            $eResponse['message'] = 'Error al procesar la solicitud: ' . $e->getMessage();
        }

        return response()->json(['eResponse' => $eResponse]);
    }
}

<?php

namespace App\Http\Controllers\Api;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use App\Http\Controllers\Controller;
use Illuminate\Support\Facades\Log;

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
                case 'RprtSalvadas.generateReport':
                    // Call stored procedure to generate report data
                    $result = DB::select('SELECT * FROM rprt_salvadas_report(:user_id, :date_from, :date_to)', [
                        'user_id' => $params['user_id'] ?? null,
                        'date_from' => $params['date_from'] ?? null,
                        'date_to' => $params['date_to'] ?? null
                    ]);
                    $eResponse['success'] = true;
                    $eResponse['data'] = $result;
                    $eResponse['message'] = 'Reporte generado correctamente.';
                    break;
                default:
                    $eResponse['message'] = 'eRequest no reconocido.';
            }
        } catch (\Exception $ex) {
            Log::error('API Execute Error: ' . $ex->getMessage());
            $eResponse['message'] = 'Error al procesar la solicitud: ' . $ex->getMessage();
        }

        return response()->json($eResponse);
    }
}

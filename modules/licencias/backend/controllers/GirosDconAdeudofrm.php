<?php

namespace App\Http\Controllers\Api;

use Illuminate\Http\Request;
use App\Http\Controllers\Controller;
use Illuminate\Support\Facades\DB;
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
        $payload = $request->input('payload', []);
        $eResponse = [
            'success' => false,
            'data' => null,
            'message' => '',
            'errors' => []
        ];

        try {
            switch ($eRequest) {
                case 'GirosDconAdeudoReport':
                    $year = isset($payload['year']) ? intval($payload['year']) : null;
                    if (!$year) {
                        $eResponse['message'] = 'El año del adeudo es requerido.';
                        break;
                    }
                    $results = DB::select('SELECT * FROM report_giros_dcon_adeudo(:p_year)', [
                        'p_year' => $year
                    ]);
                    $eResponse['success'] = true;
                    $eResponse['data'] = $results;
                    $eResponse['message'] = count($results) > 0 ? 'Datos encontrados.' : 'No se encontraron licencias...';
                    break;
                default:
                    $eResponse['message'] = 'eRequest no soportado.';
                    break;
            }
        } catch (\Exception $ex) {
            Log::error('API Execute Error: ' . $ex->getMessage());
            $eResponse['message'] = 'Error interno del servidor.';
            $eResponse['errors'][] = $ex->getMessage();
        }

        return response()->json($eResponse);
    }
}

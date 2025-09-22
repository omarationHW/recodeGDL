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
            'error' => null
        ];

        try {
            switch ($eRequest) {
                case 'dictamenfrm.getAnuncio':
                    $anuncio = $params['anuncio'] ?? null;
                    if (!$anuncio) {
                        throw new \Exception('El parámetro anuncio es requerido');
                    }
                    $result = DB::select('SELECT * FROM dictamenfrm_get_anuncio(?)', [$anuncio]);
                    $eResponse['success'] = true;
                    $eResponse['data'] = $result;
                    break;
                case 'dictamenfrm.printReport':
                    // Simulación: En un sistema real, aquí se generaría el PDF y se devolvería la URL o base64
                    $anuncio = $params['anuncio'] ?? null;
                    $tipo = $params['tipo'] ?? 0;
                    if (!$anuncio) {
                        throw new \Exception('El parámetro anuncio es requerido');
                    }
                    // Aquí se llamaría a un servicio de generación de PDF
                    $eResponse['success'] = true;
                    $eResponse['data'] = [
                        'pdf_url' => url('/storage/reports/dictamenfrm_' . $anuncio . '_' . $tipo . '.pdf'),
                        'message' => 'Reporte generado correctamente (simulado)'
                    ];
                    break;
                default:
                    throw new \Exception('eRequest no soportado: ' . $eRequest);
            }
        } catch (\Exception $ex) {
            $eResponse['error'] = $ex->getMessage();
        }

        return response()->json(['eResponse' => $eResponse]);
    }
}

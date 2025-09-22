<?php

namespace App\Http\Controllers\Api;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use App\Http\Controllers\Controller;

class ExecuteController extends Controller
{
    /**
     * Handle unified API requests (eRequest/eResponse pattern).
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
                case 'ConsGral.buscarPorPlaca':
                    $placa = isset($params['placa']) ? trim($params['placa']) : '';
                    if ($placa === '') {
                        $eResponse['message'] = 'El campo placa es requerido.';
                        break;
                    }
                    // Llamar ambos SP y unir resultados
                    $aFolios = DB::select('SELECT * FROM sp14_afolios(:parPlaca)', [ 'parPlaca' => $placa ]);
                    $bFolios = DB::select('SELECT * FROM sp14_bfolios(:parPlaca)', [ 'parPlaca' => $placa ]);
                    $eResponse['success'] = true;
                    $eResponse['data'] = [
                        'aFolios' => $aFolios,
                        'bFolios' => $bFolios
                    ];
                    break;
                default:
                    $eResponse['message'] = 'eRequest no soportado: ' . $eRequest;
            }
        } catch (\Exception $ex) {
            $eResponse['message'] = $ex->getMessage();
        }

        return response()->json($eResponse);
    }
}

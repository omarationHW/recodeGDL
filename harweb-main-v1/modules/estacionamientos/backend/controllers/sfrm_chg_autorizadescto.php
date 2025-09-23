<?php

namespace App\Http\Controllers\Api;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use App\Http\Controllers\Controller;

class ExecuteController extends Controller
{
    /**
     * Handle unified API requests via /api/execute
     *
     * @param  \Illuminate\Http\Request  $request
     * @return \Illuminate\Http\JsonResponse
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
                case 'buscar_folios_histo':
                    // params: placa
                    $result = DB::select('SELECT * FROM sp_buscar_folios_histo(?)', [
                        $params['placa'] ?? null
                    ]);
                    $eResponse['success'] = true;
                    $eResponse['data'] = $result;
                    break;
                case 'buscar_folios_free':
                    // params: axo, folio
                    $result = DB::select('SELECT * FROM sp_buscar_folios_free(?, ?)', [
                        $params['axo'] ?? null,
                        $params['folio'] ?? null
                    ]);
                    $eResponse['success'] = true;
                    $eResponse['data'] = $result;
                    break;
                case 'cambiar_a_tesorero':
                    // params: axo, folio
                    $result = DB::select('SELECT * FROM sp_cambiar_a_tesorero(?, ?)', [
                        $params['axo'] ?? null,
                        $params['folio'] ?? null
                    ]);
                    $eResponse['success'] = true;
                    $eResponse['data'] = $result;
                    break;
                default:
                    $eResponse['message'] = 'eRequest no reconocido';
            }
        } catch (\Exception $e) {
            $eResponse['message'] = $e->getMessage();
        }

        return response()->json(['eResponse' => $eResponse]);
    }
}

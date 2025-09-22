<?php

namespace App\Http\Controllers\Api;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use App\Http\Controllers\Controller;

class ExecuteController extends Controller
{
    /**
     * Handle unified API requests via /api/execute
     */
    public function handle(Request $request)
    {
        $eRequest = $request->input('eRequest');
        $params = $request->input('params', []);
        $eResponse = [
            'success' => false,
            'message' => '',
            'data' => null
        ];

        try {
            switch ($eRequest) {
                case 'reactiva_folios_buscar':
                    $result = DB::select('SELECT * FROM sp_reactiva_folios_buscar(?, ?, ?, ?)', [
                        $params['opcion'] ?? 0,
                        $params['placa'] ?? null,
                        $params['axo'] ?? null,
                        $params['folio'] ?? null
                    ]);
                    $eResponse['success'] = true;
                    $eResponse['data'] = $result;
                    break;
                case 'reactiva_folios_aplicar':
                    $result = DB::select('SELECT * FROM sp_reactiva_folios_aplicar(?, ?, ?, ?)', [
                        $params['opcion'] ?? 0,
                        $params['placa'] ?? null,
                        $params['axo'] ?? null,
                        $params['folio'] ?? null
                    ]);
                    $eResponse['success'] = $result[0]->success;
                    $eResponse['message'] = $result[0]->message;
                    break;
                default:
                    $eResponse['message'] = 'eRequest no soportado';
            }
        } catch (\Exception $ex) {
            $eResponse['success'] = false;
            $eResponse['message'] = $ex->getMessage();
        }

        return response()->json(['eResponse' => $eResponse]);
    }
}

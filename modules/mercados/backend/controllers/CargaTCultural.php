<?php
namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;

class CargaTCulturalController extends Controller
{
    /**
     * Endpoint único para ejecutar acciones (eRequest/eResponse)
     */
    public function execute(Request $request)
    {
        $eRequest = $request->input('eRequest');
        $payload = $request->input('payload', []);
        $userId = $request->user() ? $request->user()->id : null;
        $response = [
            'success' => false,
            'data' => null,
            'message' => ''
        ];

        try {
            switch ($eRequest) {
                case 'getAdeudosTCultural':
                    $response['data'] = DB::select('SELECT * FROM sp_get_adeudos_tcultural(?, ?, ?, ?, ?)', [
                        $payload['local_desde'],
                        $payload['local_hasta'],
                        $payload['periodo'],
                        $payload['axo'],
                        $userId
                    ]);
                    $response['success'] = true;
                    break;
                case 'validatePagosTCultural':
                    $response['data'] = DB::select('SELECT * FROM sp_validate_pagos_tcultural(?)', [
                        json_encode($payload['pagos'])
                    ]);
                    $response['success'] = true;
                    break;
                case 'savePagosTCultural':
                    $result = DB::select('SELECT * FROM sp_save_pagos_tcultural(?, ?)', [
                        json_encode($payload['pagos']),
                        $userId
                    ]);
                    $response['data'] = $result;
                    $response['success'] = true;
                    break;
                case 'getTianguisInfo':
                    $response['data'] = DB::select('SELECT * FROM sp_get_tianguis_info(?)', [
                        $payload['folio']
                    ]);
                    $response['success'] = true;
                    break;
                default:
                    $response['message'] = 'eRequest no soportado';
            }
        } catch (\Exception $e) {
            $response['message'] = $e->getMessage();
        }

        return response()->json(['eResponse' => $response]);
    }
}

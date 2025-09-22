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
            'error' => null
        ];

        try {
            switch ($eRequest) {
                case 'getAnuncio400':
                    $anuncio = $params['anuncio'] ?? null;
                    if (!$anuncio) {
                        throw new \Exception('El parámetro anuncio es requerido.');
                    }
                    $result = DB::select('SELECT * FROM sp_get_anuncio_400(?)', [$anuncio]);
                    $eResponse['success'] = true;
                    $eResponse['data'] = $result;
                    break;
                case 'getPagosAnuncio400':
                    $numanu = $params['numanu'] ?? null;
                    if (!$numanu) {
                        throw new \Exception('El parámetro numanu es requerido.');
                    }
                    $result = DB::select('SELECT * FROM sp_get_pagos_anun_400(?)', [$numanu]);
                    $eResponse['success'] = true;
                    $eResponse['data'] = $result;
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

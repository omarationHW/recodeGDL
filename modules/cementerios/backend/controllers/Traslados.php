<?php

namespace App\Http\Controllers\Api;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;
use App\Http\Controllers\Controller;

class TrasladosController extends Controller
{
    /**
     * Endpoint único para eRequest/eResponse
     */
    public function execute(Request $request)
    {
        $action = $request->input('action');
        $payload = $request->input('payload', []);
        $response = [
            'success' => false,
            'data' => null,
            'message' => ''
        ];

        try {
            switch ($action) {
                case 'buscarPagosOrigen':
                    $response['data'] = $this->buscarPagosOrigen($payload);
                    $response['success'] = true;
                    break;
                case 'buscarPagosDestino':
                    $response['data'] = $this->buscarPagosDestino($payload);
                    $response['success'] = true;
                    break;
                case 'trasladarPagos':
                    $response['data'] = $this->trasladarPagos($payload);
                    $response['success'] = true;
                    break;
                case 'listarCementerios':
                    $response['data'] = $this->listarCementerios();
                    $response['success'] = true;
                    break;
                default:
                    $response['message'] = 'Acción no soportada';
            }
        } catch (\Exception $e) {
            $response['message'] = $e->getMessage();
        }

        return response()->json($response);
    }

    /**
     * Buscar pagos en la ubicación origen
     */
    private function buscarPagosOrigen($payload)
    {
        $params = [
            $payload['cementerio'],
            $payload['clase'],
            $payload['clase_alfa'] ?? '',
            $payload['seccion'],
            $payload['seccion_alfa'] ?? '',
            $payload['linea'],
            $payload['linea_alfa'] ?? '',
            $payload['fosa'],
            $payload['fosa_alfa'] ?? ''
        ];
        $result = DB::select('SELECT * FROM sp_traslados_buscar_pagos_origen(?,?,?,?,?,?,?,?,?)', $params);
        return $result;
    }

    /**
     * Buscar pagos en la ubicación destino
     */
    private function buscarPagosDestino($payload)
    {
        $params = [
            $payload['cementerio'],
            $payload['clase'],
            $payload['clase_alfa'] ?? '',
            $payload['seccion'],
            $payload['seccion_alfa'] ?? '',
            $payload['linea'],
            $payload['linea_alfa'] ?? '',
            $payload['fosa'],
            $payload['fosa_alfa'] ?? ''
        ];
        $result = DB::select('SELECT * FROM sp_traslados_buscar_pagos_destino(?,?,?,?,?,?,?,?,?)', $params);
        return $result;
    }

    /**
     * Realiza el traslado de pagos
     */
    private function trasladarPagos($payload)
    {
        $userId = auth()->id() ?? 1; // O pasar desde frontend
        $params = [
            $payload['origen_control_id'],
            $payload['destino_cementerio'],
            $payload['destino_clase'],
            $payload['destino_clase_alfa'] ?? '',
            $payload['destino_seccion'],
            $payload['destino_seccion_alfa'] ?? '',
            $payload['destino_linea'],
            $payload['destino_linea_alfa'] ?? '',
            $payload['destino_fosa'],
            $payload['destino_fosa_alfa'] ?? '',
            $payload['destino_control_rcm'],
            $userId
        ];
        $result = DB::select('SELECT * FROM sp_traslados_trasladar_pagos(?,?,?,?,?,?,?,?,?,?,?,?)', $params);
        return $result;
    }

    /**
     * Listar cementerios
     */
    private function listarCementerios()
    {
        return DB::select('SELECT * FROM tc_13_cementerios ORDER BY nombre');
    }
}

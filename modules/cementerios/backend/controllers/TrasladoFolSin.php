<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;

class TrasladoFolSinController extends Controller
{
    /**
     * Endpoint unificado para eRequest/eResponse
     */
    public function execute(Request $request)
    {
        $action = $request->input('action');
        $data = $request->input('data', []);
        $response = [
            'success' => false,
            'message' => '',
            'data' => null
        ];

        try {
            switch ($action) {
                case 'verificaFolios':
                    $response = $this->verificaFolios($data);
                    break;
                case 'trasladarPagos':
                    $response = $this->trasladarPagos($data);
                    break;
                case 'getPagosByFolio':
                    $response = $this->getPagosByFolio($data);
                    break;
                case 'getDatosByFolio':
                    $response = $this->getDatosByFolio($data);
                    break;
                default:
                    $response['message'] = 'Acción no soportada';
            }
        } catch (\Exception $e) {
            $response['success'] = false;
            $response['message'] = $e->getMessage();
        }
        return response()->json($response);
    }

    /**
     * Verifica existencia y validez de los folios de traslado
     */
    private function verificaFolios($data)
    {
        $folioDe = $data['folio_de'] ?? null;
        $folioA = $data['folio_a'] ?? null;
        if (!$folioDe || !$folioA) {
            return [
                'success' => false,
                'message' => 'Folio DE y Folio A son requeridos.'
            ];
        }
        if ($folioDe == $folioA) {
            return [
                'success' => false,
                'message' => 'Los folios no deben ser iguales.'
            ];
        }
        $datosDe = DB::select('SELECT * FROM ta_13_datosrcm WHERE control_rcm = ?', [$folioDe]);
        $datosA = DB::select('SELECT * FROM ta_13_datosrcm WHERE control_rcm = ?', [$folioA]);
        if (count($datosDe) == 0) {
            return [
                'success' => false,
                'message' => 'No se encuentra Folio DE TRASLADO.'
            ];
        }
        if (count($datosA) == 0) {
            return [
                'success' => false,
                'message' => 'No se encuentra Folio A TRASLADAR.'
            ];
        }
        $pagosDe = DB::select('SELECT * FROM ta_13_pagosrcm WHERE control_rcm = ?', [$folioDe]);
        $pagosA = DB::select('SELECT * FROM ta_13_pagosrcm WHERE control_rcm = ?', [$folioA]);
        if (count($pagosDe) == 0) {
            return [
                'success' => false,
                'message' => 'No se encuentran pagos con ese registro.'
            ];
        }
        return [
            'success' => true,
            'message' => 'Folios válidos.',
            'data' => [
                'datos_de' => $datosDe[0],
                'datos_a' => $datosA[0],
                'pagos_de' => $pagosDe,
                'pagos_a' => $pagosA
            ]
        ];
    }

    /**
     * Ejecuta el traslado de pagos seleccionados de un folio a otro
     */
    private function trasladarPagos($data)
    {
        $folioDe = $data['folio_de'] ?? null;
        $folioA = $data['folio_a'] ?? null;
        $pagosIds = $data['pagos_ids'] ?? [];
        $usuarioId = $data['usuario_id'] ?? null;
        if (!$folioDe || !$folioA || empty($pagosIds) || !$usuarioId) {
            return [
                'success' => false,
                'message' => 'Datos incompletos para traslado.'
            ];
        }
        $result = DB::select('SELECT * FROM sp_traslado_folios_sin_adeudo(?, ?, ?, ?)', [
            $folioDe,
            $folioA,
            json_encode($pagosIds),
            $usuarioId
        ]);
        $row = $result[0] ?? null;
        if ($row && $row->success) {
            return [
                'success' => true,
                'message' => $row->message
            ];
        } else {
            return [
                'success' => false,
                'message' => $row ? $row->message : 'Error desconocido en traslado.'
            ];
        }
    }

    /**
     * Obtiene pagos por folio
     */
    private function getPagosByFolio($data)
    {
        $folio = $data['folio'] ?? null;
        if (!$folio) {
            return [
                'success' => false,
                'message' => 'Folio requerido.'
            ];
        }
        $pagos = DB::select('SELECT * FROM ta_13_pagosrcm WHERE control_rcm = ? ORDER BY fecing', [$folio]);
        return [
            'success' => true,
            'data' => $pagos
        ];
    }

    /**
     * Obtiene datos de folio
     */
    private function getDatosByFolio($data)
    {
        $folio = $data['folio'] ?? null;
        if (!$folio) {
            return [
                'success' => false,
                'message' => 'Folio requerido.'
            ];
        }
        $datos = DB::select('SELECT * FROM ta_13_datosrcm WHERE control_rcm = ?', [$folio]);
        return [
            'success' => true,
            'data' => $datos
        ];
    }
}

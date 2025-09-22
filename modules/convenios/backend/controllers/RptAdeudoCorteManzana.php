<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;

class AdeudoCorteManzanaController extends Controller
{
    /**
     * Endpoint unificado para eRequest/eResponse
     * POST /api/execute
     */
    public function execute(Request $request)
    {
        $eRequest = $request->input('eRequest');
        $operation = $eRequest['operation'] ?? null;
        $params = $eRequest['params'] ?? [];
        $eResponse = [
            'success' => false,
            'data' => null,
            'message' => ''
        ];

        try {
            switch ($operation) {
                case 'getAdeudoCorteManzana':
                    $data = $this->getAdeudoCorteManzana($params);
                    $eResponse['success'] = true;
                    $eResponse['data'] = $data;
                    break;
                case 'exportAdeudoCorteManzana':
                    $data = $this->exportAdeudoCorteManzana($params);
                    $eResponse['success'] = true;
                    $eResponse['data'] = $data;
                    break;
                default:
                    $eResponse['message'] = 'Operación no soportada';
            }
        } catch (\Exception $ex) {
            Log::error($ex);
            $eResponse['message'] = $ex->getMessage();
        }

        return response()->json(['eResponse' => $eResponse]);
    }

    /**
     * Consulta de reporte de Adeudo Corte Manzana
     * @param array $params
     * @return array
     */
    private function getAdeudoCorteManzana($params)
    {
        $subtipo = $params['subtipo'] ?? null;
        $fechadsd = $params['fechadsd'] ?? null;
        $fechahst = $params['fechahst'] ?? null;
        $rep = $params['rep'] ?? 1;
        $est = $params['est'] ?? 'A';

        $result = DB::select('CALL sp_adeudo_corte_manzana(?, ?, ?, ?, ?)', [
            $subtipo, $fechadsd, $fechahst, $rep, $est
        ]);
        return $result;
    }

    /**
     * Exportar reporte a Excel/PDF
     * @param array $params
     * @return string (URL o base64)
     */
    private function exportAdeudoCorteManzana($params)
    {
        // Lógica de exportación (puede usar Laravel Excel o similar)
        // Aquí solo se simula la respuesta
        return [
            'url' => '/exports/adeudo_corte_manzana_' . date('Ymd_His') . '.xlsx'
        ];
    }
}

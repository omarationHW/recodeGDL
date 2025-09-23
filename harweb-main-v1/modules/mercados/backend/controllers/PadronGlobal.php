<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;

class PadronGlobalController extends Controller
{
    /**
     * Endpoint único para eRequest/eResponse
     */
    public function execute(Request $request)
    {
        $action = $request->input('action');
        $params = $request->input('params', []);
        $response = [
            'success' => false,
            'data' => null,
            'message' => ''
        ];

        try {
            switch ($action) {
                case 'getPadronGlobal':
                    $response['data'] = $this->getPadronGlobal($params);
                    $response['success'] = true;
                    break;
                case 'exportPadronGlobalExcel':
                    $response['data'] = $this->exportPadronGlobalExcel($params);
                    $response['success'] = true;
                    break;
                case 'getVencimientoRec':
                    $response['data'] = $this->getVencimientoRec($params);
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
     * Consulta el padrón global de locales
     */
    private function getPadronGlobal($params)
    {
        $axo = $params['axo'] ?? date('Y');
        $mes = $params['mes'] ?? date('n');
        $vig = $params['vig'] ?? 'A';

        $result = DB::select('CALL sp_padron_global(?, ?, ?)', [$axo, $mes, $vig]);
        return $result;
    }

    /**
     * Exporta el padrón global a Excel (devuelve URL temporal o base64)
     */
    private function exportPadronGlobalExcel($params)
    {
        // Lógica de exportación a Excel (puede usar Laravel Excel o similar)
        // Aquí solo se simula la respuesta
        return [
            'url' => url('/storage/exports/padron_global_' . date('Ymd_His') . '.xlsx')
        ];
    }

    /**
     * Consulta los vencimientos de recargos y descuentos
     */
    private function getVencimientoRec($params)
    {
        $mes = $params['mes'] ?? date('n');
        $result = DB::select('CALL sp_vencimiento_rec(?)', [$mes]);
        return $result;
    }
}

<?php

namespace App\Http\Controllers\PagosConFPgo;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;
use App\Http\Controllers\Controller;

class PagosConFPgoController extends Controller
{
    /**
     * Endpoint único para eRequest/eResponse
     */
    public function execute(Request $request)
    {
        $action = $request->input('eRequest.action');
        $params = $request->input('eRequest.params', []);
        $response = [
            'success' => false,
            'data' => null,
            'message' => ''
        ];
        try {
            switch ($action) {
                case 'getPagosByFecha':
                    $fecha = $params['fecha'] ?? null;
                    if (!$fecha) {
                        throw new \Exception('Fecha requerida');
                    }
                    $result = DB::select('CALL sp_pagos_con_fpgo_get_pagos_by_fecha(?)', [$fecha]);
                    $response['success'] = true;
                    $response['data'] = $result;
                    break;
                case 'getContratoDetalle':
                    $controlContrato = $params['control_contrato'] ?? null;
                    if (!$controlContrato) {
                        throw new \Exception('control_contrato requerido');
                    }
                    $result = DB::select('CALL sp_pagos_con_fpgo_get_contrato_detalle(?)', [$controlContrato]);
                    $response['success'] = true;
                    $response['data'] = $result;
                    break;
                case 'getTipoAseoCatalog':
                    $result = DB::select('CALL sp_pagos_con_fpgo_get_tipo_aseo_catalog()');
                    $response['success'] = true;
                    $response['data'] = $result;
                    break;
                default:
                    $response['message'] = 'Acción no soportada';
            }
        } catch (\Exception $e) {
            Log::error('PagosConFPgoController error: ' . $e->getMessage());
            $response['message'] = $e->getMessage();
        }
        return response()->json(['eResponse' => $response]);
    }
}

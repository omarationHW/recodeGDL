<?php

namespace App\Http\Controllers\Api;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use App\Http\Controllers\Controller;

class ExecuteController extends Controller
{
    /**
     * Endpoint único para ejecutar operaciones (eRequest/eResponse)
     *
     * @param Request $request
     * @return \Illuminate\Http\JsonResponse
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
                case 'get_reportes_exec':
                    $result = DB::select('CALL sp_get_reportes_exec(?, ?)', [
                        $params['order_by'] ?? 'clasificacion',
                        $params['group_by'] ?? 'no_exclusivo'
                    ]);
                    $eResponse['success'] = true;
                    $eResponse['data'] = $result;
                    break;
                case 'get_adeudos_exec':
                    $result = DB::select('CALL sp_get_adeudos_exec()');
                    $eResponse['success'] = true;
                    $eResponse['data'] = $result;
                    break;
                case 'get_deudores_exec':
                    $result = DB::select('CALL sp_get_deudores_exec()');
                    $eResponse['success'] = true;
                    $eResponse['data'] = $result;
                    break;
                case 'get_estado_cuenta':
                    $no_exclusivo = $params['no_exclusivo'] ?? null;
                    if (!$no_exclusivo) {
                        throw new \Exception('no_exclusivo es requerido');
                    }
                    $result = DB::select('CALL sp_get_estado_cuenta(?)', [$no_exclusivo]);
                    $eResponse['success'] = true;
                    $eResponse['data'] = $result;
                    break;
                case 'get_adeudos_detalle':
                    $contrato_id = $params['contrato_id'] ?? null;
                    $axo = $params['axo'] ?? 1;
                    $mes = $params['mes'] ?? 1;
                    if (!$contrato_id) {
                        throw new \Exception('contrato_id es requerido');
                    }
                    $result = DB::select('CALL sp_adeudos_detalle(?, ?, ?)', [$contrato_id, $axo, $mes]);
                    $eResponse['success'] = true;
                    $eResponse['data'] = $result;
                    break;
                default:
                    $eResponse['message'] = 'Operación no soportada';
            }
        } catch (\Exception $ex) {
            $eResponse['success'] = false;
            $eResponse['message'] = $ex->getMessage();
        }

        return response()->json(['eResponse' => $eResponse]);
    }
}

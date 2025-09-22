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
                case 'get_apremios':
                    $result = DB::select('CALL sp_get_apremios(?, ?)', [
                        $params['par_modulo'] ?? null,
                        $params['par_control'] ?? null
                    ]);
                    $eResponse['success'] = true;
                    $eResponse['data'] = $result;
                    break;
                case 'get_periodos_by_control':
                    $result = DB::select('CALL sp_get_periodos_by_control(?)', [
                        $params['id_control'] ?? null
                    ]);
                    $eResponse['success'] = true;
                    $eResponse['data'] = $result;
                    break;
                case 'create_apremio':
                    $result = DB::select('CALL sp_create_apremio(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)', [
                        $params['zona'] ?? null,
                        $params['folio'] ?? null,
                        $params['diligencia'] ?? null,
                        $params['importe_global'] ?? null,
                        $params['importe_multa'] ?? null,
                        $params['importe_recargo'] ?? null,
                        $params['importe_gastos'] ?? null,
                        $params['zona_apremio'] ?? null,
                        $params['fecha_emision'] ?? null,
                        $params['clave_practicado'] ?? null,
                        $params['fecha_practicado'] ?? null,
                        $params['hora_practicado'] ?? null,
                        $params['fecha_entrega1'] ?? null,
                        $params['fecha_entrega2'] ?? null,
                        $params['fecha_citatorio'] ?? null,
                        $params['hora'] ?? null,
                        $params['ejecutor'] ?? null,
                        $params['clave_secuestro'] ?? null,
                        $params['clave_remate'] ?? null,
                        $params['fecha_remate'] ?? null,
                        $params['porcentaje_multa'] ?? null,
                        $params['observaciones'] ?? null,
                        $params['modulo'] ?? null,
                        $params['control_otr'] ?? null
                    ]);
                    $eResponse['success'] = true;
                    $eResponse['data'] = $result;
                    break;
                case 'update_apremio':
                    $result = DB::select('CALL sp_update_apremio(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)', [
                        $params['id_control'] ?? null,
                        $params['zona'] ?? null,
                        $params['folio'] ?? null,
                        $params['diligencia'] ?? null,
                        $params['importe_global'] ?? null,
                        $params['importe_multa'] ?? null,
                        $params['importe_recargo'] ?? null,
                        $params['importe_gastos'] ?? null,
                        $params['zona_apremio'] ?? null,
                        $params['fecha_emision'] ?? null,
                        $params['clave_practicado'] ?? null,
                        $params['fecha_practicado'] ?? null,
                        $params['hora_practicado'] ?? null,
                        $params['fecha_entrega1'] ?? null,
                        $params['fecha_entrega2'] ?? null,
                        $params['fecha_citatorio'] ?? null,
                        $params['hora'] ?? null,
                        $params['ejecutor'] ?? null,
                        $params['clave_secuestro'] ?? null,
                        $params['clave_remate'] ?? null,
                        $params['fecha_remate'] ?? null,
                        $params['porcentaje_multa'] ?? null,
                        $params['observaciones'] ?? null,
                        $params['modulo'] ?? null,
                        $params['control_otr'] ?? null
                    ]);
                    $eResponse['success'] = true;
                    $eResponse['data'] = $result;
                    break;
                case 'delete_apremio':
                    $result = DB::select('CALL sp_delete_apremio(?)', [
                        $params['id_control'] ?? null
                    ]);
                    $eResponse['success'] = true;
                    $eResponse['data'] = $result;
                    break;
                default:
                    $eResponse['message'] = 'Unknown eRequest: ' . $eRequest;
            }
        } catch (\Exception $e) {
            $eResponse['message'] = $e->getMessage();
        }

        return response()->json(['eResponse' => $eResponse]);
    }
}

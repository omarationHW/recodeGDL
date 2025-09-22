<?php
namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\Validator;

class RptAdeudoCorteManzanaSaldoAntController extends Controller
{
    /**
     * Endpoint único para ejecutar acciones del formulario RptAdeudoCorteManzanaSaldoAnt
     * Entrada: eRequest con action y parámetros
     * Salida: eResponse con datos/resultados
     */
    public function execute(Request $request)
    {
        $eRequest = $request->input('eRequest');
        $action = $eRequest['action'] ?? null;
        $params = $eRequest['params'] ?? [];
        $eResponse = [
            'success' => false,
            'data' => null,
            'message' => ''
        ];

        try {
            switch ($action) {
                case 'getReportData':
                    $eResponse = $this->getReportData($params);
                    break;
                case 'getSubtipos':
                    $eResponse = $this->getSubtipos($params);
                    break;
                case 'getSaldoAnterior':
                    $eResponse = $this->getSaldoAnterior($params);
                    break;
                default:
                    $eResponse['message'] = 'Acción no soportada';
            }
        } catch (\Exception $ex) {
            Log::error($ex->getMessage());
            $eResponse['success'] = false;
            $eResponse['message'] = $ex->getMessage();
        }
        return response()->json(['eResponse' => $eResponse]);
    }

    /**
     * Obtiene los datos del reporte principal
     */
    private function getReportData($params)
    {
        $validator = Validator::make($params, [
            'subtipo' => 'required|integer',
            'fechadsd' => 'required|date',
            'fechahst' => 'required|date',
            'rep' => 'required|integer',
            'est' => 'required|string'
        ]);
        if ($validator->fails()) {
            return [
                'success' => false,
                'message' => $validator->errors()->first()
            ];
        }
        $result = DB::select('CALL sp_rpt_adeudo_corte_manzana_saldo_ant(?, ?, ?, ?, ?)', [
            $params['subtipo'],
            $params['fechadsd'],
            $params['fechahst'],
            $params['rep'],
            $params['est']
        ]);
        return [
            'success' => true,
            'data' => $result
        ];
    }

    /**
     * Obtiene los subtipos disponibles
     */
    private function getSubtipos($params)
    {
        $tipo = $params['tipo'] ?? 14;
        $result = DB::select('SELECT subtipo, desc_subtipo FROM ta_17_subtipo_conv WHERE tipo = ?', [$tipo]);
        return [
            'success' => true,
            'data' => $result
        ];
    }

    /**
     * Obtiene el saldo anterior de un predio
     */
    private function getSaldoAnterior($params)
    {
        $validator = Validator::make($params, [
            'subtipo' => 'required|integer',
            'id_conv_predio' => 'required|integer',
            'fechadsd' => 'required|date'
        ]);
        if ($validator->fails()) {
            return [
                'success' => false,
                'message' => $validator->errors()->first()
            ];
        }
        $result = DB::select('CALL sp_saldo_anterior_predio(?, ?, ?)', [
            $params['subtipo'],
            $params['id_conv_predio'],
            $params['fechadsd']
        ]);
        return [
            'success' => true,
            'data' => $result
        ];
    }
}

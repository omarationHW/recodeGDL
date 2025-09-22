<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;

class RptAdeudosConvDiversosSaldoAntController extends Controller
{
    /**
     * Endpoint único para ejecutar acciones del formulario RptAdeudosConvDiversosSaldoAnt
     * Entrada: eRequest con action, params
     * Salida: eResponse con status, data, message
     */
    public function execute(Request $request)
    {
        $eRequest = $request->input('eRequest');
        $action = $eRequest['action'] ?? null;
        $params = $eRequest['params'] ?? [];
        $eResponse = [
            'status' => 'error',
            'data' => null,
            'message' => 'Acción no reconocida'
        ];

        try {
            switch ($action) {
                case 'getReport':
                    $validator = Validator::make($params, [
                        'tipo' => 'required|integer',
                        'subtipo' => 'required|integer',
                        'fechadsd' => 'required|date',
                        'fechahst' => 'required|date',
                        'letras' => 'required|string',
                        'estado' => 'required|string|in:A,B,P'
                    ]);
                    if ($validator->fails()) {
                        $eResponse['message'] = $validator->errors()->first();
                        break;
                    }
                    $data = DB::select('CALL sp_rpt_adeudos_conv_diversos_saldo_ant(?,?,?,?,?,?)', [
                        $params['tipo'],
                        $params['subtipo'],
                        $params['letras'],
                        $params['estado'],
                        $params['fechadsd'],
                        $params['fechahst']
                    ]);
                    $eResponse = [
                        'status' => 'success',
                        'data' => $data,
                        'message' => 'Reporte generado correctamente'
                    ];
                    break;
                case 'getSaldoAnterior':
                    $validator = Validator::make($params, [
                        'tipo' => 'required|integer',
                        'subtipo' => 'required|integer',
                        'id_conv_diver' => 'required|integer',
                        'fechadsd' => 'required|date'
                    ]);
                    if ($validator->fails()) {
                        $eResponse['message'] = $validator->errors()->first();
                        break;
                    }
                    $data = DB::select('CALL sp_rpt_adeudos_conv_diversos_saldo_ant_saldo_anterior(?,?,?,?)', [
                        $params['tipo'],
                        $params['subtipo'],
                        $params['id_conv_diver'],
                        $params['fechadsd']
                    ]);
                    $eResponse = [
                        'status' => 'success',
                        'data' => $data,
                        'message' => 'Saldo anterior obtenido correctamente'
                    ];
                    break;
                default:
                    $eResponse['message'] = 'Acción no soportada';
            }
        } catch (\Exception $ex) {
            $eResponse['status'] = 'error';
            $eResponse['message'] = $ex->getMessage();
        }
        return response()->json(['eResponse' => $eResponse]);
    }
}

<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;

class GastosCobController extends Controller
{
    /**
     * Endpoint unificado para ejecutar acciones relacionadas con Gastos de Cobranza.
     * Entrada: eRequest con action, params, user, etc.
     * Salida: eResponse con status, data, message, etc.
     */
    public function execute(Request $request)
    {
        $input = $request->all();
        $action = $input['action'] ?? null;
        $params = $input['params'] ?? [];
        $user = $input['user'] ?? null;
        $response = [
            'status' => 'error',
            'data' => null,
            'message' => 'Acción no válida'
        ];

        try {
            switch ($action) {
                case 'getRecaudadoras':
                    $data = DB::select('SELECT * FROM ta_12_recaudadoras r JOIN ta_12_zonas z ON r.id_zona = z.id_zona');
                    $response = [
                        'status' => 'success',
                        'data' => $data,
                        'message' => 'Listado de recaudadoras obtenido correctamente.'
                    ];
                    break;
                case 'getPagosGastosCob':
                    $validator = Validator::make($params, [
                        'fecha_desde' => 'required|date',
                        'fecha_hasta' => 'required|date',
                        'id_rec' => 'required|integer'
                    ]);
                    if ($validator->fails()) {
                        $response['message'] = $validator->errors()->first();
                        break;
                    }
                    $data = DB::select('CALL spd_12_gastoscob(?, ?, ?)', [
                        $params['fecha_desde'],
                        $params['fecha_hasta'],
                        $params['id_rec']
                    ]);
                    $response = [
                        'status' => 'success',
                        'data' => $data,
                        'message' => 'Pagos de gastos de cobranza obtenidos.'
                    ];
                    break;
                case 'getPagosGastosCobPorRecaudadora':
                    $validator = Validator::make($params, [
                        'fecha_desde' => 'required|date',
                        'fecha_hasta' => 'required|date',
                        'id_rec' => 'required|integer'
                    ]);
                    if ($validator->fails()) {
                        $response['message'] = $validator->errors()->first();
                        break;
                    }
                    $data = DB::select('CALL spd_12_gastoscobxrec(?, ?, ?)', [
                        $params['fecha_desde'],
                        $params['fecha_hasta'],
                        $params['id_rec']
                    ]);
                    $response = [
                        'status' => 'success',
                        'data' => $data,
                        'message' => 'Pagos de gastos de cobranza por recaudadora obtenidos.'
                    ];
                    break;
                case 'exportPagosGastosCob':
                    // Similar a getPagosGastosCob, pero retorna datos para exportar
                    $validator = Validator::make($params, [
                        'fecha_desde' => 'required|date',
                        'fecha_hasta' => 'required|date',
                        'id_rec' => 'required|integer'
                    ]);
                    if ($validator->fails()) {
                        $response['message'] = $validator->errors()->first();
                        break;
                    }
                    $data = DB::select('CALL spd_12_gastoscob(?, ?, ?)', [
                        $params['fecha_desde'],
                        $params['fecha_hasta'],
                        $params['id_rec']
                    ]);
                    // Aquí se puede agregar lógica para exportar a Excel si se requiere
                    $response = [
                        'status' => 'success',
                        'data' => $data,
                        'message' => 'Datos listos para exportar.'
                    ];
                    break;
                default:
                    $response['message'] = 'Acción no reconocida: ' . $action;
            }
        } catch (\Exception $e) {
            $response['status'] = 'error';
            $response['message'] = $e->getMessage();
        }
        return response()->json($response);
    }
}

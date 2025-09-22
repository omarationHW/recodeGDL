<?php
namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;

class ConsCapturaFechaEnergiaController extends Controller
{
    /**
     * Endpoint único para ejecutar acciones (eRequest/eResponse)
     */
    public function execute(Request $request)
    {
        $action = $request->input('action');
        $params = $request->input('params', []);
        $userId = $request->user() ? $request->user()->id : null;
        $response = [
            'success' => false,
            'data' => null,
            'message' => ''
        ];
        try {
            switch ($action) {
                case 'getPagosByFecha':
                    $response['data'] = DB::select('CALL sp_get_pagos_energia_fecha(?, ?, ?, ?)', [
                        $params['fecha_pago'],
                        $params['oficina_pago'],
                        $params['caja_pago'],
                        $params['operacion_pago']
                    ]);
                    $response['success'] = true;
                    break;
                case 'deletePagosEnergia':
                    $response['data'] = DB::select('CALL sp_delete_pagos_energia(?, ?, ?, ?, ?)', [
                        $params['pagos_ids'], // array of IDs
                        $userId,
                        $params['fecha_pago'],
                        $params['oficina_pago'],
                        $params['operacion_pago']
                    ]);
                    $response['success'] = true;
                    break;
                case 'getOficinas':
                    $response['data'] = DB::select('SELECT * FROM ta_12_recaudadoras ORDER BY id_rec');
                    $response['success'] = true;
                    break;
                case 'getCajasByOficina':
                    $response['data'] = DB::select('SELECT * FROM ta_12_cajas WHERE id_rec = ?', [$params['oficina']]);
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
}

<?php
namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;

class PagosDifIngresosController extends Controller
{
    /**
     * Endpoint unificado para eRequest/eResponse
     */
    public function execute(Request $request)
    {
        $action = $request->input('eRequest.action');
        $params = $request->input('eRequest.params', []);
        $user = $request->user(); // Si hay autenticación
        $response = [
            'eResponse' => [
                'success' => false,
                'data' => null,
                'message' => ''
            ]
        ];

        try {
            switch ($action) {
                case 'getRecaudadoras':
                    $data = DB::select('SELECT id_rec, recaudadora FROM ta_12_recaudadoras ORDER BY id_rec');
                    $response['eResponse']['success'] = true;
                    $response['eResponse']['data'] = $data;
                    break;
                case 'getPagosDiferentes':
                    $data = DB::select('SELECT * FROM spd_11_dif_pagos(:rec, :fpadsd, :fpahst)', [
                        'rec' => $params['rec'],
                        'fpadsd' => $params['fpadsd'],
                        'fpahst' => $params['fpahst']
                    ]);
                    $response['eResponse']['success'] = true;
                    $response['eResponse']['data'] = $data;
                    break;
                case 'getPagosRentaErronea':
                    $data = DB::select('SELECT * FROM spd_11_dif_renta(:rec, :fpadsd, :fpahst)', [
                        'rec' => $params['rec'],
                        'fpadsd' => $params['fpadsd'],
                        'fpahst' => $params['fpahst']
                    ]);
                    $response['eResponse']['success'] = true;
                    $response['eResponse']['data'] = $data;
                    break;
                case 'exportPagosDiferentes':
                    // Lógica de exportación a Excel (puede usar Laravel Excel)
                    // Aquí solo se retorna la data, el frontend debe generar el archivo
                    $data = DB::select('SELECT * FROM spd_11_dif_pagos(:rec, :fpadsd, :fpahst)', [
                        'rec' => $params['rec'],
                        'fpadsd' => $params['fpadsd'],
                        'fpahst' => $params['fpahst']
                    ]);
                    $response['eResponse']['success'] = true;
                    $response['eResponse']['data'] = $data;
                    break;
                case 'exportPagosRentaErronea':
                    $data = DB::select('SELECT * FROM spd_11_dif_renta(:rec, :fpadsd, :fpahst)', [
                        'rec' => $params['rec'],
                        'fpadsd' => $params['fpadsd'],
                        'fpahst' => $params['fpahst']
                    ]);
                    $response['eResponse']['success'] = true;
                    $response['eResponse']['data'] = $data;
                    break;
                default:
                    $response['eResponse']['message'] = 'Acción no soportada';
            }
        } catch (\Exception $e) {
            $response['eResponse']['success'] = false;
            $response['eResponse']['message'] = $e->getMessage();
        }
        return response()->json($response);
    }
}

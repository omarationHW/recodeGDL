<?php
namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\Validator;

class RptFacturaEmisionController extends Controller
{
    /**
     * Endpoint único para ejecutar acciones del formulario RptFacturaEmision
     * Entrada: eRequest con action, params
     * Salida: eResponse con status, data, message
     */
    public function execute(Request $request)
    {
        $input = $request->all();
        $action = $input['action'] ?? null;
        $params = $input['params'] ?? [];
        $response = [
            'status' => 'error',
            'data' => null,
            'message' => 'Acción no válida'
        ];

        try {
            switch ($action) {
                case 'getFacturaEmision':
                    $validator = Validator::make($params, [
                        'oficina' => 'required|integer',
                        'axo' => 'required|integer',
                        'periodo' => 'required|integer',
                        'mercado' => 'required|integer',
                        'opc' => 'required|integer'
                    ]);
                    if ($validator->fails()) {
                        $response['message'] = $validator->errors()->first();
                        break;
                    }
                    $result = DB::select('CALL sp_rpt_factura_emision(?,?,?,?,?)', [
                        $params['oficina'],
                        $params['axo'],
                        $params['periodo'],
                        $params['mercado'],
                        $params['opc']
                    ]);
                    $response = [
                        'status' => 'success',
                        'data' => $result,
                        'message' => 'Datos de facturación obtenidos correctamente'
                    ];
                    break;
                case 'getVencimientoRec':
                    $validator = Validator::make($params, [
                        'mes' => 'required|integer'
                    ]);
                    if ($validator->fails()) {
                        $response['message'] = $validator->errors()->first();
                        break;
                    }
                    $result = DB::select('CALL sp_get_vencimiento_rec(?)', [
                        $params['mes']
                    ]);
                    $response = [
                        'status' => 'success',
                        'data' => $result,
                        'message' => 'Datos de vencimiento obtenidos correctamente'
                    ];
                    break;
                default:
                    $response['message'] = 'Acción no soportada';
            }
        } catch (\Exception $e) {
            Log::error('RptFacturaEmisionController error: ' . $e->getMessage());
            $response = [
                'status' => 'error',
                'data' => null,
                'message' => $e->getMessage()
            ];
        }
        return response()->json($response);
    }
}

<?php
namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;

class IngresoCapturaController extends Controller
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
                case 'getIngresoCaptura':
                    $validator = Validator::make($params, [
                        'num_mercado' => 'required|integer',
                        'fecha_pago' => 'required|date',
                        'oficina_pago' => 'required|integer',
                        'caja_pago' => 'required|string',
                        'operacion_pago' => 'required|integer',
                    ]);
                    if ($validator->fails()) {
                        $response['message'] = $validator->errors()->first();
                        break;
                    }
                    $result = DB::select('CALL sp_get_ingreso_captura(?,?,?,?,?)', [
                        $params['num_mercado'],
                        $params['fecha_pago'],
                        $params['oficina_pago'],
                        $params['caja_pago'],
                        $params['operacion_pago']
                    ]);
                    $response['success'] = true;
                    $response['data'] = $result;
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

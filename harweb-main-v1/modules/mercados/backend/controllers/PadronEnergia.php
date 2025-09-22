<?php
namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;

class PadronEnergiaController extends Controller
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
                case 'getRecaudadoras':
                    $response['data'] = DB::select('SELECT id_rec, recaudadora FROM ta_12_recaudadoras ORDER BY id_rec');
                    $response['success'] = true;
                    break;
                case 'getMercadosByRecaudadora':
                    $validator = Validator::make($params, [
                        'id_rec' => 'required|integer'
                    ]);
                    if ($validator->fails()) {
                        $response['message'] = $validator->errors()->first();
                        break;
                    }
                    $response['data'] = DB::select('SELECT num_mercado_nvo, descripcion FROM ta_11_mercados WHERE oficina = ? AND cuenta_energia > 0 ORDER BY num_mercado_nvo', [$params['id_rec']]);
                    $response['success'] = true;
                    break;
                case 'getPadronEnergia':
                    $validator = Validator::make($params, [
                        'id_rec' => 'required|integer',
                        'num_mercado_nvo' => 'required|integer'
                    ]);
                    if ($validator->fails()) {
                        $response['message'] = $validator->errors()->first();
                        break;
                    }
                    $result = DB::select('CALL sp_padron_energia(?, ?)', [
                        $params['id_rec'],
                        $params['num_mercado_nvo']
                    ]);
                    $response['data'] = $result;
                    $response['success'] = true;
                    break;
                case 'exportPadronEnergiaExcel':
                    // Implementación de exportación a Excel (puede usar Laravel Excel)
                    // Aquí solo se simula la respuesta
                    $response['data'] = [
                        'url' => '/exports/padron_energia_' . $params['id_rec'] . '_' . $params['num_mercado_nvo'] . '.xlsx'
                    ];
                    $response['success'] = true;
                    break;
                case 'printPadronEnergia':
                    // Implementación de impresión (puede devolver PDF generado)
                    $response['data'] = [
                        'url' => '/exports/padron_energia_' . $params['id_rec'] . '_' . $params['num_mercado_nvo'] . '.pdf'
                    ];
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

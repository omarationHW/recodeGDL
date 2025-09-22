<?php
namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;

class EmisionEnergiaController extends Controller
{
    /**
     * Endpoint único para manejar todas las operaciones de Emisión de Energía.
     * Entrada: { eRequest: { action: string, params: array } }
     * Salida: { eResponse: { status: string, data: mixed, message: string } }
     */
    public function execute(Request $request)
    {
        $input = $request->input('eRequest');
        $action = $input['action'] ?? null;
        $params = $input['params'] ?? [];
        $response = [
            'status' => 'error',
            'data' => null,
            'message' => 'Acción no reconocida.'
        ];

        try {
            switch ($action) {
                case 'getRecaudadoras':
                    $data = DB::select('SELECT * FROM get_recaudadoras()');
                    $response = ['status' => 'ok', 'data' => $data, 'message' => ''];
                    break;
                case 'getMercadosByRecaudadora':
                    $oficina = $params['oficina'] ?? null;
                    $data = DB::select('SELECT * FROM get_mercados_by_recaudadora(?)', [$oficina]);
                    $response = ['status' => 'ok', 'data' => $data, 'message' => ''];
                    break;
                case 'getEmisionEnergia':
                    $oficina = $params['oficina'];
                    $mercado = $params['mercado'];
                    $axo = $params['axo'];
                    $periodo = $params['periodo'];
                    $data = DB::select('SELECT * FROM get_emision_energia(?,?,?,?)', [$oficina, $mercado, $axo, $periodo]);
                    $response = ['status' => 'ok', 'data' => $data, 'message' => ''];
                    break;
                case 'grabarEmisionEnergia':
                    $oficina = $params['oficina'];
                    $mercado = $params['mercado'];
                    $axo = $params['axo'];
                    $periodo = $params['periodo'];
                    $usuario = $params['usuario'];
                    $result = DB::select('SELECT * FROM grabar_emision_energia(?,?,?,?,?)', [$oficina, $mercado, $axo, $periodo, $usuario]);
                    $response = ['status' => $result[0]->status, 'data' => null, 'message' => $result[0]->message];
                    break;
                case 'facturarEmisionEnergia':
                    $oficina = $params['oficina'];
                    $mercado = $params['mercado'];
                    $axo = $params['axo'];
                    $periodo = $params['periodo'];
                    $data = DB::select('SELECT * FROM facturar_emision_energia(?,?,?,?)', [$oficina, $mercado, $axo, $periodo]);
                    $response = ['status' => 'ok', 'data' => $data, 'message' => ''];
                    break;
                default:
                    $response['message'] = 'Acción no soportada.';
            }
        } catch (\Exception $e) {
            $response = [
                'status' => 'error',
                'data' => null,
                'message' => $e->getMessage()
            ];
        }
        return response()->json(['eResponse' => $response]);
    }
}

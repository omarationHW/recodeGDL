<?php
namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;

class PagosIndividualController extends Controller
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
                case 'getPagoIndividual':
                    $response['data'] = $this->getPagoIndividual($params);
                    $response['success'] = true;
                    break;
                case 'getMercadoInfo':
                    $response['data'] = $this->getMercadoInfo($params);
                    $response['success'] = true;
                    break;
                case 'getUsuarioInfo':
                    $response['data'] = $this->getUsuarioInfo($params);
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

    /**
     * Consulta individual de pago de local
     * params: [id_local, axo, periodo]
     */
    private function getPagoIndividual($params)
    {
        $validator = Validator::make($params, [
            'id_local' => 'required|integer',
            'axo' => 'required|integer',
            'periodo' => 'required|integer',
        ]);
        if ($validator->fails()) {
            throw new \Exception('Parámetros inválidos: ' . $validator->errors()->first());
        }
        $result = DB::select('SELECT * FROM pagos_individual_get(:id_local, :axo, :periodo)', [
            'id_local' => $params['id_local'],
            'axo' => $params['axo'],
            'periodo' => $params['periodo']
        ]);
        return $result[0] ?? null;
    }

    /**
     * Consulta información de mercado
     * params: [oficina, num_mercado_nvo]
     */
    private function getMercadoInfo($params)
    {
        $validator = Validator::make($params, [
            'oficina' => 'required|integer',
            'num_mercado_nvo' => 'required|integer',
        ]);
        if ($validator->fails()) {
            throw new \Exception('Parámetros inválidos: ' . $validator->errors()->first());
        }
        $result = DB::select('SELECT * FROM mercado_info_get(:oficina, :num_mercado_nvo)', [
            'oficina' => $params['oficina'],
            'num_mercado_nvo' => $params['num_mercado_nvo']
        ]);
        return $result[0] ?? null;
    }

    /**
     * Consulta información de usuario
     * params: [id_usuario]
     */
    private function getUsuarioInfo($params)
    {
        $validator = Validator::make($params, [
            'id_usuario' => 'required|integer',
        ]);
        if ($validator->fails()) {
            throw new \Exception('Parámetros inválidos: ' . $validator->errors()->first());
        }
        $result = DB::select('SELECT * FROM usuario_info_get(:id_usuario)', [
            'id_usuario' => $params['id_usuario']
        ]);
        return $result[0] ?? null;
    }
}

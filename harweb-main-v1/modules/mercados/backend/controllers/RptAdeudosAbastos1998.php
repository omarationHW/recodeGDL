<?php
namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\Validator;

class AdeudosAbastos1998Controller extends Controller
{
    /**
     * Endpoint unificado para eRequest/eResponse
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
                case 'get_adeudos_abastos_1998':
                    $response['data'] = $this->getAdeudosAbastos1998($params);
                    $response['success'] = true;
                    break;
                case 'get_renta_1998':
                    $response['data'] = $this->getRenta1998($params);
                    $response['success'] = true;
                    break;
                case 'get_meses_adeudo_1998':
                    $response['data'] = $this->getMesesAdeudo1998($params);
                    $response['success'] = true;
                    break;
                default:
                    $response['message'] = 'Acción no soportada';
            }
        } catch (\Exception $e) {
            $response['message'] = $e->getMessage();
            Log::error($e);
        }
        return response()->json($response);
    }

    /**
     * Obtiene el listado de adeudos de abastos 1998
     * params: axo, oficina, periodo
     */
    private function getAdeudosAbastos1998($params)
    {
        $axo = $params['axo'] ?? 1998;
        $oficina = $params['oficina'] ?? 5;
        $periodo = $params['periodo'] ?? 12;
        $result = DB::select('CALL sp_get_adeudos_abastos_1998(?, ?, ?)', [$axo, $oficina, $periodo]);
        return $result;
    }

    /**
     * Obtiene la renta para un local en 1998
     * params: vaxo, vcat, vsec, vcve
     */
    private function getRenta1998($params)
    {
        $vaxo = $params['vaxo'];
        $vcat = $params['vcat'];
        $vsec = $params['vsec'];
        $vcve = $params['vcve'];
        $result = DB::select('CALL sp_get_renta_1998(?, ?, ?, ?)', [$vaxo, $vcat, $vsec, $vcve]);
        return $result;
    }

    /**
     * Obtiene los meses de adeudo para un local en 1998
     * params: vid_local, vaxo
     */
    private function getMesesAdeudo1998($params)
    {
        $vid_local = $params['vid_local'];
        $vaxo = $params['vaxo'];
        $result = DB::select('CALL sp_get_meses_adeudo_1998(?, ?)', [$vid_local, $vaxo]);
        return $result;
    }
}

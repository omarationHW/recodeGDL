<?php

namespace App\Http\Controllers\Api;

use Illuminate\Http\Request;
use App\Http\Controllers\Controller;
use Illuminate\Support\Facades\DB;

class ExecuteController extends Controller
{
    /**
     * Endpoint unificado para ejecutar acciones vía eRequest/eResponse
     *
     * @param  \Illuminate\Http\Request  $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function execute(Request $request)
    {
        $eRequest = $request->input('eRequest');
        $params = $request->input('params', []);
        $eResponse = [
            'success' => false,
            'data' => null,
            'message' => ''
        ];

        try {
            switch ($eRequest) {
                case 'RptAdeudosEnergia.getReport':
                    $axo = $params['axo'] ?? null;
                    $oficina = $params['oficina'] ?? null;
                    if (!$axo || !$oficina) {
                        throw new \Exception('Parámetros axo y oficina requeridos');
                    }
                    $result = DB::select('SELECT * FROM rpt_adeudos_energia($1, $2)', [$axo, $oficina]);
                    $eResponse['success'] = true;
                    $eResponse['data'] = $result;
                    break;
                case 'RptAdeudosEnergia.getMeses':
                    $id_energia = $params['id_energia'] ?? null;
                    $axo = $params['axo'] ?? null;
                    if (!$id_energia || !$axo) {
                        throw new \Exception('Parámetros id_energia y axo requeridos');
                    }
                    $result = DB::select('SELECT * FROM rpt_adeudos_energia_meses($1, $2)', [$id_energia, $axo]);
                    $eResponse['success'] = true;
                    $eResponse['data'] = $result;
                    break;
                default:
                    $eResponse['message'] = 'eRequest no soportado';
            }
        } catch (\Exception $ex) {
            $eResponse['success'] = false;
            $eResponse['message'] = $ex->getMessage();
        }

        return response()->json(['eResponse' => $eResponse]);
    }
}

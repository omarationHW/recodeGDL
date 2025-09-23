<?php

namespace App\Http\Controllers\Api;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use App\Http\Controllers\Controller;

class ExecuteController extends Controller
{
    /**
     * Endpoint unificado para ejecutar acciones (eRequest/eResponse)
     *
     * @param Request $request
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
                case 'RptListaxRegPub.getReport':
                    $vigencia = $params['vigencia'] ?? 'todas';
                    $clave_practicado = $params['clave_practicado'] ?? 'todas';
                    $numesta = $params['numesta'] ?? 'todas';
                    $usuario_id_rec = $params['usuario_id_rec'] ?? null;

                    // Llama al stored procedure
                    $result = DB::select('SELECT * FROM rpt_listaxregpub_get_report(?, ?, ?, ?)', [
                        $vigencia, $clave_practicado, $numesta, $usuario_id_rec
                    ]);

                    $eResponse['success'] = true;
                    $eResponse['data'] = $result;
                    break;

                case 'RptListaxRegPub.getRecaudadoraInfo':
                    $usuario_id_rec = $params['usuario_id_rec'] ?? null;
                    if (!$usuario_id_rec) {
                        throw new \Exception('usuario_id_rec es requerido');
                    }
                    $result = DB::select('SELECT * FROM rpt_listaxregpub_get_recaudadora_info(?)', [
                        $usuario_id_rec
                    ]);
                    $eResponse['success'] = true;
                    $eResponse['data'] = $result;
                    break;

                default:
                    $eResponse['message'] = 'eRequest no soportado';
            }
        } catch (\Exception $ex) {
            $eResponse['message'] = $ex->getMessage();
        }

        return response()->json($eResponse);
    }
}

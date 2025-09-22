<?php

namespace App\Http\Controllers\Api;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use App\Http\Controllers\Controller;

class RprtListaxRegAseoController extends Controller
{
    /**
     * Endpoint unificado para ejecutar acciones (eRequest/eResponse)
     */
    public function execute(Request $request)
    {
        $action = $request->input('eRequest.action');
        $params = $request->input('eRequest.params', []);
        $response = [
            'success' => false,
            'data' => null,
            'message' => ''
        ];

        try {
            switch ($action) {
                case 'getReportData':
                    $data = $this->getReportData($params);
                    $response['success'] = true;
                    $response['data'] = $data;
                    break;
                case 'getRecaudadoraZona':
                    $data = $this->getRecaudadoraZona($params);
                    $response['success'] = true;
                    $response['data'] = $data;
                    break;
                default:
                    $response['message'] = 'Acción no soportada';
            }
        } catch (\Exception $e) {
            $response['message'] = $e->getMessage();
        }

        return response()->json(['eResponse' => $response]);
    }

    /**
     * Llama al stored procedure para obtener el reporte principal
     * @param array $params
     * @return array
     */
    private function getReportData($params)
    {
        // Parámetros esperados: id_rec, tipo_aseo, clave_practicado, vigencia
        $id_rec = $params['id_rec'] ?? null;
        $tipo_aseo = $params['tipo_aseo'] ?? null;
        $clave_practicado = $params['clave_practicado'] ?? 'todas';
        $vigencia = $params['vigencia'] ?? 'todas';

        $result = DB::select('SELECT * FROM sp_rprt_listax_reg_aseo(?, ?, ?, ?)', [
            $id_rec, $tipo_aseo, $clave_practicado, $vigencia
        ]);
        return $result;
    }

    /**
     * Llama al stored procedure para obtener datos de recaudadora y zona
     * @param array $params
     * @return array
     */
    private function getRecaudadoraZona($params)
    {
        $id_rec = $params['id_rec'] ?? null;
        $result = DB::select('SELECT * FROM sp_get_recaudadora_zona(?)', [$id_rec]);
        return $result;
    }
}

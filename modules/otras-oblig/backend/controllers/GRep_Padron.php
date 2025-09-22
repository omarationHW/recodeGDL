<?php

namespace App\Http\Controllers\Api;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use App\Http\Controllers\Controller;

class ExecuteController extends Controller
{
    /**
     * Endpoint único para ejecutar acciones del sistema (eRequest/eResponse)
     * POST /api/execute
     *
     * @param Request $request
     * @return \Illuminate\Http\JsonResponse
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
                case 'getPadronConAdeudos':
                    $response['data'] = $this->getPadronConAdeudos($params);
                    $response['success'] = true;
                    break;
                case 'getPadronAdeudosDetalle':
                    $response['data'] = $this->getPadronAdeudosDetalle($params);
                    $response['success'] = true;
                    break;
                case 'getVigenciasConcesion':
                    $response['data'] = $this->getVigenciasConcesion($params);
                    $response['success'] = true;
                    break;
                case 'getEtiquetasTabla':
                    $response['data'] = $this->getEtiquetasTabla($params);
                    $response['success'] = true;
                    break;
                case 'getNombreTabla':
                    $response['data'] = $this->getNombreTabla($params);
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
     * Obtener el padrón de concesiones con adeudos
     * @param array $params
     * @return array
     */
    private function getPadronConAdeudos($params)
    {
        $par_tabla = $params['par_tabla'] ?? null;
        $par_vigencia = $params['par_vigencia'] ?? 'TODOS';
        $result = DB::select('CALL sp34_padron(?, ?)', [$par_tabla, $par_vigencia]);
        return $result;
    }

    /**
     * Obtener detalle de adeudos por concesión
     * @param array $params
     * @return array
     */
    private function getPadronAdeudosDetalle($params)
    {
        $par_tab = $params['par_tab'] ?? null;
        $par_control = $params['par_control'] ?? null;
        $par_rep = $params['par_rep'] ?? null;
        $par_fecha = $params['par_fecha'] ?? null;
        $result = DB::select('CALL con34_gdetade_01(?, ?, ?, ?)', [
            $par_tab, $par_control, $par_rep, $par_fecha
        ]);
        return $result;
    }

    /**
     * Obtener vigencias de concesión
     * @param array $params
     * @return array
     */
    private function getVigenciasConcesion($params)
    {
        $par_tab = $params['par_tab'] ?? null;
        $result = DB::select('CALL sp34_vigencias_concesion(?)', [$par_tab]);
        return $result;
    }

    /**
     * Obtener etiquetas de la tabla
     * @param array $params
     * @return array
     */
    private function getEtiquetasTabla($params)
    {
        $par_tab = $params['par_tab'] ?? null;
        $result = DB::select('CALL sp34_etiq_tabla(?)', [$par_tab]);
        return $result;
    }

    /**
     * Obtener nombre de la tabla
     * @param array $params
     * @return array
     */
    private function getNombreTabla($params)
    {
        $par_tab = $params['par_tab'] ?? null;
        $result = DB::select('CALL sp34_nombre_tabla(?)', [$par_tab]);
        return $result;
    }
}

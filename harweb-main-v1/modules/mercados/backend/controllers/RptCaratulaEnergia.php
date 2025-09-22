<?php
namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;

class RptCaratulaEnergiaController extends Controller
{
    /**
     * Endpoint único para ejecutar acciones (eRequest/eResponse)
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
                case 'getEnergiaCaratula':
                    $response['data'] = $this->getEnergiaCaratula($params);
                    $response['success'] = true;
                    break;
                case 'getAdeudosEnergia':
                    $response['data'] = $this->getAdeudosEnergia($params);
                    $response['success'] = true;
                    break;
                case 'getRequerimientosEnergia':
                    $response['data'] = $this->getRequerimientosEnergia($params);
                    $response['success'] = true;
                    break;
                case 'getDiaVencimiento':
                    $response['data'] = $this->getDiaVencimiento($params);
                    $response['success'] = true;
                    break;
                case 'calcularRecargosEnergia':
                    $response['data'] = $this->calcularRecargosEnergia($params);
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
     * Obtiene la carátula de energía para un local
     */
    private function getEnergiaCaratula($params)
    {
        $id_local = $params['id_local'] ?? null;
        if (!$id_local) {
            throw new \Exception('id_local es requerido');
        }
        $result = DB::select('SELECT * FROM sp_get_energia_caratula(?)', [$id_local]);
        return $result[0] ?? null;
    }

    /**
     * Obtiene los adeudos de energía para un local
     */
    private function getAdeudosEnergia($params)
    {
        $id_local = $params['id_local'] ?? null;
        if (!$id_local) {
            throw new \Exception('id_local es requerido');
        }
        $result = DB::select('SELECT * FROM sp_get_adeudos_energia(?)', [$id_local]);
        return $result;
    }

    /**
     * Obtiene los requerimientos de energía para un local
     */
    private function getRequerimientosEnergia($params)
    {
        $id_local = $params['id_local'] ?? null;
        if (!$id_local) {
            throw new \Exception('id_local es requerido');
        }
        $result = DB::select('SELECT * FROM sp_get_requerimientos_energia(?)', [$id_local]);
        return $result;
    }

    /**
     * Obtiene el día de vencimiento para recargos
     */
    private function getDiaVencimiento($params)
    {
        $mes = $params['mes'] ?? null;
        if (!$mes) {
            throw new \Exception('mes es requerido');
        }
        $result = DB::select('SELECT * FROM sp_get_dia_vencimiento(?)', [$mes]);
        return $result[0] ?? null;
    }

    /**
     * Calcula los recargos de energía para un adeudo
     */
    private function calcularRecargosEnergia($params)
    {
        $id_adeudo = $params['id_adeudo'] ?? null;
        if (!$id_adeudo) {
            throw new \Exception('id_adeudo es requerido');
        }
        $result = DB::select('SELECT * FROM sp_calcular_recargos_energia(?)', [$id_adeudo]);
        return $result[0] ?? null;
    }
}

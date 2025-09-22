<?php
namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\Validator;

class AdeEnergiaGrlController extends Controller
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
                case 'getMarketsByOffice':
                    $response['data'] = $this->getMarketsByOffice($params['office_id']);
                    $response['success'] = true;
                    break;
                case 'getEnergyDebts':
                    $response['data'] = $this->getEnergyDebts($params);
                    $response['success'] = true;
                    break;
                case 'exportEnergyDebtsExcel':
                    $response['data'] = $this->exportEnergyDebtsExcel($params);
                    $response['success'] = true;
                    break;
                case 'getYearsMonths':
                    $response['data'] = $this->getYearsMonths();
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
     * Obtener mercados por oficina
     */
    private function getMarketsByOffice($office_id)
    {
        return DB::select('SELECT num_mercado_nvo, descripcion FROM ta_11_mercados WHERE oficina = ? ORDER BY num_mercado_nvo', [$office_id]);
    }

    /**
     * Obtener adeudos de energía eléctrica globales
     */
    private function getEnergyDebts($params)
    {
        $office = $params['office_id'];
        $market = $params['market_id'];
        $year = $params['year'];
        $month = $params['month'];
        $result = DB::select('CALL sp_get_ade_energia_grl(?, ?, ?, ?)', [$office, $market, $year, $month]);
        return $result;
    }

    /**
     * Exportar a Excel (dummy, debe implementarse con paquete de exportación)
     */
    private function exportEnergyDebtsExcel($params)
    {
        // Aquí se implementaría la lógica real de exportación
        // Por ahora, solo retorna los datos
        return $this->getEnergyDebts($params);
    }

    /**
     * Obtener años y meses disponibles
     */
    private function getYearsMonths()
    {
        $years = DB::select('SELECT DISTINCT axo FROM ta_11_adeudo_energ ORDER BY axo DESC');
        $months = [
            ['id' => 1, 'name' => 'Enero'], ['id' => 2, 'name' => 'Febrero'], ['id' => 3, 'name' => 'Marzo'],
            ['id' => 4, 'name' => 'Abril'], ['id' => 5, 'name' => 'Mayo'], ['id' => 6, 'name' => 'Junio'],
            ['id' => 7, 'name' => 'Julio'], ['id' => 8, 'name' => 'Agosto'], ['id' => 9, 'name' => 'Septiembre'],
            ['id' => 10, 'name' => 'Octubre'], ['id' => 11, 'name' => 'Noviembre'], ['id' => 12, 'name' => 'Diciembre']
        ];
        return ['years' => $years, 'months' => $months];
    }
}

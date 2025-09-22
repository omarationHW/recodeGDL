<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\Validator;

class AdeGlobalLocalesController extends Controller
{
    /**
     * Endpoint único para manejar todas las operaciones (eRequest/eResponse)
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
                case 'getAdeGlobalLocales':
                    $response['data'] = $this->getAdeGlobalLocales($params);
                    $response['success'] = true;
                    break;
                case 'getLocalesSinAdeudoConAccesorios':
                    $response['data'] = $this->getLocalesSinAdeudoConAccesorios($params);
                    $response['success'] = true;
                    break;
                case 'exportExcel':
                    // Implementar exportación a Excel si es necesario
                    $response['data'] = null;
                    $response['success'] = true;
                    break;
                default:
                    $response['message'] = 'Acción no soportada';
            }
        } catch (\Exception $e) {
            Log::error($e->getMessage());
            $response['message'] = $e->getMessage();
        }
        return response()->json($response);
    }

    /**
     * Obtener mercados por oficina
     */
    private function getMarketsByOffice($office_id)
    {
        return DB::select('SELECT * FROM ta_11_mercados WHERE oficina = ? ORDER BY num_mercado_nvo', [$office_id]);
    }

    /**
     * Obtener locales con adeudo global y accesorios
     */
    private function getAdeGlobalLocales($params)
    {
        $result = DB::select('CALL sp_get_ade_global_locales(?, ?, ?, ?)', [
            $params['office_id'],
            $params['market_id'],
            $params['year'],
            $params['month']
        ]);
        return $result;
    }

    /**
     * Obtener locales sin adeudo pero con accesorios
     */
    private function getLocalesSinAdeudoConAccesorios($params)
    {
        $result = DB::select('CALL sp_get_locales_sin_adeudo_con_accesorios(?, ?, ?, ?)', [
            $params['market_id'],
            $params['year'],
            $params['month'],
            $params['year']
        ]);
        return $result;
    }
}

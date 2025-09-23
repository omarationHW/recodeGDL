<?php

namespace App\Http\Controllers\Api;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use App\Http\Controllers\Controller;

class ExecuteController extends Controller
{
    /**
     * Handle unified API requests via /api/execute
     *
     * @param  \Illuminate\Http\Request  $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function execute(Request $request)
    {
        $eRequest = $request->input('eRequest');
        $params = $request->input('params', []);

        switch ($eRequest) {
            case 'getLic400':
                return $this->getLic400($params);
            case 'getPagoLic400':
                return $this->getPagoLic400($params);
            default:
                return response()->json([
                    'eResponse' => [
                        'success' => false,
                        'message' => 'Invalid eRequest',
                        'data' => null
                    ]
                ], 400);
        }
    }

    /**
     * Get Licencia 400 data
     * @param array $params
     * @return \Illuminate\Http\JsonResponse
     */
    private function getLic400($params)
    {
        $licencia = $params['licencia'] ?? null;
        if (!$licencia) {
            return response()->json([
                'eResponse' => [
                    'success' => false,
                    'message' => 'Parameter licencia is required',
                    'data' => null
                ]
            ], 422);
        }
        $result = DB::select('SELECT * FROM get_lic_400(?)', [$licencia]);
        return response()->json([
            'eResponse' => [
                'success' => true,
                'message' => 'Licencia data retrieved',
                'data' => $result
            ]
        ]);
    }

    /**
     * Get Pagos for Licencia 400
     * @param array $params
     * @return \Illuminate\Http\JsonResponse
     */
    private function getPagoLic400($params)
    {
        $numlic = $params['numlic'] ?? null;
        if (!$numlic) {
            return response()->json([
                'eResponse' => [
                    'success' => false,
                    'message' => 'Parameter numlic is required',
                    'data' => null
                ]
            ], 422);
        }
        $result = DB::select('SELECT * FROM get_pago_lic_400(?)', [$numlic]);
        return response()->json([
            'eResponse' => [
                'success' => true,
                'message' => 'Pagos data retrieved',
                'data' => $result
            ]
        ]);
    }
}

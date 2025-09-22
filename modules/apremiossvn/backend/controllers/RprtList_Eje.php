<?php

namespace App\Http\Controllers\Api;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use App\Http\Controllers\Controller;

class ExecuteController extends Controller
{
    /**
     * Handle unified API requests (eRequest/eResponse pattern)
     * Endpoint: /api/execute
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
                case 'getRprtListEje':
                    $data = $this->getRprtListEje($params);
                    $response['success'] = true;
                    $response['data'] = $data;
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
     * Ejecuta el reporte RprtList_Eje
     * @param array $params
     * @return array
     */
    private function getRprtListEje($params)
    {
        // Parámetros esperados:
        // varios (string), vvig (string), vrec (string), vopc (int), vfec1 (date), vfec2 (date), vrecaudadora (int), vfecP1 (date), vfecP2 (date), vnombre (string), v90d (string)
        $varios = $params['varios'] ?? '';
        $vvig = $params['vvig'] ?? '1';
        $vrec = $params['vrec'] ?? '';
        $vopc = $params['vopc'] ?? 1;
        $vfec1 = $params['vfec1'] ?? null;
        $vfec2 = $params['vfec2'] ?? null;
        $vrecaudadora = $params['vrecaudadora'] ?? 0;
        $vfecP1 = $params['vfecP1'] ?? null;
        $vfecP2 = $params['vfecP2'] ?? null;
        $vnombre = $params['vnombre'] ?? '';
        $v90d = $params['v90d'] ?? 'N';

        // Llamar stored procedure
        $result = DB::select('SELECT * FROM rprtlist_eje_report(?,?,?,?,?,?,?,?,?,?,?)', [
            $varios, $vvig, $vrec, $vopc, $vfec1, $vfec2, $vrecaudadora, $vfecP1, $vfecP2, $vnombre, $v90d
        ]);

        return $result;
    }
}

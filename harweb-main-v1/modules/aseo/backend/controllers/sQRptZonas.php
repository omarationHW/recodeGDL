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
    public function handle(Request $request)
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
                case 'getZonasReport':
                    // opcion: 1=Control, 2=Zona, 3=Sub-Zona, 4=Descripcion
                    $opcion = isset($params['opcion']) ? (int)$params['opcion'] : 1;
                    $result = DB::select('SELECT * FROM rpt_ta_16_zonas_report(?)', [$opcion]);
                    $eResponse['success'] = true;
                    $eResponse['data'] = $result;
                    $eResponse['message'] = 'Reporte de zonas obtenido correctamente.';
                    break;
                default:
                    $eResponse['message'] = 'eRequest no soportado: ' . $eRequest;
            }
        } catch (\Exception $ex) {
            $eResponse['message'] = $ex->getMessage();
        }

        return response()->json(['eResponse' => $eResponse]);
    }
}

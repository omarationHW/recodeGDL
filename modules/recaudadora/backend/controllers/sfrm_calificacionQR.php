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
        $eResponse = [
            'success' => false,
            'data' => null,
            'error' => null
        ];

        try {
            switch ($eRequest) {
                case 'get_calificacion_qr':
                    // params: id_multa (int)
                    $result = DB::select('SELECT * FROM sp_get_calificacion_qr(?)', [
                        $params['id_multa'] ?? null
                    ]);
                    $eResponse['success'] = true;
                    $eResponse['data'] = $result;
                    break;
                case 'get_multas_articulos':
                    // params: id_multa (int)
                    $result = DB::select('SELECT * FROM sp_get_multas_articulos(?)', [
                        $params['id_multa'] ?? null
                    ]);
                    $eResponse['success'] = true;
                    $eResponse['data'] = $result;
                    break;
                case 'get_calificacion_qr_full':
                    // params: id_multa (int)
                    $main = DB::select('SELECT * FROM sp_get_calificacion_qr(?)', [
                        $params['id_multa'] ?? null
                    ]);
                    $articulos = DB::select('SELECT * FROM sp_get_multas_articulos(?)', [
                        $params['id_multa'] ?? null
                    ]);
                    $eResponse['success'] = true;
                    $eResponse['data'] = [
                        'calificacion' => $main[0] ?? null,
                        'articulos' => $articulos
                    ];
                    break;
                default:
                    $eResponse['error'] = 'Unknown eRequest: ' . $eRequest;
            }
        } catch (\Exception $ex) {
            $eResponse['error'] = $ex->getMessage();
        }

        return response()->json(['eResponse' => $eResponse]);
    }
}

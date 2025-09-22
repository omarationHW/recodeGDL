<?php

namespace App\Http\Controllers\Api;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use App\Http\Controllers\Controller;

class ExecuteController extends Controller
{
    /**
     * Handle unified API requests for multas400frm.
     * Endpoint: /api/execute
     */
    public function execute(Request $request)
    {
        $eRequest = $request->input('eRequest');
        $params = $request->input('params', []);
        $response = [
            'success' => false,
            'data' => null,
            'message' => ''
        ];

        try {
            switch ($eRequest) {
                case 'multas400_search_by_acta_fed':
                    $result = DB::select('SELECT * FROM multas_fed_400_search_by_acta(:depfed, :axofed, :numacta)', [
                        'depfed' => $params['depfed'],
                        'axofed' => $params['axofed'],
                        'numacta' => $params['numacta']
                    ]);
                    $response['success'] = true;
                    $response['data'] = $result;
                    break;
                case 'multas400_search_by_nombre_fed':
                    $result = DB::select('SELECT * FROM multas_fed_400_search_by_nombre(:nombre)', [
                        'nombre' => strtoupper($params['nombre'])
                    ]);
                    $response['success'] = true;
                    $response['data'] = $result;
                    break;
                case 'multas400_search_by_domici_fed':
                    $result = DB::select('SELECT * FROM multas_fed_400_search_by_domici(:domici)', [
                        'domici' => strtoupper($params['domici'])
                    ]);
                    $response['success'] = true;
                    $response['data'] = $result;
                    break;
                case 'multas400_search_by_acta_mpal':
                    $result = DB::select('SELECT * FROM multas_mpal_400_search_by_acta(:depen, :axoacta, :numacta)', [
                        'depen' => strtoupper($params['depen']),
                        'axoacta' => $params['axoacta'],
                        'numacta' => $params['numacta']
                    ]);
                    $response['success'] = true;
                    $response['data'] = $result;
                    break;
                case 'multas400_search_by_nombre_mpal':
                    $result = DB::select('SELECT * FROM multas_mpal_400_search_by_nombre(:nombre)', [
                        'nombre' => strtoupper($params['nombre'])
                    ]);
                    $response['success'] = true;
                    $response['data'] = $result;
                    break;
                case 'multas400_search_by_domici_mpal':
                    $result = DB::select('SELECT * FROM multas_mpal_400_search_by_domici(:domici)', [
                        'domici' => strtoupper($params['domici'])
                    ]);
                    $response['success'] = true;
                    $response['data'] = $result;
                    break;
                default:
                    $response['message'] = 'Invalid eRequest';
            }
        } catch (\Exception $e) {
            $response['message'] = $e->getMessage();
        }

        return response()->json(['eResponse' => $response]);
    }
}

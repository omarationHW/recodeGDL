<?php

namespace App\Http\Controllers\Api;

use Illuminate\Http\Request;
use App\Http\Controllers\Controller;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;

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
            'error' => null,
        ];

        try {
            switch ($eRequest) {
                case 'catalog.scian.search':
                    $descripcion = isset($params['descripcion']) ? $params['descripcion'] : '';
                    $result = DB::select('SELECT * FROM catalogo_scian_busqueda(:descripcion)', [
                        'descripcion' => $descripcion
                    ]);
                    $eResponse['success'] = true;
                    $eResponse['data'] = $result;
                    break;
                case 'catalog.scian.all':
                    $result = DB::select('SELECT * FROM catalogo_scian_busqueda(\'\')');
                    $eResponse['success'] = true;
                    $eResponse['data'] = $result;
                    break;
                default:
                    $eResponse['error'] = 'eRequest not supported.';
                    break;
            }
        } catch (\Exception $ex) {
            Log::error('API Execute Error: ' . $ex->getMessage());
            $eResponse['error'] = $ex->getMessage();
        }

        return response()->json($eResponse);
    }
}

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
     * @param  Request  $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function handle(Request $request)
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
                case 'getTiposEmpresas':
                    // opcion: 1=ctrol_emp, 2=tipo_empresa, 3=descripcion
                    $opcion = isset($params['opcion']) ? (int)$params['opcion'] : 1;
                    $result = DB::select('SELECT * FROM sp_get_tipos_empresas(?);', [$opcion]);
                    // The SP returns SETOF ta_16_tipos_emp, so we need to extract the rows
                    $rows = array_map(function($row) {
                        // If the SP returns as (ta_16_tipos_emp), unpack
                        return is_object($row) && isset($row->sp_get_tipos_empresas) ? (array)$row->sp_get_tipos_empresas : (array)$row;
                    }, $result);
                    $response['success'] = true;
                    $response['data'] = $rows;
                    break;
                default:
                    $response['message'] = 'Unknown eRequest: ' . $eRequest;
            }
        } catch (\Exception $e) {
            $response['message'] = $e->getMessage();
        }

        return response()->json(['eResponse' => $response]);
    }
}

<?php
namespace App\Http\Controllers\Api;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use App\Http\Controllers\Controller;

class PagosConsContAscController extends Controller
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
                case 'getTipoAseo':
                    $result = DB::select('SELECT * FROM sp_get_tipo_aseo()');
                    $response['success'] = true;
                    $response['data'] = $result;
                    break;
                case 'buscarContratos':
                    $contrato = $params['contrato'] ?? null;
                    $ctrol_aseo = $params['ctrol_aseo'] ?? null;
                    $result = DB::select('SELECT * FROM sp_buscar_contratos_asc(?, ?)', [$contrato, $ctrol_aseo]);
                    $response['success'] = true;
                    $response['data'] = $result;
                    break;
                case 'pagosPorContrato':
                    $control_contrato = $params['control_contrato'] ?? null;
                    $result = DB::select('SELECT * FROM sp_pagos_por_contrato_asc(?)', [$control_contrato]);
                    $response['success'] = true;
                    $response['data'] = $result;
                    break;
                default:
                    $response['message'] = 'Acción no soportada';
            }
        } catch (\Exception $e) {
            $response['message'] = $e->getMessage();
        }

        return response()->json($response);
    }
}

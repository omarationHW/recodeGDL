<?php
namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;

class RptPagosLocalesController extends Controller
{
    /**
     * Endpoint unificado para ejecutar acciones (eRequest/eResponse)
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
                case 'getPagosLocalesReport':
                    $response['data'] = $this->getPagosLocalesReport($params);
                    $response['success'] = true;
                    break;
                case 'getRecaudadoras':
                    $response['data'] = $this->getRecaudadoras();
                    $response['success'] = true;
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
     * Llama al stored procedure para obtener el reporte de pagos locales
     * @param array $params
     * @return array
     */
    private function getPagosLocalesReport($params)
    {
        $validator = Validator::make($params, [
            'fecha_desde' => 'required|date',
            'fecha_hasta' => 'required|date',
            'oficina' => 'required|integer'
        ]);
        if ($validator->fails()) {
            throw new \Exception($validator->errors()->first());
        }
        $result = DB::select('CALL sp_rpt_pagos_locales(?, ?, ?)', [
            $params['fecha_desde'],
            $params['fecha_hasta'],
            $params['oficina']
        ]);
        return $result;
    }

    /**
     * Devuelve la lista de recaudadoras para los combos
     */
    private function getRecaudadoras()
    {
        return DB::table('ta_12_recaudadoras')
            ->select('id_rec', 'recaudadora')
            ->orderBy('id_rec')
            ->get();
    }
}

<?php
namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;

class RptCaratulaDatosController extends Controller
{
    /**
     * Endpoint unificado para eRequest/eResponse
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
                case 'getCaratulaDatos':
                    $response['data'] = $this->getCaratulaDatos($params);
                    $response['success'] = true;
                    break;
                case 'getPagosDetalle':
                    $response['data'] = $this->getPagosDetalle($params);
                    $response['success'] = true;
                    break;
                case 'getAmpliacionPlazo':
                    $response['data'] = $this->getAmpliacionPlazo($params);
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
     * Obtiene los datos principales del contrato/convenio
     */
    private function getCaratulaDatos($params)
    {
        $contrato = $params['contrato'] ?? null;
        if (!$contrato) {
            throw new \Exception('Parámetro contrato requerido');
        }
        $result = DB::select('SELECT * FROM sp_get_caratula_datos(?)', [$contrato]);
        return $result[0] ?? null;
    }

    /**
     * Obtiene el detalle de pagos del contrato
     */
    private function getPagosDetalle($params)
    {
        $contrato = $params['contrato'] ?? null;
        if (!$contrato) {
            throw new \Exception('Parámetro contrato requerido');
        }
        $result = DB::select('SELECT * FROM sp_get_pagos_detalle(?)', [$contrato]);
        return $result;
    }

    /**
     * Obtiene la última ampliación de plazo vigente
     */
    private function getAmpliacionPlazo($params)
    {
        $contrato = $params['contrato'] ?? null;
        if (!$contrato) {
            throw new \Exception('Parámetro contrato requerido');
        }
        $result = DB::select('SELECT * FROM sp_get_ampliacion_plazo(?)', [$contrato]);
        return $result[0] ?? null;
    }
}

<?php
namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;

class CargaPagEnergiaElecController extends Controller
{
    /**
     * Endpoint único para ejecutar acciones (eRequest/eResponse)
     */
    public function execute(Request $request)
    {
        $action = $request->input('action');
        $data = $request->input('data', []);
        $response = [
            'success' => false,
            'message' => '',
            'data' => null
        ];

        try {
            switch ($action) {
                case 'buscarAdeudos':
                    $response['data'] = $this->buscarAdeudos($data);
                    $response['success'] = true;
                    break;
                case 'cargarPagos':
                    $response['data'] = $this->cargarPagos($data);
                    $response['success'] = true;
                    break;
                case 'consultarPagos':
                    $response['data'] = $this->consultarPagos($data);
                    $response['success'] = true;
                    break;
                case 'consultarCajas':
                    $response['data'] = $this->consultarCajas($data);
                    $response['success'] = true;
                    break;
                case 'consultarMercados':
                    $response['data'] = $this->consultarMercados($data);
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
     * Buscar adeudos de energía eléctrica para un local
     */
    private function buscarAdeudos($data)
    {
        $result = DB::select('CALL sp_buscar_adeudos_energia_elec(?, ?, ?, ?, ?, ?)', [
            $data['oficina'],
            $data['mercado'],
            $data['categoria'],
            $data['seccion'],
            $data['local_desde'],
            $data['local_hasta']
        ]);
        return $result;
    }

    /**
     * Cargar pagos de energía eléctrica
     */
    private function cargarPagos($data)
    {
        // data['pagos'] es un array de pagos a cargar
        $pagos = $data['pagos'];
        $usuario = $data['usuario_id'];
        $fecha_pago = $data['fecha_pago'];
        $oficina_pago = $data['oficina_pago'];
        $caja_pago = $data['caja_pago'];
        $operacion_pago = $data['operacion_pago'];
        $result = [];
        DB::beginTransaction();
        try {
            foreach ($pagos as $pago) {
                $spResult = DB::select('CALL sp_cargar_pago_energia_elec(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)', [
                    $pago['id_energia'],
                    $pago['axo'],
                    $pago['periodo'],
                    $fecha_pago,
                    $oficina_pago,
                    $caja_pago,
                    $operacion_pago,
                    $pago['importe'],
                    $pago['cve_consumo'],
                    $pago['cantidad'],
                    $pago['folio'],
                    $usuario
                ]);
                $result[] = $spResult;
            }
            DB::commit();
        } catch (\Exception $e) {
            DB::rollBack();
            throw $e;
        }
        return $result;
    }

    /**
     * Consultar pagos realizados para un local/energía
     */
    private function consultarPagos($data)
    {
        $result = DB::select('CALL sp_consultar_pagos_energia_elec(?)', [
            $data['id_energia']
        ]);
        return $result;
    }

    /**
     * Consultar cajas disponibles para una oficina
     */
    private function consultarCajas($data)
    {
        $result = DB::select('CALL sp_consultar_cajas(?)', [
            $data['oficina']
        ]);
        return $result;
    }

    /**
     * Consultar mercados por oficina
     */
    private function consultarMercados($data)
    {
        $result = DB::select('CALL sp_consultar_mercados(?)', [
            $data['oficina']
        ]);
        return $result;
    }
}

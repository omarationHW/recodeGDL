<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;

class DatosMovimientosController extends Controller
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
                case 'get_movimientos_by_local':
                    $response['data'] = DB::select('CALL sp_get_movimientos_by_local(?)', [$params['id_local']]);
                    $response['success'] = true;
                    break;
                case 'get_clave_movimientos':
                    $response['data'] = DB::select('CALL sp_get_clave_movimientos()');
                    $response['success'] = true;
                    break;
                case 'get_cve_cuotas':
                    $response['data'] = DB::select('CALL sp_get_cve_cuotas()');
                    $response['success'] = true;
                    break;
                case 'get_cuota_by_params':
                    $response['data'] = DB::select('CALL sp_get_cuota_by_params(?,?,?,?)', [
                        $params['vaxo'], $params['vcat'], $params['vsec'], $params['vcuo']
                    ]);
                    $response['success'] = true;
                    break;
                case 'calc_vigencia_descripcion':
                    $response['data'] = $this->calcVigenciaDescripcion($params['vigencia']);
                    $response['success'] = true;
                    break;
                case 'calc_renta':
                    $response['data'] = $this->calcRenta($params);
                    $response['success'] = true;
                    break;
                default:
                    $response['message'] = 'Acción no soportada';
            }
        } catch (\Exception $e) {
            $response['message'] = $e->getMessage();
            Log::error('DatosMovimientosController error: ' . $e->getMessage());
        }
        return response()->json($response);
    }

    /**
     * Lógica para calcular la descripción de vigencia
     */
    private function calcVigenciaDescripcion($vigencia)
    {
        switch ($vigencia) {
            case 'B': return 'BAJA';
            case 'C': return 'BAJA POR ACUERDO';
            case 'D': return 'BAJA ADMINISTRATIVA';
            default: return 'VIGENTE';
        }
    }

    /**
     * Lógica para calcular la renta
     * params: superficie, importe_cuota, seccion, clave_cuota
     */
    private function calcRenta($params)
    {
        $superficie = floatval($params['superficie']);
        $importe_cuota = floatval($params['importe_cuota']);
        $seccion = $params['seccion'];
        $clave_cuota = intval($params['clave_cuota']);
        if ($seccion === 'PS') {
            if ($clave_cuota === 4) {
                return $superficie * $importe_cuota;
            } else {
                return ($importe_cuota * $superficie) * 30;
            }
        } else {
            return $superficie * $importe_cuota;
        }
    }
}

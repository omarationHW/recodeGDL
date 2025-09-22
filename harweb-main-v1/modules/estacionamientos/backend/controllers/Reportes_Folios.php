<?php

namespace App\Http\Controllers\Api;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use App\Http\Controllers\Controller;
use Illuminate\Support\Facades\Log;

class ExecuteController extends Controller
{
    /**
     * Handle unified API requests for Reportes_Folios
     * Endpoint: /api/execute
     *
     * @param  \Illuminate\Http\Request  $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function execute(Request $request)
    {
        $eRequest = $request->input('eRequest');
        $eResponse = [
            'success' => false,
            'data' => null,
            'message' => ''
        ];

        try {
            switch ($eRequest['action']) {
                case 'getInfracciones':
                    $result = DB::select('SELECT num_clave, descripcion FROM ta14_infraccion ORDER BY num_clave');
                    $eResponse['success'] = true;
                    $eResponse['data'] = $result;
                    break;
                case 'getReportesFolios':
                    // params: cve_infraccion, tipo_solicitud, fecha_inicio, fecha_fin
                    $cveInf = $eRequest['params']['cve_infraccion'];
                    $tipoSolicitud = $eRequest['params']['tipo_solicitud'];
                    $fechaInicio = $eRequest['params']['fecha_inicio'];
                    $fechaFin = $eRequest['params']['fecha_fin'];
                    if ($tipoSolicitud < 6) {
                        $result = DB::select('CALL cons14_solicrep(?, ?, ?, ?)', [
                            $cveInf, $tipoSolicitud, $fechaInicio, $fechaFin
                        ]);
                    } else {
                        $result = DB::select('CALL cons14_solicrep_c(?, ?)', [
                            $fechaInicio, $fechaFin
                        ]);
                    }
                    $eResponse['success'] = true;
                    $eResponse['data'] = $result;
                    break;
                case 'getConInfrac':
                    // params: cve_infraccion
                    $cveInf = $eRequest['params']['cve_infraccion'];
                    if ($cveInf == 0) {
                        $result = DB::select('SELECT num_clave, descripcion FROM ta14_infraccion ORDER BY num_clave');
                    } else {
                        $result = DB::select('SELECT num_clave, descripcion FROM ta14_infraccion WHERE num_clave = ?', [$cveInf]);
                    }
                    $eResponse['success'] = true;
                    $eResponse['data'] = $result;
                    break;
                default:
                    $eResponse['message'] = 'Acción no soportada';
            }
        } catch (\Exception $e) {
            Log::error('API Execute Error: ' . $e->getMessage());
            $eResponse['message'] = $e->getMessage();
        }

        return response()->json(['eResponse' => $eResponse]);
    }
}

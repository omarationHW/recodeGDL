<?php

namespace App\Http\Controllers\Api;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use App\Http\Controllers\Controller;

class ExecuteController extends Controller
{
    /**
     * Endpoint unificado para ejecutar acciones del sistema (eRequest/eResponse)
     * POST /api/execute
     *
     * @param Request $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function execute(Request $request)
    {
        $eRequest = $request->input('eRequest');
        $action = $eRequest['action'] ?? null;
        $params = $eRequest['params'] ?? [];
        $user = $request->user();
        $eResponse = [
            'success' => false,
            'data' => null,
            'message' => '',
            'errors' => []
        ];

        try {
            switch ($action) {
                case 'getRptAdeudosConvDiversos':
                    $result = DB::select('SELECT * FROM rpt_adeudos_conv_diversos(:tipo, :subtipo, :letras, :estado, :fecha)', [
                        'tipo' => $params['tipo'],
                        'subtipo' => $params['subtipo'],
                        'letras' => $params['letras'],
                        'estado' => $params['estado'],
                        'fecha' => $params['fecha']
                    ]);
                    $eResponse['success'] = true;
                    $eResponse['data'] = $result;
                    break;
                case 'getRptAdeudosConvDiversosDetalle':
                    $result = DB::select('SELECT * FROM rpt_adeudos_conv_diversos_detalle(:id_conv_diver)', [
                        'id_conv_diver' => $params['id_conv_diver']
                    ]);
                    $eResponse['success'] = true;
                    $eResponse['data'] = $result;
                    break;
                case 'getRptAdeudosConvDiversosResumen':
                    $result = DB::select('SELECT * FROM rpt_adeudos_conv_diversos_resumen(:tipo, :subtipo, :letras, :estado, :fecha)', [
                        'tipo' => $params['tipo'],
                        'subtipo' => $params['subtipo'],
                        'letras' => $params['letras'],
                        'estado' => $params['estado'],
                        'fecha' => $params['fecha']
                    ]);
                    $eResponse['success'] = true;
                    $eResponse['data'] = $result;
                    break;
                // ... otros casos de reportes, catálogos, procesos
                default:
                    $eResponse['message'] = 'Acción no soportada: ' . $action;
                    break;
            }
        } catch (\Exception $ex) {
            $eResponse['success'] = false;
            $eResponse['message'] = 'Error al ejecutar la acción: ' . $ex->getMessage();
            $eResponse['errors'][] = $ex->getTraceAsString();
        }

        return response()->json(['eResponse' => $eResponse]);
    }
}

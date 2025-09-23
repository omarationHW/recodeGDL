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
    public function execute(Request $request)
    {
        $eRequest = $request->input('eRequest');
        $params = $request->input('params', []);
        $eResponse = [
            'success' => false,
            'data' => null,
            'message' => ''
        ];

        try {
            switch ($eRequest) {
                case 'get_dependencias':
                    $data = DB::select('SELECT * FROM c_dependencias ORDER BY descripcion');
                    $eResponse['success'] = true;
                    $eResponse['data'] = $data;
                    break;
                case 'get_infracciones_by_dependencia':
                    $id_dependencia = $params['id_dependencia'] ?? null;
                    if (!$id_dependencia) {
                        throw new \Exception('id_dependencia is required');
                    }
                    $data = DB::select('SELECT * FROM c_infracciones WHERE id_dependencia = ? ORDER BY descripcion', [$id_dependencia]);
                    $eResponse['success'] = true;
                    $eResponse['data'] = $data;
                    break;
                case 'get_multas_report':
                    // Call stored procedure with all filters
                    $filters = [
                        'id_dependencia' => $params['id_dependencia'] ?? null,
                        'id_infraccion' => $params['id_infraccion'] ?? null,
                        'contribuyente' => $params['contribuyente'] ?? null,
                        'domicilio' => $params['domicilio'] ?? null,
                        'fecha_tipo' => $params['fecha_tipo'] ?? 0, // 0: Todos, 1: Fecha, 2: Rango, 3: Año
                        'fecha1' => $params['fecha1'] ?? null,
                        'fecha2' => $params['fecha2'] ?? null,
                        'anio' => $params['anio'] ?? null,
                        'estatus' => $params['estatus'] ?? 0 // 0: Todos, 1: Vigente, 2: Pagado, 3: Cancelado
                    ];
                    $sql = 'SELECT * FROM report_multas(
                        :id_dependencia, :id_infraccion, :contribuyente, :domicilio, :fecha_tipo, :fecha1, :fecha2, :anio, :estatus
                    )';
                    $data = DB::select($sql, $filters);
                    $eResponse['success'] = true;
                    $eResponse['data'] = $data;
                    break;
                default:
                    $eResponse['message'] = 'Unknown eRequest';
            }
        } catch (\Exception $e) {
            $eResponse['message'] = $e->getMessage();
        }

        return response()->json(['eResponse' => $eResponse]);
    }
}

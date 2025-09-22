<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;

class GirosVigentesCteXgiroController extends Controller
{
    /**
     * Endpoint único para ejecutar acciones vía eRequest/eResponse
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
                case 'getClasificaciones':
                    $response['data'] = $this->getClasificaciones();
                    $response['success'] = true;
                    break;
                case 'getReporteGiros':
                    $response['data'] = $this->getReporteGiros($params);
                    $response['success'] = true;
                    break;
                case 'printReporteGiros':
                    $response['data'] = $this->printReporteGiros($params);
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
     * Devuelve las clasificaciones posibles
     */
    private function getClasificaciones()
    {
        return [
            ['value' => 0, 'label' => 'Todas'],
            ['value' => 1, 'label' => 'Solo A'],
            ['value' => 2, 'label' => 'Solo B'],
            ['value' => 3, 'label' => 'Solo C'],
            ['value' => 4, 'label' => 'Solo D']
        ];
    }

    /**
     * Obtiene el reporte de giros vigentes/cancelados agrupados por giro
     * params: {
     *   year: int|null,
     *   date_from: string|null,
     *   date_to: string|null,
     *   vigente: 'V'|'C',
     *   clasificacion: 'A'|'B'|'C'|'D'|null,
     *   order_by: 'cuantos'|'descripcion'
     * }
     */
    private function getReporteGiros($params)
    {
        $vigente = isset($params['vigente']) && $params['vigente'] === 'C' ? 'C' : 'V';
        $clasificacion = isset($params['clasificacion']) ? $params['clasificacion'] : null;
        $order_by = isset($params['order_by']) && $params['order_by'] === 'descripcion' ? 'g.descripcion' : 'cuantos DESC';
        $year = isset($params['year']) ? intval($params['year']) : null;
        $date_from = isset($params['date_from']) ? $params['date_from'] : null;
        $date_to = isset($params['date_to']) ? $params['date_to'] : null;

        $sql = 'SELECT COUNT(l.licencia) AS cuantos, l.id_giro, g.cod_giro, g.descripcion
                FROM licencias l
                JOIN c_giros g ON g.id_giro = l.id_giro
                WHERE l.vigente = :vigente';
        $bindings = ['vigente' => $vigente];

        if ($year) {
            if ($vigente === 'V') {
                $sql .= ' AND l.fecha_otorgamiento >= :fecha_ini AND l.fecha_otorgamiento <= :fecha_fin';
                $bindings['fecha_ini'] = $year . '-01-01';
                $bindings['fecha_fin'] = $year . '-12-31';
            } else {
                $sql .= ' AND l.fecha_baja >= :fecha_ini AND l.fecha_baja <= :fecha_fin';
                $bindings['fecha_ini'] = $year . '-01-01';
                $bindings['fecha_fin'] = $year . '-12-31';
            }
        } else if ($date_from && $date_to) {
            if ($vigente === 'V') {
                $sql .= ' AND l.fecha_otorgamiento >= :fecha_ini AND l.fecha_otorgamiento <= :fecha_fin';
            } else {
                $sql .= ' AND l.fecha_baja >= :fecha_ini AND l.fecha_baja <= :fecha_fin';
            }
            $bindings['fecha_ini'] = $date_from;
            $bindings['fecha_fin'] = $date_to;
        }

        if ($clasificacion) {
            $sql .= ' AND g.clasificacion = :clasificacion';
            $bindings['clasificacion'] = $clasificacion;
        }

        $sql .= ' GROUP BY l.id_giro, g.cod_giro, g.descripcion';
        $sql .= ' ORDER BY ' . $order_by;

        return DB::select($sql, $bindings);
    }

    /**
     * Simula la impresión del reporte (puede devolver un PDF generado o similar)
     */
    private function printReporteGiros($params)
    {
        // Aquí se puede implementar la generación de PDF o similar
        // Por ahora, solo retorna los datos del reporte
        return $this->getReporteGiros($params);
    }
}

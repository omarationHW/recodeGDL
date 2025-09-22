<?php
namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\Validator;

class ConsMulPagosController extends Controller
{
    /**
     * Endpoint único para ejecutar acciones sobre consmulpagos.
     * Entrada: {
     *   "eRequest": {
     *     "action": "list|filter|detail|report",
     *     "params": { ... }
     *   }
     * }
     * Salida: {
     *   "eResponse": { ... }
     * }
     */
    public function execute(Request $request)
    {
        $input = $request->input('eRequest');
        $action = $input['action'] ?? null;
        $params = $input['params'] ?? [];
        $result = null;
        $error = null;
        try {
            switch ($action) {
                case 'list':
                    $result = $this->listPagos($params);
                    break;
                case 'filter':
                    $result = $this->filterPagos($params);
                    break;
                case 'detail':
                    $result = $this->detailPago($params);
                    break;
                case 'report':
                    $result = $this->reportPagos($params);
                    break;
                default:
                    $error = 'Acción no soportada';
            }
        } catch (\Exception $ex) {
            Log::error($ex);
            $error = $ex->getMessage();
        }
        return response()->json([
            'eResponse' => [
                'result' => $result,
                'error' => $error
            ]
        ]);
    }

    /**
     * Listar todos los pagos de multas
     */
    private function listPagos($params)
    {
        $sql = "SELECT p.cvepago, p.fecha, p.recaud, p.caja, p.folio, p.importe, p.cajero, m.contribuyente, m.domicilio, m.num_acta, m.axo_acta, m.id_dependencia FROM pagos p INNER JOIN multas m ON p.cvepago = m.cvepago WHERE p.cveconcepto = 6 ORDER BY p.fecha DESC, p.recaud, p.caja, p.folio";
        $pagos = DB::select($sql);
        return $pagos;
    }

    /**
     * Filtrar pagos por fecha, recaudadora, caja, folio, nombre, num_acta
     */
    private function filterPagos($params)
    {
        $where = [];
        $bindings = [];
        if (!empty($params['fecha'])) {
            $where[] = 'p.fecha = ?';
            $bindings[] = $params['fecha'];
        }
        if (!empty($params['recaud'])) {
            $where[] = 'p.recaud = ?';
            $bindings[] = $params['recaud'];
        }
        if (!empty($params['caja'])) {
            $where[] = 'p.caja = ?';
            $bindings[] = $params['caja'];
        }
        if (!empty($params['folio'])) {
            $where[] = 'p.folio = ?';
            $bindings[] = $params['folio'];
        }
        if (!empty($params['nombre'])) {
            $where[] = 'm.contribuyente ILIKE ?';
            $bindings[] = '%' . $params['nombre'] . '%';
        }
        if (!empty($params['num_acta'])) {
            $where[] = 'm.num_acta = ?';
            $bindings[] = $params['num_acta'];
        }
        $sql = "SELECT p.cvepago, p.fecha, p.recaud, p.caja, p.folio, p.importe, p.cajero, m.contribuyente, m.domicilio, m.num_acta, m.axo_acta, m.id_dependencia FROM pagos p INNER JOIN multas m ON p.cvepago = m.cvepago WHERE p.cveconcepto = 6";
        if (count($where) > 0) {
            $sql .= ' AND ' . implode(' AND ', $where);
        }
        $sql .= ' ORDER BY p.fecha DESC, p.recaud, p.caja, p.folio';
        $pagos = DB::select($sql, $bindings);
        return $pagos;
    }

    /**
     * Detalle de un pago específico
     */
    private function detailPago($params)
    {
        $sql = "SELECT p.*, m.* FROM pagos p INNER JOIN multas m ON p.cvepago = m.cvepago WHERE p.cvepago = ?";
        $detalle = DB::select($sql, [$params['cvepago'] ?? 0]);
        return $detalle[0] ?? null;
    }

    /**
     * Reporte de pagos de multas en un rango de fechas
     */
    private function reportPagos($params)
    {
        $sql = "SELECT p.fecha, COUNT(*) as total_pagos, SUM(p.importe) as total_importe FROM pagos p WHERE p.cveconcepto = 6 AND p.fecha BETWEEN ? AND ? GROUP BY p.fecha ORDER BY p.fecha DESC";
        $result = DB::select($sql, [$params['fecha_ini'], $params['fecha_fin']]);
        return $result;
    }
}

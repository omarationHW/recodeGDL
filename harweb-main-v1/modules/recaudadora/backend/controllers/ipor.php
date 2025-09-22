<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;

class IporController extends Controller
{
    /**
     * Endpoint único para ejecutar acciones del formulario ipor
     * Entrada: {
     *   "eRequest": {
     *     "action": "string", // e.g. 'list', 'assign', 'print', 'filter', etc.
     *     "params": { ... } // parámetros según acción
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
                case 'list_controls':
                    $result = DB::select('SELECT * FROM ctrl_reqpredial ORDER BY fecha_emision, folio_inicio');
                    break;
                case 'filter_controls':
                    $query = 'SELECT * FROM ctrl_reqpredial WHERE 1=1';
                    $bindings = [];
                    if (!empty($params['recaud'])) {
                        $query .= ' AND recaud = ?';
                        $bindings[] = $params['recaud'];
                    }
                    if (!empty($params['fecha_emision'])) {
                        $query .= ' AND fecha_emision = ?';
                        $bindings[] = $params['fecha_emision'];
                    }
                    if (!empty($params['ult_impreso_lt_folio_final'])) {
                        $query .= ' AND ult_impreso < folio_final';
                    }
                    $query .= ' ORDER BY fecha_emision, folio_inicio';
                    $result = DB::select($query, $bindings);
                    break;
                case 'get_requerimientos':
                    $result = DB::select('SELECT * FROM requerimientos.get_requerimientos(?, ?, ?, ?)', [
                        $params['axoreq'],
                        $params['recaud'],
                        $params['folioini'],
                        $params['foliofin']
                    ]);
                    break;
                case 'assign_requerimientos':
                    $result = DB::select('SELECT * FROM requerimientos.assign_requerimientos(?, ?, ?, ?, ?, ?)', [
                        $params['tipo'],
                        $params['ejecutor_id'],
                        $params['fecha'],
                        $params['recaud'],
                        $params['folioini'],
                        $params['foliofin']
                    ]);
                    break;
                case 'print_requerimientos':
                    $result = DB::select('SELECT * FROM requerimientos.print_requerimientos(?, ?, ?, ?)', [
                        $params['fecha'],
                        $params['recaud'],
                        $params['tipo_impresion'],
                        $params['ejecutor_id']
                    ]);
                    break;
                case 'get_ejecutores':
                    $result = DB::select('SELECT * FROM requerimientos.get_ejecutores(?, ?)', [
                        $params['fecha'],
                        $params['recaud']
                    ]);
                    break;
                case 'get_multas_grid':
                    $result = DB::select('SELECT * FROM requerimientos.get_multas_grid(?, ?, ?, ?)', [
                        $params['tipo'],
                        $params['recaud'],
                        $params['folioini'],
                        $params['foliofin']
                    ]);
                    break;
                case 'get_licencias_grid':
                    $result = DB::select('SELECT * FROM requerimientos.get_licencias_grid(?, ?, ?, ?)', [
                        $params['tipo'],
                        $params['recaud'],
                        $params['folioini'],
                        $params['foliofin']
                    ]);
                    break;
                case 'get_anuncios_grid':
                    $result = DB::select('SELECT * FROM requerimientos.get_anuncios_grid(?, ?, ?, ?)', [
                        $params['tipo'],
                        $params['recaud'],
                        $params['folioini'],
                        $params['foliofin']
                    ]);
                    break;
                case 'get_diferencias_grid':
                    $result = DB::select('SELECT * FROM requerimientos.get_diferencias_grid(?, ?, ?, ?)', [
                        $params['tipo'],
                        $params['recaud'],
                        $params['folioini'],
                        $params['foliofin']
                    ]);
                    break;
                case 'get_ejecutor_detalle':
                    $result = DB::select('SELECT * FROM requerimientos.get_ejecutor_detalle(?)', [
                        $params['ejecutor_id']
                    ]);
                    break;
                default:
                    $error = 'Acción no soportada: ' . $action;
            }
        } catch (\Exception $e) {
            $error = $e->getMessage();
        }

        return response()->json([
            'eResponse' => [
                'result' => $result,
                'error' => $error
            ]
        ]);
    }
}

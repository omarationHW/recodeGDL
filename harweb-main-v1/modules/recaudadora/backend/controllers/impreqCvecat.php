<?php
namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;

class ImpreqCvecatController extends Controller
{
    /**
     * Endpoint único para ejecutar acciones del formulario impreqCvecat
     * Entrada: {
     *   "eRequest": {
     *     "action": "listar", "params": {...}
     *   }
     * }
     * Salida: {
     *   "eResponse": {...}
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
                case 'listar':
                    $result = $this->listar($params);
                    break;
                case 'filtrar':
                    $result = $this->filtrar($params);
                    break;
                case 'asignar':
                    $result = $this->asignar($params);
                    break;
                case 'imprimir':
                    $result = $this->imprimir($params);
                    break;
                case 'ejecutores':
                    $result = $this->ejecutores($params);
                    break;
                case 'max_impresiones':
                    $result = $this->maxImpresiones($params);
                    break;
                case 'reporte':
                    $result = $this->reporte($params);
                    break;
                default:
                    $error = 'Acción no soportada';
            }
        } catch (\Exception $ex) {
            $error = $ex->getMessage();
        }

        return response()->json([
            'eResponse' => $error ? ['error' => $error] : $result
        ]);
    }

    private function listar($params)
    {
        // Listar requerimientos por rango de folios y recaudadora
        $recaud = $params['recaud'] ?? null;
        $folioini = $params['folioini'] ?? null;
        $foliofin = $params['foliofin'] ?? null;
        $fecha = $params['fecha'] ?? null;
        $tipo = $params['tipo'] ?? 'V';
        $query = "SELECT * FROM reqpredial WHERE recaud = ? AND folioreq BETWEEN ? AND ? AND vigencia = ?";
        $data = DB::select($query, [$recaud, $folioini, $foliofin, $tipo]);
        return ['data' => $data];
    }

    private function filtrar($params)
    {
        // Filtrar control de requerimientos por recaudadora y/o fecha
        $recaud = $params['recaud'] ?? null;
        $fecha = $params['fecha'] ?? null;
        $where = [];
        $bindings = [];
        if ($recaud) {
            $where[] = 'recaud = ?';
            $bindings[] = $recaud;
        }
        if ($fecha) {
            $where[] = 'fecha_emision = ?';
            $bindings[] = $fecha;
        }
        $sql = 'SELECT * FROM ctrl_reqpredial';
        if ($where) {
            $sql .= ' WHERE ' . implode(' AND ', $where);
        }
        $sql .= ' ORDER BY fecha_emision, folio_inicio';
        $data = DB::select($sql, $bindings);
        return ['data' => $data];
    }

    private function asignar($params)
    {
        // Asignar requerimientos a ejecutores
        $recaud = $params['recaud'];
        $folioini = $params['folioini'];
        $foliofin = $params['foliofin'];
        $ejecutor = $params['ejecutor'];
        $fecha = $params['fecha'];
        $usuario = $params['usuario'];
        $result = DB::select('SELECT * FROM sp_asignar_requerimientos(?,?,?,?,?)', [
            $recaud, $folioini, $foliofin, $ejecutor, $fecha
        ]);
        return ['result' => $result];
    }

    private function imprimir($params)
    {
        // Marcar como impresos los requerimientos seleccionados
        $recaud = $params['recaud'];
        $folioini = $params['folioini'];
        $foliofin = $params['foliofin'];
        $usuario = $params['usuario'];
        $result = DB::select('SELECT * FROM sp_marcar_impresos(?,?,?,?)', [
            $recaud, $folioini, $foliofin, $usuario
        ]);
        return ['result' => $result];
    }

    private function ejecutores($params)
    {
        // Listar ejecutores disponibles por recaudadora
        $recaud = $params['recaud'];
        $fecha = $params['fecha'];
        $data = DB::select('SELECT * FROM sp_lista_ejecutores(?,?)', [$recaud, $fecha]);
        return ['data' => $data];
    }

    private function maxImpresiones($params)
    {
        // Calcular máximo de impresiones posibles
        $recaud = $params['recaud'];
        $result = DB::select('SELECT * FROM sp_max_impresiones(?)', [$recaud]);
        return ['max' => $result[0]->max ?? 0];
    }

    private function reporte($params)
    {
        // Generar reporte PDF (dummy, solo retorna datos)
        $recaud = $params['recaud'];
        $folioini = $params['folioini'];
        $foliofin = $params['foliofin'];
        $data = DB::select('SELECT * FROM reqpredial WHERE recaud = ? AND folioreq BETWEEN ? AND ?', [$recaud, $folioini, $foliofin]);
        // Aquí se llamaría a un servicio de generación de PDF
        return ['data' => $data, 'pdf_url' => '/storage/reporte.pdf'];
    }
}

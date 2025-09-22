<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;

class ConsDescController extends Controller
{
    /**
     * Endpoint único para ejecutar acciones sobre descuentos prediales
     * Entrada: eRequest con action, params
     * Salida: eResponse con status, data, message
     */
    public function execute(Request $request)
    {
        $input = $request->all();
        $action = $input['action'] ?? null;
        $params = $input['params'] ?? [];
        $response = [
            'status' => 'error',
            'data' => null,
            'message' => 'Acción no válida'
        ];

        try {
            switch ($action) {
                case 'list':
                    $response = $this->listDescuentos($params);
                    break;
                case 'search':
                    $response = $this->searchDescuentos($params);
                    break;
                case 'instituciones':
                    $response = $this->listInstituciones();
                    break;
                case 'detalle':
                    $response = $this->detalleDescuento($params);
                    break;
                default:
                    $response['message'] = 'Acción no soportada';
            }
        } catch (\Exception $e) {
            $response['status'] = 'error';
            $response['message'] = $e->getMessage();
        }
        return response()->json(['eResponse' => $response]);
    }

    /**
     * Listado general de descuentos
     */
    private function listDescuentos($params)
    {
        $sql = 'SELECT a.recaud, a.urbrus, a.cuenta, d.*, c.descripcion
                FROM descpred d
                JOIN convcta a ON d.cvecuenta = a.cvecuenta
                JOIN c_descpred c ON c.cvedescuento = d.cvedescuento';
        $where = [];
        $bindings = [];
        if (!empty($params['recaud'])) {
            $where[] = 'a.recaud = ?';
            $bindings[] = $params['recaud'];
        }
        if (!empty($params['cuenta'])) {
            $where[] = 'a.cuenta = ?';
            $bindings[] = $params['cuenta'];
        }
        if (!empty($params['propi'])) {
            $where[] = 'd.propie ILIKE ?';
            $bindings[] = '%' . $params['propi'] . '%';
        }
        if (!empty($where)) {
            $sql .= ' WHERE ' . implode(' AND ', $where);
        }
        $sql .= ' ORDER BY d.propie';
        $data = DB::select($sql, $bindings);
        return [
            'status' => 'success',
            'data' => $data,
            'message' => 'Listado de descuentos obtenido'
        ];
    }

    /**
     * Búsqueda avanzada de descuentos
     */
    private function searchDescuentos($params)
    {
        $sql = 'SELECT a.recaud, a.urbrus, a.cuenta, d.*, c.descripcion
                FROM descpred d
                JOIN convcta a ON d.cvecuenta = a.cvecuenta
                JOIN c_descpred c ON c.cvedescuento = d.cvedescuento';
        $where = [];
        $bindings = [];
        if (!empty($params['propi'])) {
            $where[] = 'd.propie ILIKE ?';
            $bindings[] = '%' . $params['propi'] . '%';
        }
        if (!empty($params['foliodesc'])) {
            $where[] = 'd.foliodesc = ?';
            $bindings[] = $params['foliodesc'];
        }
        if (!empty($params['recaud'])) {
            $where[] = 'd.recaud = ?';
            $bindings[] = $params['recaud'];
        }
        if (!empty($params['identificacion'])) {
            $where[] = 'd.identificacion ILIKE ?';
            $bindings[] = '%' . $params['identificacion'] . '%';
        }
        if (!empty($params['solicitante'])) {
            $where[] = 'd.solicitante ILIKE ?';
            $bindings[] = '%' . $params['solicitante'] . '%';
        }
        if (!empty($params['institucion'])) {
            $where[] = 'd.institucion = ?';
            $bindings[] = $params['institucion'];
        }
        if (!empty($where)) {
            $sql .= ' WHERE ' . implode(' AND ', $where);
        }
        $sql .= ' ORDER BY d.propie';
        $data = DB::select($sql, $bindings);
        return [
            'status' => 'success',
            'data' => $data,
            'message' => 'Resultados de búsqueda obtenidos'
        ];
    }

    /**
     * Listado de instituciones
     */
    private function listInstituciones()
    {
        $data = DB::select('SELECT cveinst, institucion FROM c_instituciones ORDER BY institucion');
        return [
            'status' => 'success',
            'data' => $data,
            'message' => 'Listado de instituciones obtenido'
        ];
    }

    /**
     * Detalle de un descuento
     */
    private function detalleDescuento($params)
    {
        $id = $params['id'] ?? null;
        if (!$id) {
            return [
                'status' => 'error',
                'data' => null,
                'message' => 'ID requerido'
            ];
        }
        $data = DB::selectOne('SELECT d.*, c.descripcion, a.recaud, a.urbrus, a.cuenta
            FROM descpred d
            JOIN convcta a ON d.cvecuenta = a.cvecuenta
            JOIN c_descpred c ON c.cvedescuento = d.cvedescuento
            WHERE d.foliodesc = ?', [$id]);
        if (!$data) {
            return [
                'status' => 'error',
                'data' => null,
                'message' => 'Descuento no encontrado'
            ];
        }
        return [
            'status' => 'success',
            'data' => $data,
            'message' => 'Detalle de descuento obtenido'
        ];
    }
}

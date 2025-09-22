<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;

class BloqueoDomiciliosHistoricoController extends Controller
{
    /**
     * Endpoint único para manejar todas las operaciones (API Unificada)
     * Entrada: {
     *   "eRequest": {
     *     "action": "listar|filtrar|exportar|imprimir|detalle",
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
        $action = $input['action'] ?? '';
        $params = $input['params'] ?? [];
        $response = [];

        switch ($action) {
            case 'listar':
                $response = $this->listar($params);
                break;
            case 'filtrar':
                $response = $this->filtrar($params);
                break;
            case 'exportar':
                $response = $this->exportar($params);
                break;
            case 'imprimir':
                $response = $this->imprimir($params);
                break;
            case 'detalle':
                $response = $this->detalle($params);
                break;
            default:
                $response = [
                    'error' => 'Acción no soportada',
                    'supported_actions' => ['listar', 'filtrar', 'exportar', 'imprimir', 'detalle']
                ];
        }
        return response()->json(['eResponse' => $response]);
    }

    private function listar($params)
    {
        $order = $params['order'] ?? 'calle,num_ext';
        $sql = "SELECT * FROM h_bloqueo_dom ORDER BY $order";
        $rows = DB::select($sql);
        return [
            'rows' => $rows,
            'order' => $order
        ];
    }

    private function filtrar($params)
    {
        $campo = $params['campo'] ?? null;
        $valor = $params['valor'] ?? null;
        $order = $params['order'] ?? 'calle,num_ext';
        $where = '';
        $bindings = [];
        if ($campo && $valor) {
            $where = "WHERE $campo ILIKE ?";
            $bindings[] = "%$valor%";
        }
        $sql = "SELECT * FROM h_bloqueo_dom $where ORDER BY $order";
        $rows = DB::select($sql, $bindings);
        return [
            'rows' => $rows,
            'filter' => [$campo => $valor],
            'order' => $order
        ];
    }

    private function exportar($params)
    {
        // Exporta a Excel (devuelve datos en formato para frontend)
        $order = $params['order'] ?? 'calle,num_ext';
        $sql = "SELECT * FROM h_bloqueo_dom ORDER BY $order";
        $rows = DB::select($sql);
        // El frontend debe generar el archivo Excel
        return [
            'rows' => $rows,
            'format' => 'excel',
            'filename' => 'domicilios_desbloqueados_' . date('Ymd_His') . '.xlsx'
        ];
    }

    private function imprimir($params)
    {
        // Devuelve los datos para impresión (el frontend genera el PDF)
        $order = $params['order'] ?? 'calle,num_ext';
        $sql = "SELECT * FROM h_bloqueo_dom ORDER BY $order";
        $rows = DB::select($sql);
        return [
            'rows' => $rows,
            'format' => 'pdf',
            'filename' => 'listado_domicilios_desbloqueados_' . date('Ymd_His') . '.pdf'
        ];
    }

    private function detalle($params)
    {
        $id = $params['id'] ?? null;
        if (!$id) {
            return ['error' => 'ID requerido'];
        }
        $row = DB::selectOne("SELECT * FROM h_bloqueo_dom WHERE id = ?", [$id]);
        return [
            'row' => $row
        ];
    }
}

<?php
namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;

class AuxRepController extends Controller
{
    /**
     * Endpoint unificado para ejecutar acciones del formulario AuxRep
     * Entrada: {
     *   "eRequest": {
     *     "action": "getPadron|getTablas|getEtiquetas|getVigencias|printPadron",
     *     "params": { ... }
     *   }
     * }
     * Salida: {
     *   "eResponse": { ... }
     * }
     */
    public function execute(Request $request)
    {
        $action = $request->input('eRequest.action');
        $params = $request->input('eRequest.params', []);
        $response = [];
        try {
            switch ($action) {
                case 'getPadron':
                    $response = $this->getPadron($params);
                    break;
                case 'getTablas':
                    $response = $this->getTablas($params);
                    break;
                case 'getEtiquetas':
                    $response = $this->getEtiquetas($params);
                    break;
                case 'getVigencias':
                    $response = $this->getVigencias($params);
                    break;
                case 'printPadron':
                    $response = $this->printPadron($params);
                    break;
                default:
                    return response()->json(['eResponse' => ['error' => 'Acción no soportada']], 400);
            }
            return response()->json(['eResponse' => $response]);
        } catch (\Exception $e) {
            Log::error('AuxRepController error: ' . $e->getMessage());
            return response()->json(['eResponse' => ['error' => $e->getMessage()]], 500);
        }
    }

    private function getPadron($params)
    {
        $par_tabla = $params['par_tabla'] ?? null;
        $par_vigencia = $params['par_vigencia'] ?? 'TODOS';
        $result = DB::select('CALL sp34_padron(?, ?)', [$par_tabla, $par_vigencia]);
        return ['padron' => $result];
    }

    private function getTablas($params)
    {
        $par_tab = $params['par_tab'] ?? null;
        $result = DB::select('SELECT cve_tab, nombre, descripcion FROM t34_tablas a JOIN t34_unidades b ON a.cve_tab = b.cve_tab WHERE a.cve_tab = ? GROUP BY a.cve_tab, a.nombre, b.descripcion ORDER BY a.cve_tab, a.nombre, b.descripcion', [$par_tab]);
        return ['tablas' => $result];
    }

    private function getEtiquetas($params)
    {
        $par_tab = $params['par_tab'] ?? null;
        $result = DB::select('SELECT * FROM t34_etiq WHERE cve_tab = ?', [$par_tab]);
        return ['etiquetas' => $result];
    }

    private function getVigencias($params)
    {
        $par_tab = $params['par_tab'] ?? null;
        $result = DB::select('SELECT DISTINCT b.descripcion FROM t34_datos a, t34_status b WHERE a.cve_tab = ? AND b.id_34_stat = a.id_stat GROUP BY b.descripcion ORDER BY b.descripcion', [$par_tab]);
        return ['vigencias' => $result];
    }

    private function printPadron($params)
    {
        // Simulación de impresión: retorna los datos del padrón para impresión
        $padron = $this->getPadron($params);
        // Aquí se podría generar un PDF o similar, pero para API solo retorna datos
        return ['printData' => $padron['padron']];
    }
}

<?php
namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;

class MenuController extends Controller
{
    /**
     * Endpoint único para ejecutar acciones del menú (catálogos, consultas, reportes, procesos).
     * Entrada: {
     *   "eRequest": {
     *     "action": "string", // ejemplo: 'catalog.list', 'catalog.create', 'report.generate', etc.
     *     "params": { ... } // parámetros específicos de la acción
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
                case 'catalog.list.unidades':
                    $result = DB::select('SELECT * FROM sp_cat_unidades_list(:ejercicio)', [
                        'ejercicio' => $params['ejercicio'] ?? date('Y')
                    ]);
                    break;
                case 'catalog.create.unidad':
                    $result = DB::select('SELECT * FROM sp_cat_unidades_create(:ejercicio, :clave, :descripcion, :costo_unidad, :costo_exed)', [
                        'ejercicio' => $params['ejercicio'],
                        'clave' => $params['clave'],
                        'descripcion' => $params['descripcion'],
                        'costo_unidad' => $params['costo_unidad'],
                        'costo_exed' => $params['costo_exed']
                    ]);
                    break;
                case 'catalog.update.unidad':
                    $result = DB::select('SELECT * FROM sp_cat_unidades_update(:id, :descripcion, :costo_unidad, :costo_exed)', [
                        'id' => $params['id'],
                        'descripcion' => $params['descripcion'],
                        'costo_unidad' => $params['costo_unidad'],
                        'costo_exed' => $params['costo_exed']
                    ]);
                    break;
                case 'catalog.delete.unidad':
                    $result = DB::select('SELECT * FROM sp_cat_unidades_delete(:id)', [
                        'id' => $params['id']
                    ]);
                    break;
                case 'catalog.list.tipos_aseo':
                    $result = DB::select('SELECT * FROM sp_cat_tipos_aseo_list()');
                    break;
                case 'catalog.list.zonas':
                    $result = DB::select('SELECT * FROM sp_cat_zonas_list()');
                    break;
                case 'catalog.list.empresas':
                    $result = DB::select('SELECT * FROM sp_cat_empresas_list()');
                    break;
                case 'catalog.list.tipos_emp':
                    $result = DB::select('SELECT * FROM sp_cat_tipos_emp_list()');
                    break;
                case 'catalog.list.recargos':
                    $result = DB::select('SELECT * FROM sp_cat_recargos_list(:ejercicio)', [
                        'ejercicio' => $params['ejercicio'] ?? date('Y')
                    ]);
                    break;
                case 'catalog.list.gastos':
                    $result = DB::select('SELECT * FROM sp_cat_gastos_list()');
                    break;
                case 'catalog.list.operaciones':
                    $result = DB::select('SELECT * FROM sp_cat_operaciones_list()');
                    break;
                case 'report.unidades.export':
                    $result = DB::select('SELECT * FROM sp_rep_unidades_export(:ejercicio, :order_by)', [
                        'ejercicio' => $params['ejercicio'],
                        'order_by' => $params['order_by']
                    ]);
                    break;
                // ... otros casos de reportes, procesos, etc.
                default:
                    $error = 'Acción no soportada: ' . $action;
            }
        } catch (\Exception $ex) {
            $error = $ex->getMessage();
        }

        return response()->json([
            'eResponse' => [
                'result' => $result,
                'error' => $error
            ]
        ]);
    }
}

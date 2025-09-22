<?php

namespace App\Http\Controllers\Api;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use App\Http\Controllers\Controller;

class RubrosController extends Controller
{
    /**
     * Endpoint unificado para eRequest/eResponse
     * POST /api/execute
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
                case 'getRubros':
                    $rubros = DB::select('SELECT * FROM t34_tablas WHERE auto_tab > 0 ORDER BY auto_tab');
                    $response['success'] = true;
                    $response['data'] = $rubros;
                    break;
                case 'getStatusCatalog':
                    $status = DB::select('SELECT a.cve_stat, a.descripcion FROM t34_status a, t34_tablas b WHERE b.cve_tab = a.cve_tab AND b.auto_tab > 0 GROUP BY a.cve_stat, a.descripcion ORDER BY a.cve_stat, a.descripcion');
                    $response['success'] = true;
                    $response['data'] = $status;
                    break;
                case 'createRubro':
                    // params: nombre, status_selected (array de cve_stat)
                    $nombre = $params['nombre'] ?? null;
                    $status_selected = $params['status_selected'] ?? [];
                    if (!$nombre || empty($status_selected)) {
                        throw new \Exception('Nombre y status seleccionados son requeridos.');
                    }
                    // Llamar SP para crear rubro
                    $spResult = DB::select('SELECT * FROM ins34_rubro_01(?)', [$nombre]);
                    $spStatus = $spResult[0]->status ?? -1;
                    $spConcepto = $spResult[0]->concepto_status ?? '';
                    if ($spStatus < 0) {
                        throw new \Exception("$spStatus $spConcepto");
                    }
                    $id_tabla = $spStatus;
                    // Insertar status seleccionados
                    foreach ($status_selected as $status) {
                        $cve_stat = $status['cve_stat'];
                        $descripcion = $status['descripcion'];
                        DB::statement('CALL ins34_status(?, ?, ?)', [$id_tabla, $cve_stat, $descripcion]);
                    }
                    $response['success'] = true;
                    $response['message'] = 'Rubro creado correctamente';
                    break;
                default:
                    $response['message'] = 'Acción no soportada';
            }
        } catch (\Exception $e) {
            $response['success'] = false;
            $response['message'] = $e->getMessage();
        }
        return response()->json($response);
    }
}

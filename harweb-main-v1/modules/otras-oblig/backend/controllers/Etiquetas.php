<?php

namespace App\Http\Controllers\Api;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use App\Http\Controllers\Controller;

class EtiquetasController extends Controller
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
                case 'get_tablas':
                    $data = DB::select('SELECT * FROM t34_tablas WHERE auto_tab > 0 ORDER BY auto_tab');
                    $response['success'] = true;
                    $response['data'] = $data;
                    break;
                case 'get_etiquetas':
                    $cve_tab = $params['cve_tab'] ?? null;
                    if (!$cve_tab) throw new \Exception('cve_tab requerido');
                    $data = DB::select('SELECT * FROM t34_etiq WHERE cve_tab = ?', [$cve_tab]);
                    $response['success'] = true;
                    $response['data'] = $data;
                    break;
                case 'update_etiquetas':
                    $cve_tab = $params['cve_tab'] ?? null;
                    if (!$cve_tab) throw new \Exception('cve_tab requerido');
                    $fields = [
                        'abreviatura', 'etiq_control', 'concesionario', 'ubicacion', 'superficie',
                        'fecha_inicio', 'fecha_fin', 'recaudadora', 'sector', 'zona', 'licencia',
                        'fecha_cancelacion', 'unidad', 'categoria', 'seccion', 'bloque',
                        'nombre_comercial', 'lugar', 'obs'
                    ];
                    $args = [];
                    foreach ($fields as $f) {
                        $args[$f] = $params[$f] ?? ' ';
                    }
                    $result = DB::statement('CALL sp_update_t34_etiq(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)', [
                        $args['abreviatura'],
                        $args['etiq_control'],
                        $args['concesionario'],
                        $args['ubicacion'],
                        $args['superficie'],
                        $args['fecha_inicio'],
                        $args['fecha_fin'],
                        $args['recaudadora'],
                        $args['sector'],
                        $args['zona'],
                        $args['licencia'],
                        $args['fecha_cancelacion'],
                        $args['unidad'],
                        $args['categoria'],
                        $args['seccion'],
                        $args['bloque'],
                        $args['nombre_comercial'],
                        $args['lugar'],
                        $args['obs'],
                        $cve_tab
                    ]);
                    $response['success'] = true;
                    $response['message'] = 'Etiquetas actualizadas correctamente';
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

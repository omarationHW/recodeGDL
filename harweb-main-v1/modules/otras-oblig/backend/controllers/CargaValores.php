<?php

namespace App\Http\Controllers\Api;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use App\Http\Controllers\Controller;

class ExecuteController extends Controller
{
    /**
     * Handle unified API requests (eRequest/eResponse pattern)
     * Endpoint: /api/execute
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
                    $response['data'] = DB::select('SELECT * FROM t34_tablas WHERE auto_tab > 0 ORDER BY auto_tab');
                    $response['success'] = true;
                    break;
                case 'get_unidades':
                    $cve_tab = $params['cve_tab'] ?? null;
                    $ejercicio = $params['ejercicio'] ?? date('Y');
                    $response['data'] = DB::select('SELECT ejercicio, cve_unidad, cve_operatividad, descripcion, costo FROM t34_unidades WHERE cve_tab = ? AND ejercicio = ?', [$cve_tab, $ejercicio]);
                    $response['success'] = true;
                    break;
                case 'get_max_id_unidad':
                    $result = DB::select('SELECT max(id_34_unidad) as max FROM t34_unidades');
                    $response['data'] = $result[0]->max ?? 0;
                    $response['success'] = true;
                    break;
                case 'insert_valores':
                    // params: valores (array), cve_tab (string)
                    $valores = $params['valores'] ?? [];
                    $cve_tab = $params['cve_tab'] ?? null;
                    $user = $request->user() ? $request->user()->name : 'api';
                    $result = DB::transaction(function () use ($valores, $cve_tab) {
                        $max = DB::select('SELECT max(id_34_unidad) as max FROM t34_unidades')[0]->max ?? 0;
                        foreach ($valores as $row) {
                            $max++;
                            DB::statement('CALL sp_insert_t34_unidades(?, ?, ?, ?, ?, ?, ?)', [
                                $max,
                                $row['ejercicio'],
                                $row['cve_unidad'],
                                $row['cve_operatividad'],
                                $row['descripcion'],
                                $row['costo'],
                                $cve_tab
                            ]);
                        }
                        return true;
                    });
                    $response['success'] = $result;
                    $response['message'] = $result ? 'Valores creados correctamente.' : 'Error al insertar valores.';
                    break;
                default:
                    $response['message'] = 'Acción no soportada.';
            }
        } catch (\Exception $e) {
            $response['message'] = $e->getMessage();
        }
        return response()->json($response);
    }
}

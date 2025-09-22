<?php

namespace App\Http\Controllers\Api;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;
use App\Http\Controllers\Controller;

class ExecuteController extends Controller
{
    /**
     * Endpoint único para ejecutar acciones del sistema (eRequest/eResponse)
     * POST /api/execute
     *
     * @param Request $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function execute(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'action' => 'required|string',
            'params' => 'nullable|array',
        ]);
        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'errors' => $validator->errors(),
            ], 422);
        }

        $action = $request->input('action');
        $params = $request->input('params', []);
        $response = null;

        try {
            switch ($action) {
                case 'GNuevos.getCatalogs':
                    $response = $this->getCatalogs($params);
                    break;
                case 'GNuevos.getEtiquetas':
                    $response = $this->getEtiquetas($params);
                    break;
                case 'GNuevos.create':
                    $response = $this->createGNuevo($params);
                    break;
                default:
                    return response()->json([
                        'success' => false,
                        'error' => 'Acción no soportada',
                        'action' => $action
                    ], 400);
            }
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'error' => $e->getMessage(),
                'trace' => config('app.debug') ? $e->getTraceAsString() : null
            ], 500);
        }

        return response()->json([
            'success' => true,
            'data' => $response
        ]);
    }

    /**
     * Obtener catálogos de tipos de local para el formulario GNuevos
     */
    private function getCatalogs($params)
    {
        $par_tab = $params['par_tab'] ?? null;
        if (!$par_tab) {
            throw new \Exception('par_tab es requerido');
        }
        $catalogs = DB::select('SELECT descripcion FROM t34_unidades WHERE cve_tab = ? AND cve_unidad = ? ORDER BY descripcion', [$par_tab, 'T']);
        return [
            'tipos_local' => array_map(function($row) { return $row->descripcion; }, $catalogs)
        ];
    }

    /**
     * Obtener etiquetas dinámicas para el formulario GNuevos
     */
    private function getEtiquetas($params)
    {
        $par_tab = $params['par_tab'] ?? null;
        if (!$par_tab) {
            throw new \Exception('par_tab es requerido');
        }
        $row = DB::table('t34_etiq')->where('cve_tab', $par_tab)->first();
        if (!$row) {
            throw new \Exception('No existen etiquetas para la tabla');
        }
        return $row;
    }

    /**
     * Alta de nuevo registro (GNuevos)
     * Llama al stored procedure sp_gnuevos_alta
     */
    private function createGNuevo($params)
    {
        $required = [
            'par_tabla', 'par_control', 'par_conces', 'par_ubica', 'par_sup',
            'par_Axo_Ini', 'par_Mes_Ini', 'par_ofna', 'par_sector', 'par_zona',
            'par_lic', 'par_Descrip', 'par_NomCom', 'par_Lugar', 'par_Obs', 'par_usuario'
        ];
        foreach ($required as $field) {
            if (!isset($params[$field])) {
                throw new \Exception("Falta el parámetro requerido: $field");
            }
        }
        $result = DB::select('SELECT * FROM sp_gnuevos_alta(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)', [
            $params['par_tabla'],
            $params['par_control'],
            $params['par_conces'],
            $params['par_ubica'],
            $params['par_sup'],
            $params['par_Axo_Ini'],
            $params['par_Mes_Ini'],
            $params['par_ofna'],
            $params['par_sector'],
            $params['par_zona'],
            $params['par_lic'],
            $params['par_Descrip'],
            $params['par_NomCom'],
            $params['par_Lugar'],
            $params['par_Obs'],
            $params['par_usuario']
        ]);
        if (isset($result[0])) {
            return $result[0];
        }
        throw new \Exception('Error inesperado al crear el registro');
    }
}

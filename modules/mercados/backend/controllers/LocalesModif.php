<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;

class LocalesModifController extends Controller
{
    /**
     * Endpoint único para todas las operaciones (eRequest/eResponse)
     */
    public function execute(Request $request)
    {
        $action = $request->input('action');
        $params = $request->input('params', []);
        $userId = $request->user() ? $request->user()->id : null;
        $response = [
            'success' => false,
            'message' => '',
            'data' => null
        ];

        try {
            switch ($action) {
                case 'buscar_local':
                    $response = $this->buscarLocal($params);
                    break;
                case 'modificar_local':
                    $response = $this->modificarLocal($params, $userId);
                    break;
                case 'catalogos':
                    $response = $this->catalogos();
                    break;
                case 'movimientos':
                    $response = $this->catalogoMovimientos();
                    break;
                case 'bloqueos':
                    $response = $this->catalogoBloqueos();
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

    /**
     * Buscar local por criterios
     */
    private function buscarLocal($params)
    {
        $validator = Validator::make($params, [
            'oficina' => 'required|integer',
            'num_mercado' => 'required|integer',
            'categoria' => 'required|integer',
            'seccion' => 'required|string',
            'local' => 'required|integer',
            'letra_local' => 'nullable|string',
            'bloque' => 'nullable|string',
        ]);
        if ($validator->fails()) {
            return [
                'success' => false,
                'message' => $validator->errors()->first(),
                'data' => null
            ];
        }
        $result = DB::select('SELECT * FROM sp_localesmodif_buscar_local(?,?,?,?,?,?,?)', [
            $params['oficina'],
            $params['num_mercado'],
            $params['categoria'],
            $params['seccion'],
            $params['local'],
            $params['letra_local'],
            $params['bloque']
        ]);
        if (empty($result)) {
            return [
                'success' => false,
                'message' => 'Local no encontrado',
                'data' => null
            ];
        }
        return [
            'success' => true,
            'message' => 'Local encontrado',
            'data' => $result[0]
        ];
    }

    /**
     * Modificar local (alta movimiento, update, bloqueos, etc)
     */
    private function modificarLocal($params, $userId)
    {
        $validator = Validator::make($params, [
            'id_local' => 'required|integer',
            'nombre' => 'required|string',
            'domicilio' => 'nullable|string',
            'sector' => 'required|string',
            'zona' => 'required|integer',
            'descripcion_local' => 'nullable|string',
            'superficie' => 'required|numeric',
            'giro' => 'required|integer',
            'fecha_alta' => 'required|date',
            'fecha_baja' => 'nullable|date',
            'vigencia' => 'required|string',
            'clave_cuota' => 'required|integer',
            'tipo_movimiento' => 'required|integer',
            'bloqueo' => 'nullable|integer',
            'cve_bloqueo' => 'nullable|integer',
            'fecha_inicio_bloqueo' => 'nullable|date',
            'fecha_final_bloqueo' => 'nullable|date',
            'observacion' => 'nullable|string',
        ]);
        if ($validator->fails()) {
            return [
                'success' => false,
                'message' => $validator->errors()->first(),
                'data' => null
            ];
        }
        $result = DB::select('SELECT * FROM sp_localesmodif_modificar_local(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)', [
            $params['id_local'],
            $params['nombre'],
            $params['domicilio'],
            $params['sector'],
            $params['zona'],
            $params['descripcion_local'],
            $params['superficie'],
            $params['giro'],
            $params['fecha_alta'],
            $params['fecha_baja'],
            $params['vigencia'],
            $params['clave_cuota'],
            $params['tipo_movimiento'],
            $params['bloqueo'],
            $params['cve_bloqueo'],
            $params['fecha_inicio_bloqueo'],
            $params['fecha_final_bloqueo'],
            $params['observacion'],
            $userId,
            now()
        ]);
        return [
            'success' => true,
            'message' => 'Local modificado correctamente',
            'data' => $result[0] ?? null
        ];
    }

    /**
     * Catálogos para combos (zonas, cuotas, sectores, etc)
     */
    private function catalogos()
    {
        $zonas = DB::select('SELECT id_zona, zona FROM ta_12_zonas ORDER BY id_zona');
        $cuotas = DB::select('SELECT clave_cuota, descripcion FROM ta_11_cve_cuota ORDER BY clave_cuota');
        $sectores = [
            ['clave' => 'J', 'descripcion' => 'J'],
            ['clave' => 'R', 'descripcion' => 'R'],
            ['clave' => 'L', 'descripcion' => 'L'],
            ['clave' => 'H', 'descripcion' => 'H']
        ];
        return [
            'success' => true,
            'message' => 'Catálogos obtenidos',
            'data' => [
                'zonas' => $zonas,
                'cuotas' => $cuotas,
                'sectores' => $sectores
            ]
        ];
    }

    /**
     * Catálogo de movimientos
     */
    private function catalogoMovimientos()
    {
        $movs = DB::select('SELECT clave_movimiento, descripcion FROM ta_11_clave_mov ORDER BY clave_movimiento');
        return [
            'success' => true,
            'message' => 'Catálogo movimientos',
            'data' => $movs
        ];
    }

    /**
     * Catálogo de bloqueos
     */
    private function catalogoBloqueos()
    {
        $blqs = DB::select('SELECT cve_bloqueo, descripcion FROM ta_11_cvebloqueo WHERE cve_bloqueo>3 ORDER BY cve_bloqueo');
        return [
            'success' => true,
            'message' => 'Catálogo bloqueos',
            'data' => $blqs
        ];
    }
}

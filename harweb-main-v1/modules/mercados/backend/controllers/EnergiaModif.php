<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;

class EnergiaModifController extends Controller
{
    /**
     * Endpoint único para ejecutar acciones de EnergiaModif
     * Entrada: {
     *   eRequest: {
     *     action: string, // buscar, modificar, ...
     *     data: {...}
     *   }
     * }
     * Salida: {
     *   eResponse: {...}
     * }
     */
    public function execute(Request $request)
    {
        $input = $request->input('eRequest');
        $action = $input['action'] ?? null;
        $data = $input['data'] ?? [];
        $response = [
            'success' => false,
            'message' => '',
            'data' => null
        ];

        try {
            switch ($action) {
                case 'buscar':
                    $response = $this->buscar($data);
                    break;
                case 'modificar':
                    $response = $this->modificar($data);
                    break;
                case 'catalogos':
                    $response = $this->catalogos();
                    break;
                default:
                    $response['message'] = 'Acción no soportada';
            }
        } catch (\Exception $ex) {
            $response['success'] = false;
            $response['message'] = $ex->getMessage();
        }
        return response()->json(['eResponse' => $response]);
    }

    /**
     * Buscar registro de energía para un local
     */
    private function buscar($data)
    {
        $validator = Validator::make($data, [
            'oficina' => 'required|integer',
            'num_mercado' => 'required|integer',
            'categoria' => 'required|integer',
            'seccion' => 'required|string',
            'local' => 'required|integer',
            'letra_local' => 'nullable|string',
            'bloque' => 'nullable|string',
            'movimiento' => 'required|string'
        ]);
        if ($validator->fails()) {
            return [
                'success' => false,
                'message' => $validator->errors()->first(),
                'data' => null
            ];
        }
        $params = [
            $data['oficina'],
            $data['num_mercado'],
            $data['categoria'],
            $data['seccion'],
            $data['local'],
            $data['letra_local'] ?? null,
            $data['bloque'] ?? null
        ];
        $result = DB::select('SELECT * FROM sp_energia_modif_buscar(?,?,?,?,?,?,?)', $params);
        if (empty($result)) {
            return [
                'success' => false,
                'message' => 'No existe registro de energía para el local',
                'data' => null
            ];
        }
        $energia = $result[0];
        // Validaciones de vigencia y movimiento
        $mov = strtoupper(substr($data['movimiento'], 0, 1));
        if ($energia->vigencia == 'B') {
            return [
                'success' => false,
                'message' => 'El registro de energía está dado de baja',
                'data' => null
            ];
        }
        return [
            'success' => true,
            'message' => 'Registro encontrado',
            'data' => $energia
        ];
    }

    /**
     * Modificar registro de energía
     */
    private function modificar($data)
    {
        $validator = Validator::make($data, [
            'id_energia' => 'required|integer',
            'id_local' => 'required|integer',
            'cantidad' => 'required|numeric|min:0.01',
            'vigencia' => 'required|string',
            'fecha_alta' => 'required|date',
            'fecha_baja' => 'nullable|date',
            'movimiento' => 'required|string',
            'cve_consumo' => 'required|string',
            'local_adicional' => 'nullable|string',
            'usuario_id' => 'required|integer',
            'periodo_baja_axo' => 'nullable|integer',
            'periodo_baja_mes' => 'nullable|integer'
        ]);
        if ($validator->fails()) {
            return [
                'success' => false,
                'message' => $validator->errors()->first(),
                'data' => null
            ];
        }
        $params = [
            $data['id_energia'],
            $data['id_local'],
            $data['cantidad'],
            $data['vigencia'],
            $data['fecha_alta'],
            $data['fecha_baja'] ?? null,
            $data['movimiento'],
            $data['cve_consumo'],
            $data['local_adicional'] ?? '',
            $data['usuario_id'],
            $data['periodo_baja_axo'] ?? null,
            $data['periodo_baja_mes'] ?? null
        ];
        $result = DB::select('SELECT * FROM sp_energia_modif_modificar(?,?,?,?,?,?,?,?,?,?,?,?)', $params);
        $row = $result[0] ?? null;
        if ($row && $row->success) {
            return [
                'success' => true,
                'message' => $row->message,
                'data' => null
            ];
        }
        return [
            'success' => false,
            'message' => $row ? $row->message : 'Error desconocido',
            'data' => null
        ];
    }

    /**
     * Catálogos para combos
     */
    private function catalogos()
    {
        $recaudadoras = DB::select('SELECT * FROM sp_catalogo_recaudadoras()');
        $secciones = DB::select('SELECT * FROM sp_catalogo_secciones()');
        $movimientos = [
            ['value' => 'C', 'label' => 'Cambio de Datos Generales'],
            ['value' => 'B', 'label' => 'Baja Total'],
            ['value' => 'F', 'label' => 'Cambio de Fecha de Alta'],
            ['value' => 'D', 'label' => 'Cambio de Cuota']
        ];
        $consumos = [
            ['value' => 'F', 'label' => 'Precio Fijo / Servicio Normal'],
            ['value' => 'K', 'label' => 'Precio Kilowhatts / Servicio Medido']
        ];
        return [
            'success' => true,
            'message' => '',
            'data' => [
                'recaudadoras' => $recaudadoras,
                'secciones' => $secciones,
                'movimientos' => $movimientos,
                'consumos' => $consumos
            ]
        ];
    }
}

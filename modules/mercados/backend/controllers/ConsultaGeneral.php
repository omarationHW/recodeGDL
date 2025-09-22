<?php
namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\Validator;

class ConsultaGeneralController extends Controller
{
    /**
     * Endpoint único para ejecutar acciones (eRequest/eResponse)
     */
    public function execute(Request $request)
    {
        $eRequest = $request->input('eRequest');
        $params = $request->input('params', []);
        $eResponse = [
            'success' => false,
            'data' => null,
            'message' => ''
        ];

        try {
            switch ($eRequest) {
                case 'buscar_local':
                    $eResponse = $this->buscarLocal($params);
                    break;
                case 'detalle_local':
                    $eResponse = $this->detalleLocal($params);
                    break;
                case 'adeudos_local':
                    $eResponse = $this->adeudosLocal($params);
                    break;
                case 'pagos_local':
                    $eResponse = $this->pagosLocal($params);
                    break;
                case 'requerimientos_local':
                    $eResponse = $this->requerimientosLocal($params);
                    break;
                default:
                    $eResponse['message'] = 'eRequest no soportado';
            }
        } catch (\Exception $ex) {
            Log::error($ex);
            $eResponse['message'] = $ex->getMessage();
        }
        return response()->json($eResponse);
    }

    /**
     * Buscar local por parámetros
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
        $result = DB::select('SELECT * FROM sp_consulta_general_buscar_local(?,?,?,?,?,?,?)', [
            $params['oficina'],
            $params['num_mercado'],
            $params['categoria'],
            $params['seccion'],
            $params['local'],
            $params['letra_local'] ?? null,
            $params['bloque'] ?? null
        ]);
        return [
            'success' => true,
            'data' => $result,
            'message' => count($result) ? 'Local encontrado' : 'No existe el local digitado'
        ];
    }

    /**
     * Detalle de local (datos generales)
     */
    private function detalleLocal($params)
    {
        $validator = Validator::make($params, [
            'id_local' => 'required|integer'
        ]);
        if ($validator->fails()) {
            return [
                'success' => false,
                'message' => $validator->errors()->first(),
                'data' => null
            ];
        }
        $result = DB::select('SELECT * FROM sp_consulta_general_detalle_local(?)', [
            $params['id_local']
        ]);
        return [
            'success' => true,
            'data' => $result,
            'message' => count($result) ? 'Detalle encontrado' : 'No existe el local'
        ];
    }

    /**
     * Adeudos del local
     */
    private function adeudosLocal($params)
    {
        $validator = Validator::make($params, [
            'id_local' => 'required|integer'
        ]);
        if ($validator->fails()) {
            return [
                'success' => false,
                'message' => $validator->errors()->first(),
                'data' => null
            ];
        }
        $result = DB::select('SELECT * FROM sp_consulta_general_adeudos_local(?)', [
            $params['id_local']
        ]);
        return [
            'success' => true,
            'data' => $result,
            'message' => 'Adeudos obtenidos'
        ];
    }

    /**
     * Pagos del local
     */
    private function pagosLocal($params)
    {
        $validator = Validator::make($params, [
            'id_local' => 'required|integer'
        ]);
        if ($validator->fails()) {
            return [
                'success' => false,
                'message' => $validator->errors()->first(),
                'data' => null
            ];
        }
        $result = DB::select('SELECT * FROM sp_consulta_general_pagos_local(?)', [
            $params['id_local']
        ]);
        return [
            'success' => true,
            'data' => $result,
            'message' => 'Pagos obtenidos'
        ];
    }

    /**
     * Requerimientos del local
     */
    private function requerimientosLocal($params)
    {
        $validator = Validator::make($params, [
            'id_local' => 'required|integer'
        ]);
        if ($validator->fails()) {
            return [
                'success' => false,
                'message' => $validator->errors()->first(),
                'data' => null
            ];
        }
        $result = DB::select('SELECT * FROM sp_consulta_general_requerimientos_local(?)', [
            $params['id_local']
        ]);
        return [
            'success' => true,
            'data' => $result,
            'message' => 'Requerimientos obtenidos'
        ];
    }
}

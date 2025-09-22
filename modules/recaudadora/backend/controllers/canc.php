<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;

class CancelacionRangoController extends Controller
{
    /**
     * Endpoint unificado para ejecutar acciones (eRequest/eResponse)
     */
    public function execute(Request $request)
    {
        $action = $request->input('eRequest.action');
        $params = $request->input('eRequest.params', []);
        $response = [
            'eResponse' => [
                'status' => 'error',
                'message' => 'Acción no reconocida',
                'data' => null
            ]
        ];

        try {
            switch ($action) {
                case 'buscarFolios':
                    $response['eResponse'] = $this->buscarFolios($params);
                    break;
                case 'reasignarFolios':
                    $response['eResponse'] = $this->reasignarFolios($params);
                    break;
                case 'cancelarFolios':
                    $response['eResponse'] = $this->cancelarFolios($params);
                    break;
                case 'asignarFoliosEjecutor':
                    $response['eResponse'] = $this->asignarFoliosEjecutor($params);
                    break;
                case 'consultarEjecutores':
                    $response['eResponse'] = $this->consultarEjecutores($params);
                    break;
                default:
                    $response['eResponse']['message'] = 'Acción no soportada';
            }
        } catch (\Exception $e) {
            $response['eResponse']['status'] = 'error';
            $response['eResponse']['message'] = $e->getMessage();
        }
        return response()->json($response);
    }

    /**
     * Buscar folios en un rango para cancelar o reasignar
     */
    private function buscarFolios($params)
    {
        $validator = Validator::make($params, [
            'tipo' => 'required|string',
            'folio_ini' => 'required|integer',
            'folio_fin' => 'required|integer',
            'recaud' => 'required|integer',
        ]);
        if ($validator->fails()) {
            return [
                'status' => 'error',
                'message' => $validator->errors()->first(),
                'data' => null
            ];
        }
        $tipo = $params['tipo'];
        $folio_ini = $params['folio_ini'];
        $folio_fin = $params['folio_fin'];
        $recaud = $params['recaud'];
        $table = $this->getTableByTipo($tipo);
        $folios = DB::select(
            "SELECT * FROM $table WHERE vigencia = 'V' AND recaud = ? AND folioreq BETWEEN ? AND ?",
            [$recaud, $folio_ini, $folio_fin]
        );
        return [
            'status' => 'success',
            'message' => 'Folios encontrados',
            'data' => $folios
        ];
    }

    /**
     * Reasignar folios a otro ejecutor
     */
    private function reasignarFolios($params)
    {
        $validator = Validator::make($params, [
            'tipo' => 'required|string',
            'folio_ini' => 'required|integer',
            'folio_fin' => 'required|integer',
            'recaud' => 'required|integer',
            'ejecutor_actual' => 'required|integer',
            'ejecutor_nuevo' => 'required|integer',
            'fecha' => 'required|date',
        ]);
        if ($validator->fails()) {
            return [
                'status' => 'error',
                'message' => $validator->errors()->first(),
                'data' => null
            ];
        }
        $result = DB::select('SELECT * FROM spd_updreasigna(?,?,?,?,?,?,?,?)', [
            $params['ejecutor_actual'],
            $params['recaud'],
            $params['folio_ini'],
            $params['folio_fin'],
            $params['ejecutor_nuevo'],
            $params['fecha'],
            0, // cantidad
            $this->getOpcionByTipo($params['tipo'])
        ]);
        return [
            'status' => 'success',
            'message' => 'Folios reasignados',
            'data' => $result
        ];
    }

    /**
     * Cancelar folios en un rango
     */
    private function cancelarFolios($params)
    {
        $validator = Validator::make($params, [
            'tipo' => 'required|string',
            'folio_ini' => 'required|integer',
            'folio_fin' => 'required|integer',
            'recaud' => 'required|integer',
            'usuario' => 'required|string',
            'motivo' => 'required|string',
        ]);
        if ($validator->fails()) {
            return [
                'status' => 'error',
                'message' => $validator->errors()->first(),
                'data' => null
            ];
        }
        $table = $this->getTableByTipo($params['tipo']);
        $folios = DB::update(
            "UPDATE $table SET vigencia = 'C', feccan = NOW(), capturista = ?, obs = ? WHERE vigencia = 'V' AND recaud = ? AND folioreq BETWEEN ? AND ?",
            [$params['usuario'], $params['motivo'], $params['recaud'], $params['folio_ini'], $params['folio_fin']]
        );
        return [
            'status' => 'success',
            'message' => 'Folios cancelados',
            'data' => ['folios_afectados' => $folios]
        ];
    }

    /**
     * Asignar folios a ejecutor
     */
    private function asignarFoliosEjecutor($params)
    {
        $validator = Validator::make($params, [
            'tipo' => 'required|string',
            'folio_ini' => 'required|integer',
            'folio_fin' => 'required|integer',
            'recaud' => 'required|integer',
            'ejecutor' => 'required|integer',
            'fecha_asignacion' => 'required|date',
        ]);
        if ($validator->fails()) {
            return [
                'status' => 'error',
                'message' => $validator->errors()->first(),
                'data' => null
            ];
        }
        $result = DB::select('SELECT * FROM spd_updasigna(?,?,?,?,?,?)', [
            $params['recaud'],
            $params['folio_ini'],
            $params['folio_fin'],
            $params['ejecutor'],
            $params['fecha_asignacion'],
            $this->getOpcionByTipo($params['tipo'])
        ]);
        return [
            'status' => 'success',
            'message' => 'Folios asignados',
            'data' => $result
        ];
    }

    /**
     * Consultar ejecutores disponibles
     */
    private function consultarEjecutores($params)
    {
        $validator = Validator::make($params, [
            'recaud' => 'required|integer',
            'fecha_ini' => 'required|date',
            'fecha_fin' => 'required|date',
        ]);
        if ($validator->fails()) {
            return [
                'status' => 'error',
                'message' => $validator->errors()->first(),
                'data' => null
            ];
        }
        $ejecutores = DB::select(
            "SELECT e.cveejecutor, (e.paterno || ' ' || e.materno || ' ' || e.nombres) as nombre_comp FROM ejecutor e INNER JOIN detejecutor d ON e.cveejecutor = d.cveejecutor WHERE d.recaud = ? AND e.vigencia = 'V' AND e.fecinic >= ? AND e.fecterm <= ?",
            [$params['recaud'], $params['fecha_ini'], $params['fecha_fin']]
        );
        return [
            'status' => 'success',
            'message' => 'Ejecutores encontrados',
            'data' => $ejecutores
        ];
    }

    /**
     * Helper para obtener tabla según tipo
     */
    private function getTableByTipo($tipo)
    {
        switch (strtolower($tipo)) {
            case 'predial': return 'reqpredial';
            case 'multas': return 'reqmultas';
            case 'licencias': return 'reqlicencias';
            case 'anuncios': return 'reqanuncios';
            case 'diferencias': return 'reqdiftransmision';
            default: throw new \Exception('Tipo de requerimiento no soportado');
        }
    }

    /**
     * Helper para obtener opción numérica según tipo
     */
    private function getOpcionByTipo($tipo)
    {
        switch (strtolower($tipo)) {
            case 'predial': return 1;
            case 'multas': return 2;
            case 'licencias': return 3;
            case 'anuncios': return 4;
            case 'diferencias': return 5;
            default: return 0;
        }
    }
}

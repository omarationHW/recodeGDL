<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;

class PadronConveniosController extends Controller
{
    /**
     * Endpoint unificado para eRequest/eResponse
     */
    public function execute(Request $request)
    {
        $input = $request->all();
        $action = $input['eRequest']['action'] ?? null;
        $params = $input['eRequest']['params'] ?? [];
        $response = [
            'success' => false,
            'data' => null,
            'message' => ''
        ];

        try {
            switch ($action) {
                case 'getPadronConvenios':
                    $response['data'] = $this->getPadronConvenios($params);
                    $response['success'] = true;
                    break;
                case 'getPadronConveniosFolios':
                    $response['data'] = $this->getPadronConveniosFolios($params);
                    $response['success'] = true;
                    break;
                case 'getTipos':
                    $response['data'] = $this->getTipos();
                    $response['success'] = true;
                    break;
                case 'getSubtipos':
                    $response['data'] = $this->getSubtipos($params);
                    $response['success'] = true;
                    break;
                case 'getRecaudadoras':
                    $response['data'] = $this->getRecaudadoras();
                    $response['success'] = true;
                    break;
                case 'getVigencias':
                    $response['data'] = $this->getVigencias();
                    $response['success'] = true;
                    break;
                default:
                    $response['message'] = 'Acción no soportada';
            }
        } catch (\Exception $e) {
            $response['message'] = $e->getMessage();
        }
        return response()->json(['eResponse' => $response]);
    }

    /**
     * Consulta principal del padrón de convenios
     */
    private function getPadronConvenios($params)
    {
        $tipo = $params['tipo'] ?? null;
        $subtipo = $params['subtipo'] ?? null;
        $vigencia = $params['vigencia'] ?? null;
        $recaudadora = $params['recaudadora'] ?? null;
        $anio_desde = $params['anio_desde'] ?? null;
        $anio_hasta = $params['anio_hasta'] ?? null;

        $result = DB::select('CALL sp_padron_convenios(?, ?, ?, ?, ?, ?)', [
            $tipo, $subtipo, $vigencia, $recaudadora, $anio_desde, $anio_hasta
        ]);
        return $result;
    }

    /**
     * Consulta de folios de convenios (parcialidades)
     */
    private function getPadronConveniosFolios($params)
    {
        $id_conv_resto = $params['id_conv_resto'] ?? null;
        $modulo = $params['modulo'] ?? null;
        $id_referencia = $params['id_referencia'] ?? null;
        $fecha_inicio = $params['fecha_inicio'] ?? null;
        $fecha_venc = $params['fecha_venc'] ?? null;

        $result = DB::select('CALL sp_padron_convenios_folios(?, ?, ?, ?, ?)', [
            $modulo, $id_referencia, $fecha_inicio, $fecha_venc, $id_conv_resto
        ]);
        return $result;
    }

    /**
     * Catálogo de tipos
     */
    private function getTipos()
    {
        return DB::table('ta_17_tipos')->orderBy('tipo')->get();
    }

    /**
     * Catálogo de subtipos por tipo
     */
    private function getSubtipos($params)
    {
        $tipo = $params['tipo'] ?? null;
        return DB::table('ta_17_subtipo_conv')->where('tipo', $tipo)->orderBy('subtipo')->get();
    }

    /**
     * Catálogo de recaudadoras
     */
    private function getRecaudadoras()
    {
        return DB::table('ta_12_recaudadoras')->orderBy('id_rec')->get();
    }

    /**
     * Catálogo de vigencias
     */
    private function getVigencias()
    {
        return [
            ['value' => '0', 'label' => 'TODAS LAS VIGENCIAS'],
            ['value' => 'A', 'label' => 'VIGENTES'],
            ['value' => 'B', 'label' => 'BAJAS'],
            ['value' => 'P', 'label' => 'PAGADOS']
        ];
    }
}

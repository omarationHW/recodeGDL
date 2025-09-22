<?php
namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;

class IndividualDiversosController extends Controller
{
    /**
     * Endpoint unificado para ejecutar acciones sobre IndividualDiversos
     * Entrada: {
     *   "eRequest": {
     *     "action": "getConvenio|getAdeudos|getPagos|buscarConvenio|...",
     *     "params": { ... }
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
                case 'getConvenio':
                    $result = $this->getConvenio($params);
                    break;
                case 'getAdeudos':
                    $result = $this->getAdeudos($params);
                    break;
                case 'getPagos':
                    $result = $this->getPagos($params);
                    break;
                case 'buscarConvenio':
                    $result = $this->buscarConvenio($params);
                    break;
                case 'getReferencias':
                    $result = $this->getReferencias($params);
                    break;
                case 'getTipos':
                    $result = $this->getTipos();
                    break;
                case 'getSubTipos':
                    $result = $this->getSubTipos($params);
                    break;
                case 'getFirma':
                    $result = $this->getFirma($params);
                    break;
                case 'getResumen':
                    $result = $this->getResumen($params);
                    break;
                default:
                    $error = 'Acción no soportada';
            }
        } catch (\Exception $ex) {
            $error = $ex->getMessage();
        }

        return response()->json([
            'eResponse' => $error ? ['error' => $error] : $result
        ]);
    }

    private function getConvenio($params)
    {
        $id_conv = $params['id_conv'] ?? null;
        $tipo = $params['tipo'] ?? null;
        if (!$id_conv || !$tipo) {
            throw new \Exception('Parámetros insuficientes');
        }
        $row = DB::selectOne('SELECT * FROM ta_17_conv_d_resto WHERE id_conv_diver = ? AND tipo = ?', [$id_conv, $tipo]);
        if (!$row) {
            throw new \Exception('Convenio no encontrado');
        }
        return ['convenio' => $row];
    }

    private function getAdeudos($params)
    {
        $id_conv_resto = $params['id_conv_resto'] ?? null;
        if (!$id_conv_resto) {
            throw new \Exception('Parámetro id_conv_resto requerido');
        }
        $rows = DB::select('SELECT * FROM ta_17_adeudos_div WHERE id_conv_resto = ? ORDER BY pago_parcial', [$id_conv_resto]);
        return ['adeudos' => $rows];
    }

    private function getPagos($params)
    {
        $id_conv_resto = $params['id_conv_resto'] ?? null;
        if (!$id_conv_resto) {
            throw new \Exception('Parámetro id_conv_resto requerido');
        }
        $rows = DB::select('SELECT * FROM ta_17_conv_pagos WHERE id_conv_resto = ? ORDER BY pago_parcial', [$id_conv_resto]);
        return ['pagos' => $rows];
    }

    private function buscarConvenio($params)
    {
        $tipo = $params['tipo'] ?? null;
        $subtipo = $params['subtipo'] ?? null;
        $manzana = $params['manzana'] ?? null;
        $lote = $params['lote'] ?? null;
        $letra = $params['letra'] ?? null;
        $letras_exp = $params['letras_exp'] ?? null;
        $numero_exp = $params['numero_exp'] ?? null;
        $axo_exp = $params['axo_exp'] ?? null;
        if ($tipo == 14) {
            $row = DB::selectOne('SELECT * FROM ta_17_con_reg_pred WHERE tipo = ? AND subtipo = ? AND manzana = ? AND lote = ? AND (letra = ? OR (? IS NULL AND letra IS NULL))',
                [$tipo, $subtipo, $manzana, $lote, $letra, $letra]);
            if (!$row) {
                throw new \Exception('Predio no encontrado');
            }
            return ['convenio' => $row];
        } else {
            $row = DB::selectOne('SELECT * FROM ta_17_conv_diverso WHERE tipo = ? AND subtipo = ? AND letras_exp = ? AND numero_exp = ? AND axo_exp = ?',
                [$tipo, $subtipo, $letras_exp, $numero_exp, $axo_exp]);
            if (!$row) {
                throw new \Exception('Expediente no encontrado');
            }
            return ['convenio' => $row];
        }
    }

    private function getReferencias($params)
    {
        $id_conv_resto = $params['id_conv_resto'] ?? null;
        if (!$id_conv_resto) {
            throw new \Exception('Parámetro id_conv_resto requerido');
        }
        $rows = DB::select('SELECT * FROM ta_17_referencia WHERE id_conv_resto = ? ORDER BY id_control', [$id_conv_resto]);
        return ['referencias' => $rows];
    }

    private function getTipos()
    {
        $rows = DB::select('SELECT * FROM ta_17_tipos ORDER BY tipo');
        return ['tipos' => $rows];
    }

    private function getSubTipos($params)
    {
        $tipo = $params['tipo'] ?? null;
        if (!$tipo) {
            throw new \Exception('Parámetro tipo requerido');
        }
        $rows = DB::select('SELECT * FROM ta_17_subtipo_conv WHERE tipo = ? ORDER BY subtipo', [$tipo]);
        return ['subtipos' => $rows];
    }

    private function getFirma($params)
    {
        $recaudadora = $params['recaudadora'] ?? null;
        if (!$recaudadora) {
            throw new \Exception('Parámetro recaudadora requerido');
        }
        $row = DB::selectOne('SELECT * FROM ta_17_firmaconv WHERE recaudadora = ?', [$recaudadora]);
        return ['firma' => $row];
    }

    private function getResumen($params)
    {
        // Implementar lógica de resumen de adeudos, pagos, intereses, etc.
        // Puede llamar a un stored procedure
        $id_conv_resto = $params['id_conv_resto'] ?? null;
        if (!$id_conv_resto) {
            throw new \Exception('Parámetro id_conv_resto requerido');
        }
        $res = DB::selectOne('SELECT * FROM sp_individual_diversos_resumen(?)', [$id_conv_resto]);
        return ['resumen' => $res];
    }
}

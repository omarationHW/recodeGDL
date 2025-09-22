<?php

namespace App\Http\Controllers\Api;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;
use App\Http\Controllers\Controller;

class ImprimeOficioController extends Controller
{
    /**
     * Endpoint único para manejar todas las operaciones del formulario ImprimeOficio
     * Entrada: {
     *   "eRequest": {
     *     "operation": "buscar|imprimir_oficio|imprimir_pagare|salir|otro|testigo1|testigo2|firma_titular|cargo_titular",
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
        $operation = $input['operation'] ?? null;
        $params = $input['params'] ?? [];
        $response = [];

        switch ($operation) {
            case 'buscar':
                $response = $this->buscarConvenio($params);
                break;
            case 'imprimir_oficio':
                $response = $this->imprimirOficio($params);
                break;
            case 'imprimir_pagare':
                $response = $this->imprimirPagare($params);
                break;
            case 'salir':
                $response = ['status' => 'ok', 'message' => 'Sesión cerrada'];
                break;
            case 'otro':
                $response = ['status' => 'ok', 'message' => 'Formulario reiniciado'];
                break;
            case 'testigo1':
                $response = ['status' => 'ok', 'message' => 'Testigo 1 editable'];
                break;
            case 'testigo2':
                $response = ['status' => 'ok', 'message' => 'Testigo 2 editable'];
                break;
            case 'firma_titular':
                $response = ['status' => 'ok', 'message' => 'Firma titular editable'];
                break;
            case 'cargo_titular':
                $response = ['status' => 'ok', 'message' => 'Cargo titular editable'];
                break;
            default:
                $response = ['status' => 'error', 'message' => 'Operación no soportada'];
        }
        return response()->json(['eResponse' => $response]);
    }

    private function buscarConvenio($params)
    {
        $validator = Validator::make($params, [
            'letras' => 'required|string',
            'numero' => 'required|integer',
            'axo' => 'required|integer',
            'tipo' => 'required|integer',
        ]);
        if ($validator->fails()) {
            return ['status' => 'error', 'message' => $validator->errors()->first()];
        }
        $letras = $params['letras'];
        $numero = $params['numero'];
        $axo = $params['axo'];
        $tipo = $params['tipo'];

        // Llama al SP de búsqueda
        $result = DB::select('SELECT * FROM sp_imprime_oficio_buscar_convenio(?, ?, ?, ?)', [
            $letras, $numero, $axo, $tipo
        ]);
        if (empty($result)) {
            return [
                'status' => 'not_found',
                'message' => 'No existe el convenio o no está vigente',
                'convenio' => null
            ];
        }
        $convenio = $result[0];
        // Adeudos sin desglose
        $adeudos = DB::select('SELECT * FROM sp_imprime_oficio_adeudos_sin_desglose(?)', [$convenio->id_conv_resto]);
        if (!empty($adeudos)) {
            return [
                'status' => 'error',
                'message' => 'Existen parcialidades que no tienen el desglose de cuentas, no puedes imprimir el oficio y/o pagaré',
                'convenio' => $convenio
            ];
        }
        // Firmas
        $firma = DB::select('SELECT * FROM sp_imprime_oficio_firma(?)', [substr($letras, 2, 1)]);
        // Testigos, etc.
        return [
            'status' => 'ok',
            'convenio' => $convenio,
            'firma' => $firma[0] ?? null
        ];
    }

    private function imprimirOficio($params)
    {
        // Lógica para generar el PDF del oficio
        // Llama al SP que arma los textos y devuelve los datos para el reporte
        $id_conv_resto = $params['id_conv_resto'] ?? null;
        if (!$id_conv_resto) {
            return ['status' => 'error', 'message' => 'Falta id_conv_resto'];
        }
        $data = DB::select('SELECT * FROM sp_imprime_oficio_datos_oficio(?)', [$id_conv_resto]);
        // Aquí se generaría el PDF y se retorna la URL o base64
        return [
            'status' => 'ok',
            'pdf_url' => '/api/reports/oficio/'.$id_conv_resto,
            'data' => $data[0] ?? null
        ];
    }

    private function imprimirPagare($params)
    {
        // Lógica para generar el PDF del pagaré
        $id_conv_resto = $params['id_conv_resto'] ?? null;
        if (!$id_conv_resto) {
            return ['status' => 'error', 'message' => 'Falta id_conv_resto'];
        }
        $data = DB::select('SELECT * FROM sp_imprime_oficio_datos_pagare(?)', [$id_conv_resto]);
        return [
            'status' => 'ok',
            'pdf_url' => '/api/reports/pagare/'.$id_conv_resto,
            'data' => $data[0] ?? null
        ];
    }
}

<?php

namespace App\Http\Controllers\Api;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use App\Http\Controllers\Controller;

class ConsultaRegController extends Controller
{
    /**
     * Endpoint unificado para ejecutar acciones de ConsultaReg
     * Entrada: {
     *   "eRequest": {
     *     "action": "buscar|detalle|otro",
     *     "params": { ... }
     *   }
     * }
     * Salida: {
     *   "eResponse": { ... }
     * }
     */
    public function execute(Request $request)
    {
        $action = $request->input('eRequest.action');
        $params = $request->input('eRequest.params', []);
        $response = [];

        try {
            switch ($action) {
                case 'buscar':
                    $response = $this->buscarRegistro($params);
                    break;
                case 'detalle':
                    $response = $this->detalleRegistro($params);
                    break;
                case 'otro':
                    $response = $this->resetFormulario();
                    break;
                default:
                    return response()->json([
                        'eResponse' => [
                            'success' => false,
                            'message' => 'Acción no soportada.'
                        ]
                    ], 400);
            }
            return response()->json(['eResponse' => $response]);
        } catch (\Exception $e) {
            return response()->json([
                'eResponse' => [
                    'success' => false,
                    'message' => $e->getMessage()
                ]
            ], 500);
        }
    }

    /**
     * Buscar registro según tipo de aplicación
     */
    private function buscarRegistro($params)
    {
        $tipo = $params['tipo']; // 0: Mercados, 1: Aseo, 2: Publicos, 3: Exclusivos, 4: Infracciones, 5: Cementerios
        $data = null;
        $modulo = null;
        $contro = null;
        $detalle = null;
        switch ($tipo) {
            case 0: // Mercados
                $data = DB::select('SELECT * FROM sp_consultareg_mercados(?,?,?,?,?,?)', [
                    $params['oficina'], $params['num_mercado'], $params['seccion'], $params['local'], $params['letra_local'], $params['bloque']
                ]);
                if (empty($data)) {
                    return [ 'success' => false, 'message' => 'Registro no encontrado' ];
                }
                $modulo = 11;
                $contro = $data[0]->id_local;
                break;
            case 1: // Aseo
                $data = DB::select('SELECT * FROM sp_consultareg_aseo(?,?)', [
                    $params['contrato'], $params['tipo_aseo']
                ]);
                if (empty($data)) {
                    return [ 'success' => false, 'message' => 'Registro no encontrado' ];
                }
                $modulo = 16;
                $contro = $data[0]->control_contrato;
                break;
            case 2: // Publicos
                $data = DB::select('SELECT * FROM sp_consultareg_publicos(?)', [
                    $params['numesta']
                ]);
                if (empty($data)) {
                    return [ 'success' => false, 'message' => 'Registro no encontrado' ];
                }
                $modulo = 24;
                $contro = $data[0]->id;
                break;
            case 3: // Exclusivos
                $data = DB::select('SELECT * FROM sp_consultareg_exclusivos(?)', [
                    $params['no_exclusivo']
                ]);
                if (empty($data)) {
                    return [ 'success' => false, 'message' => 'Registro no encontrado' ];
                }
                $modulo = 28;
                $contro = $data[0]->id;
                break;
            case 4: // Infracciones
                $data = DB::select('SELECT * FROM sp_consultareg_infracciones(?)', [
                    $params['placa']
                ]);
                if (empty($data)) {
                    return [ 'success' => false, 'message' => 'Registro no encontrado' ];
                }
                $modulo = 14;
                $contro = $data[0]->id;
                break;
            case 5: // Cementerios
                $data = DB::select('SELECT * FROM sp_consultareg_cementerios(?)', [
                    $params['folio']
                ]);
                if (empty($data)) {
                    return [ 'success' => false, 'message' => 'Registro no encontrado' ];
                }
                $modulo = 13;
                $contro = $data[0]->control_rcm;
                break;
            default:
                return [ 'success' => false, 'message' => 'Tipo de aplicación no soportado' ];
        }
        // Detalle de requerimiento
        $detalle = DB::select('SELECT * FROM sp_consultareg_detalle(?,?)', [$modulo, $contro]);
        return [
            'success' => true,
            'registro' => $data[0],
            'detalle' => $detalle
        ];
    }

    /**
     * Obtener detalle de requerimiento por id
     */
    private function detalleRegistro($params)
    {
        $modulo = $params['modulo'];
        $contro = $params['contro'];
        $detalle = DB::select('SELECT * FROM sp_consultareg_detalle(?,?)', [$modulo, $contro]);
        return [
            'success' => true,
            'detalle' => $detalle
        ];
    }

    /**
     * Resetear formulario (simula FlatButtonOtroClick)
     */
    private function resetFormulario()
    {
        return [
            'success' => true,
            'reset' => true
        ];
    }
}

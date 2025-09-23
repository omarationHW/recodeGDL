<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;

class LigaPagoTransController extends Controller
{
    /**
     * Endpoint unificado para ejecutar acciones sobre liga de pagos a transmisiones.
     * Entrada: eRequest con action, params
     * Salida: eResponse con status, data, message
     */
    public function execute(Request $request)
    {
        $input = $request->all();
        $action = $input['action'] ?? null;
        $params = $input['params'] ?? [];
        $response = [
            'status' => 'error',
            'data' => null,
            'message' => 'Acción no reconocida'
        ];

        try {
            switch ($action) {
                case 'searchPago':
                    $response = $this->searchPago($params);
                    break;
                case 'searchTransmision':
                    $response = $this->searchTransmision($params);
                    break;
                case 'ligarPagoTransmision':
                    $response = $this->ligarPagoTransmision($params);
                    break;
                case 'getDiferenciaTransmision':
                    $response = $this->getDiferenciaTransmision($params);
                    break;
                default:
                    $response['message'] = 'Acción no soportada';
            }
        } catch (\Exception $e) {
            $response['status'] = 'error';
            $response['message'] = $e->getMessage();
        }
        return response()->json($response);
    }

    /**
     * Buscar pago por fecha, recaudadora, caja y folio
     */
    private function searchPago($params)
    {
        $validator = Validator::make($params, [
            'fecha' => 'required|date',
            'recaud' => 'required|integer',
            'caja' => 'required|string',
            'folio' => 'required|integer'
        ]);
        if ($validator->fails()) {
            return [
                'status' => 'error',
                'message' => $validator->errors()->first()
            ];
        }
        $result = DB::select('SELECT * FROM pagos WHERE fecha = ? AND recaud = ? AND caja = ? AND folio = ? AND cveconcepto = 4', [
            $params['fecha'], $params['recaud'], $params['caja'], $params['folio']
        ]);
        return [
            'status' => 'ok',
            'data' => $result,
            'message' => count($result) ? 'Pago encontrado' : 'No se encontró el pago'
        ];
    }

    /**
     * Buscar transmisión patrimonial por folio
     */
    private function searchTransmision($params)
    {
        $validator = Validator::make($params, [
            'folio' => 'required|integer'
        ]);
        if ($validator->fails()) {
            return [
                'status' => 'error',
                'message' => $validator->errors()->first()
            ];
        }
        $result = DB::select('SELECT * FROM actostransm WHERE folio = ?', [$params['folio']]);
        return [
            'status' => 'ok',
            'data' => $result,
            'message' => count($result) ? 'Transmisión encontrada' : 'No se encontró la transmisión'
        ];
    }

    /**
     * Ligar pago a transmisión patrimonial
     * Params: cvepago, cvecta, usuario, tipo, fecha, folio_transmision
     */
    private function ligarPagoTransmision($params)
    {
        $validator = Validator::make($params, [
            'cvepago' => 'required|integer',
            'cvecta' => 'required|integer',
            'usuario' => 'required|string',
            'tipo' => 'required|integer',
            'fecha' => 'required|date',
            'folio_transmision' => 'required|integer'
        ]);
        if ($validator->fails()) {
            return [
                'status' => 'error',
                'message' => $validator->errors()->first()
            ];
        }
        // Llamar SP
        $result = DB::select('SELECT * FROM sp_ligar_pago_transmision(?,?,?,?,?,?) as res', [
            $params['cvepago'], $params['cvecta'], $params['usuario'], $params['tipo'], $params['fecha'], $params['folio_transmision']
        ]);
        return [
            'status' => 'ok',
            'data' => $result,
            'message' => 'Pago ligado correctamente'
        ];
    }

    /**
     * Obtener información de diferencia de transmisión
     */
    private function getDiferenciaTransmision($params)
    {
        $validator = Validator::make($params, [
            'folio' => 'required|integer'
        ]);
        if ($validator->fails()) {
            return [
                'status' => 'error',
                'message' => $validator->errors()->first()
            ];
        }
        $result = DB::select('SELECT * FROM diferencias_glosa WHERE foliot = ?', [$params['folio']]);
        return [
            'status' => 'ok',
            'data' => $result,
            'message' => count($result) ? 'Diferencia encontrada' : 'No se encontró diferencia'
        ];
    }
}

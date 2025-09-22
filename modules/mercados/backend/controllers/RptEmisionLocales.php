<?php
namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;

class RptEmisionLocalesController extends Controller
{
    /**
     * Endpoint único para ejecutar acciones del formulario RptEmisionLocales
     * Entrada: {
     *   "eRequest": {
     *     "action": "string", // 'get', 'emit', 'preview', etc.
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
        $response = [];

        switch ($action) {
            case 'get':
                $response = $this->getEmisionLocales($params);
                break;
            case 'emit':
                $response = $this->emitirRecibos($params);
                break;
            case 'preview':
                $response = $this->previewRecibos($params);
                break;
            case 'get-mercados':
                $response = $this->getMercados($params);
                break;
            default:
                $response = [
                    'success' => false,
                    'message' => 'Acción no soportada.'
                ];
        }
        return response()->json(['eResponse' => $response]);
    }

    /**
     * Consulta la emisión de recibos para locales
     */
    private function getEmisionLocales($params)
    {
        $validator = Validator::make($params, [
            'oficina' => 'required|integer',
            'axo' => 'required|integer',
            'periodo' => 'required|integer',
            'mercado' => 'required|integer',
        ]);
        if ($validator->fails()) {
            return [
                'success' => false,
                'errors' => $validator->errors()
            ];
        }
        $result = DB::select('CALL sp_rpt_emision_locales_get(?, ?, ?, ?)', [
            $params['oficina'],
            $params['axo'],
            $params['periodo'],
            $params['mercado']
        ]);
        return [
            'success' => true,
            'data' => $result
        ];
    }

    /**
     * Ejecuta la emisión (grabado) de recibos
     */
    private function emitirRecibos($params)
    {
        $validator = Validator::make($params, [
            'oficina' => 'required|integer',
            'axo' => 'required|integer',
            'periodo' => 'required|integer',
            'mercado' => 'required|integer',
            'usuario_id' => 'required|integer'
        ]);
        if ($validator->fails()) {
            return [
                'success' => false,
                'errors' => $validator->errors()
            ];
        }
        $result = DB::select('CALL sp_rpt_emision_locales_emit(?, ?, ?, ?, ?)', [
            $params['oficina'],
            $params['axo'],
            $params['periodo'],
            $params['mercado'],
            $params['usuario_id']
        ]);
        return [
            'success' => true,
            'message' => 'Emisión realizada correctamente',
            'data' => $result
        ];
    }

    /**
     * Previsualiza los recibos (sin grabar)
     */
    private function previewRecibos($params)
    {
        // Puede ser igual a getEmisionLocales, pero sin grabar nada
        return $this->getEmisionLocales($params);
    }

    /**
     * Devuelve lista de mercados para una oficina
     */
    private function getMercados($params)
    {
        $validator = Validator::make($params, [
            'oficina' => 'required|integer'
        ]);
        if ($validator->fails()) {
            return [
                'success' => false,
                'errors' => $validator->errors()
            ];
        }
        $result = DB::select('SELECT * FROM ta_11_mercados WHERE oficina = ? AND tipo_emision = 'M' ORDER BY num_mercado_nvo', [
            $params['oficina']
        ]);
        return [
            'success' => true,
            'data' => $result
        ];
    }
}

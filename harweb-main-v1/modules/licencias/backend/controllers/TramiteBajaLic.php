<?php
namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;
use Illuminate\Support\Facades\Log;

class TramiteBajaLicController extends Controller
{
    /**
     * Endpoint único para ejecutar acciones del formulario TramiteBajaLic
     * Entrada: {
     *   "eRequest": {
     *     "action": "string", // consultar, agregar, tramitar_baja, recalcular, imprimir_orden
     *     "params": { ... } // parámetros según acción
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
        try {
            switch ($action) {
                case 'consultar':
                    $response = $this->consultarLicencia($params);
                    break;
                case 'agregar':
                    $response = $this->agregarTramite($params);
                    break;
                case 'tramitar_baja':
                    $response = $this->tramitarBaja($params);
                    break;
                case 'recalcular':
                    $response = $this->recalcularProporcional($params);
                    break;
                case 'imprimir_orden':
                    $response = $this->imprimirOrdenPago($params);
                    break;
                default:
                    return response()->json(['eResponse' => [
                        'success' => false,
                        'message' => 'Acción no soportada'
                    ]]);
            }
            return response()->json(['eResponse' => $response]);
        } catch (\Exception $e) {
            Log::error($e->getMessage());
            return response()->json(['eResponse' => [
                'success' => false,
                'message' => $e->getMessage()
            ]]);
        }
    }

    private function consultarLicencia($params)
    {
        $licencia = $params['licencia'] ?? null;
        if (!$licencia) {
            return [
                'success' => false,
                'message' => 'Número de licencia requerido'
            ];
        }
        $result = DB::select('SELECT * FROM sp_tramite_baja_lic_consulta(?)', [$licencia]);
        if (empty($result)) {
            return [
                'success' => false,
                'message' => 'Licencia no encontrada'
            ];
        }
        return [
            'success' => true,
            'data' => $result[0]
        ];
    }

    private function agregarTramite($params)
    {
        // No requiere parámetros, solo limpia el formulario
        return [
            'success' => true,
            'message' => 'Formulario listo para nuevo trámite'
        ];
    }

    private function tramitarBaja($params)
    {
        $licencia = $params['licencia'] ?? null;
        $motivo = $params['motivo'] ?? null;
        $baja_admva = $params['baja_admva'] ?? null;
        $usuario = $params['usuario'] ?? null;
        if (!$licencia || !$motivo || !$usuario) {
            return [
                'success' => false,
                'message' => 'Datos incompletos para tramitar baja'
            ];
        }
        $result = DB::select('SELECT * FROM sp_tramite_baja_lic_tramitar(?,?,?,?)', [
            $licencia, $motivo, $baja_admva, $usuario
        ]);
        return [
            'success' => true,
            'data' => $result[0]
        ];
    }

    private function recalcularProporcional($params)
    {
        $licencia = $params['licencia'] ?? null;
        if (!$licencia) {
            return [
                'success' => false,
                'message' => 'Número de licencia requerido'
            ];
        }
        $result = DB::select('SELECT * FROM sp_tramite_baja_lic_recalcula(?)', [$licencia]);
        return [
            'success' => true,
            'data' => $result[0]
        ];
    }

    private function imprimirOrdenPago($params)
    {
        $folio = $params['folio'] ?? null;
        if (!$folio) {
            return [
                'success' => false,
                'message' => 'Folio requerido para impresión'
            ];
        }
        // Aquí se podría generar un PDF y devolver la URL o base64
        // Simulación:
        return [
            'success' => true,
            'pdf_url' => url('/storage/ordenes_pago/' . $folio . '.pdf')
        ];
    }
}

<?php
namespace App\Http\Controllers\PagosConsCont;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use App\Http\Controllers\Controller;

class PagosConsContController extends Controller
{
    /**
     * Endpoint único para eRequest/eResponse
     */
    public function execute(Request $request)
    {
        $action = $request->input('action');
        $params = $request->input('params', []);
        $response = [
            'success' => false,
            'data' => null,
            'message' => ''
        ];

        try {
            switch ($action) {
                case 'getTipoAseo':
                    $response['data'] = DB::select('SELECT ctrol_aseo, tipo_aseo, descripcion FROM ta_16_tipo_aseo ORDER BY ctrol_aseo');
                    $response['success'] = true;
                    break;
                case 'buscarContrato':
                    $contrato = $params['contrato'] ?? null;
                    $ctrol_aseo = $params['ctrol_aseo'] ?? null;
                    if (!$contrato || !$ctrol_aseo) {
                        $response['message'] = 'Faltan parámetros.';
                        break;
                    }
                    $result = DB::select('SELECT control_contrato, num_contrato, ctrol_aseo FROM ta_16_contratos WHERE num_contrato = ? AND ctrol_aseo = ? ORDER BY num_contrato', [$contrato, $ctrol_aseo]);
                    $response['data'] = $result;
                    $response['success'] = true;
                    break;
                case 'buscarPagos':
                    $control_contrato = $params['control_contrato'] ?? null;
                    if (!$control_contrato) {
                        $response['message'] = 'Falta control_contrato.';
                        break;
                    }
                    $result = DB::select('CALL sp_pagos_cons_cont_buscar_pagos(?)', [$control_contrato]);
                    $response['data'] = $result;
                    $response['success'] = true;
                    break;
                case 'edoCuentaPDF':
                    // Aquí se llamaría a un SP que genera el PDF y retorna la URL o base64
                    $control_contrato = $params['control_contrato'] ?? null;
                    if (!$control_contrato) {
                        $response['message'] = 'Falta control_contrato.';
                        break;
                    }
                    $pdf = DB::select('SELECT * FROM sp_pagos_cons_cont_edocuenta(?)', [$control_contrato]);
                    $response['data'] = $pdf;
                    $response['success'] = true;
                    break;
                default:
                    $response['message'] = 'Acción no soportada.';
            }
        } catch (\Exception $e) {
            $response['message'] = $e->getMessage();
        }
        return response()->json($response);
    }
}

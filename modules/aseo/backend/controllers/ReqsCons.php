<?php

namespace App\Http\Controllers\Api;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use App\Http\Controllers\Controller;

class ReqsConsController extends Controller
{
    /**
     * Endpoint único para ejecutar acciones (eRequest/eResponse)
     */
    public function execute(Request $request)
    {
        $action = $request->input('action');
        $params = $request->input('params', []);
        $response = [
            'status' => 'error',
            'message' => 'Acción no reconocida',
            'data' => null
        ];

        try {
            switch ($action) {
                case 'getTipoAseo':
                    $data = DB::select('SELECT ctrol_aseo, tipo_aseo, descripcion FROM ta_16_tipo_aseo ORDER BY ctrol_aseo');
                    $response = ['status' => 'ok', 'data' => $data];
                    break;
                case 'getRecaudadoras':
                    $data = DB::select('SELECT id_rec, recaudadora FROM ta_12_recaudadoras ORDER BY id_rec');
                    $response = ['status' => 'ok', 'data' => $data];
                    break;
                case 'buscarContrato':
                    $contrato = $params['contrato'] ?? null;
                    $ctrolAseo = $params['ctrol_aseo'] ?? null;
                    $data = DB::selectOne('SELECT control_contrato, status_vigencia FROM ta_16_contratos WHERE num_contrato = ? AND ctrol_aseo = ?', [$contrato, $ctrolAseo]);
                    $response = ['status' => $data ? 'ok' : 'not_found', 'data' => $data];
                    break;
                case 'buscarApremios':
                    $controlContrato = $params['control_contrato'] ?? null;
                    $data = DB::select('SELECT id_control, folio, importe_multa, importe_recargo, importe_gastos, fecha_emision, fecha_practicado, vigencia FROM ta_15_apremios WHERE modulo = 16 AND control_otr = ? AND vigencia = \'1\' AND clave_practicado = \'P\' ORDER BY folio', [$controlContrato]);
                    $response = ['status' => 'ok', 'data' => $data];
                    break;
                case 'buscarPeriodosApremio':
                    $idApremio = $params['id_apremio'] ?? null;
                    $data = DB::select('SELECT id_control, control_otr, ayo, periodo, importe, recargos, cantidad, tipo FROM ta_15_periodos WHERE control_otr = ? ORDER BY ayo, periodo', [$idApremio]);
                    $response = ['status' => 'ok', 'data' => $data];
                    break;
                case 'buscarConvenio':
                    $idlc = $params['idlc'] ?? null;
                    $data = DB::selectOne('SELECT (trim(d.letras_exp)||\'/\'||d.numero_exp||\'/\'||d.axo_exp) convenio FROM ta_17_referencia a, ta_17_conv_d_resto b, ta_17_conv_diverso d WHERE a.id_referencia = ? AND a.modulo = 16 AND b.id_conv_resto = a.id_conv_resto AND b.vigencia = \'A\' AND d.tipo = b.tipo AND d.id_conv_diver = b.id_conv_diver', [$idlc]);
                    $response = ['status' => $data ? 'ok' : 'not_found', 'data' => $data];
                    break;
                case 'ejecutarPagoApremio':
                    // params: fecha, id_rec, caja, operacion, importe_gastos, id_control
                    $result = DB::statement('CALL sp_pagar_apremio(?, ?, ?, ?, ?, ?)', [
                        $params['fecha'],
                        $params['id_rec'],
                        $params['caja'],
                        $params['operacion'],
                        $params['importe_gastos'],
                        $params['id_control']
                    ]);
                    $response = ['status' => 'ok', 'message' => 'Pago registrado'];
                    break;
                default:
                    $response = ['status' => 'error', 'message' => 'Acción no reconocida'];
            }
        } catch (\Exception $e) {
            $response = ['status' => 'error', 'message' => $e->getMessage()];
        }
        return response()->json($response);
    }
}

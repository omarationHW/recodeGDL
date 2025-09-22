<?php

namespace App\Http\Controllers\Api;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;
use App\Http\Controllers\Controller;

class ExecuteController extends Controller
{
    /**
     * Endpoint único para ejecutar acciones del sistema (eRequest/eResponse)
     *
     * @param Request $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function execute(Request $request)
    {
        $eRequest = $request->input('eRequest');
        $action = $eRequest['action'] ?? null;
        $params = $eRequest['params'] ?? [];
        $userId = $request->user()->id ?? null;
        $eResponse = [
            'success' => false,
            'data' => null,
            'message' => ''
        ];

        try {
            switch ($action) {
                case 'getEstacionamiento':
                    $result = DB::select('SELECT a.*, b.descripcion FROM pubmain a JOIN pubcategoria b ON a.pubcategoria_id = b.id WHERE a.numesta = ?', [$params['numesta']]);
                    $eResponse['success'] = true;
                    $eResponse['data'] = $result;
                    break;
                case 'updateEstacionamiento':
                    $result = DB::select('SELECT * FROM sppubmodi(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)', [
                        $params['id'],
                        $params['sector'],
                        $params['zona'],
                        $params['subzona'],
                        $params['numlicencia'],
                        $params['cvecuenta'],
                        $params['calle'],
                        $params['numext'],
                        $params['telefono'],
                        $params['fecha_at'],
                        $params['fecha_inicial'],
                        $params['fecha_vencimiento'],
                        $params['movto_cve'],
                        $userId,
                        $params['solicitud'],
                        $params['control']
                    ]);
                    $eResponse['success'] = true;
                    $eResponse['data'] = $result;
                    break;
                case 'bajaEstacionamiento':
                    $result = DB::select('SELECT * FROM sppubbaja(?, ?, ?, ?, ?)', [
                        $params['id'],
                        $params['movto_cve'],
                        $userId,
                        $params['folio'],
                        $params['fecbaja']
                    ]);
                    $eResponse['success'] = true;
                    $eResponse['data'] = $result;
                    break;
                case 'getAdeudos':
                    $result = DB::select('SELECT * FROM cajero_pub_detalle(?, ?, ?, ?)', [3, $params['pubid'], 0, 0]);
                    $eResponse['success'] = true;
                    $eResponse['data'] = $result;
                    break;
                case 'getRecibos':
                    $result = DB::select('SELECT fecha_movto, pag_reca, pag_caja, pag_operacion, pag_importe, COUNT(clave) as count FROM pubadeudo_histo WHERE pubmain_id = ? GROUP BY fecha_movto, pag_reca, pag_caja, pag_operacion, pag_importe ORDER BY fecha_movto', [$params['pubmain_id']]);
                    $eResponse['success'] = true;
                    $eResponse['data'] = $result;
                    break;
                case 'getReciboDetalle':
                    $result = DB::select('SELECT b.tipo, a.concepto, a.axo, a.mes, a.ade_importe, a.ade_descto, a.ade_recgos, a.ade_importe + a.ade_recgos as total, a.fecha_movto, a.pag_reca, a.pag_caja, a.pag_operacion FROM pubadeudo_histo a JOIN pubtipoadeudo b ON b.tipo_id = a.tipo WHERE a.pubmain_id = ? AND a.fecha_movto = ? AND a.pag_reca = ? AND a.pag_caja = ? AND a.pag_operacion = ?', [
                        $params['pubmain_id'],
                        $params['fecha_movto'],
                        $params['pag_reca'],
                        $params['pag_caja'],
                        $params['pag_operacion']
                    ]);
                    $eResponse['success'] = true;
                    $eResponse['data'] = $result;
                    break;
                case 'getCategorias':
                    $result = DB::select('SELECT id, tipo, categoria, descripcion FROM pubcategoria WHERE tipo = ?', ['N']);
                    $eResponse['success'] = true;
                    $eResponse['data'] = $result;
                    break;
                case 'deleteAdeudo':
                    $result = DB::statement('CALL delete_pubadeudo(?, ?, ?)', [
                        $params['pubmain_id'],
                        $params['axo'],
                        $params['mes']
                    ]);
                    $eResponse['success'] = true;
                    $eResponse['message'] = 'Adeudo eliminado correctamente';
                    break;
                case 'insertAdeudo':
                    $result = DB::statement('CALL insert_pubadeudo(?, ?, ?, ?, ?, ?)', [
                        $params['pubmain_id'],
                        $params['axo'],
                        $params['mes'],
                        $params['concepto'],
                        $params['ade_importe'],
                        $userId
                    ]);
                    $eResponse['success'] = true;
                    $eResponse['message'] = 'Adeudo insertado correctamente';
                    break;
                case 'actualizaPubPago':
                    $result = DB::select('SELECT * FROM actualiza_pub_pago(?, ?, ?, ?, ?, ?, ?, ?, ?)', [
                        $params['opc'],
                        $params['pubmain_id'],
                        $params['axo'],
                        $params['mes'],
                        $params['tipo'],
                        $params['fecha'],
                        $params['reca'],
                        $params['caja'],
                        $params['operacion']
                    ]);
                    $eResponse['success'] = true;
                    $eResponse['data'] = $result;
                    break;
                case 'spPubMovtos':
                    $result = DB::select('SELECT * FROM sp_pub_movtos(?, ?, ?, ?, ?, ?, ?)', [
                        $params['opc'],
                        $params['pubmain_id'],
                        $params['fecha'],
                        $params['cajones'],
                        $params['categoria'],
                        $params['oficio'],
                        $userId
                    ]);
                    $eResponse['success'] = true;
                    $eResponse['data'] = $result;
                    break;
                case 'getMultasRelacionadas':
                    $result = DB::select('SELECT (d.numesta) as num_esta, (d.fecha_baja) as fec_baja_esta, (a.vigente) as status_rel, b.id_multa, b.id_dependencia, c.descripcion, b.axo_acta, b.num_acta, b.fecha_acta, b.fecha_recepcion, b.fecha_cancelacion, b.contribuyente, b.domicilio, b.noexterior, b.interior, b.recaud, b.num_licencia, b.giro, b.id_ley, b.id_infraccion, b.expediente, b.calificacion, b.multa, b.gastos, b.total, b.observacion, b.fecha_plazo, b.comentario FROM pub_rel_multas a, catastro_gdl.multas b, catastro_gdl.c_dependencias c, pubmain d WHERE a.pubmain_id = ? AND b.id_multa = a.id_multa AND b.id_dependencia = a.id_dependencia AND b.axo_acta = a.axo_acta AND b.num_acta = a.num_acta AND c.id_dependencia = b.id_dependencia AND d.id = a.pubmain_id ORDER BY d.numesta', [$params['parNumEsta']]);
                    $eResponse['success'] = true;
                    $eResponse['data'] = $result;
                    break;
                // ... otros casos según sea necesario
                default:
                    $eResponse['message'] = 'Acción no soportada';
            }
        } catch (\Exception $e) {
            Log::error('API Execute Error: ' . $e->getMessage());
            $eResponse['message'] = $e->getMessage();
        }
        return response()->json(['eResponse' => $eResponse]);
    }
}

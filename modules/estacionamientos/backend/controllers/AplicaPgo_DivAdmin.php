<?php

namespace App\Http\Controllers\Api;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;
use App\Http\Controllers\Controller;

class ExecuteController extends Controller
{
    /**
     * Handle unified API requests (eRequest/eResponse pattern)
     * Endpoint: /api/execute
     */
    public function execute(Request $request)
    {
        $eRequest = $request->input('eRequest');
        $eResponse = [
            'success' => false,
            'data' => null,
            'message' => ''
        ];

        try {
            switch ($eRequest['action']) {
                case 'getRecaudadoras':
                    $recaudadoras = DB::select('SELECT * FROM ta_12_recaudadoras ORDER BY id_rec');
                    $eResponse['success'] = true;
                    $eResponse['data'] = $recaudadoras;
                    break;
                case 'buscarFolios':
                    $params = $eRequest['params'];
                    $result = DB::select('SELECT * FROM sp_busca_folios_divadmin(:opcion, :placa, :folio, :axo)', [
                        'opcion' => $params['opcion'],
                        'placa' => $params['placa'],
                        'folio' => $params['folio'],
                        'axo' => $params['axo']
                    ]);
                    $eResponse['success'] = true;
                    $eResponse['data'] = $result;
                    break;
                case 'aplicarPagosDiversosAdmin':
                    $params = $eRequest['params'];
                    $aplicados = [];
                    $errores = [];
                    DB::beginTransaction();
                    try {
                        foreach ($params['folios'] as $folio) {
                            $res = DB::select('SELECT * FROM sp_aplica_pago_divadmin(:axo, :folio, :fecha, :reca, :caja, :oper, :usuario)', [
                                'axo' => $folio['axo'],
                                'folio' => $folio['folio'],
                                'fecha' => $params['fecha'],
                                'reca' => $params['reca'],
                                'caja' => $params['caja'],
                                'oper' => $params['oper'],
                                'usuario' => $params['usuario']
                            ]);
                            if (isset($res[0]->success) && $res[0]->success) {
                                $aplicados[] = $folio['folio'];
                            } else {
                                $errores[] = $folio['folio'];
                            }
                        }
                        DB::commit();
                        $eResponse['success'] = true;
                        $eResponse['data'] = [
                            'aplicados' => $aplicados,
                            'errores' => $errores
                        ];
                        $eResponse['message'] = count($errores) > 0 ?
                            'Finalizó con errores en algunos registros.' :
                            'Todos los pagos aplicados correctamente.';
                    } catch (\Exception $ex) {
                        DB::rollBack();
                        $eResponse['message'] = 'Error al aplicar pagos: ' . $ex->getMessage();
                        $eResponse['data'] = [
                            'aplicados' => $aplicados,
                            'errores' => $errores
                        ];
                    }
                    break;
                default:
                    $eResponse['message'] = 'Acción no reconocida.';
            }
        } catch (\Exception $e) {
            Log::error('API Execute error: ' . $e->getMessage());
            $eResponse['message'] = 'Error interno: ' . $e->getMessage();
        }

        return response()->json(['eResponse' => $eResponse]);
    }
}

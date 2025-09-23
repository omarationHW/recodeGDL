<?php

namespace App\Http\Controllers\Api;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
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
        $params = $request->input('params', []);
        $userId = $request->user() ? $request->user()->id : null;
        $eResponse = [
            'success' => false,
            'data' => null,
            'message' => '',
            'errors' => null
        ];

        try {
            switch ($eRequest) {
                case 'getMaxAxo':
                    $result = DB::select('SELECT max(axo) as axo FROM ta_axocaptura');
                    $eResponse['success'] = true;
                    $eResponse['data'] = $result[0];
                    break;

                case 'searchConciliadosByFolio':
                    $axo = $params['axo'] ?? null;
                    $folio = $params['folio'] ?? null;
                    if (!$axo || !$folio) {
                        throw new \Exception('Año y folio son requeridos');
                    }
                    $result = DB::select('SELECT * FROM sp_conciliados_by_folio(?, ?)', [$axo, $folio]);
                    $eResponse['success'] = true;
                    $eResponse['data'] = $result;
                    break;

                case 'searchConciliadosByFecha':
                    $fecha = $params['fecha'] ?? null;
                    if (!$fecha) {
                        throw new \Exception('Fecha es requerida');
                    }
                    $result = DB::select('SELECT * FROM sp_conciliados_by_fecha(?)', [$fecha]);
                    $eResponse['success'] = true;
                    $eResponse['data'] = $result;
                    break;

                case 'getHistoByAxoFolio':
                    $axo = $params['axo'] ?? null;
                    $folio = $params['folio'] ?? null;
                    if (!$axo || !$folio) {
                        throw new \Exception('Año y folio son requeridos');
                    }
                    $result = DB::select('SELECT * FROM sp_histo_by_axo_folio(?, ?)', [$axo, $folio]);
                    $eResponse['success'] = true;
                    $eResponse['data'] = $result;
                    break;

                case 'cambiarPlaca':
                    $control = $params['control'] ?? null;
                    $idbanco = $params['idbanco'] ?? null;
                    $axo = $params['axo'] ?? null;
                    $folio = $params['folio'] ?? null;
                    $placa = $params['placa'] ?? null;
                    $id_usuario = $userId ?? ($params['id_usuario'] ?? null);
                    $opcion = 1;
                    $result = DB::select('SELECT * FROM spd_chg_conci(?, ?, ?, ?, ?, ?, ?)', [
                        $control, $idbanco, $axo, $folio, $placa, $id_usuario, $opcion
                    ]);
                    $clave = $result[0]->clave ?? null;
                    $eResponse['success'] = ($clave == 0);
                    $eResponse['data'] = $result[0];
                    $eResponse['message'] = ($clave == 0) ? 'Cambio realizado correctamente' : 'No se realizó el cambio, Verificar...';
                    break;

                case 'cambiarFolio':
                    $control = $params['control'] ?? null;
                    $idbanco = $params['idbanco'] ?? null;
                    $axo = $params['axo'] ?? null;
                    $folio = $params['folio'] ?? null;
                    $placa = $params['placa'] ?? null;
                    $id_usuario = $userId ?? ($params['id_usuario'] ?? null);
                    $opcion = $params['opcion'] ?? 2; // 2: existe folio, 3: no existe
                    $result = DB::select('SELECT * FROM spd_chg_conci(?, ?, ?, ?, ?, ?, ?)', [
                        $control, $idbanco, $axo, $folio, $placa, $id_usuario, $opcion
                    ]);
                    $clave = $result[0]->clave ?? null;
                    $eResponse['success'] = ($clave == 0);
                    $eResponse['data'] = $result[0];
                    $eResponse['message'] = ($clave == 0) ? 'Cambio realizado correctamente' : 'No se realizó el cambio, Verificar...';
                    break;

                default:
                    throw new \Exception('eRequest no soportado');
            }
        } catch (\Exception $e) {
            $eResponse['success'] = false;
            $eResponse['message'] = $e->getMessage();
            $eResponse['errors'] = method_exists($e, 'getTrace') ? $e->getTrace() : null;
        }

        return response()->json(['eResponse' => $eResponse]);
    }
}

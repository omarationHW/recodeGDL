<?php

namespace App\Http\Controllers\Api;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use App\Http\Controllers\Controller;

class ExecuteController extends Controller
{
    /**
     * Endpoint unificado para ejecutar acciones del formulario RAdeudos_OpcMult
     * Entrada: {
     *   eRequest: {
     *     action: string, // 'search_local', 'get_adeudos', 'execute_opc', 'get_recaudadoras', 'get_cajas'
     *     params: {...}
     *   }
     * }
     * Salida: {
     *   eResponse: {...}
     * }
     */
    public function execute(Request $request)
    {
        $eRequest = $request->input('eRequest');
        $action = $eRequest['action'] ?? null;
        $params = $eRequest['params'] ?? [];
        $eResponse = [];

        try {
            switch ($action) {
                case 'search_local':
                    // Busca local por número y letra
                    $control = trim($params['numero']) . '-' . trim($params['letra']);
                    $local = DB::selectOne('SELECT * FROM t34_datos WHERE control = ?', [$control]);
                    if ($local) {
                        $eResponse['local'] = $local;
                    } else {
                        $eResponse['error'] = 'No existe LOCAL con este dato, intentalo de nuevo';
                    }
                    break;
                case 'get_adeudos':
                    // Obtiene adeudos por id_datos
                    $id_datos = $params['id_datos'];
                    $adeudos = DB::select('SELECT * FROM con34_rdetade_021($1)', [$id_datos]);
                    $eResponse['adeudos'] = $adeudos;
                    break;
                case 'execute_opc':
                    // Ejecuta la opción seleccionada sobre los adeudos marcados
                    $id_datos = $params['id_datos'];
                    $selected = $params['selected']; // array de {registro, axo, mes}
                    $fecha = $params['fecha'];
                    $id_rec = $params['id_rec'];
                    $caja = $params['caja'];
                    $consec = $params['consec'];
                    $folio_rcbo = $params['folio_rcbo'];
                    $status = $params['status']; // 'P', 'S', 'C', 'R'
                    $opc = $params['opc']; // 'B'
                    $results = [];
                    DB::beginTransaction();
                    try {
                        foreach ($selected as $row) {
                            $result = DB::selectOne('SELECT * FROM upd34_ade_01(?,?,?,?,?,?,?,?,?,?,?)', [
                                $row['registro'],
                                $row['axo'],
                                $row['mes'],
                                $fecha,
                                $id_rec,
                                $caja,
                                $consec,
                                $folio_rcbo,
                                'E',
                                $status,
                                $opc
                            ]);
                            $results[] = $result;
                            if ($result->status != 0) {
                                throw new \Exception($result->concepto_status);
                            }
                        }
                        DB::commit();
                        $eResponse['results'] = $results;
                        $eResponse['success'] = true;
                    } catch (\Exception $ex) {
                        DB::rollBack();
                        $eResponse['error'] = 'Error al REALIZAR EL PROCESO upd34_ade_01: ' . $ex->getMessage();
                        $eResponse['success'] = false;
                    }
                    break;
                case 'get_recaudadoras':
                    $recaudadoras = DB::select('SELECT id_rec, recaudadora FROM ta_12_recaudadoras ORDER BY id_rec');
                    $eResponse['recaudadoras'] = $recaudadoras;
                    break;
                case 'get_cajas':
                    $cajas = DB::select('SELECT id_rec, caja FROM ta_12_operaciones ORDER BY id_rec, caja');
                    $eResponse['cajas'] = $cajas;
                    break;
                default:
                    $eResponse['error'] = 'Acción no soportada';
            }
        } catch (\Exception $e) {
            $eResponse['error'] = $e->getMessage();
        }

        return response()->json(['eResponse' => $eResponse]);
    }
}

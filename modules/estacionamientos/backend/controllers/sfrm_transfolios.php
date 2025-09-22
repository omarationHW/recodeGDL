<?php

namespace App\Http\Controllers\Api;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;
use App\Http\Controllers\Controller;

class ExecuteController extends Controller
{
    /**
     * Endpoint unificado para ejecutar operaciones del formulario sfrm_transfolios
     * Entrada: {
     *   eRequest: {
     *     action: 'altas_folios'|'bajas_folios'|'altas_calcomanias',
     *     data: [...], // array de registros
     *     usuario_id: int,
     *     ejercicio: int
     *   }
     * }
     * Salida: {
     *   eResponse: {
     *     status: 'ok'|'error',
     *     message: string,
     *     results: [...]
     *   }
     * }
     */
    public function execute(Request $request)
    {
        $input = $request->input('eRequest');
        $action = $input['action'] ?? null;
        $data = $input['data'] ?? [];
        $usuario_id = $input['usuario_id'] ?? null;
        $ejercicio = $input['ejercicio'] ?? null;
        $results = [];

        try {
            switch ($action) {
                case 'altas_folios':
                    foreach ($data as $row) {
                        $res = DB::select('SELECT * FROM sp_altas_folios(:axo, :folio, :placa, :fec, :clave, :estado, :agente, :captura)', [
                            'axo' => $row['axo'],
                            'folio' => $row['folio'],
                            'placa' => $row['placa'],
                            'fec' => $row['fec'],
                            'clave' => $row['clave'],
                            'estado' => 14,
                            'agente' => 1,
                            'captura' => $usuario_id
                        ]);
                        $results[] = [
                            'row' => $row,
                            'status' => ($res && $res[0]->result == 1) ? 'OK' : 'error',
                            'message' => $res[0]->msg ?? ''
                        ];
                    }
                    return response()->json(['eResponse' => [
                        'status' => 'ok',
                        'message' => 'Altas de folios procesadas',
                        'results' => $results
                    ]]);
                case 'bajas_folios':
                    foreach ($data as $row) {
                        $res = DB::select('SELECT * FROM sp_bajas_folios(:axo, :folio, :placa, :fecha, :convenio, :reca, :caja, :oper, :opc, :usuauto)', [
                            'axo' => $row['axo'],
                            'folio' => $row['folio'],
                            'placa' => $row['placa'],
                            'fecha' => $row['fecha'],
                            'convenio' => 0,
                            'reca' => 1,
                            'caja' => 'Z',
                            'oper' => 0,
                            'opc' => $row['opc'],
                            'usuauto' => $usuario_id
                        ]);
                        $results[] = [
                            'row' => $row,
                            'status' => ($res && $res[0]->result == 1) ? 'OK' : 'error',
                            'message' => $res[0]->msg ?? ''
                        ];
                    }
                    return response()->json(['eResponse' => [
                        'status' => 'ok',
                        'message' => 'Bajas de folios procesadas',
                        'results' => $results
                    ]]);
                case 'altas_calcomanias':
                    foreach ($data as $row) {
                        $res = DB::select('SELECT * FROM sp_altas_calcomanias(:axo, :calco, :status, :turno, :fecini, :fecfin, :placa, :propie, :usu)', [
                            'axo' => $ejercicio,
                            'calco' => $row['calco'],
                            'status' => $row['status'],
                            'turno' => $row['turno'],
                            'fecini' => $row['fecini'],
                            'fecfin' => $row['fecfin'],
                            'placa' => $row['placa'],
                            'propie' => 1,
                            'usu' => $usuario_id
                        ]);
                        $results[] = [
                            'row' => $row,
                            'status' => ($res && $res[0]->result == 1) ? 'OK' : 'error',
                            'message' => $res[0]->msg ?? ''
                        ];
                    }
                    return response()->json(['eResponse' => [
                        'status' => 'ok',
                        'message' => 'Altas de calcomanías procesadas',
                        'results' => $results
                    ]]);
                default:
                    return response()->json(['eResponse' => [
                        'status' => 'error',
                        'message' => 'Acción no soportada',
                        'results' => []
                    ]], 400);
            }
        } catch (\Exception $e) {
            return response()->json(['eResponse' => [
                'status' => 'error',
                'message' => $e->getMessage(),
                'results' => []
            ]], 500);
        }
    }
}

<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;

class ListadosController extends Controller
{
    /**
     * Endpoint unificado para ejecutar acciones de Listados
     * Entrada: eRequest (JSON)
     * Salida: eResponse (JSON)
     */
    public function execute(Request $request)
    {
        $input = $request->all();
        $action = $input['eRequest']['action'] ?? null;
        $params = $input['eRequest']['params'] ?? [];
        $response = [
            'success' => false,
            'data' => null,
            'message' => ''
        ];

        try {
            switch ($action) {
                case 'getClaves':
                    $response['data'] = DB::select('SELECT * FROM sp_listados_get_claves()');
                    $response['success'] = true;
                    break;
                case 'getVigencias':
                    $response['data'] = DB::select('SELECT * FROM sp_listados_get_vigencias()');
                    $response['success'] = true;
                    break;
                case 'getRecaudadoras':
                    $response['data'] = DB::select('SELECT * FROM sp_listados_get_recaudadoras()');
                    $response['success'] = true;
                    break;
                case 'getListados':
                    $validator = Validator::make($params, [
                        'id_rec' => 'required|integer',
                        'modulo' => 'required|integer',
                        'folio_desde' => 'required|integer',
                        'folio_hasta' => 'required|integer',
                        'clave' => 'required|string',
                        'vigencia' => 'required|string',
                        'fecha_prac_desde' => 'nullable|date',
                        'fecha_prac_hasta' => 'nullable|date'
                    ]);
                    if ($validator->fails()) {
                        $response['message'] = $validator->errors()->first();
                        break;
                    }
                    $result = DB::select('SELECT * FROM sp_listados_get_listados(?,?,?,?,?,?,?,?)', [
                        $params['id_rec'],
                        $params['modulo'],
                        $params['folio_desde'],
                        $params['folio_hasta'],
                        $params['clave'],
                        $params['vigencia'],
                        $params['fecha_prac_desde'],
                        $params['fecha_prac_hasta']
                    ]);
                    $response['data'] = $result;
                    $response['success'] = true;
                    break;
                case 'exportExcel':
                    // Lógica para exportar a Excel (puede ser un job o respuesta base64)
                    $response['message'] = 'Funcionalidad de exportación a Excel no implementada en este endpoint.';
                    break;
                default:
                    $response['message'] = 'Acción no soportada.';
            }
        } catch (\Exception $e) {
            $response['message'] = $e->getMessage();
        }

        return response()->json(['eResponse' => $response]);
    }
}

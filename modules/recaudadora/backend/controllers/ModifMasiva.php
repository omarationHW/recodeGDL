<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;

class ModifMasivaController extends Controller
{
    /**
     * Endpoint único para ejecutar acciones de modificación masiva de requerimientos.
     * Recibe eRequest con acción y parámetros.
     */
    public function execute(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'action' => 'required|string',
            'params' => 'required|array',
            'user'   => 'required|string',
        ]);
        if ($validator->fails()) {
            return response()->json([
                'eResponse' => [
                    'status' => 'error',
                    'message' => $validator->errors()->first()
                ]
            ], 400);
        }

        $action = $request->input('action');
        $params = $request->input('params');
        $user   = $request->input('user');

        try {
            switch ($action) {
                case 'modificar_predial':
                    $result = DB::select('SELECT * FROM sp_modifmasiva_predial(?, ?, ?, ?, ?)', [
                        $params['recaud'],
                        $params['folio_ini'],
                        $params['folio_fin'],
                        $params['fecha'],
                        $user
                    ]);
                    break;
                case 'cancelar_predial':
                    $result = DB::select('SELECT * FROM sp_cancelamasiva_predial(?, ?, ?, ?, ?)', [
                        $params['recaud'],
                        $params['folio_ini'],
                        $params['folio_fin'],
                        $params['fecha'],
                        $user
                    ]);
                    break;
                case 'modificar_multa':
                    $result = DB::select('SELECT * FROM sp_modifmasiva_multa(?, ?, ?, ?, ?)', [
                        $params['recaud'],
                        $params['folio_ini'],
                        $params['folio_fin'],
                        $params['fecha'],
                        $user
                    ]);
                    break;
                case 'cancelar_multa':
                    $result = DB::select('SELECT * FROM sp_cancelamasiva_multa(?, ?, ?, ?, ?)', [
                        $params['recaud'],
                        $params['folio_ini'],
                        $params['folio_fin'],
                        $params['fecha'],
                        $user
                    ]);
                    break;
                case 'modificar_licencia':
                    $result = DB::select('SELECT * FROM sp_modifmasiva_licencia(?, ?, ?, ?, ?)', [
                        $params['recaud'],
                        $params['folio_ini'],
                        $params['folio_fin'],
                        $params['fecha'],
                        $user
                    ]);
                    break;
                case 'cancelar_licencia':
                    $result = DB::select('SELECT * FROM sp_cancelamasiva_licencia(?, ?, ?, ?, ?)', [
                        $params['recaud'],
                        $params['folio_ini'],
                        $params['folio_fin'],
                        $params['fecha'],
                        $user
                    ]);
                    break;
                case 'modificar_anuncio':
                    $result = DB::select('SELECT * FROM sp_modifmasiva_anuncio(?, ?, ?, ?, ?)', [
                        $params['recaud'],
                        $params['folio_ini'],
                        $params['folio_fin'],
                        $params['fecha'],
                        $user
                    ]);
                    break;
                case 'cancelar_anuncio':
                    $result = DB::select('SELECT * FROM sp_cancelamasiva_anuncio(?, ?, ?, ?, ?)', [
                        $params['recaud'],
                        $params['folio_ini'],
                        $params['folio_fin'],
                        $params['fecha'],
                        $user
                    ]);
                    break;
                default:
                    return response()->json([
                        'eResponse' => [
                            'status' => 'error',
                            'message' => 'Acción no soportada.'
                        ]
                    ], 400);
            }
            return response()->json([
                'eResponse' => [
                    'status' => 'success',
                    'data' => $result
                ]
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'eResponse' => [
                    'status' => 'error',
                    'message' => $e->getMessage()
                ]
            ], 500);
        }
    }
}

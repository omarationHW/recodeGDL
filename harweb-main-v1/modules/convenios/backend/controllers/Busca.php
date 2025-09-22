<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;

class BuscaController extends Controller
{
    /**
     * Endpoint único para ejecutar acciones del formulario Busca
     * Entrada: eRequest con action y params
     * Salida: eResponse con status, data, message
     */
    public function execute(Request $request)
    {
        $eRequest = $request->input('eRequest');
        $action = $eRequest['action'] ?? null;
        $params = $eRequest['params'] ?? [];
        $eResponse = [
            'status' => 'error',
            'data' => null,
            'message' => 'Acción no válida'
        ];

        try {
            switch ($action) {
                case 'searchByNombre':
                    $validator = Validator::make($params, [
                        'nombre' => 'required|string|max:255'
                    ]);
                    if ($validator->fails()) {
                        $eResponse['message'] = $validator->errors()->first();
                        break;
                    }
                    $result = DB::select('CALL sp_busca_by_nombre(?)', [$params['nombre']]);
                    $eResponse = [
                        'status' => 'success',
                        'data' => $result,
                        'message' => 'Búsqueda por nombre exitosa'
                    ];
                    break;
                case 'searchByDomicilio':
                    $validator = Validator::make($params, [
                        'calle' => 'required|string|max:255',
                        'num_exterior' => 'nullable|integer'
                    ]);
                    if ($validator->fails()) {
                        $eResponse['message'] = $validator->errors()->first();
                        break;
                    }
                    $result = DB::select('CALL sp_busca_by_domicilio(?, ?)', [
                        $params['calle'],
                        $params['num_exterior'] ?? null
                    ]);
                    $eResponse = [
                        'status' => 'success',
                        'data' => $result,
                        'message' => 'Búsqueda por domicilio exitosa'
                    ];
                    break;
                case 'searchByCuenta':
                    $validator = Validator::make($params, [
                        'rec' => 'required|integer',
                        'ur' => 'required|string|max:10',
                        'cuenta' => 'required|integer'
                    ]);
                    if ($validator->fails()) {
                        $eResponse['message'] = $validator->errors()->first();
                        break;
                    }
                    $result = DB::select('CALL sp_busca_by_cuenta(?, ?, ?)', [
                        $params['rec'],
                        $params['ur'],
                        $params['cuenta']
                    ]);
                    $eResponse = [
                        'status' => 'success',
                        'data' => $result,
                        'message' => 'Búsqueda por cuenta exitosa'
                    ];
                    break;
                case 'searchByLicencia':
                    $validator = Validator::make($params, [
                        'licencia' => 'required|integer'
                    ]);
                    if ($validator->fails()) {
                        $eResponse['message'] = $validator->errors()->first();
                        break;
                    }
                    $result = DB::select('CALL sp_busca_by_licencia(?)', [
                        $params['licencia']
                    ]);
                    $eResponse = [
                        'status' => 'success',
                        'data' => $result,
                        'message' => 'Búsqueda por licencia exitosa'
                    ];
                    break;
                case 'searchByAnuncio':
                    $validator = Validator::make($params, [
                        'anuncio' => 'required|integer'
                    ]);
                    if ($validator->fails()) {
                        $eResponse['message'] = $validator->errors()->first();
                        break;
                    }
                    $result = DB::select('CALL sp_busca_by_anuncio(?)', [
                        $params['anuncio']
                    ]);
                    $eResponse = [
                        'status' => 'success',
                        'data' => $result,
                        'message' => 'Búsqueda por anuncio exitosa'
                    ];
                    break;
                case 'searchByMulta':
                    $validator = Validator::make($params, [
                        'dependencia' => 'required|string|max:10',
                        'axo_acta' => 'required|integer',
                        'num_acta' => 'required|integer'
                    ]);
                    if ($validator->fails()) {
                        $eResponse['message'] = $validator->errors()->first();
                        break;
                    }
                    $result = DB::select('CALL sp_busca_by_multa(?, ?, ?)', [
                        $params['dependencia'],
                        $params['axo_acta'],
                        $params['num_acta']
                    ]);
                    $eResponse = [
                        'status' => 'success',
                        'data' => $result,
                        'message' => 'Búsqueda por multa exitosa'
                    ];
                    break;
                // ... otros casos para mercados, aseo, permiso, estacionamiento, lic. construcción
                default:
                    $eResponse['message'] = 'Acción no reconocida';
            }
        } catch (\Exception $ex) {
            $eResponse['status'] = 'error';
            $eResponse['message'] = $ex->getMessage();
        }
        return response()->json(['eResponse' => $eResponse]);
    }
}

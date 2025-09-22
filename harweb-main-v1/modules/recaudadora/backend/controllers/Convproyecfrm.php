<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;

class ConvenioProyeccionController extends Controller
{
    /**
     * Endpoint único para ejecutar acciones del formulario de convenio proyección.
     * Entrada: eRequest (objeto JSON con acción y parámetros)
     * Salida: eResponse (objeto JSON con resultado, datos, errores)
     */
    public function execute(Request $request)
    {
        $eRequest = $request->input('eRequest');
        $action = $eRequest['action'] ?? null;
        $params = $eRequest['params'] ?? [];
        $eResponse = [
            'success' => false,
            'data' => null,
            'errors' => []
        ];

        try {
            switch ($action) {
                case 'getConvenioProyeccion':
                    $validator = Validator::make($params, [
                        'cvecuenta' => 'required|integer',
                        'mensualidades' => 'required|integer|min:1',
                        'importe' => 'required|numeric|min:0',
                        'fecha_inicial' => 'required|date',
                        'porcentaje_inicial' => 'nullable|integer|min:0|max:100'
                    ]);
                    if ($validator->fails()) {
                        $eResponse['errors'] = $validator->errors()->all();
                        break;
                    }
                    $result = DB::select('CALL spd_mens_convenio(?, ?, ?, ?)', [
                        $params['cvecuenta'],
                        $params['mensualidades'],
                        $params['importe'],
                        $params['fecha_inicial']
                    ]);
                    $eResponse['success'] = true;
                    $eResponse['data'] = $result;
                    break;
                case 'getConvenioProyeccionPorcentaje':
                    $validator = Validator::make($params, [
                        'cvecuenta' => 'required|integer',
                        'mensualidades' => 'required|integer|min:1',
                        'importe' => 'required|numeric|min:0',
                        'porcentaje' => 'required|integer|min:1|max:100',
                        'fecha_inicial' => 'required|date'
                    ]);
                    if ($validator->fails()) {
                        $eResponse['errors'] = $validator->errors()->all();
                        break;
                    }
                    $result = DB::select('CALL spd_getmens_convenio(?, ?, ?, ?, ?)', [
                        $params['cvecuenta'],
                        $params['mensualidades'],
                        $params['importe'],
                        $params['porcentaje'],
                        $params['fecha_inicial']
                    ]);
                    $eResponse['success'] = true;
                    $eResponse['data'] = $result;
                    break;
                case 'getDatosCuenta':
                    $validator = Validator::make($params, [
                        'cvecuenta' => 'required|integer'
                    ]);
                    if ($validator->fails()) {
                        $eResponse['errors'] = $validator->errors()->all();
                        break;
                    }
                    $result = DB::select('SELECT * FROM vw_datos_cuenta WHERE cvecuenta = ?', [$params['cvecuenta']]);
                    $eResponse['success'] = true;
                    $eResponse['data'] = $result;
                    break;
                case 'getSaldosCuenta':
                    $validator = Validator::make($params, [
                        'cvecuenta' => 'required|integer'
                    ]);
                    if ($validator->fails()) {
                        $eResponse['errors'] = $validator->errors()->all();
                        break;
                    }
                    $result = DB::select('SELECT * FROM saldos WHERE cvecuenta = ?', [$params['cvecuenta']]);
                    $eResponse['success'] = true;
                    $eResponse['data'] = $result;
                    break;
                default:
                    $eResponse['errors'][] = 'Acción no soportada: ' . $action;
            }
        } catch (\Exception $ex) {
            $eResponse['errors'][] = $ex->getMessage();
        }
        return response()->json(['eResponse' => $eResponse]);
    }
}

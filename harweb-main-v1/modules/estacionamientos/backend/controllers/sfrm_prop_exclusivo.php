<?php

namespace App\Http\Controllers\Api;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use App\Http\Controllers\Controller;

class ExecuteController extends Controller
{
    /**
     * Handle unified API requests via /api/execute
     *
     * @param  \Illuminate\Http\Request  $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function execute(Request $request)
    {
        $eRequest = $request->input('eRequest');
        $params = $request->input('params', []);
        $eResponse = [
            'success' => false,
            'message' => '',
            'data' => null
        ];

        try {
            switch ($eRequest) {
                case 'ex_propietario_create':
                    $result = DB::select('SELECT * FROM ex_propietario_create(:sociedad, :rfc, :propietario, :domicilio, :colonia, :telefono, :celular, :email)', [
                        'sociedad' => $params['sociedad'],
                        'rfc' => $params['rfc'],
                        'propietario' => $params['propietario'],
                        'domicilio' => $params['domicilio'],
                        'colonia' => $params['colonia'],
                        'telefono' => $params['telefono'],
                        'celular' => $params['celular'],
                        'email' => $params['email'],
                    ]);
                    $eResponse['success'] = $result[0]->success;
                    $eResponse['message'] = $result[0]->message;
                    $eResponse['data'] = $result[0]->id ?? null;
                    break;
                case 'ex_propietario_update':
                    $result = DB::select('SELECT * FROM ex_propietario_update(:id, :sociedad, :rfc, :propietario, :domicilio, :colonia, :telefono, :celular, :email)', [
                        'id' => $params['id'],
                        'sociedad' => $params['sociedad'],
                        'rfc' => $params['rfc'],
                        'propietario' => $params['propietario'],
                        'domicilio' => $params['domicilio'],
                        'colonia' => $params['colonia'],
                        'telefono' => $params['telefono'],
                        'celular' => $params['celular'],
                        'email' => $params['email'],
                    ]);
                    $eResponse['success'] = $result[0]->success;
                    $eResponse['message'] = $result[0]->message;
                    $eResponse['data'] = $result[0]->id ?? null;
                    break;
                case 'ex_propietario_by_rfc':
                    $result = DB::select('SELECT * FROM ex_propietario_by_rfc(:rfc)', [
                        'rfc' => $params['rfc'],
                    ]);
                    $eResponse['success'] = true;
                    $eResponse['data'] = $result;
                    break;
                case 'ex_propietario_by_id':
                    $result = DB::select('SELECT * FROM ex_propietario_by_id(:id)', [
                        'id' => $params['id'],
                    ]);
                    $eResponse['success'] = true;
                    $eResponse['data'] = $result;
                    break;
                default:
                    $eResponse['message'] = 'Unknown eRequest: ' . $eRequest;
            }
        } catch (\Exception $e) {
            $eResponse['message'] = $e->getMessage();
        }

        return response()->json(['eResponse' => $eResponse]);
    }
}

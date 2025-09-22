<?php

namespace App\Http\Controllers\Api;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;
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
        $user = $request->user(); // If using auth

        $eResponse = [
            'success' => false,
            'data' => null,
            'message' => ''
        ];

        try {
            switch ($eRequest) {
                case 'get_infracciones':
                    $data = DB::select('SELECT * FROM ta14_infraccion');
                    $eResponse['success'] = true;
                    $eResponse['data'] = $data;
                    break;
                case 'get_estados':
                    $data = DB::select('SELECT * FROM ta14_estados');
                    $eResponse['success'] = true;
                    $eResponse['data'] = $data;
                    break;
                case 'get_vigilantes':
                    $data = DB::select('SELECT b.id_esta_persona, (TRIM(b.ap_pater) || ' ' || TRIM(b.ap_mater) || ' ' || TRIM(b.nombre)) AS agente FROM ta14_agentes a, ta14_personas b WHERE a.id_esta_persona = b.id_esta_persona ORDER BY 2');
                    $eResponse['success'] = true;
                    $eResponse['data'] = $data;
                    break;
                case 'get_axo_captura':
                    $data = DB::select('SELECT axo FROM ta_axocaptura');
                    $eResponse['success'] = true;
                    $eResponse['data'] = $data;
                    break;
                case 'get_folio_adeudo':
                    $validator = Validator::make($params, [
                        'axo' => 'required|integer',
                        'folio' => 'required|integer',
                    ]);
                    if ($validator->fails()) {
                        $eResponse['message'] = $validator->errors()->first();
                        break;
                    }
                    $data = DB::select('SELECT * FROM ta14_folios_adeudo WHERE axo = ? AND folio = ?', [$params['axo'], $params['folio']]);
                    $eResponse['success'] = true;
                    $eResponse['data'] = $data;
                    break;
                case 'get_folio_histo':
                    $validator = Validator::make($params, [
                        'axo' => 'required|integer',
                        'folio' => 'required|integer',
                    ]);
                    if ($validator->fails()) {
                        $eResponse['message'] = $validator->errors()->first();
                        break;
                    }
                    $data = DB::select('SELECT * FROM ta14_folios_histo WHERE axo = ? AND folio = ? AND codigo_movto <> 1', [$params['axo'], $params['folio']]);
                    $eResponse['success'] = true;
                    $eResponse['data'] = $data;
                    break;
                case 'get_calcomania':
                    $validator = Validator::make($params, [
                        'placa' => 'required|string',
                        'fecha' => 'required|date',
                    ]);
                    if ($validator->fails()) {
                        $eResponse['message'] = $validator->errors()->first();
                        break;
                    }
                    $data = DB::select('SELECT * FROM ta14_calcomanias WHERE placa = ? AND fecha_inicial <= ? AND fecha_fin >= ?', [$params['placa'], $params['fecha'], $params['fecha']]);
                    $eResponse['success'] = true;
                    $eResponse['data'] = $data;
                    break;
                case 'get_padron_vehiculo':
                    $validator = Validator::make($params, [
                        'placa' => 'required|string',
                    ]);
                    if ($validator->fails()) {
                        $eResponse['message'] = $validator->errors()->first();
                        break;
                    }
                    $data = DB::select('SELECT id, placa, marca, modelo, color FROM ta_padron WHERE placa = ?', [$params['placa']]);
                    $eResponse['success'] = true;
                    $eResponse['data'] = $data;
                    break;
                case 'insert_folio_adeudo':
                    $validator = Validator::make($params, [
                        'axo' => 'required|integer',
                        'folio' => 'required|integer',
                        'fecha_folio' => 'required|date',
                        'placa' => 'required|string',
                        'infraccion' => 'required|integer',
                        'estado' => 'required|integer',
                        'vigilante' => 'required|integer',
                        'usu_inicial' => 'required|integer',
                        'zona' => 'required|integer',
                        'espacio' => 'required|integer',
                    ]);
                    if ($validator->fails()) {
                        $eResponse['message'] = $validator->errors()->first();
                        break;
                    }
                    $result = DB::select('SELECT * FROM sp_insert_folio_adeudo(?, ?, ?, ?, ?, ?, ?, ?, ?, ?)', [
                        $params['axo'],
                        $params['folio'],
                        $params['fecha_folio'],
                        $params['placa'],
                        $params['infraccion'],
                        $params['estado'],
                        $params['vigilante'],
                        $params['usu_inicial'],
                        $params['zona'],
                        $params['espacio']
                    ]);
                    $eResponse['success'] = true;
                    $eResponse['data'] = $result;
                    break;
                default:
                    $eResponse['message'] = 'eRequest not recognized.';
            }
        } catch (\Exception $ex) {
            $eResponse['message'] = $ex->getMessage();
        }

        return response()->json(['eResponse' => $eResponse]);
    }
}

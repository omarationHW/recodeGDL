<?php
namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;

class SolSdosFavorController extends Controller
{
    // Endpoint único para eRequest/eResponse
    public function execute(Request $request)
    {
        $action = $request->input('action');
        $params = $request->input('params', []);
        $user = $request->user(); // Asumimos autenticación JWT o similar
        $response = [
            'success' => false,
            'data' => null,
            'message' => ''
        ];

        try {
            switch ($action) {
                case 'getSolicitud':
                    $response['data'] = DB::select('SELECT * FROM sol_sdosfavor WHERE folio = ? AND axofol = ?', [
                        $params['folio'], $params['axofol']
                    ]);
                    $response['success'] = true;
                    break;
                case 'createSolicitud':
                    $validator = Validator::make($params, [
                        'cvecuenta' => 'required|integer',
                        'domp' => 'required|string',
                        'extp' => 'required|string',
                        'intp' => 'nullable|string',
                        'colp' => 'required|string',
                        'telefono' => 'nullable|string',
                        'codp' => 'nullable|string',
                        'solicitante' => 'required|string',
                        'observaciones' => 'nullable|string',
                        'doctos' => 'nullable|string',
                        'status' => 'required|string',
                        'inconf' => 'nullable|integer',
                        'peticionario' => 'nullable|integer'
                    ]);
                    if ($validator->fails()) {
                        $response['message'] = $validator->errors()->first();
                        break;
                    }
                    $result = DB::select('SELECT * FROM sp_sol_sdosfavor_create(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)', [
                        $params['cvecuenta'],
                        $params['domp'],
                        $params['extp'],
                        $params['intp'],
                        $params['colp'],
                        $params['telefono'],
                        $params['codp'],
                        $params['solicitante'],
                        $params['observaciones'],
                        $params['doctos'],
                        $params['status'],
                        $params['inconf'],
                        $params['peticionario'],
                        $user->id,
                        now()
                    ]);
                    $response['success'] = true;
                    $response['data'] = $result;
                    break;
                case 'updateSolicitud':
                    $result = DB::select('SELECT * FROM sp_sol_sdosfavor_update(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)', [
                        $params['id_solic'],
                        $params['cvecuenta'],
                        $params['domp'],
                        $params['extp'],
                        $params['intp'],
                        $params['colp'],
                        $params['telefono'],
                        $params['codp'],
                        $params['solicitante'],
                        $params['observaciones'],
                        $params['doctos'],
                        $params['status'],
                        $params['inconf'],
                        $params['peticionario'],
                        $user->id,
                        now()
                    ]);
                    $response['success'] = true;
                    $response['data'] = $result;
                    break;
                case 'cancelSolicitud':
                    $result = DB::select('SELECT * FROM sp_sol_sdosfavor_cancel(?, ?)', [
                        $params['id_solic'],
                        $user->id
                    ]);
                    $response['success'] = true;
                    $response['data'] = $result;
                    break;
                case 'listSolicitudes':
                    $status = $params['status'] ?? null;
                    if ($status) {
                        $response['data'] = DB::select('SELECT * FROM sol_sdosfavor WHERE status = ? ORDER BY folio ASC', [$status]);
                    } else {
                        $response['data'] = DB::select('SELECT * FROM sol_sdosfavor ORDER BY folio ASC');
                    }
                    $response['success'] = true;
                    break;
                case 'getDoctosCatalog':
                    $response['data'] = DB::select('SELECT * FROM doctos_catalog ORDER BY id');
                    $response['success'] = true;
                    break;
                case 'getPeticionariosCatalog':
                    $response['data'] = DB::select('SELECT * FROM peticionarios_catalog ORDER BY id');
                    $response['success'] = true;
                    break;
                case 'getInconformidadesCatalog':
                    $response['data'] = DB::select('SELECT * FROM inconformidades_catalog ORDER BY id');
                    $response['success'] = true;
                    break;
                default:
                    $response['message'] = 'Acción no soportada';
            }
        } catch (\Exception $e) {
            $response['message'] = $e->getMessage();
        }
        return response()->json($response);
    }
}

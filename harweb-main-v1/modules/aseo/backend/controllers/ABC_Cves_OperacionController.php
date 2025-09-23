<?php

namespace App\Http\Controllers\Api;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use App\Http\Controllers\Controller;

class ExecuteController extends Controller
{
    /**
     * Endpoint único para ejecutar acciones del sistema (eRequest/eResponse)
     *
     * @param Request $request
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
                case 'ABC_Cves_Operacion.list':
                    $result = DB::select('SELECT * FROM ta_16_operacion ORDER BY ctrol_operacion');
                    $eResponse['success'] = true;
                    $eResponse['data'] = $result;
                    break;
                case 'ABC_Cves_Operacion.insert':
                    $res = DB::select('SELECT * FROM sp_abc_cves_operacion_insert(?, ?)', [
                        $params['cve_operacion'],
                        $params['descripcion']
                    ]);
                    $eResponse['success'] = $res[0]->success;
                    $eResponse['message'] = $res[0]->message;
                    break;
                case 'ABC_Cves_Operacion.update':
                    $res = DB::select('SELECT * FROM sp_abc_cves_operacion_update(?, ?, ?)', [
                        $params['ctrol_operacion'],
                        $params['cve_operacion'],
                        $params['descripcion']
                    ]);
                    $eResponse['success'] = $res[0]->success;
                    $eResponse['message'] = $res[0]->message;
                    break;
                case 'ABC_Cves_Operacion.delete':
                    $res = DB::select('SELECT * FROM sp_abc_cves_operacion_delete(?)', [
                        $params['ctrol_operacion']
                    ]);
                    $eResponse['success'] = $res[0]->success;
                    $eResponse['message'] = $res[0]->message;
                    break;
                case 'ABC_Cves_Operacion.report':
                    $order = $params['order'] ?? 'ctrol_operacion';
                    $result = DB::select('SELECT * FROM ta_16_operacion ORDER BY ' . $order);
                    $eResponse['success'] = true;
                    $eResponse['data'] = $result;
                    break;
                default:
                    $eResponse['message'] = 'eRequest not implemented';
            }
        } catch (\Exception $ex) {
            $eResponse['success'] = false;
            $eResponse['message'] = $ex->getMessage();
        }

        return response()->json(['eResponse' => $eResponse]);
    }
}

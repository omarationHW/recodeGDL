<?php

namespace App\Http\Controllers\Api;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use App\Http\Controllers\Controller;

class ExecuteController extends Controller
{
    /**
     * Endpoint único para ejecutar acciones del sistema (eRequest/eResponse)
     * POST /api/execute
     *
     * @param Request $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function execute(Request $request)
    {
        $action = $request->input('action');
        $params = $request->input('params', []);
        $response = [
            'success' => false,
            'data' => null,
            'message' => ''
        ];

        try {
            switch ($action) {
                case 'rbaja.buscar_local':
                    $result = DB::select('SELECT * FROM sp_rbaja_buscar_local(?, ?)', [
                        $params['numero'],
                        $params['letra']
                    ]);
                    $response['success'] = true;
                    $response['data'] = $result;
                    break;
                case 'rbaja.verificar_adeudos':
                    $result = DB::select('SELECT * FROM sp_rbaja_verificar_adeudos(?, ?)', [
                        $params['id_34_datos'],
                        $params['periodo']
                    ]);
                    $response['success'] = true;
                    $response['data'] = $result;
                    break;
                case 'rbaja.verificar_adeudos_post':
                    $result = DB::select('SELECT * FROM sp_rbaja_verificar_adeudos_post(?, ?)', [
                        $params['id_34_datos'],
                        $params['periodo']
                    ]);
                    $response['success'] = true;
                    $response['data'] = $result;
                    break;
                case 'rbaja.cancelar_local':
                    DB::beginTransaction();
                    $result = DB::select('SELECT * FROM sp_rbaja_cancelar_local(?, ?, ?)', [
                        $params['id_34_datos'],
                        $params['axo_fin'],
                        $params['mes_fin']
                    ]);
                    if (isset($result[0]) && $result[0]->codigo = 0) {
                        DB::commit();
                    } else {
                        DB::rollBack();
                    }
                    $response['success'] = true;
                    $response['data'] = $result;
                    break;
                default:
                    $response['message'] = 'Acción no soportada';
            }
        } catch (\Exception $e) {
            DB::rollBack();
            $response['message'] = $e->getMessage();
        }

        return response()->json($response);
    }
}

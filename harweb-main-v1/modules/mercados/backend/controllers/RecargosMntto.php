<?php
namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;

class RecargosMnttoController extends Controller
{
    /**
     * Endpoint unificado para eRequest/eResponse
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
                case 'get_recargo':
                    $response['data'] = DB::select('SELECT * FROM sp_get_recargo(:axo, :periodo)', [
                        'axo' => $params['axo'],
                        'periodo' => $params['periodo']
                    ]);
                    $response['success'] = true;
                    break;
                case 'insert_recargo':
                    $validator = Validator::make($params, [
                        'axo' => 'required|integer|min:1994|max:2999',
                        'periodo' => 'required|integer|min:1|max:12',
                        'porcentaje' => 'required|numeric|min:0.01|max:99'
                    ]);
                    if ($validator->fails()) {
                        $response['message'] = $validator->errors()->first();
                        break;
                    }
                    $result = DB::select('SELECT * FROM sp_insert_recargo(:axo, :periodo, :porcentaje, :id_usuario)', [
                        'axo' => $params['axo'],
                        'periodo' => $params['periodo'],
                        'porcentaje' => $params['porcentaje'],
                        'id_usuario' => $params['id_usuario'] ?? 1
                    ]);
                    $response['success'] = $result[0]->success;
                    $response['message'] = $result[0]->msg;
                    break;
                case 'update_recargo':
                    $validator = Validator::make($params, [
                        'axo' => 'required|integer|min:1994|max:2999',
                        'periodo' => 'required|integer|min:1|max:12',
                        'porcentaje' => 'required|numeric|min:0.01|max:99'
                    ]);
                    if ($validator->fails()) {
                        $response['message'] = $validator->errors()->first();
                        break;
                    }
                    $result = DB::select('SELECT * FROM sp_update_recargo(:axo, :periodo, :porcentaje, :id_usuario)', [
                        'axo' => $params['axo'],
                        'periodo' => $params['periodo'],
                        'porcentaje' => $params['porcentaje'],
                        'id_usuario' => $params['id_usuario'] ?? 1
                    ]);
                    $response['success'] = $result[0]->success;
                    $response['message'] = $result[0]->msg;
                    break;
                case 'list_recargos':
                    $response['data'] = DB::select('SELECT * FROM sp_list_recargos()');
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

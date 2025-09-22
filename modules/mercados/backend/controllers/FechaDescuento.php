<?php
namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;

class FechaDescuentoController extends Controller
{
    /**
     * Endpoint único para eRequest/eResponse
     */
    public function execute(Request $request)
    {
        $action = $request->input('eRequest.action');
        $params = $request->input('eRequest.params', []);
        $response = [
            'success' => false,
            'data' => null,
            'message' => ''
        ];

        try {
            switch ($action) {
                case 'list':
                    $response['data'] = DB::select('SELECT * FROM sp_fechadescuento_list()');
                    $response['success'] = true;
                    break;
                case 'update':
                    $validator = Validator::make($params, [
                        'mes' => 'required|integer|min:1|max:12',
                        'fecha_descuento' => 'required|date',
                        'fecha_recargos' => 'required|date',
                        'id_usuario' => 'required|integer|min:1'
                    ]);
                    if ($validator->fails()) {
                        $response['message'] = $validator->errors()->first();
                        break;
                    }
                    $result = DB::select('SELECT * FROM sp_fechadescuento_update(?, ?, ?, ?)', [
                        $params['mes'],
                        $params['fecha_descuento'],
                        $params['fecha_recargos'],
                        $params['id_usuario']
                    ]);
                    $response['data'] = $result;
                    $response['success'] = true;
                    break;
                case 'get':
                    $mes = $params['mes'] ?? null;
                    if (!$mes) {
                        $response['message'] = 'Mes requerido';
                        break;
                    }
                    $result = DB::select('SELECT * FROM sp_fechadescuento_get(?)', [$mes]);
                    $response['data'] = $result;
                    $response['success'] = true;
                    break;
                default:
                    $response['message'] = 'Acción no soportada';
            }
        } catch (\Exception $e) {
            $response['message'] = $e->getMessage();
        }

        return response()->json(['eResponse' => $response]);
    }
}

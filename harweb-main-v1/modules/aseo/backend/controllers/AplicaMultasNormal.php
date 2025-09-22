<?php
namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;

class AplicaMultasNormalController extends Controller
{
    /**
     * Endpoint único para eRequest/eResponse
     */
    public function execute(Request $request)
    {
        $action = $request->input('action');
        $params = $request->input('params', []);
        $response = [
            'success' => false,
            'message' => '',
            'data' => null
        ];

        try {
            switch ($action) {
                case 'get_aplicareq':
                    $result = DB::select('SELECT * FROM ta_aplicareq LIMIT 1');
                    $response['success'] = true;
                    $response['data'] = $result ? $result[0] : null;
                    break;
                case 'update_aplicareq':
                    $validator = Validator::make($params, [
                        'aplica' => 'required|string|in:S,N',
                        'porc' => 'required|integer|min:0|max:100'
                    ]);
                    if ($validator->fails()) {
                        $response['message'] = $validator->errors()->first();
                        break;
                    }
                    $affected = DB::update('UPDATE ta_aplicareq SET aplica = ?, porc = ?', [
                        $params['aplica'],
                        $params['porc']
                    ]);
                    $response['success'] = true;
                    $response['message'] = $params['aplica'] === 'S'
                        ? 'La Aplicación Normal Realizada'
                        : ($params['porc'] > 0
                            ? 'La NO Aplicación Normal CON PORCENTAJE Realizada'
                            : 'Falta el porcentaje de Aplicación de Multa');
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

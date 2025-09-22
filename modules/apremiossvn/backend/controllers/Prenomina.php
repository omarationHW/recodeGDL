<?php
namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;

class PrenominaController extends Controller
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
            'data' => null,
            'message' => ''
        ];

        try {
            switch ($action) {
                case 'getRecaudadoras':
                    $response['data'] = DB::select('SELECT * FROM sp_get_recaudadoras()');
                    $response['success'] = true;
                    break;
                case 'getPrenominaReport':
                    $validator = Validator::make($params, [
                        'fecha_desde' => 'required|date',
                        'fecha_hasta' => 'required|date',
                        'recaudadora_desde' => 'required|integer',
                        'recaudadora_hasta' => 'required|integer',
                    ]);
                    if ($validator->fails()) {
                        $response['message'] = $validator->errors()->first();
                        break;
                    }
                    $result = DB::select('SELECT * FROM sp_prenomina_report(?, ?, ?, ?)', [
                        $params['fecha_desde'],
                        $params['fecha_hasta'],
                        $params['recaudadora_desde'],
                        $params['recaudadora_hasta']
                    ]);
                    $response['data'] = $result;
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

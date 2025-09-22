<?php
namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;

class RptAdeudosAnterioresController extends Controller
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
                case 'get_report':
                    $validator = Validator::make($params, [
                        'axo' => 'required|integer',
                        'oficina' => 'required|integer',
                        'periodo' => 'required|integer'
                    ]);
                    if ($validator->fails()) {
                        $response['message'] = $validator->errors()->first();
                        break;
                    }
                    $result = DB::select('CALL rpt_adeudos_anteriores(?, ?, ?)', [
                        $params['axo'],
                        $params['oficina'],
                        $params['periodo']
                    ]);
                    $response['success'] = true;
                    $response['data'] = $result;
                    break;
                case 'get_mes_adeudo':
                    $validator = Validator::make($params, [
                        'id_local' => 'required|integer',
                        'axo' => 'required|integer'
                    ]);
                    if ($validator->fails()) {
                        $response['message'] = $validator->errors()->first();
                        break;
                    }
                    $result = DB::select('CALL rpt_mes_adeudo_ant(?, ?)', [
                        $params['id_local'],
                        $params['axo']
                    ]);
                    $response['success'] = true;
                    $response['data'] = $result;
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

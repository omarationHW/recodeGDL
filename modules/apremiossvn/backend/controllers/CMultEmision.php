<?php
namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;

class CMultEmisionController extends Controller
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
                    $response['data'] = DB::select('SELECT id_rec, recaudadora FROM ta_12_recaudadoras ORDER BY id_rec');
                    $response['success'] = true;
                    break;
                case 'searchFoliosByFechaEmision':
                    $validator = Validator::make($params, [
                        'modulo' => 'required|integer',
                        'zona' => 'required|integer',
                        'fecha_emision' => 'required|date',
                    ]);
                    if ($validator->fails()) {
                        $response['message'] = $validator->errors()->first();
                        break;
                    }
                    $folios = DB::select('SELECT * FROM sp_cmultemision_search(:modulo, :zona, :fecha_emision)', [
                        'modulo' => $params['modulo'],
                        'zona' => $params['zona'],
                        'fecha_emision' => $params['fecha_emision'],
                    ]);
                    $response['data'] = $folios;
                    $response['success'] = true;
                    break;
                case 'getFolioDetail':
                    $validator = Validator::make($params, [
                        'id_control' => 'required|integer',
                    ]);
                    if ($validator->fails()) {
                        $response['message'] = $validator->errors()->first();
                        break;
                    }
                    $folio = DB::select('SELECT * FROM sp_cmultemision_folio_detail(:id_control)', [
                        'id_control' => $params['id_control'],
                    ]);
                    $response['data'] = $folio;
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

<?php

namespace App\Http\Controllers\Api;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
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
        $eResponse = [
            'success' => false,
            'data' => null,
            'message' => ''
        ];

        try {
            switch ($eRequest) {
                case 'getInspectors':
                    $result = DB::select('SELECT * FROM sp_get_inspectors()');
                    $eResponse['success'] = true;
                    $eResponse['data'] = $result;
                    break;
                case 'getFoliosReport':
                    $date = $params['date'] ?? null;
                    $vigila = $params['vigila'] ?? null;
                    $mode = $params['mode'] ?? 'elaborados'; // 'elaborados', 'capturados', 'por_vigilante'
                    $result = DB::select('SELECT * FROM sp_get_folios_report(?, ?, ?)', [$date, $vigila, $mode]);
                    $eResponse['success'] = true;
                    $eResponse['data'] = $result;
                    break;
                case 'getFoliosByInspector':
                    $date = $params['date'] ?? null;
                    $result = DB::select('SELECT * FROM sp_get_folios_by_inspector(?)', [$date]);
                    $eResponse['success'] = true;
                    $eResponse['data'] = $result;
                    break;
                case 'getUsuarios':
                    $result = DB::select('SELECT * FROM sp_get_usuarios()');
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

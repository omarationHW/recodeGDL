<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;

class EstadxFolioController extends Controller
{
    /**
     * Handle unified API requests for EstadxFolio.
     * Endpoint: /api/execute
     */
    public function execute(Request $request)
    {
        $action = $request->input('eRequest.action');
        $params = $request->input('eRequest.params', []);
        $user = $request->user(); // For permissions if needed

        switch ($action) {
            case 'estadxfolio.getRecaudadoras':
                $data = DB::select('SELECT id_rec, recaudadora FROM ta_12_recaudadoras ORDER BY id_rec');
                return response()->json(['eResponse' => ['status' => 'ok', 'data' => $data]]);

            case 'estadxfolio.getStats':
                $validator = Validator::make($params, [
                    'modulo' => 'required|integer',
                    'rec' => 'required|integer',
                    'fol1' => 'required|integer',
                    'fol2' => 'required|integer',
                ]);
                if ($validator->fails()) {
                    return response()->json(['eResponse' => ['status' => 'error', 'errors' => $validator->errors()]], 422);
                }
                $result = DB::select('CALL estadxfolio_stats(?, ?, ?, ?)', [
                    $params['modulo'],
                    $params['rec'],
                    $params['fol1'],
                    $params['fol2']
                ]);
                return response()->json(['eResponse' => ['status' => 'ok', 'data' => $result]]);

            case 'estadxfolio.exportExcel':
                // This would trigger a job or return a download URL
                // For demo, just return the data
                $result = DB::select('CALL estadxfolio_stats(?, ?, ?, ?)', [
                    $params['modulo'],
                    $params['rec'],
                    $params['fol1'],
                    $params['fol2']
                ]);
                // Here you would generate and store the Excel file, then return a URL
                return response()->json(['eResponse' => ['status' => 'ok', 'data' => $result, 'excel_url' => null]]);

            default:
                return response()->json(['eResponse' => ['status' => 'error', 'message' => 'Unknown action']], 400);
        }
    }
}

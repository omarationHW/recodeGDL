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
                case 'grs_dlg_search':
                    // params: table, field, value, case_insensitive
                    $table = $params['table'] ?? null;
                    $field = $params['field'] ?? null;
                    $value = $params['value'] ?? '';
                    $caseInsensitive = $params['case_insensitive'] ?? true;
                    $partial = $params['partial'] ?? true;

                    if (!$table || !$field) {
                        throw new \Exception('Missing table or field parameter.');
                    }

                    $result = DB::select('SELECT * FROM sp_grs_dlg_search(?, ?, ?, ?, ?)', [
                        $table,
                        $field,
                        $value,
                        $caseInsensitive,
                        $partial
                    ]);

                    $eResponse['success'] = true;
                    $eResponse['data'] = $result;
                    break;
                default:
                    $eResponse['message'] = 'Unknown eRequest.';
            }
        } catch (\Exception $ex) {
            $eResponse['message'] = $ex->getMessage();
        }

        return response()->json(['eResponse' => $eResponse]);
    }
}

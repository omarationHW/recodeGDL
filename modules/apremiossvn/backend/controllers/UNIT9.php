<?php

namespace App\Http\Controllers\Api;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use App\Http\Controllers\Controller;

class ExecuteController extends Controller
{
    /**
     * Handle unified API requests (eRequest/eResponse pattern)
     * Endpoint: /api/execute
     */
    public function execute(Request $request)
    {
        $eRequest = $request->input('eRequest');
        $params = $request->input('params', []);
        $response = [
            'success' => false,
            'data' => null,
            'message' => ''
        ];

        try {
            switch ($eRequest) {
                case 'UNIT9_REPORT_PREVIEW':
                    // Call stored procedure to get report preview data
                    $result = DB::select('SELECT * FROM sp_unit9_report_preview()');
                    $response['success'] = true;
                    $response['data'] = $result;
                    break;
                case 'UNIT9_REPORT_LOAD':
                    // Load report from file (simulate, as file system is not used)
                    $filename = $params['filename'] ?? null;
                    if (!$filename) {
                        throw new \Exception('Filename is required');
                    }
                    $result = DB::select('SELECT * FROM sp_unit9_report_load(?)', [$filename]);
                    $response['success'] = true;
                    $response['data'] = $result;
                    break;
                case 'UNIT9_REPORT_SAVE':
                    // Save report to file (simulate)
                    $filename = $params['filename'] ?? null;
                    $report_data = $params['report_data'] ?? null;
                    if (!$filename || !$report_data) {
                        throw new \Exception('Filename and report_data are required');
                    }
                    $result = DB::select('SELECT * FROM sp_unit9_report_save(?, ?)', [$filename, $report_data]);
                    $response['success'] = true;
                    $response['data'] = $result;
                    break;
                case 'UNIT9_REPORT_PRINT':
                    // Print report (simulate)
                    $result = DB::select('SELECT * FROM sp_unit9_report_print()');
                    $response['success'] = true;
                    $response['data'] = $result;
                    break;
                default:
                    $response['message'] = 'Unknown eRequest: ' . $eRequest;
            }
        } catch (\Exception $ex) {
            $response['success'] = false;
            $response['message'] = $ex->getMessage();
        }

        return response()->json(['eResponse' => $response]);
    }
}

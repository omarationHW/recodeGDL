<?php

namespace App\Http\Controllers\Api;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;
use App\Http\Controllers\Controller;

class ExecuteController extends Controller
{
    /**
     * Handle unified API requests (eRequest/eResponse pattern)
     * Endpoint: /api/execute
     */
    public function execute(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'eRequest' => 'required|array',
            'eRequest.action' => 'required|string',
            'eRequest.data' => 'required|array',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'eResponse' => [
                    'success' => false,
                    'message' => 'Validation error',
                    'errors' => $validator->errors(),
                ]
            ], 422);
        }

        $action = $request->input('eRequest.action');
        $data = $request->input('eRequest.data');

        switch ($action) {
            case 'up_pagos_upload':
                return $this->processUpPagosUpload($data);
            default:
                return response()->json([
                    'eResponse' => [
                        'success' => false,
                        'message' => 'Unknown action',
                    ]
                ], 400);
        }
    }

    /**
     * Process the upload and update of pagos (payments)
     * @param array $data
     * @return \Illuminate\Http\JsonResponse
     */
    private function processUpPagosUpload($data)
    {
        // data: { file_content: base64, filename: string }
        if (!isset($data['file_content']) || !isset($data['filename'])) {
            return response()->json([
                'eResponse' => [
                    'success' => false,
                    'message' => 'Missing file_content or filename',
                ]
            ], 400);
        }

        $fileContent = base64_decode($data['file_content']);
        $lines = preg_split('/\r\n|\r|\n/', $fileContent);
        $total = 0;
        $errors = 0;
        $error_lines = [];
        $updated = 0;

        foreach ($lines as $line) {
            $line = trim($line);
            if ($line === '') continue;
            $total++;
            // Parse fields as per Delphi logic
            // alo: chars 1-4, folio: chars 5-11, fecha: chars 19-24 (YYMMDD)
            try {
                $alo = intval(substr($line, 0, 4));
                $folio = intval(substr($line, 4, 7));
                $yy = substr($line, 18, 2);
                $mm = substr($line, 20, 2);
                $dd = substr($line, 22, 2);
                // Assume 20xx for years < 50, 19xx for >= 50
                $century = intval($yy) < 50 ? '20' : '19';
                $fecha = $century . $yy . '-' . $mm . '-' . $dd;

                $result = DB::select('SELECT * FROM sp_up_pagos_update(?, ?, ?)', [
                    $alo, $folio, $fecha
                ]);
                if (isset($result[0]->success) && $result[0]->success) {
                    $updated++;
                } else {
                    $errors++;
                    $error_lines[] = [
                        'line' => $line,
                        'error' => $result[0]->message ?? 'Unknown error'
                    ];
                }
            } catch (\Exception $ex) {
                $errors++;
                $error_lines[] = [
                    'line' => $line,
                    'error' => $ex->getMessage()
                ];
            }
        }

        return response()->json([
            'eResponse' => [
                'success' => $errors === 0,
                'total' => $total,
                'updated' => $updated,
                'errors' => $errors,
                'error_lines' => $error_lines,
                'message' => $errors === 0 ? 'All records updated successfully' : 'Some records failed to update',
            ]
        ]);
    }
}

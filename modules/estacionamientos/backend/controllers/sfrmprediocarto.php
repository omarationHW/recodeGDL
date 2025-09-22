<?php

namespace App\Http\Controllers\Api;

use Illuminate\Http\Request;
use App\Http\Controllers\Controller;
use Illuminate\Support\Facades\Validator;

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
            'eRequest.data' => 'nullable|array',
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
        $data = $request->input('eRequest.data', []);

        switch ($action) {
            case 'getPredioCartoUrl':
                return $this->getPredioCartoUrl($data);
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
     * Returns the URL for the predio cartografico viewer
     * @param array $data
     * @return \Illuminate\Http\JsonResponse
     */
    private function getPredioCartoUrl($data)
    {
        // Validate input
        if (!isset($data['cvecatastro']) || empty($data['cvecatastro'])) {
            return response()->json([
                'eResponse' => [
                    'success' => false,
                    'message' => 'Missing cvecatastro parameter',
                ]
            ], 422);
        }

        $cvecatastro = $data['cvecatastro'];
        // You could add further validation here (e.g., regex)

        // Build the URL (could be dynamic in the future)
        $baseUrl = 'http://192.168.4.20:8080/Visor/index.html';
        $params = http_build_query([
            'user' => '123',
            'session' => 'se123',
            'clavePredi0' => $cvecatastro
        ]);
        $url = $baseUrl . '#user=123&session=se123&clavePredi0=' . urlencode($cvecatastro);

        return response()->json([
            'eResponse' => [
                'success' => true,
                'url' => $url,
                'message' => 'URL generated successfully',
            ]
        ]);
    }
}

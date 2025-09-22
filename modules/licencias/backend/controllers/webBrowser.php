<?php

namespace App\Http\Controllers\Api;

use Illuminate\Http\Request;
use App\Http\Controllers\Controller;
use Illuminate\Support\Facades\Validator;

class WebBrowserController extends Controller
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
                    'status' => 'error',
                    'message' => $validator->errors()->first(),
                    'data' => null
                ]
            ], 400);
        }

        $action = $request->input('eRequest.action');
        $data = $request->input('eRequest.data', []);

        switch ($action) {
            case 'navigate_url':
                return $this->navigateUrl($data);
            default:
                return response()->json([
                    'eResponse' => [
                        'status' => 'error',
                        'message' => 'Unknown action',
                        'data' => null
                    ]
                ], 400);
        }
    }

    /**
     * Action: navigate_url
     * Receives a URL and returns it (could be extended for logging, validation, etc)
     */
    private function navigateUrl($data)
    {
        $url = isset($data['url']) ? $data['url'] : null;
        if (!$url) {
            return response()->json([
                'eResponse' => [
                    'status' => 'error',
                    'message' => 'URL is required',
                    'data' => null
                ]
            ], 400);
        }
        // Optionally: Validate URL format
        if (!filter_var($url, FILTER_VALIDATE_URL)) {
            return response()->json([
                'eResponse' => [
                    'status' => 'error',
                    'message' => 'Invalid URL format',
                    'data' => null
                ]
            ], 400);
        }
        // Optionally: Log navigation event, store in DB, etc.
        // For now, just return the URL
        return response()->json([
            'eResponse' => [
                'status' => 'success',
                'message' => 'Navigation successful',
                'data' => [
                    'url' => $url
                ]
            ]
        ]);
    }
}

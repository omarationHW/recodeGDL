<?php

namespace App\Http\Controllers\Api;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use App\Http\Controllers\Controller;

class ExecuteController extends Controller
{
    /**
     * Handle unified API requests via /api/execute endpoint.
     *
     * @param  \Illuminate\Http\Request  $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function handle(Request $request)
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
                case 'UNIT9_PREVIEW_NAVIGATE':
                    // params: { action: 'first'|'prev'|'next'|'last' }
                    $result = DB::select('SELECT * FROM sp_unit9_preview_navigate( ? )', [ $params['action'] ?? null ]);
                    $eResponse['success'] = true;
                    $eResponse['data'] = $result;
                    break;
                case 'UNIT9_PREVIEW_LOAD':
                    // params: { file_path: string }
                    $result = DB::select('SELECT * FROM sp_unit9_preview_load( ? )', [ $params['file_path'] ?? null ]);
                    $eResponse['success'] = true;
                    $eResponse['data'] = $result;
                    break;
                case 'UNIT9_PREVIEW_SAVE':
                    // params: { file_path: string }
                    $result = DB::select('SELECT * FROM sp_unit9_preview_save( ? )', [ $params['file_path'] ?? null ]);
                    $eResponse['success'] = true;
                    $eResponse['data'] = $result;
                    break;
                case 'UNIT9_PREVIEW_PRINT':
                    $result = DB::select('SELECT * FROM sp_unit9_preview_print()');
                    $eResponse['success'] = true;
                    $eResponse['data'] = $result;
                    break;
                case 'UNIT9_PREVIEW_ONEPAGE':
                    $result = DB::select('SELECT * FROM sp_unit9_preview_onepage()');
                    $eResponse['success'] = true;
                    $eResponse['data'] = $result;
                    break;
                case 'UNIT9_PREVIEW_ZOOM':
                    // params: { zoom: int }
                    $result = DB::select('SELECT * FROM sp_unit9_preview_zoom( ? )', [ $params['zoom'] ?? 100 ]);
                    $eResponse['success'] = true;
                    $eResponse['data'] = $result;
                    break;
                case 'UNIT9_PREVIEW_PAGEWIDTH':
                    $result = DB::select('SELECT * FROM sp_unit9_preview_pagewidth()');
                    $eResponse['success'] = true;
                    $eResponse['data'] = $result;
                    break;
                case 'UNIT9_MODAL_OK':
                    $eResponse['success'] = true;
                    $eResponse['data'] = [ 'modalResult' => 'ok' ];
                    break;
                default:
                    $eResponse['message'] = 'Unknown eRequest: ' . $eRequest;
            }
        } catch (\Exception $ex) {
            $eResponse['message'] = $ex->getMessage();
        }

        return response()->json(['eResponse' => $eResponse]);
    }
}

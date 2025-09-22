<?php

namespace App\Http\Controllers\CtrolImpCat;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use App\Http\Controllers\Controller;

class CtrolImpCatController extends Controller
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
                case 'getOptions':
                    $response['success'] = true;
                    $response['data'] = [
                        ['value' => 1, 'label' => 'Control'],
                        ['value' => 2, 'label' => 'Clave'],
                        ['value' => 3, 'label' => 'Descripcion']
                    ];
                    break;
                case 'previewReport':
                    $order = $params['order'] ?? 1;
                    $result = DB::select('CALL sp_ctrol_imp_cat_report(?)', [$order]);
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

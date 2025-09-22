<?php

namespace App\Http\Controllers\Api;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use App\Http\Controllers\Controller;

class ExecuteController extends Controller
{
    /**
     * Handle unified API requests (eRequest/eResponse pattern)
     */
    public function execute(Request $request)
    {
        $eRequest = $request->input('eRequest');
        $eResponse = [
            'success' => false,
            'data' => null,
            'message' => ''
        ];

        try {
            switch ($eRequest['action']) {
                case 'getDescuentosMulta':
                    $params = $eRequest['params'];
                    $recaud = (int) $params['recaud'];
                    $fini = $params['fini'];
                    $ffin = $params['ffin'];
                    $result = DB::select('SELECT * FROM report_descuentos_multa(:recaud, :fini, :ffin)', [
                        'recaud' => $recaud,
                        'fini' => $fini,
                        'ffin' => $ffin
                    ]);
                    $eResponse['success'] = true;
                    $eResponse['data'] = $result;
                    break;
                default:
                    $eResponse['message'] = 'Acción no soportada';
            }
        } catch (\Exception $ex) {
            $eResponse['message'] = $ex->getMessage();
        }

        return response()->json(['eResponse' => $eResponse]);
    }
}

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
        $params = $request->input('params', []);
        $eResponse = [
            'success' => false,
            'data' => null,
            'message' => ''
        ];

        try {
            switch ($eRequest) {
                case 'reqctascanfrm.get_cancelled_accounts':
                    $recaud = $params['recaud'] ?? null;
                    $fini = $params['fini'] ?? null;
                    $ffin = $params['ffin'] ?? null;
                    if (!$recaud || !$fini || !$ffin) {
                        throw new \Exception('Parámetros requeridos: recaud, fini, ffin');
                    }
                    $result = DB::select('SELECT * FROM report_reqctascanfrm(:recaud, :fini, :ffin)', [
                        'recaud' => $recaud,
                        'fini' => $fini,
                        'ffin' => $ffin
                    ]);
                    $eResponse['success'] = true;
                    $eResponse['data'] = $result;
                    break;
                case 'reqctascanfrm.get_folios_by_cvecuenta':
                    $cvecuenta = $params['cvecuenta'] ?? null;
                    if (!$cvecuenta) {
                        throw new \Exception('Parámetro requerido: cvecuenta');
                    }
                    $result = DB::select('SELECT * FROM report_reqctascanfrm_folios(:cvecuenta)', [
                        'cvecuenta' => $cvecuenta
                    ]);
                    $eResponse['success'] = true;
                    $eResponse['data'] = $result;
                    break;
                case 'reqctascanfrm.get_recaudadoras':
                    // Hardcoded as per Delphi RadioGroup
                    $eResponse['success'] = true;
                    $eResponse['data'] = [
                        ["id" => 1, "name" => "Zona Centro"],
                        ["id" => 2, "name" => "Zona Olimpica"],
                        ["id" => 3, "name" => "Zona Oblatos"],
                        ["id" => 4, "name" => "Zona Minerva"]
                    ];
                    break;
                default:
                    $eResponse['message'] = 'eRequest no soportado';
            }
        } catch (\Exception $ex) {
            $eResponse['success'] = false;
            $eResponse['message'] = $ex->getMessage();
        }

        return response()->json(['eResponse' => $eResponse]);
    }
}

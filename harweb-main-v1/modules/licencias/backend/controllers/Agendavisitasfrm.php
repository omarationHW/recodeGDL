<?php

namespace App\Http\Controllers\Api;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use App\Http\Controllers\Controller;

class ExecuteController extends Controller
{
    /**
     * Handle unified API requests via /api/execute
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
                case 'get_dependencias':
                    $result = DB::select('SELECT * FROM sp_get_dependencias()');
                    $eResponse['success'] = true;
                    $eResponse['data'] = $result;
                    break;
                case 'get_agenda_visitas':
                    $id_dependencia = $params['id_dependencia'] ?? null;
                    $fechaini = $params['fechaini'] ?? null;
                    $fechafin = $params['fechafin'] ?? null;
                    if (!$id_dependencia || !$fechaini || !$fechafin) {
                        $eResponse['message'] = 'Parámetros requeridos: id_dependencia, fechaini, fechafin';
                        break;
                    }
                    $result = DB::select('SELECT * FROM sp_get_agenda_visitas(?, ?, ?)', [
                        $id_dependencia,
                        $fechaini,
                        $fechafin
                    ]);
                    $eResponse['success'] = true;
                    $eResponse['data'] = $result;
                    break;
                case 'export_agenda_visitas':
                    $id_dependencia = $params['id_dependencia'] ?? null;
                    $fechaini = $params['fechaini'] ?? null;
                    $fechafin = $params['fechafin'] ?? null;
                    if (!$id_dependencia || !$fechaini || !$fechafin) {
                        $eResponse['message'] = 'Parámetros requeridos: id_dependencia, fechaini, fechafin';
                        break;
                    }
                    $result = DB::select('SELECT * FROM sp_get_agenda_visitas(?, ?, ?)', [
                        $id_dependencia,
                        $fechaini,
                        $fechafin
                    ]);
                    // Export logic (CSV/Excel) should be handled in frontend or another endpoint
                    $eResponse['success'] = true;
                    $eResponse['data'] = $result;
                    break;
                default:
                    $eResponse['message'] = 'eRequest no soportado';
            }
        } catch (\Exception $ex) {
            $eResponse['message'] = $ex->getMessage();
        }

        return response()->json(['eResponse' => $eResponse]);
    }
}

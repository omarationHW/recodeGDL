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
        $eResponse = [
            'success' => false,
            'data' => null,
            'message' => ''
        ];

        try {
            switch ($eRequest) {
                case 'RAdeudos.BuscaCont':
                    $cve = $params['cve'] ?? null;
                    $control = $params['control'] ?? null;
                    $result = DB::select('SELECT id_34_datos, control, concesionario, ubicacion, superficie, fecha_inicio, fecha_fin, id_recaudadora, sector, id_zona, licencia FROM t34_datos WHERE cve_tab = ? AND control = ?', [$cve, $control]);
                    $eResponse['success'] = true;
                    $eResponse['data'] = $result;
                    break;
                case 'RAdeudos.BuscaAdeudos01':
                    $control = $params['par_Control'] ?? null;
                    $rep = $params['par_Rep'] ?? null;
                    $fecha = $params['par_Fecha'] ?? null;
                    $result = DB::select('CALL con34_1detade_01(?, ?, ?)', [$control, $rep, $fecha]);
                    $eResponse['success'] = true;
                    $eResponse['data'] = $result;
                    break;
                case 'RAdeudos.BuscaAdeudos02':
                    $control = $params['par_Control'] ?? null;
                    $rep = $params['par_Rep'] ?? null;
                    $fecha = $params['par_Fecha'] ?? null;
                    $result = DB::select('CALL con34_1detade_02(?, ?, ?)', [$control, $rep, $fecha]);
                    $eResponse['success'] = true;
                    $eResponse['data'] = $result;
                    break;
                default:
                    $eResponse['message'] = 'Unknown eRequest: ' . $eRequest;
            }
        } catch (\Exception $ex) {
            $eResponse['message'] = $ex->getMessage();
        }

        return response()->json($eResponse);
    }
}

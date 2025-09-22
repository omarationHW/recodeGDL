<?php

namespace App\Http\Controllers\Api;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use App\Http\Controllers\Controller;

class ExecuteController extends Controller
{
    /**
     * Handle unified API requests for RepOper (Operaciones Report).
     * Endpoint: /api/execute
     *
     * @param  \Illuminate\Http\Request  $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function handle(Request $request)
    {
        $eRequest = $request->input('eRequest');
        $operation = $eRequest['operation'] ?? null;
        $params = $eRequest['params'] ?? [];
        $eResponse = [
            'success' => false,
            'data' => null,
            'error' => null
        ];

        try {
            switch ($operation) {
                case 'getCajasByFechaRecaud':
                    $fecha = $params['fecha'] ?? null;
                    $recaud = $params['recaud'] ?? null;
                    $result = DB::select('SELECT DISTINCT caja FROM pagos WHERE fecha = ? AND recaud = ?', [$fecha, $recaud]);
                    $eResponse['success'] = true;
                    $eResponse['data'] = $result;
                    break;
                case 'getTotalesOperaciones':
                    $fecha = $params['fecha'] ?? null;
                    $recaud = $params['recaud'] ?? null;
                    $caja = $params['caja'] ?? null;
                    $result = DB::select('SELECT * FROM repoper_totales(?, ?, ?)', [$fecha, $recaud, $caja]);
                    $eResponse['success'] = true;
                    $eResponse['data'] = $result[0] ?? null;
                    break;
                case 'getDesgloseOperaciones':
                    $fecha = $params['fecha'] ?? null;
                    $recaud = $params['recaud'] ?? null;
                    $caja = $params['caja'] ?? null;
                    $result = DB::select('SELECT * FROM repoper_desglose(?, ?, ?)', [$fecha, $recaud, $caja]);
                    $eResponse['success'] = true;
                    $eResponse['data'] = $result;
                    break;
                default:
                    $eResponse['error'] = 'Operación no soportada';
            }
        } catch (\Exception $ex) {
            $eResponse['error'] = $ex->getMessage();
        }

        return response()->json(['eResponse' => $eResponse]);
    }
}

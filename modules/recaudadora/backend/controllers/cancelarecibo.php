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
        $user = $request->user(); // If using auth, else pass USERNAME in params

        switch ($eRequest) {
            case 'buscar_recibo_pago':
                // params: recaud, caja, folio, importe, fecha (opcional), user_name
                $recaud = $params['recaud'] ?? null;
                $caja = $params['caja'] ?? null;
                $folio = $params['folio'] ?? null;
                $importe = $params['importe'] ?? null;
                $fecha = $params['fecha'] ?? null;
                $user_name = $params['user_name'] ?? ($user ? $user->username : null);
                $result = DB::select('SELECT * FROM buscar_recibo_pago(?, ?, ?, ?, ?, ?)', [
                    $recaud, $caja, $folio, $importe, $fecha, $user_name
                ]);
                return response()->json(['eResponse' => $result]);

            case 'verificar_no_adeudo':
                // params: cvecuenta, cvepago
                $cvecuenta = $params['cvecuenta'] ?? null;
                $cvepago = $params['cvepago'] ?? null;
                $result = DB::select('SELECT * FROM verificar_no_adeudo(?, ?)', [
                    $cvecuenta, $cvepago
                ]);
                return response()->json(['eResponse' => $result]);

            case 'cancelar_recibo_pago':
                // params: cvepago, cvecuenta, cveconcepto, user_name
                $cvepago = $params['cvepago'] ?? null;
                $cvecuenta = $params['cvecuenta'] ?? null;
                $cveconcepto = $params['cveconcepto'] ?? null;
                $user_name = $params['user_name'] ?? ($user ? $user->username : null);
                $fecha_cancelacion = $params['fecha_cancelacion'] ?? date('Y-m-d');
                $result = DB::select('SELECT * FROM cancelar_recibo_pago(?, ?, ?, ?, ?)', [
                    $cvepago, $cvecuenta, $cveconcepto, $user_name, $fecha_cancelacion
                ]);
                return response()->json(['eResponse' => $result]);

            default:
                return response()->json(['error' => 'eRequest not supported'], 400);
        }
    }
}

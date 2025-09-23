<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;

class ConsDesgloceController extends Controller
{
    /**
     * Endpoint único para ejecutar acciones (eRequest/eResponse)
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
                case 'getDesgloce':
                    $id_adeudo = $eRequest['params']['id_adeudo'] ?? null;
                    if (!$id_adeudo) {
                        throw new \Exception('Parámetro id_adeudo requerido');
                    }
                    $result = DB::select('SELECT * FROM sp_consdesgloce_get_desgloce(?)', [$id_adeudo]);
                    $eResponse['success'] = true;
                    $eResponse['data'] = $result;
                    break;
                case 'getCuentasAplicacion':
                    $year = $eRequest['params']['year'] ?? date('Y');
                    $result = DB::select('SELECT * FROM sp_consdesgloce_get_cuentas_aplicacion(?)', [$year]);
                    $eResponse['success'] = true;
                    $eResponse['data'] = $result;
                    break;
                default:
                    throw new \Exception('Acción no soportada');
            }
        } catch (\Exception $ex) {
            Log::error('ConsDesgloceController error: ' . $ex->getMessage());
            $eResponse['message'] = $ex->getMessage();
        }

        return response()->json(['eResponse' => $eResponse]);
    }
}

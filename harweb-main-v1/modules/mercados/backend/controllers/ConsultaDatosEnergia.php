<?php
namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;

class ConsultaDatosEnergiaController extends Controller
{
    /**
     * Endpoint único para todas las operaciones (eRequest/eResponse)
     */
    public function execute(Request $request)
    {
        $eRequest = $request->input('eRequest');
        $action = $eRequest['action'] ?? null;
        $params = $eRequest['params'] ?? [];
        $eResponse = [
            'success' => false,
            'data' => null,
            'message' => ''
        ];

        try {
            switch ($action) {
                case 'getEnergiaByLocal':
                    $id_local = $params['id_local'] ?? null;
                    $result = DB::select('SELECT * FROM sp_get_energia_by_local(?)', [$id_local]);
                    $eResponse['success'] = true;
                    $eResponse['data'] = $result;
                    break;
                case 'getRequerimientosEnergia':
                    $id_local = $params['id_local'] ?? null;
                    $result = DB::select('SELECT * FROM sp_get_requerimientos_energia(?)', [$id_local]);
                    $eResponse['success'] = true;
                    $eResponse['data'] = $result;
                    break;
                case 'getAdeudosEnergia':
                    $id_local = $params['id_local'] ?? null;
                    $result = DB::select('SELECT * FROM sp_get_adeudos_energia(?)', [$id_local]);
                    $eResponse['success'] = true;
                    $eResponse['data'] = $result;
                    break;
                case 'getRecargosEnergia':
                    $axo = $params['axo'] ?? null;
                    $mes = $params['mes'] ?? null;
                    $result = DB::select('SELECT * FROM sp_get_recargos_energia(?, ?)', [$axo, $mes]);
                    $eResponse['success'] = true;
                    $eResponse['data'] = $result;
                    break;
                case 'getDiaVencimiento':
                    $mes = $params['mes'] ?? null;
                    $result = DB::select('SELECT * FROM sp_get_dia_vencimiento(?)', [$mes]);
                    $eResponse['success'] = true;
                    $eResponse['data'] = $result;
                    break;
                case 'getPagosEnergia':
                    $id_energia = $params['id_energia'] ?? null;
                    $result = DB::select('SELECT * FROM sp_get_pagos_energia(?)', [$id_energia]);
                    $eResponse['success'] = true;
                    $eResponse['data'] = $result;
                    break;
                case 'getCondonacionesEnergia':
                    $id_energia = $params['id_energia'] ?? null;
                    $result = DB::select('SELECT * FROM sp_get_condonaciones_energia(?)', [$id_energia]);
                    $eResponse['success'] = true;
                    $eResponse['data'] = $result;
                    break;
                default:
                    $eResponse['message'] = 'Acción no soportada';
            }
        } catch (\Exception $e) {
            $eResponse['success'] = false;
            $eResponse['message'] = $e->getMessage();
        }

        return response()->json(['eResponse' => $eResponse]);
    }
}

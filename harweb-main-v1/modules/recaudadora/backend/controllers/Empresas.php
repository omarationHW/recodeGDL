<?php

namespace App\Http\Controllers\Api;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;
use App\Http\Controllers\Controller;

class EmpresasController extends Controller
{
    /**
     * Endpoint único para todas las operaciones (eRequest/eResponse)
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
                case 'get_ejecutores':
                    $result = DB::select('SELECT * FROM sp_get_ejecutores()');
                    $eResponse['success'] = true;
                    $eResponse['data'] = $result;
                    break;
                case 'check_cuenta':
                    $result = DB::select('SELECT * FROM sp_check_cuenta(?, ?, ?)', [
                        $eRequest['cvecuenta'],
                        $eRequest['cveejecutor'],
                        $eRequest['fecha_trabajo']
                    ]);
                    $eResponse['success'] = true;
                    $eResponse['data'] = $result[0] ?? null;
                    break;
                case 'check_empresa_diferente':
                    $result = DB::select('SELECT * FROM sp_check_empresa_diferente(?, ?)', [
                        $eRequest['cvecuenta'],
                        $eRequest['cveejecutor']
                    ]);
                    $eResponse['success'] = true;
                    $eResponse['data'] = $result[0] ?? null;
                    break;
                case 'insert_ctaempexterna':
                    $result = DB::select('SELECT * FROM sp_insert_ctaempexterna(?, ?, ?)', [
                        $eRequest['cvecuenta'],
                        $eRequest['cveejecutor'],
                        $eRequest['fecha_trabajo']
                    ]);
                    $eResponse['success'] = $result[0]->inserted;
                    $eResponse['data'] = $result[0];
                    break;
                case 'get_empresas_folios':
                    $result = DB::select('SELECT * FROM sp_empresas_folios(?, ?, ?, ?, ?, ?, ?, ?)', [
                        $eRequest['rec'],
                        $eRequest['axo'],
                        $eRequest['fdsd'],
                        $eRequest['fhst'],
                        $eRequest['fecha'],
                        $eRequest['ejecutor'],
                        $eRequest['mod'],
                        $eRequest['opc']
                    ]);
                    $eResponse['success'] = true;
                    $eResponse['data'] = $result;
                    break;
                case 'get_predial_principal':
                    $result = DB::select('SELECT * FROM sp_predial_principal(?, ?)', [
                        $eRequest['cveejecutor'],
                        $eRequest['fecha']
                    ]);
                    $eResponse['success'] = true;
                    $eResponse['data'] = $result;
                    break;
                case 'get_predial_detalle':
                    $result = DB::select('SELECT * FROM sp_predial_detalle(?, ?)', [
                        $eRequest['cveejecutor'],
                        $eRequest['fecha']
                    ]);
                    $eResponse['success'] = true;
                    $eResponse['data'] = $result;
                    break;
                // Agregar más acciones según sea necesario
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

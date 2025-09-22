<?php

namespace App\Http\Controllers\Api;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use App\Http\Controllers\Controller;
use Illuminate\Support\Facades\Validator;

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
            'message' => '',
            'data' => null
        ];

        try {
            switch ($eRequest['action']) {
                case 'insert_baja_multiple':
                    $archivo = $eRequest['archivo'];
                    $registros = $eRequest['registros']; // array de objetos
                    DB::beginTransaction();
                    foreach ($registros as $registro) {
                        DB::select('CALL sp_insert_folios_baja_esta(?, ?, ?, ?, ?, ?)', [
                            $archivo,
                            $registro['referencia'],
                            $registro['folio_archivo'],
                            $registro['fecha_archivo'],
                            $registro['placa'],
                            $registro['anomalia']
                        ]);
                    }
                    DB::commit();
                    $eResponse['success'] = true;
                    $eResponse['message'] = 'Registros procesados correctamente.';
                    break;

                case 'aplicar_baja_multiple':
                    // Ejecuta el proceso de llenado y aplicación
                    DB::select('CALL sp14_ejecuta_sp()');
                    $eResponse['success'] = true;
                    $eResponse['message'] = 'Llenado y aplicación completados.';
                    break;

                case 'get_incidencias_baja_multiple':
                    $archivo = $eRequest['archivo'];
                    $result = DB::select('SELECT * FROM sp_get_incidencias_baja_multiple(?)', [$archivo]);
                    $eResponse['success'] = true;
                    $eResponse['data'] = $result;
                    break;

                default:
                    $eResponse['message'] = 'Acción no soportada.';
            }
        } catch (\Exception $ex) {
            DB::rollBack();
            $eResponse['message'] = 'Error: ' . $ex->getMessage();
        }

        return response()->json(['eResponse' => $eResponse]);
    }
}

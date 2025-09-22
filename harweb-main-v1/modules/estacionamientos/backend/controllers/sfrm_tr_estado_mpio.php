<?php

namespace App\Http\Controllers\Api;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Facades\Validator;
use App\Http\Controllers\Controller;

class ExecuteController extends Controller
{
    /**
     * Endpoint unificado para ejecutar acciones vía eRequest/eResponse
     */
    public function execute(Request $request)
    {
        $eRequest = $request->input('eRequest');
        $eParams = $request->input('eParams', []);
        $eResponse = [
            'success' => false,
            'data' => null,
            'message' => ''
        ];

        try {
            switch ($eRequest) {
                case 'get_remesas_estado_mpio':
                    $remesas = DB::select('SELECT * FROM sp_get_remesas_estado_mpio()');
                    $eResponse['success'] = true;
                    $eResponse['data'] = $remesas;
                    break;

                case 'upload_archivo_estado_mpio':
                    // Espera archivo en multipart/form-data
                    if ($request->hasFile('archivo')) {
                        $file = $request->file('archivo');
                        $path = $file->storeAs('edo_mpio_uploads', uniqid('edo_') . '_' . $file->getClientOriginalName());
                        // Procesar archivo (insertar datos)
                        $result = DB::select('SELECT * FROM sp_insert_folios_estado_mpio(?)', [$path]);
                        $eResponse['success'] = true;
                        $eResponse['data'] = $result;
                        $eResponse['message'] = 'Archivo subido y procesado correctamente.';
                    } else {
                        $eResponse['message'] = 'No se recibió archivo.';
                    }
                    break;

                case 'procesar_delesta01':
                    // Ejecuta el stored procedure spd_delesta01
                    $params = [
                        $eParams['axo'] ?? 0,
                        $eParams['folio'] ?? 0,
                        $eParams['placa'] ?? '',
                        $eParams['convenio'] ?? 0,
                        $eParams['fecha'] ?? null,
                        $eParams['reca'] ?? 0,
                        $eParams['caja'] ?? '',
                        $eParams['oper'] ?? 0,
                        $eParams['usuauto'] ?? 0,
                        $eParams['opc'] ?? 0
                    ];
                    $result = DB::select('SELECT * FROM spd_delesta01(?, ?, ?, ?, ?, ?, ?, ?, ?, ?)', $params);
                    $eResponse['success'] = true;
                    $eResponse['data'] = $result;
                    break;

                default:
                    $eResponse['message'] = 'eRequest no reconocido.';
            }
        } catch (\Exception $ex) {
            Log::error('API Execute Error: ' . $ex->getMessage());
            $eResponse['message'] = 'Error en la ejecución: ' . $ex->getMessage();
        }

        return response()->json($eResponse);
    }
}

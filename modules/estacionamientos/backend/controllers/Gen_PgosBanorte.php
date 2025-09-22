<?php

namespace App\Http\Controllers\Api;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\Storage;
use App\Http\Controllers\Controller;
use Carbon\Carbon;

class GenPgosBanorteController extends Controller
{
    /**
     * Endpoint único para manejar todas las operaciones del formulario Gen_PgosBanorte
     * Patrón eRequest/eResponse
     */
    public function execute(Request $request)
    {
        $eRequest = $request->input('eRequest');
        $operation = $eRequest['operation'] ?? null;
        $params = $eRequest['params'] ?? [];
        $eResponse = [
            'success' => false,
            'message' => '',
            'data' => null
        ];

        try {
            switch ($operation) {
                case 'get_periodo':
                    // Obtener último periodo de pagos Banorte
                    $row = DB::selectOne('SELECT fecha_inicio, fecha_fin FROM ta14_bitacora WHERE tipo = ? ORDER BY fecha_fin DESC LIMIT 1', ['D']);
                    $eResponse['success'] = true;
                    $eResponse['data'] = $row;
                    break;

                case 'ejecutar_remesa':
                    // Ejecutar proceso de generación de remesa
                    $axo = $params['axo'];
                    $fec_ini = $params['fec_ini'];
                    $fec_fin = $params['fec_fin'];
                    $fec_a_fin = Carbon::now()->toDateString();
                    $result = DB::select('SELECT * FROM sp14_remesa(?, ?, ?, ?, ?)', [2, $axo, $fec_ini, $fec_fin, $fec_a_fin]);
                    $sp = $result[0] ?? null;
                    if ($sp && $sp->status == 0) {
                        // Buscar folios de la remesa
                        $count = DB::selectOne('SELECT COUNT(*) as count FROM ta14_datos_mpio WHERE remesa = ?', [$sp->remesa]);
                        $eResponse['success'] = true;
                        $eResponse['data'] = [
                            'remesa' => $sp->remesa,
                            'obs' => $sp->obs,
                            'count' => $count->count
                        ];
                    } else {
                        $eResponse['message'] = 'Hubo errores en el proceso sp14_remesa';
                        $eResponse['data'] = $sp;
                    }
                    break;

                case 'generar_archivo':
                    // Generar archivo de texto con los registros de la remesa
                    $remesa = $params['remesa'];
                    $rows = DB::select('SELECT idrmunicipio, tipoact, folio, trim(to_char(fechagenreq, \'MM/DD/YYYY\')) as fechagenreq, placa, trim(folionot) as folionot, trim(to_char(fechanot, \'MM/DD/YYYY\')) as fechanot, trim(to_char(fechapago, \'MM/DD/YYYY\')) as fechapago, trim(to_char(fechacancelado, \'MM/DD/YYYY\')) as fechacancelado, importe, clave, to_char(fechaalta, \'MM/DD/YYYY\') as fechaalta, to_char(fechavenc, \'MM/DD/YYYY\') as fechavenc, folioec, trim(folioecmpio) as folioecmpio, gastos, remesa, to_char(fecharemesa, \'MM/DD/YYYY\') as fecharemesa FROM ta14_datos_mpio WHERE remesa = ?', [$remesa]);
                    if (count($rows) > 0) {
                        $lines = [];
                        foreach ($rows as $row) {
                            $registro = [
                                $row->idrmunicipio,
                                $row->tipoact,
                                $row->folio,
                                $row->fechagenreq,
                                $row->placa,
                                $row->folionot,
                                $row->fechanot,
                                $row->fechapago,
                                $row->fechacancelado,
                                $row->importe,
                                $row->clave,
                                $row->fechaalta,
                                $row->fechavenc,
                                $row->folioec,
                                $row->folioecmpio,
                                $row->gastos,
                                $row->remesa,
                                $row->fecharemesa
                            ];
                            $lines[] = implode('|', $registro) . '|';
                        }
                        // Guardar archivo en storage/app/remesas/
                        $filename = 'remesa_' . $remesa . '_' . date('Ymd_His') . '.txt';
                        $filepath = 'remesas/' . $filename;
                        Storage::disk('local')->put($filepath, implode("\n", $lines));
                        $eResponse['success'] = true;
                        $eResponse['data'] = [
                            'filename' => $filename,
                            'download_url' => url('/api/remesas/download/' . $filename),
                            'count' => count($lines)
                        ];
                    } else {
                        $eResponse['message'] = 'No hubo registros para generar el archivo de texto, intenta con otro.';
                    }
                    break;

                case 'descargar_archivo':
                    // Descargar archivo generado
                    $filename = $params['filename'];
                    $filepath = 'remesas/' . $filename;
                    if (Storage::disk('local')->exists($filepath)) {
                        return response()->download(storage_path('app/' . $filepath));
                    } else {
                        $eResponse['message'] = 'Archivo no encontrado.';
                    }
                    break;

                default:
                    $eResponse['message'] = 'Operación no soportada.';
            }
        } catch (\Exception $e) {
            Log::error('GenPgosBanorteController error: ' . $e->getMessage());
            $eResponse['message'] = 'Error: ' . $e->getMessage();
        }

        return response()->json(['eResponse' => $eResponse]);
    }

    /**
     * Endpoint para descargar archivos de remesas
     */
    public function download($filename)
    {
        $filepath = 'remesas/' . $filename;
        if (Storage::disk('local')->exists($filepath)) {
            return response()->download(storage_path('app/' . $filepath));
        } else {
            abort(404, 'Archivo no encontrado.');
        }
    }
}

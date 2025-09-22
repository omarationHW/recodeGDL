<?php

namespace App\Http\Controllers\Api;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Facades\Validator;
use App\Http\Controllers\Controller;
use Carbon\Carbon;

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
            'status' => 'error',
            'message' => 'Unknown operation',
            'data' => null
        ];

        try {
            switch ($eRequest) {
                case 'get_periodo_diario':
                    $row = DB::selectOne("SELECT fecha_inicio, fecha_fin FROM ta14_bitacora WHERE tipo = 'C' ORDER BY fecha_fin DESC LIMIT 1");
                    $eResponse = [
                        'status' => 'ok',
                        'data' => $row
                    ];
                    break;
                case 'get_periodo_altas':
                    $row = DB::selectOne("SELECT fecha_inicio, fecha_fin FROM ta14_bitacora WHERE tipo = 'B' ORDER BY fecha_fin DESC LIMIT 1");
                    $eResponse = [
                        'status' => 'ok',
                        'data' => $row
                    ];
                    break;
                case 'ejecutar_remesa':
                    // params: p_Axo, p_Fec_Ini, p_Fec_Fin, p_Fec_A_Fin
                    $result = DB::selectOne("SELECT * FROM sp14_remesa(?, ?, ?, ?, ?)", [
                        1, // p_Opc = 1 (carga diaria)
                        $params['p_Axo'],
                        $params['p_Fec_Ini'],
                        $params['p_Fec_Fin'],
                        $params['p_Fec_A_Fin']
                    ]);
                    $eResponse = [
                        'status' => 'ok',
                        'data' => $result
                    ];
                    break;
                case 'buscar_folios_remesa':
                    // params: remesa, tipoact
                    $row = DB::selectOne("SELECT COUNT(*) as count FROM ta14_datos_mpio WHERE remesa = ? AND tipoact = ?", [
                        $params['remesa'], $params['tipoact']
                    ]);
                    $eResponse = [
                        'status' => 'ok',
                        'data' => $row
                    ];
                    break;
                case 'generar_archivo_remesa':
                    // params: remesa
                    $rows = DB::select("
                        SELECT 
                            idrmunicipio, tipoact, folio, 
                            TO_CHAR(fechagenreq, 'MM/DD/YYYY') as fechagenreq, 
                            placa, TRIM(folionot) as folionot, TO_CHAR(fechanot, 'MM/DD/YYYY') as fechanot, 
                            TO_CHAR(fechapago, 'MM/DD/YYYY') as fechapago, 
                            TO_CHAR(fechacancelado, 'MM/DD/YYYY') as fechacancelado, 
                            importe, clave, 
                            TO_CHAR(fechaalta, 'MM/DD/YYYY') as fechaalta, 
                            TO_CHAR(fechavenc, 'MM/DD/YYYY') as fechavenc, 
                            folioec, TRIM(folioecmpio) as folioecmpio, gastos, remesa, 
                            TO_CHAR(fecharemesa, 'MM/DD/YYYY') as fecharemesa
                        FROM ta14_datos_mpio WHERE remesa = ?
                    ", [$params['remesa']]);
                    if (count($rows) === 0) {
                        $eResponse = [
                            'status' => 'error',
                            'message' => 'No hubo registros para generar el archivo de texto, intenta con otro',
                            'data' => null
                        ];
                        break;
                    }
                    // Generar archivo de texto temporal
                    $filename = 'remesa_' . $params['remesa'] . '_' . date('Ymd_His') . '.txt';
                    $filepath = 'remesas/' . $filename;
                    $lines = [];
                    foreach ($rows as $row) {
                        $registro =
                            $row->idrmunicipio . '|' .
                            $row->tipoact . '|' .
                            $row->folio . '|' .
                            $row->fechagenreq . '|' .
                            $row->placa . '|' .
                            $row->folionot . '|' .
                            $row->fechanot . '|' .
                            $row->fechapago . '|' .
                            $row->fechacancelado . '|' .
                            $row->importe . '|' .
                            $row->clave . '|' .
                            $row->fechaalta . '|' .
                            $row->fechavenc . '|' .
                            $row->folioec . '|' .
                            $row->folioecmpio . '|' .
                            $row->gastos . '|' .
                            $row->remesa . '|' .
                            $row->fecharemesa . '|';
                        $lines[] = $registro;
                    }
                    Storage::disk('local')->put($filepath, implode("\n", $lines));
                    $url = route('api.remesa.download', ['filename' => $filename]);
                    $eResponse = [
                        'status' => 'ok',
                        'data' => [
                            'filename' => $filename,
                            'download_url' => $url
                        ]
                    ];
                    break;
                default:
                    $eResponse = [
                        'status' => 'error',
                        'message' => 'Operación no soportada: ' . $eRequest
                    ];
            }
        } catch (\Exception $e) {
            Log::error('API Execute error: ' . $e->getMessage());
            $eResponse = [
                'status' => 'error',
                'message' => $e->getMessage()
            ];
        }
        return response()->json(['eResponse' => $eResponse]);
    }

    /**
     * Endpoint to download generated remesa file
     * Route: api/remesa/download/{filename}
     */
    public function downloadRemesa($filename)
    {
        $filepath = 'remesas/' . $filename;
        if (!Storage::disk('local')->exists($filepath)) {
            abort(404, 'Archivo no encontrado');
        }
        return response()->download(storage_path('app/' . $filepath), $filename, [
            'Content-Type' => 'text/plain'
        ]);
    }
}

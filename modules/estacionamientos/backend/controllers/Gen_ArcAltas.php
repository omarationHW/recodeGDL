<?php

namespace App\Http\Controllers\Api;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Facades\Validator;
use Illuminate\Http\JsonResponse;
use App\Http\Controllers\Controller;

class GenArcAltasController extends Controller
{
    /**
     * Endpoint único para manejar todas las operaciones del formulario Gen_ArcAltas
     * Entrada: {
     *   eRequest: {
     *     action: string, // 'get_periodos', 'ejecutar_remesa', 'contar_folios', 'generar_archivo'
     *     params: {...} // parámetros según acción
     *   }
     * }
     */
    public function execute(Request $request)
    {
        $eRequest = $request->input('eRequest', []);
        $action = $eRequest['action'] ?? null;
        $params = $eRequest['params'] ?? [];
        $eResponse = [
            'success' => false,
            'data' => null,
            'message' => ''
        ];

        try {
            switch ($action) {
                case 'get_periodos':
                    $periodos = DB::select('SELECT fecha_inicio, fecha_fin FROM ta14_bitacora WHERE tipo = ? ORDER BY fecha_fin DESC LIMIT 1', ['B']);
                    $eResponse['success'] = true;
                    $eResponse['data'] = $periodos[0] ?? null;
                    break;
                case 'ejecutar_remesa':
                    // params: { fec_ini, fec_fin }
                    $fec_ini = $params['fec_ini'] ?? null;
                    $fec_fin = $params['fec_fin'] ?? null;
                    $axo = date('Y', strtotime($fec_ini));
                    $fec_a_fin = date('Y-m-d');
                    $result = DB::select('SELECT * FROM sp14_remesa(?, ?, ?, ?, ?)', [0, $axo, $fec_ini, $fec_fin, $fec_a_fin]);
                    $row = $result[0] ?? null;
                    $eResponse['success'] = true;
                    $eResponse['data'] = $row;
                    break;
                case 'contar_folios':
                    // params: { remesa }
                    $remesa = $params['remesa'] ?? null;
                    $count = DB::select('SELECT COUNT(*) as total FROM ta14_datos_mpio WHERE remesa = ?', [$remesa]);
                    $eResponse['success'] = true;
                    $eResponse['data'] = [ 'total' => $count[0]->total ?? 0 ];
                    break;
                case 'generar_archivo':
                    // params: { remesa }
                    $remesa = $params['remesa'] ?? null;
                    $rows = DB::select('SELECT idrmunicipio, tipoact, folio, to_char(fechagenreq, \'MM/DD/YYYY\') as fechagenreq, placa, trim(folionot) as folionot, to_char(fechanot, \'MM/DD/YYYY\') as fechanot, to_char(fechapago, \'MM/DD/YYYY\') as fechapago, to_char(fechacancelado, \'MM/DD/YYYY\') as fechacancelado, importe, clave, to_char(fechaalta, \'MM/DD/YYYY\') as fechaalta, to_char(fechavenc, \'MM/DD/YYYY\') as fechavenc, folioec, trim(folioecmpio) as folioecmpio, gastos, remesa, to_char(fecharemesa, \'MM/DD/YYYY\') as fecharemesa FROM ta14_datos_mpio WHERE remesa = ?', [$remesa]);
                    if (count($rows) == 0) {
                        $eResponse['success'] = false;
                        $eResponse['message'] = 'No hubo registros para generar el archivo de texto, intenta con otro';
                        break;
                    }
                    $lines = [];
                    foreach ($rows as $row) {
                        $registro = implode('|', [
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
                            $row->fecharemesa,
                        ]);
                        $lines[] = $registro;
                    }
                    // Guardar archivo temporal y devolver URL de descarga
                    $filename = 'remesa_' . $remesa . '_' . date('Ymd_His') . '.txt';
                    $filepath = 'remesas/' . $filename;
                    Storage::disk('local')->put($filepath, implode("\n", $lines));
                    $url = route('api.genarcaltas.download', ['filename' => $filename]);
                    $eResponse['success'] = true;
                    $eResponse['data'] = [ 'download_url' => $url ];
                    break;
                default:
                    $eResponse['message'] = 'Acción no soportada';
            }
        } catch (\Exception $e) {
            Log::error('GenArcAltasController error: ' . $e->getMessage());
            $eResponse['message'] = $e->getMessage();
        }
        return response()->json(['eResponse' => $eResponse]);
    }

    /**
     * Descarga de archivo generado
     */
    public function download($filename)
    {
        $filepath = 'remesas/' . $filename;
        if (!Storage::disk('local')->exists($filepath)) {
            abort(404);
        }
        return response()->download(storage_path('app/' . $filepath), $filename, [
            'Content-Type' => 'text/plain',
        ]);
    }
}

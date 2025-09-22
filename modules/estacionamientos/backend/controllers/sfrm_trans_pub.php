<?php

namespace App\Http\Controllers\Api;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;
use App\Http\Controllers\Controller;

class ExecuteController extends Controller
{
    /**
     * Handle unified API requests for sfrm_trans_pub operations
     * Endpoint: /api/execute
     */
    public function handle(Request $request)
    {
        $eRequest = $request->input('eRequest');
        $payload = $request->input('payload', []);
        $eResponse = [
            'success' => false,
            'message' => '',
            'data' => null
        ];

        try {
            switch ($eRequest) {
                case 'sfrm_trans_pub.upload_file':
                    // File upload and parse
                    if (!$request->hasFile('file')) {
                        $eResponse['message'] = 'No file uploaded.';
                        break;
                    }
                    $file = $request->file('file');
                    $lines = file($file->getRealPath(), FILE_IGNORE_NEW_LINES);
                    $parsed = [];
                    foreach ($lines as $line) {
                        if (substr($line, 3, 4) !== '9999' && substr($line, 153, 1) !== 'B') {
                            $parsed[] = [
                                'sector' => substr($line, 0, 1),
                                'categoria' => substr($line, 1, 2),
                                'numero' => substr($line, 3, 4),
                                'nombre' => trim(substr($line, 7, 30)),
                                'telefono' => trim(substr($line, 37, 7)),
                                'calle' => trim(substr($line, 44, 30)),
                                'num' => trim(substr($line, 74, 4)),
                                'cupo' => trim(substr($line, 78, 4)),
                                'fec_alta' => substr($line, 82, 2) . '/' . substr($line, 84, 2) . '/' . substr($line, 86, 2),
                                'fec_inic' => substr($line, 88, 2) . '/' . substr($line, 90, 2) . '/' . substr($line, 92, 2),
                                'fec_venci' => substr($line, 94, 2) . '/' . substr($line, 96, 2) . '/' . substr($line, 98, 2),
                                'de_las' => trim(substr($line, 100, 4)),
                                'a_las' => trim(substr($line, 104, 4)),
                                'de_las_dom' => trim(substr($line, 108, 4)),
                                'a_las_dom' => trim(substr($line, 112, 4)),
                                'lun' => substr($line, 116, 1),
                                'mar' => substr($line, 117, 1),
                                'mier' => substr($line, 118, 1),
                                'jue' => substr($line, 119, 1),
                                'vie' => substr($line, 120, 1),
                                'sat' => substr($line, 121, 1),
                                'dom' => substr($line, 122, 1),
                                'pol_num' => trim(substr($line, 123, 12)),
                                'pol_fec' => substr($line, 135, 2) . '/' . substr($line, 137, 2) . '/' . substr($line, 139, 2),
                                'num_lic' => trim(substr($line, 141, 9)),
                                'zona' => substr($line, 150, 1),
                                'sub_zona' => substr($line, 151, 2),
                                'estatus' => substr($line, 153, 1),
                                'clave' => substr($line, 154, 1)
                            ];
                        }
                    }
                    $eResponse['success'] = true;
                    $eResponse['data'] = $parsed;
                    $eResponse['message'] = 'Archivo procesado correctamente.';
                    break;

                case 'sfrm_trans_pub.insert_records':
                    // Insert records via stored procedure
                    $records = $payload['records'] ?? [];
                    $inserted = 0;
                    foreach ($records as $rec) {
                        $result = DB::select('SELECT sp_ta_15_publicos_insert(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?) as inserted', [
                            $rec['sector'],
                            $rec['categoria'],
                            $rec['numero'],
                            $rec['nombre'],
                            $rec['telefono'],
                            $rec['calle'],
                            $rec['num'],
                            $rec['cupo'],
                            $rec['fec_alta'],
                            $rec['fec_inic'],
                            $rec['fec_venci'],
                            $rec['de_las'],
                            $rec['a_las'],
                            $rec['de_las_dom'],
                            $rec['a_las_dom'],
                            $rec['lun'],
                            $rec['mar'],
                            $rec['mier'],
                            $rec['jue'],
                            $rec['vie'],
                            $rec['sat'],
                            $rec['dom'],
                            $rec['pol_num'],
                            $rec['pol_fec'],
                            $rec['num_lic'],
                            $rec['zona'],
                            $rec['sub_zona'],
                            $rec['estatus'],
                            $rec['clave'],
                            auth()->id() ?? 1 // control/usuario
                        ]);
                        if ($result && $result[0]->inserted) $inserted++;
                    }
                    $eResponse['success'] = true;
                    $eResponse['message'] = "Registros insertados: $inserted";
                    break;

                case 'sfrm_trans_pub.update_pol_fec_ven':
                    // Update pol_fec_ven via stored procedure
                    $updates = $payload['updates'] ?? [];
                    $updated = 0;
                    foreach ($updates as $upd) {
                        $result = DB::select('SELECT sp_ta_15_publicos_update_pol_fec_ven(?,?,?,?) as updated', [
                            $upd['sector'],
                            $upd['categoria'],
                            $upd['numero'],
                            $upd['pol_fec_ven']
                        ]);
                        if ($result && $result[0]->updated) $updated++;
                    }
                    $eResponse['success'] = true;
                    $eResponse['message'] = "Registros actualizados: $updated";
                    break;

                default:
                    $eResponse['message'] = 'eRequest no soportado.';
            }
        } catch (\Exception $ex) {
            $eResponse['message'] = $ex->getMessage();
        }
        return response()->json(['eResponse' => $eResponse]);
    }
}

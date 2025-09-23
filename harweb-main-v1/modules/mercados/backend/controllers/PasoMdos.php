<?php
namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;

class PasoMdosController extends Controller
{
    /**
     * Endpoint único para ejecutar acciones relacionadas con PasoMdos
     * Entrada: eRequest con action, data
     * Salida: eResponse con status, message, data
     */
    public function execute(Request $request)
    {
        $action = $request->input('action');
        $data = $request->input('data');
        $response = [
            'status' => 'error',
            'message' => 'Acción no reconocida',
            'data' => null
        ];

        try {
            switch ($action) {
                case 'get_tianguis':
                    $result = DB::select('SELECT * FROM cobrotrimestral');
                    $response = [
                        'status' => 'success',
                        'message' => 'Datos obtenidos',
                        'data' => $result
                    ];
                    break;
                case 'get_padron':
                    $folio = $data['folio'] ?? null;
                    $result = DB::select('SELECT * FROM ta_11_locales WHERE oficina=1 AND num_mercado=214 AND categoria=1 AND seccion=\'SS\' AND local=? AND letra_local IS NULL AND bloque IS NULL', [$folio]);
                    $response = [
                        'status' => 'success',
                        'message' => 'Padron obtenido',
                        'data' => $result
                    ];
                    break;
                case 'migrar_tianguis_a_padron':
                    $userId = $data['user_id'] ?? 1;
                    $result = DB::select('SELECT * FROM cobrotrimestral');
                    $errores = [];
                    $existentes = 0;
                    foreach ($result as $row) {
                        $padron = DB::select('SELECT * FROM ta_11_locales WHERE oficina=1 AND num_mercado=214 AND categoria=1 AND seccion=\'SS\' AND local=? AND letra_local IS NULL AND bloque IS NULL', [$row->Folio]);
                        if (count($padron) == 0) {
                            try {
                                DB::statement('CALL sp_insert_tianguis_padron(?, ?, ?, ?, ?, ?, ?, ?, ?, ?)', [
                                    $row->Folio,
                                    $row->Nombre,
                                    $row->Domicilio,
                                    $row->Superficie,
                                    $row->Giro,
                                    $row->Descuento,
                                    $row->MotivoDescuento,
                                    $userId,
                                    now(),
                                    'A'
                                ]);
                            } catch (\Exception $e) {
                                $errores[] = [
                                    'folio' => $row->Folio,
                                    'error' => $e->getMessage()
                                ];
                            }
                        } else {
                            $existentes++;
                        }
                    }
                    $response = [
                        'status' => 'success',
                        'message' => 'Migración completada',
                        'data' => [
                            'errores' => $errores,
                            'existentes' => $existentes
                        ]
                    ];
                    break;
                default:
                    $response['message'] = 'Acción no soportada';
            }
        } catch (\Exception $e) {
            $response = [
                'status' => 'error',
                'message' => $e->getMessage(),
                'data' => null
            ];
        }
        return response()->json($response);
    }
}

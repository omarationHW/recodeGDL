<?php

namespace App\Http\Controllers\Api;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;
use App\Http\Controllers\Controller;
use Illuminate\Support\Facades\Validator;

class GenIndividualController extends Controller
{
    /**
     * Endpoint único para manejar todas las operaciones del formulario Gen_Individual
     * Entrada: {
     *   eRequest: {
     *     action: string, // 'init', 'add', 'execute', 'generate_file', 'consult', 'get_remesa', etc.
     *     params: {...} // parámetros según acción
     *   }
     * }
     * Salida: {
     *   eResponse: {...}
     * }
     */
    public function execute(Request $request)
    {
        $input = $request->input('eRequest');
        $action = $input['action'] ?? null;
        $params = $input['params'] ?? [];
        $response = ["success" => false, "message" => "Acción no válida", "data" => null];

        try {
            switch ($action) {
                case 'init':
                    // Obtener número de remesa siguiente y fechas
                    $remesa = DB::selectOne('SELECT COALESCE(MAX(num_remesa),0)+1 as next_remesa FROM ta14_bitacora WHERE tipo IN (\'C\',\'B\',\'D\')');
                    $fecha = DB::selectOne('SELECT fecha_inicio, fecha_fin FROM ta14_bitacora WHERE tipo = \'C\' ORDER BY fecha_fin DESC LIMIT 1');
                    $response = [
                        "success" => true,
                        "data" => [
                            "next_remesa" => $remesa->next_remesa,
                            "fecha_inicio" => $fecha->fecha_inicio,
                            "fecha_fin" => $fecha->fecha_fin
                        ]
                    ];
                    break;
                case 'add':
                    // Buscar registros por placa/folio/año y grabar en ta14_datos_mpio
                    $result = DB::select('SELECT * FROM sp_gen_individual_add(:opcion, :placa, :axo, :folio, :remesa)', [
                        'opcion' => $params['opcion'],
                        'placa' => $params['placa'] ?? null,
                        'axo' => $params['axo'] ?? null,
                        'folio' => $params['folio'] ?? null,
                        'remesa' => $params['remesa']
                    ]);
                    $response = [
                        "success" => true,
                        "data" => $result
                    ];
                    break;
                case 'execute':
                    // Ejecutar grabación de registros seleccionados
                    $result = DB::select('SELECT * FROM sp_gen_individual_execute(:remesa)', [
                        'remesa' => $params['remesa']
                    ]);
                    $response = [
                        "success" => true,
                        "data" => $result
                    ];
                    break;
                case 'generate_file':
                    // Generar archivo de texto con los datos de la remesa
                    $result = DB::select('SELECT * FROM sp_gen_individual_generate_file(:remesa)', [
                        'remesa' => $params['remesa']
                    ]);
                    $lines = [];
                    foreach ($result as $row) {
                        $lines[] = implode('|', array_values((array)$row));
                    }
                    $filename = 'remesa_' . $params['remesa'] . '_' . date('Ymd_His') . '.txt';
                    $filepath = storage_path('app/remesas/' . $filename);
                    if (!file_exists(dirname($filepath))) {
                        mkdir(dirname($filepath), 0777, true);
                    }
                    file_put_contents($filepath, implode("\n", $lines));
                    $response = [
                        "success" => true,
                        "file" => $filename,
                        "url" => url('storage/remesas/' . $filename)
                    ];
                    break;
                case 'consult':
                    // Consultar registros de la remesa
                    $result = DB::select('SELECT * FROM ta14_datos_mpio WHERE remesa = :remesa', [
                        'remesa' => $params['remesa']
                    ]);
                    $response = [
                        "success" => true,
                        "data" => $result
                    ];
                    break;
                case 'delete_remesa':
                    // Borrar registros de la remesa
                    DB::statement('DELETE FROM ta14_datos_mpio WHERE remesa = :remesa', [
                        'remesa' => $params['remesa']
                    ]);
                    $response = [
                        "success" => true,
                        "message" => "Remesa eliminada"
                    ];
                    break;
                default:
                    $response = ["success" => false, "message" => "Acción no reconocida"];
            }
        } catch (\Exception $e) {
            Log::error($e->getMessage());
            $response = ["success" => false, "message" => $e->getMessage()];
        }

        return response()->json(["eResponse" => $response]);
    }
}

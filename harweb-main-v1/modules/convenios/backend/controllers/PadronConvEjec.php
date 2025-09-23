<?php
namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;

class PadronConvEjecController extends Controller
{
    /**
     * Endpoint único para ejecutar acciones del formulario PadronConvEjec
     * Entrada: {
     *   "eRequest": {
     *     "action": "list|export|filters|init|getFolios|getTipos|getSubtipos|getRecaudadoras|getEjecutores",
     *     ... parámetros ...
     *   }
     * }
     * Salida: {
     *   "eResponse": { ... }
     * }
     */
    public function execute(Request $request)
    {
        $input = $request->input('eRequest', []);
        $action = $input['action'] ?? null;
        $response = ["success" => false, "data" => null, "message" => ""];

        try {
            switch ($action) {
                case 'init':
                    $response['data'] = [
                        'tipos' => DB::select('SELECT * FROM sp_padronconvejec_get_tipos()'),
                        'recaudadoras' => DB::select('SELECT * FROM sp_padronconvejec_get_recaudadoras()'),
                        'ejecutores' => DB::select('SELECT * FROM sp_padronconvejec_get_ejecutores()'),
                        'vigencias' => [
                            ["value" => "0", "label" => "TODAS LAS VIGENCIAS"],
                            ["value" => "A", "label" => "VIGENTES"],
                            ["value" => "B", "label" => "BAJAS"],
                            ["value" => "P", "label" => "PAGADOS"]
                        ]
                    ];
                    $response['success'] = true;
                    break;
                case 'getTipos':
                    $response['data'] = DB::select('SELECT * FROM sp_padronconvejec_get_tipos()');
                    $response['success'] = true;
                    break;
                case 'getSubtipos':
                    $tipo = $input['tipo'] ?? null;
                    $response['data'] = DB::select('SELECT * FROM sp_padronconvejec_get_subtipos(?)', [$tipo]);
                    $response['success'] = true;
                    break;
                case 'getRecaudadoras':
                    $response['data'] = DB::select('SELECT * FROM sp_padronconvejec_get_recaudadoras()');
                    $response['success'] = true;
                    break;
                case 'getEjecutores':
                    $response['data'] = DB::select('SELECT * FROM sp_padronconvejec_get_ejecutores()');
                    $response['success'] = true;
                    break;
                case 'list':
                    $params = [
                        $input['tipo'] ?? null,
                        $input['subtipo'] ?? null,
                        $input['recaudadora'] ?? null,
                        $input['vigencia'] ?? null,
                        $input['ejecutor'] ?? null,
                        $input['anio_ini'] ?? null,
                        $input['anio_fin'] ?? null
                    ];
                    $response['data'] = DB::select('SELECT * FROM sp_padronconvejec_list(?,?,?,?,?,?,?)', $params);
                    $response['success'] = true;
                    break;
                case 'export':
                    $params = [
                        $input['tipo'] ?? null,
                        $input['subtipo'] ?? null,
                        $input['recaudadora'] ?? null,
                        $input['vigencia'] ?? null,
                        $input['ejecutor'] ?? null,
                        $input['anio_ini'] ?? null,
                        $input['anio_fin'] ?? null
                    ];
                    $data = DB::select('SELECT * FROM sp_padronconvejec_list(?,?,?,?,?,?,?)', $params);
                    // Aquí se puede implementar la exportación a Excel y devolver la URL del archivo
                    $response['data'] = $data;
                    $response['success'] = true;
                    break;
                default:
                    $response['message'] = 'Acción no soportada';
            }
        } catch (\Exception $e) {
            $response['message'] = $e->getMessage();
        }
        return response()->json(['eResponse' => $response]);
    }
}

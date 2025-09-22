<?php
namespace App\Http\Controllers\Api;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use App\Http\Controllers\Controller;

class ListxFecController extends Controller
{
    /**
     * Endpoint único para ejecutar acciones del formulario ListxFec
     * Entrada: eRequest con action, params
     * Salida: eResponse con status, data, message
     */
    public function execute(Request $request)
    {
        $action = $request->input('action');
        $params = $request->input('params', []);
        $response = [
            'status' => 'error',
            'data' => null,
            'message' => 'Acción no reconocida'
        ];

        try {
            switch ($action) {
                case 'getVigencias':
                    $vigencias = DB::select('SELECT * FROM sp_listxFec_get_vigencias()');
                    $response = [
                        'status' => 'ok',
                        'data' => $vigencias,
                        'message' => ''
                    ];
                    break;
                case 'getRecaudadoras':
                    $recaudadoras = DB::select('SELECT * FROM sp_listxFec_get_recaudadoras()');
                    $response = [
                        'status' => 'ok',
                        'data' => $recaudadoras,
                        'message' => ''
                    ];
                    break;
                case 'getEjecutores':
                    $rec = $params['rec'] ?? null;
                    $ejecutores = DB::select('SELECT * FROM sp_listxFec_get_ejecutores(?)', [$rec]);
                    $response = [
                        'status' => 'ok',
                        'data' => $ejecutores,
                        'message' => ''
                    ];
                    break;
                case 'getReport':
                    // Parámetros esperados: rec, modulo, tipo_fecha, fecha1, fecha2, vigencia, ejecutor
                    $rec = $params['rec'] ?? null;
                    $modulo = $params['modulo'] ?? null;
                    $tipo_fecha = $params['tipo_fecha'] ?? null;
                    $fecha1 = $params['fecha1'] ?? null;
                    $fecha2 = $params['fecha2'] ?? null;
                    $vigencia = $params['vigencia'] ?? null;
                    $ejecutor = $params['ejecutor'] ?? null;
                    $result = DB::select('SELECT * FROM sp_listxFec_report(?,?,?,?,?,?,?)', [
                        $rec, $modulo, $tipo_fecha, $fecha1, $fecha2, $vigencia, $ejecutor
                    ]);
                    $response = [
                        'status' => 'ok',
                        'data' => $result,
                        'message' => ''
                    ];
                    break;
                default:
                    $response['message'] = 'Acción no soportada';
            }
        } catch (\Exception $e) {
            $response['status'] = 'error';
            $response['message'] = $e->getMessage();
        }
        return response()->json($response);
    }
}

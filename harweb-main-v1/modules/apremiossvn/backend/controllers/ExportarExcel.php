<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;

class ExportarExcelController extends Controller
{
    /**
     * Endpoint único para ejecutar acciones relacionadas con ExportarExcel
     * Entrada: eRequest con action y parámetros
     * Salida: eResponse con status, data, message
     */
    public function execute(Request $request)
    {
        $input = $request->all();
        $action = $input['action'] ?? null;
        $params = $input['params'] ?? [];
        $response = [
            'status' => 'error',
            'data' => null,
            'message' => 'Acción no reconocida'
        ];

        try {
            switch ($action) {
                case 'getRecaudadoras':
                    $data = DB::select('SELECT id_rec, recaudadora FROM ta_12_recaudadoras ORDER BY id_rec');
                    $response = [
                        'status' => 'success',
                        'data' => $data,
                        'message' => 'Lista de recaudadoras obtenida'
                    ];
                    break;
                case 'getFoliosPagos':
                    $validator = Validator::make($params, [
                        'prec' => 'required|integer',
                        'pmod' => 'required|integer',
                        'pfold' => 'required|integer',
                        'pfolh' => 'required|integer',
                        'pfemi' => 'required|date',
                        'pfpagd' => 'required|date',
                        'pfpagh' => 'required|date',
                    ]);
                    if ($validator->fails()) {
                        $response['message'] = $validator->errors()->first();
                        break;
                    }
                    $result = DB::select('CALL spd_15_foliospag(?, ?, ?, ?, ?, ?, ?)', [
                        $params['prec'],
                        $params['pmod'],
                        $params['pfold'],
                        $params['pfolh'],
                        $params['pfemi'],
                        $params['pfpagd'],
                        $params['pfpagh']
                    ]);
                    $response = [
                        'status' => 'success',
                        'data' => $result,
                        'message' => 'Folios pagos consultados'
                    ];
                    break;
                case 'exportExcel':
                    // Aquí se asume que el frontend solicita los datos y genera el Excel
                    // Si se requiere generación en backend, implementar lógica de exportación
                    $response = [
                        'status' => 'success',
                        'data' => null,
                        'message' => 'Exportación a Excel debe ser manejada en frontend con los datos obtenidos'
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

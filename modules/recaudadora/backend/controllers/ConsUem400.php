<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;

class ConsUem400Controller extends Controller
{
    /**
     * Endpoint único para ejecutar acciones sobre ConsUem400
     * Entrada: eRequest con action, params
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
                case 'search_by_comprobante':
                    $anio = $params['anio'] ?? null;
                    $comprob = $params['comprob'] ?? null;
                    $historico = DB::select('SELECT * FROM historico WHERE recaud = 0');
                    $comp400 = DB::select('SELECT * FROM comp_400 WHERE axocomc = ? AND comproc = ?', [str_pad($anio, 4, '0', STR_PAD_LEFT), str_pad($comprob, 6, '0', STR_PAD_LEFT)]);
                    $response = [
                        'status' => 'success',
                        'data' => [
                            'historico' => $historico,
                            'comp_400' => $comp400
                        ],
                        'message' => 'Consulta por comprobante exitosa'
                    ];
                    break;
                case 'search_by_cuenta':
                    $recaud = $params['recaud'] ?? null;
                    $ur = $params['ur'] ?? null;
                    $cuenta = $params['cuenta'] ?? null;
                    $historico = DB::select('SELECT * FROM historico WHERE recaud = ? AND ur = ? AND cuenta = ?', [str_pad($recaud, 3, '0', STR_PAD_LEFT), $ur, str_pad($cuenta, 6, '0', STR_PAD_LEFT)]);
                    $comp400 = DB::select('SELECT * FROM comp_400 WHERE recaud = ? AND urbrus = ? AND cuenta = ?', [str_pad($recaud, 3, '0', STR_PAD_LEFT), $ur, str_pad($cuenta, 6, '0', STR_PAD_LEFT)]);
                    $response = [
                        'status' => 'success',
                        'data' => [
                            'historico' => $historico,
                            'comp_400' => $comp400
                        ],
                        'message' => 'Consulta por cuenta exitosa'
                    ];
                    break;
                default:
                    $response['message'] = 'Acción no soportada para ConsUem400';
            }
        } catch (\Exception $e) {
            $response = [
                'status' => 'error',
                'data' => null,
                'message' => $e->getMessage()
            ];
        }
        return response()->json($response);
    }
}

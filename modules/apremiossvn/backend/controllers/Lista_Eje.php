<?php
namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;

class ListaEjeController extends Controller
{
    /**
     * Endpoint único para ejecutar acciones sobre Lista_Eje
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
                case 'get_lista_eje':
                    $vigentes = $params['vigentes'] ?? false;
                    $result = DB::select('CALL sp_lista_eje_get(?, ?)', [
                        $params['rec'] ?? 1,
                        $params['rec1'] ?? 9
                    ]);
                    if ($vigentes) {
                        $result = array_filter($result, function($row) {
                            return $row->vigencia === 'A';
                        });
                    }
                    $response = [
                        'status' => 'success',
                        'data' => array_values($result),
                        'message' => 'Lista obtenida correctamente'
                    ];
                    break;
                case 'export_lista_eje_excel':
                    // Lógica para exportar a Excel (puede ser implementada con un paquete como maatwebsite/excel)
                    // Aquí solo se simula la respuesta
                    $response = [
                        'status' => 'success',
                        'data' => null,
                        'message' => 'Exportación a Excel generada (simulada)'
                    ];
                    break;
                case 'print_lista_eje':
                    // Lógica para impresión (puede devolver PDF o datos para impresión)
                    $response = [
                        'status' => 'success',
                        'data' => null,
                        'message' => 'Impresión generada (simulada)'
                    ];
                    break;
                default:
                    $response['message'] = 'Acción no soportada';
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

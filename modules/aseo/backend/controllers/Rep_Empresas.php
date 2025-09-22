<?php
namespace App\Http\Controllers\Api;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use App\Http\Controllers\Controller;

class EmpresasReportController extends Controller
{
    /**
     * Endpoint unificado para ejecutar acciones relacionadas con el reporte de empresas.
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
            'message' => 'Acción no reconocida.'
        ];

        try {
            switch ($action) {
                case 'getReportOptions':
                    $response = [
                        'status' => 'success',
                        'data' => [
                            ['id' => 1, 'label' => 'Número de Empresa'],
                            ['id' => 2, 'label' => 'Tipo de Empresa'],
                            ['id' => 3, 'label' => 'Nombre'],
                            ['id' => 4, 'label' => 'Representante']
                        ],
                        'message' => 'Opciones de orden recuperadas.'
                    ];
                    break;
                case 'getEmpresasReport':
                    $order = isset($params['order']) ? intval($params['order']) : 1;
                    $result = DB::select('CALL sp_rep_empresas_report(?)', [$order]);
                    $response = [
                        'status' => 'success',
                        'data' => $result,
                        'message' => 'Reporte generado correctamente.'
                    ];
                    break;
                case 'previewEmpresasReport':
                    // Para exportar/preview, se puede reutilizar el mismo SP
                    $order = isset($params['order']) ? intval($params['order']) : 1;
                    $result = DB::select('CALL sp_rep_empresas_report(?)', [$order]);
                    // Aquí se podría generar PDF/Excel si se requiere
                    $response = [
                        'status' => 'success',
                        'data' => $result,
                        'message' => 'Vista previa generada.'
                    ];
                    break;
                default:
                    $response['message'] = 'Acción no soportada: ' . $action;
            }
        } catch (\Exception $e) {
            $response['status'] = 'error';
            $response['message'] = $e->getMessage();
        }
        return response()->json($response);
    }
}

<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;

class IngresoZonificadoController extends Controller
{
    /**
     * Endpoint único para ejecutar acciones (eRequest/eResponse)
     */
    public function execute(Request $request)
    {
        $action = $request->input('action');
        $params = $request->input('params', []);
        $response = [
            'success' => false,
            'data' => null,
            'message' => ''
        ];

        try {
            switch ($action) {
                case 'getIngresoZonificado':
                    $fecdesde = $params['fecdesde'] ?? null;
                    $fechasta = $params['fechasta'] ?? null;
                    if (!$fecdesde || !$fechasta) {
                        throw new \Exception('Fechas requeridas');
                    }
                    $result = DB::select('CALL sp_ingreso_zonificado(?, ?)', [$fecdesde, $fechasta]);
                    $response['success'] = true;
                    $response['data'] = $result;
                    break;
                case 'exportIngresoZonificadoPDF':
                    // Lógica para exportar PDF (puede usar un paquete como barryvdh/laravel-dompdf)
                    // Aquí solo se simula la respuesta
                    $response['success'] = true;
                    $response['data'] = [
                        'url' => url('/storage/reports/ingreso_zonificado.pdf')
                    ];
                    break;
                default:
                    $response['message'] = 'Acción no soportada';
            }
        } catch (\Exception $e) {
            $response['message'] = $e->getMessage();
            Log::error('IngresoZonificadoController error: ' . $e->getMessage());
        }

        return response()->json($response);
    }
}

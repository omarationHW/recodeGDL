<?php

namespace App\Http\Controllers\Api;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use App\Http\Controllers\Controller;
use Illuminate\Support\Facades\Validator;

class RepEstadoController extends Controller
{
    /**
     * Endpoint único para ejecutar acciones del formulario repestado
     * Entrada: {
     *   "eRequest": {
     *     "action": "get_estado_tramite", // o "print_reporte"
     *     "params": { ... }
     *   }
     * }
     */
    public function execute(Request $request)
    {
        $eRequest = $request->input('eRequest');
        $action = $eRequest['action'] ?? null;
        $params = $eRequest['params'] ?? [];
        $eResponse = [
            'success' => false,
            'data' => null,
            'message' => ''
        ];

        try {
            switch ($action) {
                case 'get_estado_tramite':
                    $tramiteId = $params['id_tramite'] ?? null;
                    if (!$tramiteId) {
                        throw new \Exception('El parámetro id_tramite es requerido');
                    }
                    $result = DB::select('SELECT * FROM sp_repestado_get_estado_tramite(?)', [$tramiteId]);
                    $eResponse['success'] = true;
                    $eResponse['data'] = $result;
                    break;
                case 'print_reporte':
                    $tramiteId = $params['id_tramite'] ?? null;
                    if (!$tramiteId) {
                        throw new \Exception('El parámetro id_tramite es requerido');
                    }
                    // Aquí se podría generar un PDF o devolver los datos para impresión
                    $result = DB::select('SELECT * FROM sp_repestado_get_estado_tramite(?)', [$tramiteId]);
                    // Simulación de generación de PDF (en real, usar dompdf o similar)
                    $pdfUrl = url('/storage/reportes/repestado_' . $tramiteId . '.pdf');
                    $eResponse['success'] = true;
                    $eResponse['data'] = [
                        'tramite' => $result,
                        'pdf_url' => $pdfUrl
                    ];
                    break;
                default:
                    throw new \Exception('Acción no soportada');
            }
        } catch (\Exception $ex) {
            $eResponse['success'] = false;
            $eResponse['message'] = $ex->getMessage();
        }
        return response()->json(['eResponse' => $eResponse]);
    }
}

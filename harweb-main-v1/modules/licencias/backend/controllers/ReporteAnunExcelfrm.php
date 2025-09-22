<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\Validator;

class ReporteAnunExcelController extends Controller
{
    /**
     * Endpoint único para ejecutar acciones del formulario ReporteAnunExcel
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
                case 'getGruposAnun':
                    $response = $this->getGruposAnun();
                    break;
                case 'getReporteAnuncios':
                    $response = $this->getReporteAnuncios($params);
                    break;
                case 'exportReporteAnuncios':
                    $response = $this->exportReporteAnuncios($params);
                    break;
                default:
                    $response['message'] = 'Acción no soportada';
            }
        } catch (\Exception $e) {
            Log::error($e->getMessage());
            $response['status'] = 'error';
            $response['message'] = $e->getMessage();
        }
        return response()->json($response);
    }

    /**
     * Obtener grupos de anuncios
     */
    private function getGruposAnun()
    {
        $grupos = DB::select('SELECT id, descripcion FROM anuncios_grupos ORDER BY descripcion');
        return [
            'status' => 'success',
            'data' => $grupos,
            'message' => 'Grupos de anuncios obtenidos'
        ];
    }

    /**
     * Obtener reporte de anuncios según filtros
     */
    private function getReporteAnuncios($params)
    {
        // Validar y mapear parámetros
        $vigencia = $params['vigencia'] ?? 0;
        $tipoRep = $params['tipoRep'] ?? 0;
        $fechaCons = $params['fechaCons'] ?? null;
        $fechaIni = $params['fechaIni'] ?? null;
        $fechaFin = $params['fechaFin'] ?? null;
        $adeudo = $params['adeudo'] ?? 0;
        $axoIni = $params['axoIni'] ?? null;
        $fechaPagoIni = $params['fechaPagoIni'] ?? null;
        $fechaPagoFin = $params['fechaPagoFin'] ?? null;
        $grupoAnunId = $params['grupoAnunId'] ?? null;

        // Llamar SP
        $result = DB::select('SELECT * FROM sp_reporte_anuncios_excel(?,?,?,?,?,?,?,?,?,?)', [
            $vigencia, $tipoRep, $fechaCons, $fechaIni, $fechaFin, $adeudo, $axoIni, $fechaPagoIni, $fechaPagoFin, $grupoAnunId
        ]);
        return [
            'status' => 'success',
            'data' => $result,
            'message' => 'Reporte generado'
        ];
    }

    /**
     * Exportar reporte de anuncios a Excel (devuelve URL temporal)
     */
    private function exportReporteAnuncios($params)
    {
        // Reutiliza getReporteAnuncios
        $data = $this->getReporteAnuncios($params);
        if ($data['status'] !== 'success') {
            return $data;
        }
        // Generar archivo Excel temporal
        $filename = 'reporte_anuncios_' . date('Ymd_His') . '.xlsx';
        $filepath = storage_path('app/public/reports/' . $filename);
        // Usar PhpSpreadsheet o similar para exportar
        // ...
        // Simulación:
        file_put_contents($filepath, 'Simulación de archivo Excel');
        $url = asset('storage/reports/' . $filename);
        return [
            'status' => 'success',
            'data' => [ 'url' => $url ],
            'message' => 'Archivo generado'
        ];
    }
}

<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\ProyectoObra;
use App\Services\ProyectoObraService;
use Barryvdh\DomPDF\Facade\Pdf;
use Illuminate\Http\Request;
use Illuminate\Http\Response;
use Illuminate\Support\Facades\DB;

class ReporteController extends Controller
{
    public function __construct(
        private ProyectoObraService $service
    ) {}

    public function generarPDF(Request $request)
    {
        $configuracion = $request->validate([
            'titulo' => 'string|max:200',
            'periodo' => 'string|max:50',
            'formato' => 'in:carta,oficio',
            'orientacion' => 'in:vertical,horizontal',
            'incluir_estadisticas' => 'boolean',
            'incluir_detalles' => 'boolean',
            'incluir_adeudos' => 'boolean',
            'incluir_graficos' => 'boolean'
        ]);

        // Valores por defecto
        $configuracion = array_merge([
            'titulo' => 'Reporte de Obras de Pavimentación 2025',
            'periodo' => '2025',
            'formato' => 'carta',
            'orientacion' => 'vertical',
            'incluir_estadisticas' => true,
            'incluir_detalles' => true,
            'incluir_adeudos' => true,
            'incluir_graficos' => true
        ], $configuracion);

        try {
            // Obtener datos para el reporte
            $datos = $this->obtenerDatosReporte($configuracion);
            
            // Configurar el PDF
            $paper = $configuracion['formato'] === 'carta' ? 'letter' : 'legal';
            $orientation = $configuracion['orientacion'] === 'vertical' ? 'portrait' : 'landscape';
            
            // Generar el PDF
            $pdf = Pdf::loadView('reportes.pavimentacion-pdf', [
                'configuracion' => $configuracion,
                'datos' => $datos,
                'fecha_generacion' => now()->format('d/m/Y H:i:s')
            ])
            ->setPaper($paper, $orientation)
            ->setOptions([
                'isHtml5ParserEnabled' => true,
                'isRemoteEnabled' => true,
                'defaultFont' => 'Arial'
            ]);
            
            $filename = 'reporte_pavimentacion_' . date('Y-m-d_H-i-s') . '.pdf';
            
            return $pdf->download($filename);
            
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Error al generar el reporte: ' . $e->getMessage()
            ], 500);
        }
    }

    private function obtenerDatosReporte(array $configuracion): array
    {
        $datos = [];
        
        // Estadísticas generales
        if ($configuracion['incluir_estadisticas']) {
            $datos['estadisticas'] = $this->service->obtenerEstadisticas();
        }
        
        // Detalle de proyectos
        if ($configuracion['incluir_detalles']) {
            $datos['proyectos'] = $this->service->obtenerProyectosOptimizado();
        }
        
        // Resumen de adeudos
        if ($configuracion['incluir_adeudos']) {
            $datos['adeudos'] = $this->obtenerResumenAdeudos();
        }
        
        // Datos para gráficos
        if ($configuracion['incluir_graficos']) {
            $datos['graficos'] = $this->obtenerDatosGraficos();
        }
        
        return $datos;
    }
    
    private function obtenerResumenAdeudos(): array
    {
        $adeudos = DB::select("
            SELECT 
                po.contrato,
                po.nombre,
                po.costototal,
                COALESCE(SUM(CASE WHEN ao.estado = 'P' THEN ao.mensualidad ELSE 0 END), 0) as monto_pagado,
                COALESCE(SUM(CASE WHEN ao.estado = 'V' THEN ao.mensualidad ELSE 0 END), 0) as monto_pendiente,
                COUNT(CASE WHEN ao.estado = 'P' THEN 1 END) as mensualidades_pagadas,
                COUNT(CASE WHEN ao.estado = 'V' THEN 1 END) as mensualidades_pendientes
            FROM pavimentacion.ta_99_proyecto_obra_pavimiento po
            LEFT JOIN pavimentacion.ta_99_adeudos_obra ao ON po.id_control = ao.id_control
            GROUP BY po.id_control, po.contrato, po.nombre, po.costototal
            ORDER BY po.contrato
        ");
        
        return array_map(function($adeudo) {
            return [
                'contrato' => $adeudo->contrato,
                'nombre' => $adeudo->nombre,
                'costototal' => floatval($adeudo->costototal),
                'monto_pagado' => floatval($adeudo->monto_pagado),
                'monto_pendiente' => floatval($adeudo->monto_pendiente),
                'mensualidades_pagadas' => $adeudo->mensualidades_pagadas,
                'mensualidades_pendientes' => $adeudo->mensualidades_pendientes,
                'porcentaje_avance' => $adeudo->costototal > 0 ? 
                    round(($adeudo->monto_pagado / $adeudo->costototal) * 100, 2) : 0
            ];
        }, $adeudos);
    }
    
    private function obtenerDatosGraficos(): array
    {
        // Distribución por tipo de pavimento
        $tiposPavimento = DB::select("
            SELECT 
                tipo_pavimento,
                COUNT(*) as cantidad,
                SUM(costototal) as inversion_total
            FROM pavimentacion.ta_99_proyecto_obra_pavimiento
            GROUP BY tipo_pavimento
        ");
        
        // Estado de pagos por mes
        $estadoPagos = DB::select("
            SELECT 
                mes,
                COUNT(CASE WHEN estado = 'P' THEN 1 END) as pagados,
                COUNT(CASE WHEN estado = 'V' THEN 1 END) as pendientes,
                SUM(CASE WHEN estado = 'P' THEN mensualidad ELSE 0 END) as monto_pagado,
                SUM(CASE WHEN estado = 'V' THEN mensualidad ELSE 0 END) as monto_pendiente
            FROM pavimentacion.ta_99_adeudos_obra
            WHERE axo = 2025
            GROUP BY mes
            ORDER BY mes
        ");
        
        return [
            'tipos_pavimento' => array_map(function($tipo) {
                return [
                    'tipo' => $tipo->tipo_pavimento === 'A' ? 'Asfalto' : 'Concreto Hidráulico',
                    'cantidad' => $tipo->cantidad,
                    'inversion_total' => floatval($tipo->inversion_total)
                ];
            }, $tiposPavimento),
            'estado_pagos' => array_map(function($estado) {
                return [
                    'mes' => $estado->mes,
                    'pagados' => $estado->pagados,
                    'pendientes' => $estado->pendientes,
                    'monto_pagado' => floatval($estado->monto_pagado),
                    'monto_pendiente' => floatval($estado->monto_pendiente)
                ];
            }, $estadoPagos)
        ];
    }
}
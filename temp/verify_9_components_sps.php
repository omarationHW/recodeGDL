<?php

// SPs detectados en los componentes
$spsRequeridos = [
    'RptFacturaGLunes' => ['sp_rpt_factura_global'],
    'RptIngresos' => ['sp_rpt_ingresos_locales'],
    'RptIngresosEnergia' => ['sp_rpt_ingresos_energia'],
    'RptLocalesGiro' => ['sp_rpt_locales_giro'],
    'RptMercados' => ['sp_rpt_catalogo_mercados'],
    'RptPagosDetalle' => ['sp_rpt_pagos_detalle'],
    'RptPagosGrl' => ['sp_rpt_pagos_grl'],
    'RptSaldosLocales' => ['sp_rpt_saldos_locales'],
    'ZonasMercados' => ['sp_zonas_list', 'sp_zonas_delete']
];

// Rutas donde buscar SPs
$rutasBase = [
    'C:/guadalajara/code/recodeGDLCurrent/recodeGDL/RefactorX/Base/mercados/database/ok/',
    'C:/guadalajara/code/recodeGDLCurrent/recodeGDL/RefactorX/Base/mercados/database/database/'
];

echo "\n╔══════════════════════════════════════════════════════════════════════════════╗\n";
echo "║ VERIFICACIÓN DE STORED PROCEDURES - 9 COMPONENTES NUEVOS                    ║\n";
echo "╚══════════════════════════════════════════════════════════════════════════════╝\n\n";

$reporte = [];
$totalSPs = 0;
$spsEncontrados = 0;

foreach ($spsRequeridos as $componente => $sps) {
    echo "═══════════════════════════════════════════════════════════════════════════════\n";
    echo "COMPONENTE: {$componente}.vue\n";
    echo "═══════════════════════════════════════════════════════════════════════════════\n";

    foreach ($sps as $sp) {
        $totalSPs++;
        echo "\nSP: {$sp}\n";

        $encontrado = false;
        $ubicacion = '';

        // Buscar en carpeta ok/
        foreach (glob($rutasBase[0] . '*.sql') as $archivo) {
            $contenido = file_get_contents($archivo);
            if (preg_match("/CREATE\s+(OR\s+REPLACE\s+)?FUNCTION\s+{$sp}\s*\(/i", $contenido)) {
                $encontrado = true;
                $ubicacion = basename($archivo);
                break;
            }
        }

        // Si no se encontró, buscar en database/
        if (!$encontrado) {
            $patronArchivo = $rutasBase[1] . '*' . $sp . '*.sql';
            $archivos = glob($patronArchivo);

            if (!empty($archivos)) {
                $encontrado = true;
                $ubicacion = basename($archivos[0]);
            }
        }

        if ($encontrado) {
            echo "  ✅ ENCONTRADO: {$ubicacion}\n";
            $spsEncontrados++;
        } else {
            echo "  ❌ NO ENCONTRADO\n";
        }

        $reporte[$componente][$sp] = [
            'encontrado' => $encontrado,
            'ubicacion' => $ubicacion
        ];
    }

    echo "\n";
}

echo "═══════════════════════════════════════════════════════════════════════════════\n";
echo "RESUMEN GENERAL\n";
echo "═══════════════════════════════════════════════════════════════════════════════\n";
echo "Total SPs requeridos:  {$totalSPs}\n";
echo "SPs encontrados:       {$spsEncontrados}/{$totalSPs}\n";
echo "SPs faltantes:         " . ($totalSPs - $spsEncontrados) . "/{$totalSPs}\n\n";

if ($spsEncontrados == $totalSPs) {
    echo "✅ TODOS LOS STORED PROCEDURES ESTÁN DISPONIBLES\n";
} else {
    echo "⚠️  FALTAN STORED PROCEDURES POR CREAR O DESPLEGAR\n\n";
    echo "SPs faltantes:\n";
    foreach ($reporte as $comp => $sps) {
        foreach ($sps as $sp => $info) {
            if (!$info['encontrado']) {
                echo "  - {$sp} (usado en {$comp}.vue)\n";
            }
        }
    }
}

echo "\n";

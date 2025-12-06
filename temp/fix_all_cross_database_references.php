<?php
/**
 * Script para corregir TODAS las referencias cross-database en SPs de mercados
 * Elimina referencias tipo: padron_licencias.schema.tabla
 * Reemplaza por: schema.tabla
 */

$baseDir = dirname(__DIR__);
$databaseDir = $baseDir . '/RefactorX/Base/mercados/database/database';

// Archivos con referencias cross-database
$archivos = [
    'PadronEnergia_sp_get_mercados_by_recaudadora.sql',
    'PasoMdos_sp_insert_tianguis_padron_corregido.sql',
    'RptAdeEnergiaGrl_sp_get_ade_energia_grl_CORREGIDO.sql',
    'RptAdeudosAbastos1998_CORREGIDO.sql',
    'RptAdeudosAnteriores_CORREGIDO.sql',
    'RptAdeudosEnergia_CORREGIDO.sql',
    'RptAdeudosLocales_CORREGIDO.sql',
    'RptCaratulaDatos_CORREGIDO.sql',
    'RptCaratulaEnergia_CORREGIDO.sql',
    'RptCuentaPublica_CORREGIDO.sql',
    'RptEmisionEnergia_CORREGIDO.sql',
    'RptEmisionLaser_CORREGIDO.sql',
    'RptEmisionLocales_sp_rpt_emision_locales_emit_CORREGIDO.sql',
    'RptEmisionLocales_sp_rpt_emision_locales_get_CORREGIDO.sql',
    'RptEmisionRbosAbastos_sp_get_recargos_mes_abastos_CORREGIDO.sql',
    'RptEmisionRbosAbastos_sp_get_requerimientos_abastos_CORREGIDO.sql',
    'RptEmisionRbosAbastos_sp_rpt_emision_rbos_abastos_CORREGIDO.sql',
    'RptEstadisticaAdeudos_rpt_estadistica_adeudos_CORREGIDO.sql',
    'RptEstadPagosyAdeudos_sp_estad_pagosyadeudos_CORREGIDO.sql',
    'RptEstadPagosyAdeudos_sp_estad_pagosyadeudos_resumen_CORREGIDO.sql',
    'RptFacturaEmision_sp_get_vencimiento_rec_CORREGIDO.sql',
    'RptFacturaEmision_sp_rpt_factura_emision_CORREGIDO.sql',
    'RptFacturaEnergia_rpt_factura_energia_CORREGIDO.sql',
    'RptIngresoZonificado_sp_ingreso_zonificado_CORREGIDO.sql',
    'RptMovimientos_sp_get_movimientos_locales.sql',
    'RptMovimientos_sp_get_movimientos_locales_CORREGIDO.sql',
    'RptMovimientos_sp_get_recaudadoras.sql',
    'RptPadronEnergia_rpt_padron_energia_CORREGIDO.sql',
    'RptPadronEnergia_rpt_padron_energia_FINAL.sql',
    'RptPadronEnergia_sp_get_mercados_by_recaudadora.sql',
    'RptPadronEnergia_sp_get_recaudadoras.sql',
    'RptPadronGlobal_sp_padron_global_CORREGIDO.sql'
];

$totalArchivos = count($archivos);
$corregidos = 0;
$errores = 0;
$cambiosTotales = 0;

echo "═══════════════════════════════════════════════════════════════\n";
echo " CORRECCIÓN MASIVA DE REFERENCIAS CROSS-DATABASE EN SPs\n";
echo "═══════════════════════════════════════════════════════════════\n\n";
echo "📁 Directorio: $databaseDir\n";
echo "📋 Archivos a procesar: $totalArchivos\n\n";

foreach ($archivos as $archivo) {
    $rutaCompleta = $databaseDir . '/' . $archivo;

    if (!file_exists($rutaCompleta)) {
        echo "⚠️  SALTADO: $archivo (no existe)\n";
        $errores++;
        continue;
    }

    $contenido = file_get_contents($rutaCompleta);
    $contenidoOriginal = $contenido;
    $cambiosArchivo = 0;

    // Patrones a reemplazar
    $reemplazos = [
        'padron_licencias.comun.' => 'comun.',
        'padron_licencias.db_ingresos.' => 'db_ingresos.',
        'padron_licencias.comunX.' => 'comunX.',
        'padron_licencias.catastro_gdl.' => 'catastro_gdl.',
        'padron_licencias.public.' => 'public.',
        'mercados.comun.' => 'comun.',
        'mercados.db_ingresos.' => 'db_ingresos.',
        'mercados.public.' => 'public.'
    ];

    foreach ($reemplazos as $buscar => $reemplazar) {
        $ocurrencias = substr_count($contenido, $buscar);
        if ($ocurrencias > 0) {
            $contenido = str_replace($buscar, $reemplazar, $contenido);
            $cambiosArchivo += $ocurrencias;
        }
    }

    if ($cambiosArchivo > 0) {
        file_put_contents($rutaCompleta, $contenido);
        echo "✅ CORREGIDO: $archivo ($cambiosArchivo cambios)\n";
        $corregidos++;
        $cambiosTotales += $cambiosArchivo;
    } else {
        echo "   OK: $archivo (sin cambios necesarios)\n";
    }
}

echo "\n═══════════════════════════════════════════════════════════════\n";
echo " RESUMEN FINAL\n";
echo "═══════════════════════════════════════════════════════════════\n";
echo "Total archivos procesados: $totalArchivos\n";
echo "✅ Archivos corregidos: $corregidos\n";
echo "⚠️  Archivos con error: $errores\n";
echo "🔧 Total de cambios realizados: $cambiosTotales\n";
echo "\n";

if ($corregidos > 0) {
    echo "🎉 CORRECCIÓN COMPLETADA EXITOSAMENTE\n";
    echo "\n";
    echo "📋 SIGUIENTE PASO:\n";
    echo "   Desplegar los SPs corregidos ejecutando:\n";
    echo "   - Para los SPs principales del componente EnergiaModif:\n";
    echo "     temp\\DEPLOY_ENERGIAMODIF_FIX.bat\n";
    echo "\n";
} else {
    echo "ℹ️  No se encontraron referencias cross-database para corregir\n";
}

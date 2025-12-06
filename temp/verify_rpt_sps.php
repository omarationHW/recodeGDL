<?php
/**
 * Script para verificar los SPs de los componentes Rpt*.vue
 */

$components = [
    'RptEmisionLocales' => ['48_SP_MERCADOS_EMISIONLOCALES', '88_SP_MERCADOS_RPTEMISIONLOCALES'],
    'RptEmisionRbosAbastos' => ['49_SP_MERCADOS_EMISIONRBOSABASTOS', '89_SP_MERCADOS_RPTEMISIONRBOSABASTOS'],
    'RptEstadPagosyAdeudos' => ['51_SP_MERCADOS_ESTADPAGOSYADEUDOS', '91_SP_MERCADOS_RPTESTADPAGOSYADEUDOS'],
    'RptEstadisticaAdeudos' => ['52_SP_MERCADOS_ESTADISTICAADEUDOS', '81_SP_MERCADOS_RPTESTADISTICAADEUDOS'],
    'RptFacturaEmision' => ['92_SP_MERCADOS_RPTFACTURAEMISION'],
    'RptFacturaEnergia' => ['93_SP_MERCADOS_RPTFACTURAENERGIA'],
    'RptFechasVencimiento' => ['95_SP_MERCADOS_RPTFECHASVENCIMIENTO'],
    'RptIngresoZonificado' => ['94_SP_MERCADOS_RPTINGRESOZONIFICADO'],
    'RptMovimientos' => ['96_SP_MERCADOS_RPTMOVIMIENTOS'],
    'RptPadronGlobal' => ['97_SP_MERCADOS_RPTPADRONGLOBAL'],
];

$basePath = 'RefactorX/Base/mercados/database/ok/';

echo "═══════════════════════════════════════════════════════════════\n";
echo " VERIFICACIÓN DE SPs PARA COMPONENTES Rpt*.vue\n";
echo "═══════════════════════════════════════════════════════════════\n\n";

$totalFound = 0;
$totalMissing = 0;

foreach ($components as $comp => $spFiles) {
    echo "📦 $comp.vue\n";

    foreach ($spFiles as $spFile) {
        $fullPath = $basePath . $spFile . '_EXACTO_all_procedures.sql';

        if (file_exists($fullPath)) {
            $size = filesize($fullPath);
            $sizek = round($size / 1024, 1);
            echo "   ✅ $spFile ($sizek KB)\n";
            $totalFound++;
        } else {
            echo "   ❌ $spFile - NO ENCONTRADO\n";
            $totalMissing++;
        }
    }

    echo "\n";
}

echo "═══════════════════════════════════════════════════════════════\n";
echo " RESUMEN\n";
echo "═══════════════════════════════════════════════════════════════\n\n";
echo "SPs encontrados: $totalFound\n";
echo "SPs faltantes: $totalMissing\n";

if ($totalMissing > 0) {
    echo "\n⚠️  ADVERTENCIA: Hay $totalMissing SPs faltantes que necesitan ser creados/migrados\n";
}

echo "\n";

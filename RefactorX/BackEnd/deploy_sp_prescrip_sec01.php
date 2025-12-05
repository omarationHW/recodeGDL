<?php

require __DIR__ . '/vendor/autoload.php';

use Illuminate\Support\Facades\DB;

$app = require_once __DIR__ . '/bootstrap/app.php';
$kernel = $app->make(Illuminate\Contracts\Console\Kernel::class);
$kernel->bootstrap();

echo "📦 Desplegando SP recaudadora_sfrm_prescrip_sec01...\n\n";

try {
    $sql = file_get_contents(__DIR__ . '/recaudadora_sfrm_prescrip_sec01.sql');

    DB::connection('pgsql')->unprepared($sql);

    echo "✅ SP creado exitosamente\n\n";

    echo "═══════════════════════════════════════════════════════════\n";
    echo "🧪 PROBANDO EL SP CON DIFERENTES FILTROS:\n";
    echo "═══════════════════════════════════════════════════════════\n\n";

    // Test 1: Sin filtro (últimos registros)
    echo "Test 1: Sin filtro (últimos 5 registros)\n";
    $result = DB::connection('pgsql')->select("
        SELECT * FROM recaudadora_sfrm_prescrip_sec01('')
        LIMIT 5
    ");
    echo "  Registros encontrados: " . count($result) . "\n";
    if (count($result) > 0) {
        $r = $result[0];
        echo "  Ejemplo: ID {$r->id_prescri} - Multa {$r->id_multa} - Oficio {$r->oficio}\n";
    }
    echo "\n";

    // Test 2: Buscar por ID multa específica
    echo "Test 2: Buscar por ID Multa '324792'\n";
    $result = DB::connection('pgsql')->select("
        SELECT * FROM recaudadora_sfrm_prescrip_sec01('324792')
    ");
    echo "  Registros encontrados: " . count($result) . "\n";
    if (count($result) > 0) {
        $r = $result[0];
        echo "  Resultado: ID Prescripción {$r->id_prescri}\n";
        echo "  Fecha: {$r->fecha_prescri}\n";
        echo "  Oficio: {$r->oficio}\n";
        echo "  Dependencia: {$r->dependencia}\n";
    }
    echo "\n";

    // Test 3: Buscar por oficio
    echo "Test 3: Buscar por oficio 'TE/2651/25'\n";
    $result = DB::connection('pgsql')->select("
        SELECT * FROM recaudadora_sfrm_prescrip_sec01('TE/2651/25')
    ");
    echo "  Registros encontrados: " . count($result) . "\n";
    if (count($result) > 0) {
        $r = $result[0];
        echo "  Resultado: ID Multa {$r->id_multa}\n";
        echo "  Capturista: {$r->capturista}\n";
    }
    echo "\n";

    // Test 4: Buscar por dependencia
    echo "Test 4: Buscar por 'TESORERIA'\n";
    $result = DB::connection('pgsql')->select("
        SELECT * FROM recaudadora_sfrm_prescrip_sec01('TESORERIA')
        LIMIT 5
    ");
    echo "  Registros encontrados: " . count($result) . "\n";
    if (count($result) > 0) {
        echo "  Primeros resultados:\n";
        foreach ($result as $i => $r) {
            if ($i >= 3) break;
            echo "    • ID {$r->id_prescri} - Multa {$r->id_multa} - {$r->oficio}\n";
        }
    }
    echo "\n";

    echo "╔════════════════════════════════════════════════════════════╗\n";
    echo "║              🎉 DESPLIEGUE EXITOSO 🎉                      ║\n";
    echo "╚════════════════════════════════════════════════════════════╝\n";
    echo "\n";
    echo "📋 EJEMPLOS PARA PROBAR EN EL FRONTEND:\n\n";

    // Obtener 3 ejemplos concretos
    $ejemplos = DB::connection('pgsql')->select("
        SELECT
            id_prescri,
            id_multa,
            oficio,
            dependencia,
            fecha_prescri
        FROM catastro_gdl.presc_multas
        WHERE id_multa IS NOT NULL
        ORDER BY id_prescri DESC
        LIMIT 3
    ");

    foreach ($ejemplos as $i => $ej) {
        echo "Ejemplo " . ($i + 1) . ":\n";
        echo "  Filtro: '{$ej->id_multa}' (buscar por ID Multa)\n";
        echo "  Resultado esperado: ID Prescripción {$ej->id_prescri}\n";
        echo "  Oficio: {$ej->oficio}\n";
        echo "  Dependencia: " . trim($ej->dependencia) . "\n";
        echo "  Fecha: {$ej->fecha_prescri}\n";
        echo "\n";
    }

    echo "💡 OTROS FILTROS PARA PROBAR:\n";
    echo "  • Vacío (sin filtro) → Muestra últimos 100 registros\n";
    echo "  • 'TESORERIA' → Busca por dependencia\n";
    echo "  • 'TE/2651/25' → Busca por número de oficio\n";
    echo "  • 'sruvalca' → Busca por capturista\n";
    echo "\n";

} catch (Exception $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
    exit(1);
}

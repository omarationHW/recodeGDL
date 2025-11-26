<?php
/**
 * Buscar 5 trámites válidos con datos completos
 */

$host = '192.168.6.146';
$port = '5432';
$dbname = 'padron_licencias';
$user = 'refact';
$password = 'FF)-BQk2';

try {
    $dsn = "pgsql:host=$host;port=$port;dbname=$dbname";
    $pdo = new PDO($dsn, $user, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "🔍 Buscando trámites válidos con datos completos...\n\n";

    // Buscar trámites con cuenta asociada y tipo de trámite válido
    $sql = "
        SELECT
            t.id_tramite,
            t.tipo_tramite,
            tt.descripcion as tipo_descripcion,
            t.actividad,
            t.propietario,
            t.cvecuenta,
            t.id_giro,
            t.zona,
            t.subzona
        FROM catastro_gdl.tramites t
        LEFT JOIN catastro_gdl.c_tipotramite tt ON t.tipo_tramite = tt.id_tipotramite::text
        WHERE t.cvecuenta > 0
        AND t.tipo_tramite IS NOT NULL
        AND t.actividad IS NOT NULL
        AND t.propietario IS NOT NULL
        ORDER BY t.id_tramite DESC
        LIMIT 5
    ";

    $stmt = $pdo->query($sql);
    $tramites = $stmt->fetchAll(PDO::FETCH_ASSOC);

    if (count($tramites) > 0) {
        echo "✅ Encontrados " . count($tramites) . " trámites:\n\n";

        foreach ($tramites as $idx => $tramite) {
            $num = $idx + 1;
            echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n";
            echo "TRÁMITE #{$num}: {$tramite['id_tramite']}\n";
            echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n";
            echo "  📋 Tipo: {$tramite['tipo_tramite']} - " . trim($tramite['tipo_descripcion']) . "\n";
            echo "  👤 Propietario: " . trim($tramite['propietario']) . "\n";
            echo "  🏢 Actividad: " . trim($tramite['actividad']) . "\n";
            echo "  🏠 Cuenta: {$tramite['cvecuenta']}\n";
            echo "  🎯 ID Giro: {$tramite['id_giro']}\n";
            echo "  📍 Zona: {$tramite['zona']} / Subzona: {$tramite['subzona']}\n";
            echo "\n";
        }

        echo "\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n";
        echo "RESUMEN DE TRÁMITES PARA PROBAR\n";
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n\n";

        foreach ($tramites as $idx => $tramite) {
            $num = $idx + 1;
            echo "{$num}. Trámite: {$tramite['id_tramite']} (" . trim($tramite['tipo_descripcion']) . ")\n";
        }

        echo "\n💡 Puedes usar cualquiera de estos ID de trámite en el formulario ligapagoTra.vue\n";

    } else {
        echo "❌ No se encontraron trámites con datos completos\n";
    }

    // Buscar también algunos trámites recientes (últimos 10)
    echo "\n\n🔍 Últimos 10 trámites registrados:\n\n";

    $stmt = $pdo->query("
        SELECT
            id_tramite,
            tipo_tramite,
            actividad,
            propietario,
            cvecuenta
        FROM catastro_gdl.tramites
        ORDER BY id_tramite DESC
        LIMIT 10
    ");

    $recientes = $stmt->fetchAll(PDO::FETCH_ASSOC);

    foreach ($recientes as $t) {
        echo "  ID: {$t['id_tramite']} | Tipo: {$t['tipo_tramite']} | Cuenta: {$t['cvecuenta']} | Propietario: " . trim($t['propietario'] ?? 'N/A') . "\n";
    }

} catch (Exception $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
    exit(1);
}

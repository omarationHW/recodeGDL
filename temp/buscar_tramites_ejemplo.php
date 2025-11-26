<?php
/**
 * Buscar trámites de ejemplo
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

    echo "🔍 Buscando trámites de ejemplo...\n\n";

    // Ver estructura de la tabla tramites
    echo "📊 Estructura de catastro_gdl.tramites:\n\n";

    $stmt = $pdo->query("
        SELECT column_name, data_type
        FROM information_schema.columns
        WHERE table_schema = 'catastro_gdl'
        AND table_name = 'tramites'
        ORDER BY ordinal_position
        LIMIT 20
    ");

    $columns = $stmt->fetchAll(PDO::FETCH_ASSOC);
    foreach ($columns as $col) {
        echo "  - {$col['column_name']}: {$col['data_type']}\n";
    }

    // Ver algunos registros de ejemplo
    echo "\n\n📝 Ejemplos de trámites (primeros 5):\n\n";

    $stmt = $pdo->query("
        SELECT * FROM catastro_gdl.tramites
        LIMIT 5
    ");

    $tramites = $stmt->fetchAll(PDO::FETCH_ASSOC);

    if (count($tramites) > 0) {
        foreach ($tramites as $idx => $tramite) {
            $num = $idx + 1;
            echo "Trámite #{$num}:\n";
            $count = 0;
            foreach ($tramite as $key => $value) {
                if ($count < 15) { // Mostrar solo los primeros 15 campos
                    echo "  $key: " . ($value ?? 'NULL') . "\n";
                    $count++;
                }
            }
            echo "\n";
        }
    } else {
        echo "No se encontraron trámites en catastro_gdl.tramites\n\n";
    }

    // Buscar tipos de trámite
    echo "📋 Tipos de trámites (catastro_gdl.c_tipotramite):\n\n";

    $stmt = $pdo->query("
        SELECT * FROM catastro_gdl.c_tipotramite
        LIMIT 10
    ");

    $tipos = $stmt->fetchAll(PDO::FETCH_ASSOC);

    if (count($tipos) > 0) {
        foreach ($tipos as $tipo) {
            echo "  - ";
            foreach ($tipo as $key => $value) {
                echo "$key: " . ($value ?? 'NULL') . " | ";
            }
            echo "\n";
        }
    } else {
        echo "No se encontraron tipos de trámite\n";
    }

    // Contar registros
    echo "\n\n📊 Estadísticas:\n";

    $stmt = $pdo->query("SELECT COUNT(*) as total FROM catastro_gdl.tramites");
    $result = $stmt->fetch(PDO::FETCH_ASSOC);
    echo "  - Total trámites en catastro_gdl.tramites: {$result['total']}\n";

    $stmt = $pdo->query("SELECT COUNT(*) as total FROM catastro_gdl.c_tipotramite");
    $result = $stmt->fetch(PDO::FETCH_ASSOC);
    echo "  - Total tipos de trámite: {$result['total']}\n";

} catch (Exception $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
    exit(1);
}

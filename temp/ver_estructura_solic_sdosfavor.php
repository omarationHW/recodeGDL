<?php
/**
 * Ver estructura de tabla solic_sdosfavor
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

    echo "📊 Tabla: catastro_gdl.solic_sdosfavor\n\n";

    // Conteo de registros
    $count = $pdo->query("SELECT COUNT(*) FROM catastro_gdl.solic_sdosfavor")->fetchColumn();
    echo "📝 Total de registros: " . number_format($count) . "\n\n";

    // Estructura de la tabla
    $sql = "
        SELECT column_name, data_type, character_maximum_length, is_nullable
        FROM information_schema.columns
        WHERE table_schema = 'catastro_gdl'
        AND table_name = 'solic_sdosfavor'
        ORDER BY ordinal_position
    ";

    $stmt = $pdo->query($sql);
    $columns = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo "📋 Estructura de la tabla:\n\n";
    foreach ($columns as $col) {
        $type = $col['data_type'];
        if ($col['character_maximum_length']) {
            $type .= "({$col['character_maximum_length']})";
        }
        $nullable = $col['is_nullable'] === 'YES' ? 'NULL' : 'NOT NULL';
        echo sprintf("  %-25s %-20s %s\n", $col['column_name'], $type, $nullable);
    }

    // Ejemplos de datos
    echo "\n\n🔍 Ejemplos de datos (primeros 5 registros):\n\n";
    $sample = $pdo->query("
        SELECT *
        FROM catastro_gdl.solic_sdosfavor
        ORDER BY id_solic DESC
        LIMIT 5
    ")->fetchAll(PDO::FETCH_ASSOC);

    foreach ($sample as $idx => $row) {
        echo "Registro " . ($idx + 1) . ":\n";
        foreach ($row as $key => $value) {
            echo "  $key: " . ($value ?? 'NULL') . "\n";
        }
        echo "\n";
    }

    // Estadísticas útiles
    echo "\n📊 Estadísticas:\n\n";

    // Por vigencia
    echo "Por vigencia:\n";
    $stats = $pdo->query("
        SELECT vigencia, COUNT(*) as cantidad
        FROM catastro_gdl.solic_sdosfavor
        GROUP BY vigencia
        ORDER BY cantidad DESC
    ")->fetchAll(PDO::FETCH_ASSOC);

    foreach ($stats as $stat) {
        $vig = $stat['vigencia'] ?? 'NULL';
        echo sprintf("  %s: %s registros\n", $vig, number_format($stat['cantidad']));
    }

    // Por tipo de saldo a favor
    echo "\nPor tipo de saldo a favor:\n";
    $stats = $pdo->query("
        SELECT cve_tiposdosfavor, COUNT(*) as cantidad
        FROM catastro_gdl.solic_sdosfavor
        GROUP BY cve_tiposdosfavor
        ORDER BY cantidad DESC
    ")->fetchAll(PDO::FETCH_ASSOC);

    foreach ($stats as $stat) {
        $tipo = $stat['cve_tiposdosfavor'] ?? 'NULL';
        echo sprintf("  Tipo %s: %s registros\n", $tipo, number_format($stat['cantidad']));
    }

} catch (Exception $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
    exit(1);
}

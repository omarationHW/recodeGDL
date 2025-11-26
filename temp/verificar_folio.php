<?php
/**
 * Script para verificar si existe el folio en reqdiftransmision
 */

$host = '192.168.6.146';
$port = '5432';
$dbname = 'multas_reglamentos';
$user = 'refact';
$password = 'FF)-BQk2';

try {
    $dsn = "pgsql:host=$host;port=$port;dbname=$dbname";
    $pdo = new PDO($dsn, $user, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "✅ Conectado a la base de datos: $dbname\n\n";

    // 1. Ver estructura de la tabla reqdiftransmision
    echo "📋 ESTRUCTURA DE LA TABLA reqdiftransmision:\n";
    echo "==============================================\n";
    $struct = $pdo->query("
        SELECT column_name, data_type, character_maximum_length
        FROM information_schema.columns
        WHERE table_name = 'reqdiftransmision'
        ORDER BY ordinal_position
    ");

    while ($col = $struct->fetch(PDO::FETCH_ASSOC)) {
        $length = $col['character_maximum_length'] ? "({$col['character_maximum_length']})" : "";
        echo "  - {$col['column_name']}: {$col['data_type']}{$length}\n";
    }

    // 2. Buscar el folio específico
    echo "\n\n🔍 BUSCANDO FOLIO 1003/2024 con clave_cuenta '11111111111111':\n";
    echo "================================================================\n";

    // Primero ver qué campos tiene la tabla relacionados con folio
    $check = $pdo->query("
        SELECT * FROM reqdiftransmision
        WHERE folioreq = 1003
        LIMIT 5
    ");

    $found = false;
    while ($row = $check->fetch(PDO::FETCH_ASSOC)) {
        $found = true;
        echo "\n✅ Folio encontrado:\n";
        foreach ($row as $key => $value) {
            echo "  - {$key}: {$value}\n";
        }
    }

    if (!$found) {
        echo "❌ No se encontró ningún folio 1003\n";

        // Buscar folios similares
        echo "\n🔍 Buscando folios con clave_cuenta similar...\n";
        $similar = $pdo->query("
            SELECT cvecuenta, folioreq, axoreq, COUNT(*) as cant
            FROM reqdiftransmision
            WHERE cvecuenta::TEXT LIKE '%11111%'
            GROUP BY cvecuenta, folioreq, axoreq
            LIMIT 10
        ");

        while ($row = $similar->fetch(PDO::FETCH_ASSOC)) {
            echo "  - cvecuenta: {$row['cvecuenta']}, folio: {$row['folioreq']}, año: {$row['axoreq']}, cant: {$row['cant']}\n";
        }
    }

    // 3. Ver algunos folios de ejemplo
    echo "\n\n📋 ALGUNOS FOLIOS DE EJEMPLO (últimos 10):\n";
    echo "==========================================\n";
    $examples = $pdo->query("
        SELECT cvecuenta, folioreq, axoreq, fecprac
        FROM reqdiftransmision
        ORDER BY folioreq DESC
        LIMIT 10
    ");

    while ($row = $examples->fetch(PDO::FETCH_ASSOC)) {
        echo "  - cvecuenta: {$row['cvecuenta']}, folio: {$row['folioreq']}, año: {$row['axoreq']}, fecprac: {$row['fecprac']}\n";
    }

    // 4. Contar total de folios
    echo "\n\n📊 ESTADÍSTICAS:\n";
    echo "================\n";
    $stats = $pdo->query("SELECT COUNT(*) as total FROM reqdiftransmision")->fetch();
    echo "  - Total de registros en reqdiftransmision: {$stats['total']}\n";

    $years = $pdo->query("
        SELECT axoreq, COUNT(*) as cant
        FROM reqdiftransmision
        GROUP BY axoreq
        ORDER BY axoreq DESC
        LIMIT 5
    ")->fetchAll();

    echo "  - Registros por año (últimos 5 años):\n";
    foreach ($years as $y) {
        echo "    * {$y['axoreq']}: {$y['cant']} registros\n";
    }

} catch (Exception $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
    echo "\n🔍 Stack trace:\n" . $e->getTraceAsString() . "\n";
    exit(1);
}

<?php
/**
 * Script para ver la estructura de las tablas de detalle
 */

$host = "192.168.6.146";
$port = "5432";
$dbname = "mercados";
$user = "refact";
$password = "FF)-BQk2";

try {
    $dsn = "pgsql:host=$host;port=$port;dbname=$dbname";
    $pdo = new PDO($dsn, $user, $password, [
        PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
        PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC
    ]);

    echo "\n=== ESTRUCTURA DE TABLAS PARA DETALLE ===\n\n";

    // 1. Tabla de adeudos
    echo "1. ESTRUCTURA: publico.ta_11_adeudo_local\n";
    echo str_repeat("-", 80) . "\n";
    $sql = "
        SELECT
            column_name,
            data_type,
            character_maximum_length,
            is_nullable
        FROM information_schema.columns
        WHERE table_schema = 'publico'
          AND table_name = 'ta_11_adeudo_local'
        ORDER BY ordinal_position
    ";
    $stmt = $pdo->query($sql);
    $columnas = $stmt->fetchAll();
    foreach ($columnas as $col) {
        $length = $col['character_maximum_length'] ? "({$col['character_maximum_length']})" : "";
        $nullable = $col['is_nullable'] == 'YES' ? 'NULL' : 'NOT NULL';
        echo "  - {$col['column_name']}: {$col['data_type']}{$length} {$nullable}\n";
    }

    // Ver datos de ejemplo
    echo "\n  Datos de ejemplo:\n";
    $sql = "SELECT * FROM publico.ta_11_adeudo_local WHERE id_local = 11256 LIMIT 3";
    $stmt = $pdo->query($sql);
    $datos = $stmt->fetchAll();
    if (count($datos) > 0) {
        foreach ($datos as $row) {
            echo "    - Año: {$row['axo']}, Periodo: {$row['periodo']}, Importe: {$row['importe']}\n";
        }
    } else {
        echo "    ⚠️  No hay datos para este local\n";
    }

    // 2. Tabla de pagos (probar ambos nombres)
    $tabla_pagos = 'ta_11_pagos_local'; // Primero con 's'
    echo "\n2. ESTRUCTURA: publico.{$tabla_pagos}\n";
    echo str_repeat("-", 80) . "\n";
    $sql = "
        SELECT
            column_name,
            data_type,
            character_maximum_length,
            is_nullable
        FROM information_schema.columns
        WHERE table_schema = 'publico'
          AND table_name = '{$tabla_pagos}'
        ORDER BY ordinal_position
    ";
    $stmt = $pdo->query($sql);
    $columnas = $stmt->fetchAll();

    if (count($columnas) == 0) {
        // Probar sin 's'
        $tabla_pagos = 'ta_11_pago_local';
        echo "  ⚠️  No encontrada, probando publico.{$tabla_pagos}...\n";
        $sql = "
            SELECT column_name, data_type, character_maximum_length, is_nullable
            FROM information_schema.columns
            WHERE table_schema = 'publico' AND table_name = '{$tabla_pagos}'
            ORDER BY ordinal_position
        ";
        $stmt = $pdo->query($sql);
        $columnas = $stmt->fetchAll();
    }

    foreach ($columnas as $col) {
        $length = $col['character_maximum_length'] ? "({$col['character_maximum_length']})" : "";
        $nullable = $col['is_nullable'] == 'YES' ? 'NULL' : 'NOT NULL';
        echo "  - {$col['column_name']}: {$col['data_type']}{$length} {$nullable}\n";
    }

    // Ver datos de ejemplo
    echo "\n  Datos de ejemplo:\n";
    $sql = "SELECT * FROM publico.{$tabla_pagos} WHERE id_local = 11256 LIMIT 3";
    $stmt = $pdo->query($sql);
    $datos = $stmt->fetchAll();
    if (count($datos) > 0) {
        foreach ($datos as $row) {
            echo "    - Año: {$row['axo']}, Periodo: {$row['periodo']}, Fecha: {$row['fecha_pago']}, Importe: " . ($row['imp_pago'] ?? $row['importe_pago'] ?? 'N/A') . "\n";
        }
    } else {
        echo "    ⚠️  No hay datos para este local\n";
    }

    // 3. Buscar tablas con "multa" o "infraccion" para requerimientos
    echo "\n3. BUSCAR TABLAS PARA REQUERIMIENTOS:\n";
    echo str_repeat("-", 80) . "\n";
    $sql = "
        SELECT schemaname, tablename
        FROM pg_tables
        WHERE (tablename LIKE '%multa%' OR tablename LIKE '%infraccion%' OR tablename LIKE '%sancion%')
          AND schemaname IN ('public', 'publico')
        ORDER BY tablename
    ";
    $stmt = $pdo->query($sql);
    $tablas = $stmt->fetchAll();
    if (count($tablas) > 0) {
        foreach ($tablas as $t) {
            echo "  - {$t['schemaname']}.{$t['tablename']}\n";
        }
    } else {
        echo "  ⚠️  No se encontraron tablas de requerimientos/multas\n";
    }

    echo "\n✅ ANÁLISIS COMPLETADO\n\n";

} catch (PDOException $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
    exit(1);
}

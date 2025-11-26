<?php
/**
 * Script para investigar cómo se maneja el bloqueo de multas
 */

$host = '192.168.6.146';
$port = '5432';
$dbname = 'padron_licencias';
$user = 'refact';
$password = 'FF)-BQk2';

try {
    $pdo = new PDO("pgsql:host=$host;port=$port;dbname=$dbname", $user, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "=== INVESTIGACIÓN BLOQUEO DE MULTAS ===\n\n";

    // 1. Ver estructura completa de reqmultas
    echo "1. Estructura completa de catastro_gdl.reqmultas:\n";
    echo str_repeat("-", 80) . "\n";

    $sql = "
        SELECT column_name, data_type, character_maximum_length, is_nullable
        FROM information_schema.columns
        WHERE table_schema = 'catastro_gdl'
          AND table_name = 'reqmultas'
        ORDER BY ordinal_position;
    ";

    $stmt = $pdo->query($sql);
    $columns = $stmt->fetchAll(PDO::FETCH_ASSOC);

    foreach ($columns as $col) {
        $length = $col['character_maximum_length'] ? "({$col['character_maximum_length']})" : "";
        $nullable = $col['is_nullable'] === 'YES' ? 'NULL' : 'NOT NULL';
        echo sprintf("  %-25s %-20s %s\n", $col['column_name'], $col['data_type'] . $length, $nullable);
    }

    // 2. Buscar registros con posible bloqueo
    echo "\n\n2. Buscando registros que pudieran estar bloqueados:\n";
    echo str_repeat("-", 80) . "\n";

    // Ver algunos ejemplos de vigencia diferentes
    $sql2 = "
        SELECT vigencia, COUNT(*) as count
        FROM catastro_gdl.reqmultas
        GROUP BY vigencia
        ORDER BY count DESC;
    ";

    $stmt2 = $pdo->query($sql2);
    $vigencias = $stmt2->fetchAll(PDO::FETCH_ASSOC);

    echo "Estados de vigencia en reqmultas:\n";
    foreach ($vigencias as $v) {
        echo "  Vigencia '{$v['vigencia']}': {$v['count']} registros\n";
    }

    // 3. Ver si hay tabla específica para bloqueo de multas
    echo "\n\n3. Buscando tablas específicas de bloqueo de multas:\n";
    echo str_repeat("-", 80) . "\n";

    $sql3 = "
        SELECT schemaname, tablename
        FROM pg_tables
        WHERE (tablename ILIKE '%bloqueo%' AND tablename ILIKE '%multa%')
           OR (tablename ILIKE '%req%' AND tablename ILIKE '%bloq%')
        ORDER BY schemaname, tablename;
    ";

    $stmt3 = $pdo->query($sql3);
    $tables = $stmt3->fetchAll(PDO::FETCH_ASSOC);

    if (empty($tables)) {
        echo "  No se encontraron tablas específicas de bloqueo de multas\n";
        echo "  Esto sugiere que el bloqueo se maneja mediante el campo 'vigencia' en reqmultas\n";
    } else {
        foreach ($tables as $t) {
            echo "  ✅ {$t['schemaname']}.{$t['tablename']}\n";
        }
    }

    // 4. Ver un ejemplo de cada tipo de vigencia
    echo "\n\n4. Ejemplos de registros por vigencia:\n";
    echo str_repeat("-", 80) . "\n";

    foreach ($vigencias as $v) {
        $vigencia = $v['vigencia'];
        echo "\nVigencia '{$vigencia}':\n";

        $sql4 = "
            SELECT folioreq, axoreq, id_multa, vigencia, multas, total, fecemi
            FROM catastro_gdl.reqmultas
            WHERE vigencia = :vigencia
            LIMIT 1;
        ";

        $stmt4 = $pdo->prepare($sql4);
        $stmt4->execute(['vigencia' => $vigencia]);
        $example = $stmt4->fetch(PDO::FETCH_ASSOC);

        if ($example) {
            foreach ($example as $key => $value) {
                if ($value !== null) {
                    echo "  $key: $value\n";
                }
            }
        }
    }

    // 5. Ver si hay campos que indiquen estado de bloqueo
    echo "\n\n5. Campos que pudieran indicar bloqueo:\n";
    echo str_repeat("-", 80) . "\n";

    $possibleFields = ['bloqueado', 'bloq', 'estatus', 'status', 'estado'];
    foreach ($possibleFields as $field) {
        $found = false;
        foreach ($columns as $col) {
            if (stripos($col['column_name'], $field) !== false) {
                echo "  ✅ Encontrado: {$col['column_name']}\n";
                $found = true;
            }
        }
        if (!$found && $field === 'bloqueado') {
            echo "  ❌ No hay campo 'bloqueado' en reqmultas\n";
        }
    }

    // 6. Ver campos de auditoría/tracking
    echo "\n\n6. Campos de auditoría/tracking:\n";
    echo str_repeat("-", 80) . "\n";

    $auditFields = [];
    foreach ($columns as $col) {
        $name = $col['column_name'];
        if (stripos($name, 'fec') !== false ||
            stripos($name, 'capt') !== false ||
            stripos($name, 'user') !== false ||
            stripos($name, 'obs') !== false) {
            $auditFields[] = $name;
        }
    }

    foreach ($auditFields as $field) {
        echo "  - $field\n";
    }

    // 7. Verificar si existe tabla h_reqmultas (histórico)
    echo "\n\n7. Verificando tabla histórica:\n";
    echo str_repeat("-", 80) . "\n";

    $sql7 = "
        SELECT COUNT(*) as count
        FROM pg_tables
        WHERE schemaname = 'catastro_gdl'
          AND tablename = 'h_reqmultas';
    ";

    $stmt7 = $pdo->query($sql7);
    $hasHistory = $stmt7->fetch(PDO::FETCH_ASSOC)['count'] > 0;

    if ($hasHistory) {
        echo "  ✅ Existe catastro_gdl.h_reqmultas (tabla histórica)\n";

        // Ver estructura
        $sql7b = "
            SELECT column_name
            FROM information_schema.columns
            WHERE table_schema = 'catastro_gdl'
              AND table_name = 'h_reqmultas'
            ORDER BY ordinal_position;
        ";

        $stmt7b = $pdo->query($sql7b);
        $hColumns = $stmt7b->fetchAll(PDO::FETCH_COLUMN);

        echo "  Columnas adicionales en histórico:\n";
        foreach ($hColumns as $hCol) {
            if (!in_array($hCol, array_column($columns, 'column_name'))) {
                echo "    + $hCol (adicional)\n";
            }
        }

        // Ver conteo
        $sql7c = "SELECT COUNT(*) as count FROM catastro_gdl.h_reqmultas";
        $stmt7c = $pdo->query($sql7c);
        $hCount = $stmt7c->fetch(PDO::FETCH_ASSOC)['count'];
        echo "  Registros históricos: $hCount\n";
    } else {
        echo "  ❌ No existe tabla histórica h_reqmultas\n";
    }

    echo "\n\n" . str_repeat("=", 80) . "\n";
    echo "CONCLUSIÓN:\n";
    echo str_repeat("=", 80) . "\n";
    echo "Basado en el análisis, el bloqueo de multas parece manejarse mediante:\n";
    echo "1. Campo 'vigencia' en reqmultas (V=Vigente, C=Cancelada, P=Pagada)\n";
    echo "2. Posiblemente necesitamos crear una nueva tabla para tracking de bloqueos\n";
    echo "   o usar una tabla de observaciones/histórico\n";

} catch (PDOException $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
}

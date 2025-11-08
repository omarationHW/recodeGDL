<?php
// Verificar estructura y duplicados en la tabla

try {
    $db = new PDO('pgsql:host=192.168.6.146;port=5432;dbname=padron_licencias', 'refact', 'FF)-BQk2');
    $db->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "=== ANÁLISIS DE TABLA comun.c_actividades ===\n\n";

    // 1. Ver estructura de la tabla
    echo "📋 Estructura de la tabla:\n";
    echo str_repeat("-", 80) . "\n";
    $stmt = $db->query("
        SELECT
            column_name,
            data_type,
            character_maximum_length,
            is_nullable
        FROM information_schema.columns
        WHERE table_schema = 'comun' AND table_name = 'c_actividades'
        ORDER BY ordinal_position
    ");
    $columns = $stmt->fetchAll(PDO::FETCH_ASSOC);
    foreach ($columns as $col) {
        echo sprintf("%-20s %-15s %s %s\n",
            $col['column_name'],
            $col['data_type'],
            $col['character_maximum_length'] ? "($col[character_maximum_length])" : "",
            $col['is_nullable'] === 'NO' ? 'NOT NULL' : 'NULL'
        );
    }
    echo str_repeat("-", 80) . "\n\n";

    // 2. Verificar clave primaria
    echo "🔑 Clave primaria:\n";
    $stmt = $db->query("
        SELECT
            a.attname as column_name
        FROM pg_index i
        JOIN pg_attribute a ON a.attrelid = i.indrelid AND a.attnum = ANY(i.indkey)
        WHERE i.indrelid = 'comun.c_actividades'::regclass
        AND i.indisprimary
    ");
    $pk = $stmt->fetchAll(PDO::FETCH_ASSOC);
    if (count($pk) > 0) {
        echo "✅ PK existe: " . implode(', ', array_column($pk, 'column_name')) . "\n";
    } else {
        echo "❌ NO hay clave primaria definida\n";
    }
    echo "\n";

    // 3. Verificar duplicados en la tabla
    echo "🔍 Verificando duplicados en la tabla:\n";
    $stmt = $db->query("
        SELECT
            generico,
            uso,
            actividad,
            concepto,
            COUNT(*) as veces
        FROM comun.c_actividades
        GROUP BY generico, uso, actividad, concepto
        HAVING COUNT(*) > 1
        LIMIT 10
    ");
    $duplicados_tabla = $stmt->fetchAll(PDO::FETCH_ASSOC);

    if (count($duplicados_tabla) > 0) {
        echo "❌ La tabla TIENE duplicados:\n";
        foreach ($duplicados_tabla as $dup) {
            echo "   {$dup['generico']}.{$dup['uso']}.{$dup['actividad']} - aparece {$dup['veces']} veces\n";
        }
    } else {
        echo "✅ La tabla NO tiene duplicados por (generico, uso, actividad, concepto)\n";
    }
    echo "\n";

    // 4. Verificar duplicados solo por clave (sin concepto)
    echo "🔍 Verificando duplicados solo por (generico, uso, actividad):\n";
    $stmt = $db->query("
        SELECT
            generico,
            uso,
            actividad,
            COUNT(*) as veces
        FROM comun.c_actividades
        GROUP BY generico, uso, actividad
        HAVING COUNT(*) > 1
        LIMIT 10
    ");
    $duplicados_clave = $stmt->fetchAll(PDO::FETCH_ASSOC);

    if (count($duplicados_clave) > 0) {
        echo "❌ Hay registros con misma clave (generico, uso, actividad):\n";
        foreach ($duplicados_clave as $dup) {
            echo "   {$dup['generico']}.{$dup['uso']}.{$dup['actividad']} - aparece {$dup['veces']} veces\n";

            // Mostrar los conceptos diferentes para esta clave
            $stmt2 = $db->prepare("
                SELECT concepto
                FROM comun.c_actividades
                WHERE generico = ? AND uso = ? AND actividad = ?
            ");
            $stmt2->execute([$dup['generico'], $dup['uso'], $dup['actividad']]);
            $conceptos = $stmt2->fetchAll(PDO::FETCH_COLUMN);
            foreach ($conceptos as $i => $concepto) {
                echo "      " . ($i+1) . ". " . trim($concepto) . "\n";
            }
        }
    } else {
        echo "✅ NO hay duplicados por clave\n";
    }

} catch (PDOException $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
}

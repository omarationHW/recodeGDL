<?php
// Ver datos de las tablas candidatas para IPOR

$host = '192.168.6.146';
$dbname = 'multas_reglamentos';
$user = 'refact';
$password = 'FF)-BQk2';

try {
    $pdo = new PDO("pgsql:host=$host;dbname=$dbname", $user, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "=== OPCIÓN 1: publico.c_conceptos (46 registros) ===\n\n";

    $stmt1 = $pdo->query("
        SELECT
            cveconcepto as id,
            TRIM(descripcion) as concepto,
            TRIM(ncorto) as nombre_corto
        FROM publico.c_conceptos
        ORDER BY cveconcepto
        LIMIT 10
    ");

    $conceptos = $stmt1->fetchAll(PDO::FETCH_ASSOC);

    foreach ($conceptos as $c) {
        echo "ID: {$c['id']}, Concepto: {$c['concepto']}, Corto: {$c['nombre_corto']}\n";
    }

    echo "\n\n=== OPCIÓN 2: public.c_tasas (240 registros) ===\n\n";

    $stmt2 = $pdo->query("
        SELECT
            tasa as id,
            tasaporcen as porcentaje,
            axo as anio
        FROM public.c_tasas
        ORDER BY tasa
        LIMIT 10
    ");

    $tasas = $stmt2->fetchAll(PDO::FETCH_ASSOC);

    foreach ($tasas as $t) {
        $porc = $t['porcentaje'] * 100; // Convertir a porcentaje
        echo "ID: {$t['id']}, Porcentaje: {$porc}%, Año: {$t['anio']}\n";
    }

    // Ver si hay recargos
    echo "\n\n=== VERIFICANDO TABLA DE RECARGOS ===\n\n";

    $stmt3 = $pdo->query("
        SELECT
            schemaname,
            tablename
        FROM pg_tables
        WHERE schemaname IN ('public', 'publico')
        AND tablename ILIKE '%recargo%'
    ");

    $recargos = $stmt3->fetchAll(PDO::FETCH_ASSOC);

    foreach ($recargos as $r) {
        echo "Tabla: {$r['schemaname']}.{$r['tablename']}\n";

        // Contar
        try {
            $count = $pdo->query("SELECT COUNT(*) as total FROM {$r['schemaname']}.{$r['tablename']}")->fetch(PDO::FETCH_ASSOC);
            echo "  Registros: {$count['total']}\n";
        } catch (Exception $e) {
            echo "  Registros: Error\n";
        }

        // Ver columnas
        $cols = $pdo->prepare("
            SELECT column_name, data_type
            FROM information_schema.columns
            WHERE table_schema = ? AND table_name = ?
            ORDER BY ordinal_position
        ");
        $cols->execute([$r['schemaname'], $r['tablename']]);
        $columnas = $cols->fetchAll(PDO::FETCH_ASSOC);

        echo "  Columnas:\n";
        foreach ($columnas as $col) {
            echo "    - {$col['column_name']} ({$col['data_type']})\n";
        }

        // Ejemplos
        try {
            $samples = $pdo->query("SELECT * FROM {$r['schemaname']}.{$r['tablename']} LIMIT 5")->fetchAll(PDO::FETCH_ASSOC);
            if (count($samples) > 0) {
                echo "  Ejemplos:\n";
                foreach ($samples as $s) {
                    $vals = array_values($s);
                    echo "    - " . implode(", ", array_slice($vals, 0, 5)) . "\n";
                }
            }
        } catch (Exception $e) {
            echo "  Ejemplos: Error\n";
        }

        echo "\n";
    }

    // Ver si la tabla multas tiene conceptos
    echo "\n=== VERIFICANDO TABLA MULTAS ===\n\n";

    $stmt4 = $pdo->query("
        SELECT column_name, data_type
        FROM information_schema.columns
        WHERE table_schema = 'publico'
        AND table_name = 'multas'
        AND (column_name ILIKE '%concepto%' OR column_name ILIKE '%articulo%')
        ORDER BY ordinal_position
    ");

    $cols_multas = $stmt4->fetchAll(PDO::FETCH_ASSOC);

    if (count($cols_multas) > 0) {
        echo "Columnas relacionadas en multas:\n";
        foreach ($cols_multas as $col) {
            echo "  - {$col['column_name']} ({$col['data_type']})\n";
        }
    }

} catch (PDOException $e) {
    echo "Error: " . $e->getMessage() . "\n";
    exit(1);
}

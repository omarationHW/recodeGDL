<?php
// Buscar tablas de multas para multas400frm.vue

$host = '192.168.6.146';
$dbname = 'multas_reglamentos';
$user = 'refact';
$password = 'FF)-BQk2';

try {
    $pdo = new PDO("pgsql:host=$host;dbname=$dbname", $user, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "=== BUSCANDO TABLAS DE MULTAS ===\n\n";

    // Buscar todas las tablas con "multa" en el nombre
    $stmt = $pdo->query("
        SELECT schemaname, tablename
        FROM pg_tables
        WHERE tablename ILIKE '%multa%'
        AND schemaname IN ('public', 'publico')
        ORDER BY schemaname, tablename
    ");

    $tablas = $stmt->fetchAll(PDO::FETCH_ASSOC);

    foreach ($tablas as $tabla) {
        echo "Tabla: {$tabla['schemaname']}.{$tabla['tablename']}\n";

        // Contar registros
        $count_stmt = $pdo->query("SELECT COUNT(*) as total FROM {$tabla['schemaname']}.{$tabla['tablename']}");
        $count = $count_stmt->fetch(PDO::FETCH_ASSOC);
        echo "  Registros: " . number_format($count['total']) . "\n";

        // Ver estructura
        $cols_stmt = $pdo->query("
            SELECT column_name, data_type
            FROM information_schema.columns
            WHERE table_schema = '{$tabla['schemaname']}'
            AND table_name = '{$tabla['tablename']}'
            ORDER BY ordinal_position
            LIMIT 20
        ");

        $cols = $cols_stmt->fetchAll(PDO::FETCH_ASSOC);
        if (count($cols) > 0) {
            echo "  Campos principales:\n";
            foreach ($cols as $col) {
                echo "    - {$col['column_name']} ({$col['data_type']})\n";
            }
        }

        echo "\n" . str_repeat("-", 70) . "\n\n";
    }

    // Ver detalles específicos de public.multas (tabla principal)
    echo "\n=== DETALLE DE public.multas ===\n\n";

    $stmt = $pdo->query("
        SELECT column_name, data_type, character_maximum_length
        FROM information_schema.columns
        WHERE table_schema = 'public' AND table_name = 'multas'
        ORDER BY ordinal_position
    ");

    echo "Estructura completa:\n";
    foreach ($stmt->fetchAll(PDO::FETCH_ASSOC) as $col) {
        $len = $col['character_maximum_length'] ? "({$col['character_maximum_length']})" : "";
        echo "  - {$col['column_name']}: {$col['data_type']}$len\n";
    }

    // Ver ejemplos de registros
    echo "\n\nEjemplos de registros:\n";
    $stmt = $pdo->query("
        SELECT num_acta, axo_acta, nomcom, domicilio, multa, gastos, total, cvecanc
        FROM public.multas
        WHERE cvecanc IS NULL
        ORDER BY num_acta DESC
        LIMIT 5
    ");

    foreach ($stmt->fetchAll(PDO::FETCH_ASSOC) as $i => $row) {
        echo "\n  " . ($i + 1) . ". Acta: {$row['num_acta']}/{$row['axo_acta']}\n";
        echo "     Contribuyente: {$row['nomcom']}\n";
        echo "     Multa: $" . number_format($row['multa'], 2) . "\n";
        echo "     Total: $" . number_format($row['total'], 2) . "\n";
        echo "     Estado: " . ($row['cvecanc'] ? 'Cancelada' : 'Activa') . "\n";
    }

    echo "\n\n✅ Búsqueda completada!\n";

} catch (PDOException $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
    exit(1);
}

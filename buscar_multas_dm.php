<?php
// Buscar tablas de multas para MultasDM.vue

$host = '192.168.6.146';
$dbname = 'multas_reglamentos';
$user = 'refact';
$password = 'FF)-BQk2';

try {
    $pdo = new PDO("pgsql:host=$host;dbname=$dbname", $user, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "=== BUSCANDO TABLAS DE MULTAS ===\n\n";

    // Ya sabemos de tablas anteriores, verificar cuál es la más apropiada
    echo "1. Tablas principales de multas conocidas:\n\n";

    $tablas_conocidas = [
        ['schema' => 'publico', 'table' => 'multas'],
        ['schema' => 'publico', 'table' => 'h_multasnvo'],
        ['schema' => 'publico', 'table' => 'resp_multas']
    ];

    foreach ($tablas_conocidas as $t) {
        echo "Tabla: {$t['schema']}.{$t['table']}\n";

        $count_stmt = $pdo->query("SELECT COUNT(*) as total FROM {$t['schema']}.{$t['table']}");
        $count = $count_stmt->fetch(PDO::FETCH_ASSOC);
        echo "  Registros: " . number_format($count['total']) . "\n";

        // Ver campos relevantes
        $cols_stmt = $pdo->query("
            SELECT column_name
            FROM information_schema.columns
            WHERE table_schema = '{$t['schema']}'
            AND table_name = '{$t['table']}'
            AND (column_name ILIKE '%acta%'
                 OR column_name ILIKE '%contribuyente%'
                 OR column_name ILIKE '%ejercicio%'
                 OR column_name = 'axo_acta')
            ORDER BY ordinal_position
        ");

        $cols = $cols_stmt->fetchAll(PDO::FETCH_ASSOC);
        if (count($cols) > 0) {
            echo "  Campos relevantes: ";
            $col_names = array_map(function($c) { return $c['column_name']; }, $cols);
            echo implode(', ', $col_names) . "\n";
        }

        echo "\n" . str_repeat("-", 70) . "\n\n";
    }

    // Ver estructura completa de publico.multas (más completa)
    echo "2. ESTRUCTURA DETALLADA DE publico.multas:\n\n";

    $stmt = $pdo->query("
        SELECT column_name, data_type, character_maximum_length
        FROM information_schema.columns
        WHERE table_schema = 'publico' AND table_name = 'multas'
        ORDER BY ordinal_position
    ");

    echo "Campos principales:\n";
    foreach ($stmt->fetchAll(PDO::FETCH_ASSOC) as $col) {
        $len = $col['character_maximum_length'] ? "({$col['character_maximum_length']})" : "";
        echo "  - {$col['column_name']}: {$col['data_type']}$len\n";
    }

    // Ver ejemplos
    echo "\n\n3. EJEMPLOS DE MULTAS:\n";
    $stmt = $pdo->query("
        SELECT
            id_multa,
            num_acta,
            axo_acta,
            contribuyente,
            domicilio,
            multa,
            gastos,
            total,
            fecha_acta,
            fecha_cancelacion
        FROM publico.multas
        ORDER BY id_multa DESC
        LIMIT 5
    ");

    foreach ($stmt->fetchAll(PDO::FETCH_ASSOC) as $i => $row) {
        echo "\n  " . ($i + 1) . ". ID: {$row['id_multa']}\n";
        echo "     Acta: {$row['num_acta']}/{$row['axo_acta']}\n";
        echo "     Contribuyente: {$row['contribuyente']}\n";
        echo "     Domicilio: {$row['domicilio']}\n";
        echo "     Fecha: {$row['fecha_acta']}\n";
        echo "     Multa: $" . number_format($row['multa'], 2) . "\n";
        echo "     Total: $" . number_format($row['total'], 2) . "\n";
        echo "     Estado: " . ($row['fecha_cancelacion'] ? 'Cancelada' : 'Activa') . "\n";
    }

    // Ver distribución por ejercicio (año)
    echo "\n\n4. DISTRIBUCIÓN POR EJERCICIO (AXO_ACTA):\n";
    $stmt = $pdo->query("
        SELECT
            axo_acta AS ejercicio,
            COUNT(*) as total
        FROM publico.multas
        GROUP BY axo_acta
        ORDER BY axo_acta DESC
        LIMIT 10
    ");

    foreach ($stmt->fetchAll(PDO::FETCH_ASSOC) as $row) {
        echo "   Ejercicio {$row['ejercicio']}: " . number_format($row['total']) . " multas\n";
    }

    // Ver distribución por estado
    echo "\n\n5. DISTRIBUCIÓN POR ESTADO:\n";
    $stmt = $pdo->query("
        SELECT
            CASE
                WHEN fecha_cancelacion IS NOT NULL THEN 'Cancelada'
                ELSE 'Activa'
            END as estado,
            COUNT(*) as total
        FROM publico.multas
        GROUP BY estado
        ORDER BY total DESC
    ");

    foreach ($stmt->fetchAll(PDO::FETCH_ASSOC) as $row) {
        echo "   {$row['estado']}: " . number_format($row['total']) . "\n";
    }

    // Mapeo propuesto
    echo "\n\n" . str_repeat("=", 70) . "\n\n";
    echo "6. MAPEO PROPUESTO PARA MultasDM:\n\n";
    echo "Usar: publico.multas (416,928 registros)\n\n";
    echo "Campos a mapear:\n";
    echo "  clave_cuenta → num_acta || '/' || axo_acta (identificador compuesto)\n";
    echo "  folio → num_acta\n";
    echo "  ejercicio → axo_acta (año de acta)\n";
    echo "  contribuyente → contribuyente\n";
    echo "  domicilio → domicilio\n";
    echo "  multa → multa\n";
    echo "  gastos → gastos\n";
    echo "  total → total\n";
    echo "  fecha_acta → fecha_acta\n";
    echo "  fecha_recepcion → fecha_recepcion\n";
    echo "  estado → CASE WHEN fecha_cancelacion IS NOT NULL THEN 'Cancelada' ELSE 'Activa' END\n";

    echo "\n✅ Verificación completada!\n";

} catch (PDOException $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
    exit(1);
}

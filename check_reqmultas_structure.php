<?php
// Script para ver la estructura de reqmultas y determinar el mapeo correcto

$host = '192.168.6.146';
$dbname = 'multas_reglamentos';
$user = 'refact';
$password = 'FF)-BQk2';

try {
    $pdo = new PDO("pgsql:host=$host;dbname=$dbname", $user, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "Conectado exitosamente.\n\n";

    // 1. Ver estructura de reqmultas
    echo "=== ESTRUCTURA DE publico.reqmultas ===\n\n";
    $stmt = $pdo->query("
        SELECT column_name, data_type, character_maximum_length, is_nullable, column_default
        FROM information_schema.columns
        WHERE table_schema = 'publico'
        AND table_name = 'reqmultas'
        ORDER BY ordinal_position
    ");
    $columns = $stmt->fetchAll(PDO::FETCH_ASSOC);

    foreach ($columns as $col) {
        $length = $col['character_maximum_length'] ? "({$col['character_maximum_length']})" : "";
        $nullable = $col['is_nullable'] == 'YES' ? 'NULL' : 'NOT NULL';
        $default = $col['column_default'] ? " DEFAULT {$col['column_default']}" : "";
        echo "  {$col['column_name']}: {$col['data_type']}{$length} {$nullable}{$default}\n";
    }

    // 2. Ver algunos registros de ejemplo
    echo "\n\n=== REGISTROS DE EJEMPLO ===\n\n";
    $stmt = $pdo->query("SELECT * FROM publico.reqmultas LIMIT 3");
    $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);

    foreach ($rows as $i => $row) {
        echo "Registro " . ($i + 1) . ":\n";
        foreach ($row as $key => $val) {
            $val = is_null($val) ? 'NULL' : (is_string($val) ? substr(trim($val), 0, 50) : $val);
            echo "  $key: $val\n";
        }
        echo "\n";
    }

    // 3. Ver el último folio usado
    echo "\n=== ÚLTIMO FOLIO USADO ===\n\n";
    $stmt = $pdo->query("
        SELECT cvereq, folioreq, axoreq, fecemi, id_multa
        FROM publico.reqmultas
        ORDER BY cvereq DESC
        LIMIT 5
    ");
    $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);

    foreach ($rows as $row) {
        echo "  cvereq: {$row['cvereq']}, folioreq: {$row['folioreq']}, axoreq: {$row['axoreq']}, fecemi: {$row['fecemi']}, id_multa: {$row['id_multa']}\n";
    }

    echo "\n✅ Búsqueda completada!\n";

} catch (PDOException $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
    exit(1);
}

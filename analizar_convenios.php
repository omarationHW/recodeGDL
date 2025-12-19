<?php
// Script para analizar tabla convenios y otras candidatas

$host = '192.168.6.146';
$dbname = 'multas_reglamentos';
$user = 'refact';
$password = 'FF)-BQk2';

try {
    $pdo = new PDO("pgsql:host=$host;dbname=$dbname", $user, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "Conectado exitosamente.\n\n";

    $tablas = ['convenios', 'aut_desctos', 'aut_desctosotorgados'];

    foreach ($tablas as $tabla) {
        echo "========================================\n";
        echo "TABLA: public.$tabla\n";
        echo "========================================\n\n";

        // Estructura completa
        echo "--- ESTRUCTURA COMPLETA ---\n";
        $stmt = $pdo->query("
            SELECT column_name, data_type, character_maximum_length
            FROM information_schema.columns
            WHERE table_schema = 'public'
            AND table_name = '$tabla'
            ORDER BY ordinal_position
        ");

        $columns = $stmt->fetchAll(PDO::FETCH_ASSOC);

        foreach ($columns as $col) {
            $length = $col['character_maximum_length'] ? "({$col['character_maximum_length']})" : "";
            echo "  {$col['column_name']}: {$col['data_type']}{$length}\n";
        }

        // Registros de ejemplo
        echo "\n--- REGISTROS DE EJEMPLO (primeros 3) ---\n\n";

        $stmt = $pdo->query("SELECT * FROM public.$tabla ORDER BY fecha_inicio DESC LIMIT 3");
        $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);

        foreach ($rows as $i => $row) {
            echo "Registro " . ($i + 1) . ":\n";
            foreach ($row as $key => $value) {
                $display_value = is_null($value) ? 'NULL' : (strlen($value) > 50 ? substr($value, 0, 50) . '...' : $value);
                echo "  {$key}: {$display_value}\n";
            }
            echo "\n";
        }

        // Estadísticas
        $stmt = $pdo->query("SELECT COUNT(*) as total FROM public.$tabla");
        $total = $stmt->fetch(PDO::FETCH_ASSOC);
        echo "Total registros: " . number_format($total['total']) . "\n\n";
    }

} catch (PDOException $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
    exit(1);
}

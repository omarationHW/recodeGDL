<?php
// Script para ver la estructura completa de c_dependencias

$host = '192.168.6.146';
$dbname = 'multas_reglamentos';
$user = 'refact';
$password = 'FF)-BQk2';

try {
    $pdo = new PDO("pgsql:host=$host;dbname=$dbname", $user, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "Conectado exitosamente.\n\n";

    // Verificar si existe en public o publico
    echo "=== BUSCANDO c_dependencias EN AMBOS ESQUEMAS ===\n";

    foreach (['public', 'publico'] as $schema) {
        echo "\n--- Esquema: $schema ---\n";

        try {
            // Ver estructura
            $stmt = $pdo->query("
                SELECT column_name, data_type, character_maximum_length, is_nullable
                FROM information_schema.columns
                WHERE table_schema = '$schema'
                AND table_name = 'c_dependencias'
                ORDER BY ordinal_position
            ");
            $columns = $stmt->fetchAll(PDO::FETCH_ASSOC);

            if (count($columns) > 0) {
                echo "Estructura:\n";
                foreach ($columns as $col) {
                    $length = $col['character_maximum_length'] ? "({$col['character_maximum_length']})" : "";
                    $nullable = $col['is_nullable'] == 'YES' ? 'NULL' : 'NOT NULL';
                    echo "  - {$col['column_name']}: {$col['data_type']}{$length} {$nullable}\n";
                }

                // Ver datos de ejemplo
                echo "\nDatos de ejemplo (primeros 5 registros):\n";
                $stmt = $pdo->query("SELECT * FROM $schema.c_dependencias LIMIT 5");
                $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);

                foreach ($rows as $i => $row) {
                    echo "\nRegistro " . ($i + 1) . ":\n";
                    foreach ($row as $key => $value) {
                        echo "  $key: " . (is_null($value) ? 'NULL' : trim($value)) . "\n";
                    }
                }

                // Contar registros activos
                $stmt = $pdo->query("SELECT COUNT(*) as total FROM $schema.c_dependencias WHERE vigencia = 'A'");
                $count = $stmt->fetch(PDO::FETCH_ASSOC);
                echo "\nTotal de registros activos (vigencia='A'): {$count['total']}\n";

            } else {
                echo "  (No existe en este esquema)\n";
            }
        } catch (Exception $e) {
            echo "  Error: " . $e->getMessage() . "\n";
        }
    }

} catch (PDOException $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
    exit(1);
}

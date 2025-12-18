<?php
// Script para ver la estructura de la tabla usuarios

$host = '192.168.6.146';
$dbname = 'multas_reglamentos';
$user = 'refact';
$password = 'FF)-BQk2';

try {
    $pdo = new PDO("pgsql:host=$host;dbname=$dbname", $user, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "Conectado exitosamente.\n\n";

    // Verificar en ambos esquemas
    foreach (['public', 'publico'] as $schema) {
        echo "=== ESQUEMA: $schema ===\n\n";

        // Ver estructura de usuarios
        echo "Estructura de {$schema}.usuarios:\n";
        try {
            $stmt = $pdo->query("
                SELECT column_name, data_type, character_maximum_length, is_nullable
                FROM information_schema.columns
                WHERE table_schema = '$schema'
                AND table_name = 'usuarios'
                ORDER BY ordinal_position
            ");
            $columns = $stmt->fetchAll(PDO::FETCH_ASSOC);

            if (count($columns) > 0) {
                foreach ($columns as $col) {
                    $length = $col['character_maximum_length'] ? "({$col['character_maximum_length']})" : "";
                    $nullable = $col['is_nullable'] == 'YES' ? 'NULL' : 'NOT NULL';
                    echo "  - {$col['column_name']}: {$col['data_type']}{$length} {$nullable}\n";
                }

                // Ver datos de ejemplo
                echo "\nDatos de ejemplo (primeros 3 registros):\n";
                $stmt = $pdo->query("SELECT * FROM {$schema}.usuarios LIMIT 3");
                $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);

                if (count($rows) > 0) {
                    foreach ($rows as $i => $row) {
                        echo "\nRegistro " . ($i + 1) . ":\n";
                        foreach ($row as $key => $value) {
                            if ($key == 'clave' || $key == 'password' || $key == 'passwd') {
                                echo "  $key: ***\n";
                            } else {
                                $displayValue = is_null($value) ? 'NULL' : trim($value);
                                echo "  $key: $displayValue\n";
                            }
                        }
                    }
                } else {
                    echo "  (No hay datos en la tabla)\n";
                }

                // Contar registros
                $stmt = $pdo->query("SELECT COUNT(*) as total FROM {$schema}.usuarios");
                $count = $stmt->fetch(PDO::FETCH_ASSOC);
                echo "\nTotal de registros: {$count['total']}\n\n";
            } else {
                echo "  (No existe en este esquema)\n\n";
            }
        } catch (Exception $e) {
            echo "  Error: " . $e->getMessage() . "\n\n";
        }
    }

} catch (PDOException $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
    exit(1);
}

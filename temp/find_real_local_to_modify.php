<?php
// Script para buscar un local real que podamos modificar

$host = '192.168.6.146';
$port = '5432';
$dbname = 'mercados';
$user = 'refact';
$password = 'FF)-BQk2';

try {
    $dsn = "pgsql:host=$host;port=$port;dbname=$dbname";
    $pdo = new PDO($dsn, $user, $password, [PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION]);

    echo "=== BUSCANDO LOCAL REAL PARA MODIFICAR ===\n\n";

    // Buscar específicamente ta_11_locales en diferentes schemas
    $schemas = ['db_ingresos', 'comun', 'public', 'padron_licencias'];

    foreach ($schemas as $schema) {
        try {
            $query = "SELECT * FROM $schema.ta_11_locales LIMIT 3";
            $stmt = $pdo->query($query);
            $records = $stmt->fetchAll(PDO::FETCH_ASSOC);

            if (!empty($records)) {
                echo "✓✓✓ ENCONTRADO EN: $schema.ta_11_locales\n";
                echo "Total registros encontrados: " . count($records) . "\n\n";

                foreach ($records as $idx => $record) {
                    echo "========================================\n";
                    echo "REGISTRO " . ($idx + 1) . " - DATOS PARA BUSCAR:\n";
                    echo "========================================\n";
                    echo "Recaudadora (oficina): " . ($record['oficina'] ?? $record['id_rec'] ?? 'N/A') . "\n";
                    echo "Mercado: " . ($record['num_mercado'] ?? $record['mercado'] ?? 'N/A') . "\n";
                    echo "Categoría: " . ($record['categoria'] ?? 'N/A') . "\n";
                    echo "Sección: " . ($record['seccion'] ?? 'N/A') . "\n";
                    echo "Local: " . ($record['local'] ?? $record['num_local'] ?? 'N/A') . "\n";
                    echo "Letra Local: " . ($record['letra_local'] ?? 'N/A') . "\n";
                    echo "Bloque: " . ($record['bloque'] ?? 'N/A') . "\n";
                    echo "---\n";
                    echo "Nombre: " . ($record['nombre'] ?? 'N/A') . "\n";
                    echo "Domicilio: " . ($record['domicilio'] ?? 'N/A') . "\n";
                    echo "Superficie: " . ($record['superficie'] ?? 'N/A') . "\n";
                    echo "Giro: " . ($record['giro'] ?? 'N/A') . "\n";
                    echo "Vigencia: " . ($record['vigencia'] ?? 'N/A') . "\n";
                    echo "\n";
                }

                // Mostrar todas las columnas del primer registro
                echo "========================================\n";
                echo "TODAS LAS COLUMNAS DISPONIBLES:\n";
                echo "========================================\n";
                foreach ($records[0] as $col => $val) {
                    echo "$col: " . ($val ?? 'NULL') . "\n";
                }

                break;
            }
        } catch (Exception $e) {
            // Continuar con el siguiente schema
        }
    }

} catch (PDOException $e) {
    echo "Error de conexión: " . $e->getMessage() . "\n";
}

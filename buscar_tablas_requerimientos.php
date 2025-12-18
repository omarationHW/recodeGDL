<?php
// Buscar tablas relacionadas con requerimientos en la BD multas_reglamentos

$host = '192.168.6.146';
$dbname = 'multas_reglamentos';
$user = 'refact';
$password = 'FF)-BQk2';

try {
    $pdo = new PDO("pgsql:host=$host;dbname=$dbname", $user, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "=== BUSCANDO TABLAS RELACIONADAS CON REQUERIMIENTOS ===\n\n";

    // Buscar tablas que contengan 'req' (ya sabemos que reqmultas existe)
    $stmt = $pdo->query("
        SELECT
            schemaname,
            tablename
        FROM pg_tables
        WHERE schemaname IN ('public', 'publico')
        AND tablename ILIKE '%req%'
        ORDER BY schemaname, tablename
    ");

    $tablas = $stmt->fetchAll(PDO::FETCH_ASSOC);

    if (count($tablas) > 0) {
        foreach ($tablas as $tabla) {
            echo "Tabla: {$tabla['schemaname']}.{$tabla['tablename']}\n";

            // Contar registros
            try {
                $count_stmt = $pdo->query("SELECT COUNT(*) as total FROM {$tabla['schemaname']}.{$tabla['tablename']}");
                $count = $count_stmt->fetch(PDO::FETCH_ASSOC);
                echo "  Registros: " . number_format($count['total']) . "\n";

                // Ver columnas
                $col_stmt = $pdo->prepare("
                    SELECT column_name, data_type
                    FROM information_schema.columns
                    WHERE table_schema = ? AND table_name = ?
                    ORDER BY ordinal_position
                ");
                $col_stmt->execute([$tabla['schemaname'], $tabla['tablename']]);
                $columnas = $col_stmt->fetchAll(PDO::FETCH_ASSOC);

                echo "  Columnas:\n";
                foreach ($columnas as $col) {
                    echo "    - {$col['column_name']} ({$col['data_type']})\n";
                }
            } catch (Exception $e) {
                echo "  Error al leer tabla: {$e->getMessage()}\n";
            }

            echo "\n" . str_repeat("-", 60) . "\n\n";
        }
    } else {
        echo "No se encontraron tablas.\n\n";
    }

    echo "✅ Búsqueda completada!\n";

} catch (PDOException $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
    exit(1);
}

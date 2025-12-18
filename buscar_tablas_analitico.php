<?php
// Buscar tablas relacionadas con listado analítico en la BD multas_reglamentos

$host = '192.168.6.146';
$dbname = 'multas_reglamentos';
$user = 'refact';
$password = 'FF)-BQk2';

try {
    $pdo = new PDO("pgsql:host=$host;dbname=$dbname", $user, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "=== BUSCANDO TABLAS RELACIONADAS CON ANALÍTICO ===\n\n";

    // Buscar tablas que contengan palabras relacionadas
    $stmt = $pdo->query("
        SELECT
            schemaname,
            tablename
        FROM pg_tables
        WHERE schemaname IN ('public', 'publico')
        AND (
            tablename ILIKE '%ana%'
            OR tablename ILIKE '%analitico%'
            OR tablename ILIKE '%detalle%'
            OR tablename ILIKE '%det%'
            OR tablename ILIKE '%listado%'
        )
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

                // Ver columnas solo si tiene registros
                if ($count['total'] > 0 && $count['total'] < 50000000) {
                    $col_stmt = $pdo->prepare("
                        SELECT column_name, data_type
                        FROM information_schema.columns
                        WHERE table_schema = ? AND table_name = ?
                        ORDER BY ordinal_position
                    ");
                    $col_stmt->execute([$tabla['schemaname'], $tabla['tablename']]);
                    $columnas = $col_stmt->fetchAll(PDO::FETCH_ASSOC);

                    echo "  Columnas:\n";
                    $count_cols = 0;
                    foreach ($columnas as $col) {
                        if ($count_cols < 20) {
                            echo "    - {$col['column_name']} ({$col['data_type']})\n";
                            $count_cols++;
                        }
                    }
                    if (count($columnas) > 20) {
                        echo "    ... y " . (count($columnas) - 20) . " columnas más\n";
                    }
                }
            } catch (Exception $e) {
                echo "  Error al leer tabla: {$e->getMessage()}\n";
            }

            echo "\n" . str_repeat("-", 60) . "\n\n";
        }
    } else {
        echo "No se encontraron tablas.\n\n";
    }

    // También buscar en tablas que ya conocemos que podrían ser útiles
    echo "\n=== TABLAS ALTERNATIVAS CONOCIDAS ===\n\n";

    $tablas_alt = ['reqmultas', 'reqpredial', 'detreqpredial', 'detreqanun', 'detreqlic'];

    foreach ($tablas_alt as $nombre_tabla) {
        $stmt_alt = $pdo->query("
            SELECT schemaname, tablename
            FROM pg_tables
            WHERE tablename = '$nombre_tabla'
            AND schemaname IN ('public', 'publico')
        ");
        $resultado = $stmt_alt->fetch(PDO::FETCH_ASSOC);

        if ($resultado) {
            echo "Tabla encontrada: {$resultado['schemaname']}.{$resultado['tablename']}\n";

            $count_stmt = $pdo->query("SELECT COUNT(*) as total FROM {$resultado['schemaname']}.{$resultado['tablename']}");
            $count = $count_stmt->fetch(PDO::FETCH_ASSOC);
            echo "  Registros: " . number_format($count['total']) . "\n\n";
        }
    }

    echo "✅ Búsqueda completada!\n";

} catch (PDOException $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
    exit(1);
}

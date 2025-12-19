<?php
// Script para buscar tablas relacionadas con resoluciones de juez

$host = '192.168.6.146';
$dbname = 'multas_reglamentos';
$user = 'refact';
$password = 'FF)-BQk2';

try {
    $pdo = new PDO("pgsql:host=$host;dbname=$dbname", $user, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "=== BÚSQUEDA DE TABLAS PARA RESOLUCIÓN DE JUEZ ===\n\n";

    // Campos que necesitamos
    $campos_necesarios = [
        'id_resolucion', 'cvecuenta', 'axoini', 'bimini', 'axofin', 'bimfin',
        'accesorios', 'fecha_calcular', 'vigencia', 'cvepago',
        'not_canceladas', 'observaciones', 'fecha_alta', 'usuario_alta',
        'fecha_baja', 'usuario_baja'
    ];

    echo "Campos necesarios:\n";
    foreach ($campos_necesarios as $campo) {
        echo "  - $campo\n";
    }
    echo "\n";

    // Buscar tablas con palabras clave
    echo "1. Buscando tablas con 'resol' o 'juez'...\n\n";

    $stmt = $pdo->query("
        SELECT tablename
        FROM pg_tables
        WHERE schemaname = 'public'
        AND (tablename ILIKE '%resol%' OR tablename ILIKE '%juez%')
        ORDER BY tablename
    ");

    $tablas_resolucion = $stmt->fetchAll(PDO::FETCH_COLUMN);

    if (count($tablas_resolucion) > 0) {
        echo "Tablas encontradas con 'resol' o 'juez':\n";
        foreach ($tablas_resolucion as $tabla) {
            echo "  - $tabla\n";
        }
    } else {
        echo "❌ No se encontraron tablas con 'resol' o 'juez'\n";
    }

    // Buscar tablas con 'norequer' o similares
    echo "\n\n2. Buscando tablas con 'norequer'...\n\n";

    $stmt = $pdo->query("
        SELECT tablename
        FROM pg_tables
        WHERE schemaname = 'public'
        AND tablename ILIKE '%norequer%'
        ORDER BY tablename
    ");

    $tablas_noreq = $stmt->fetchAll(PDO::FETCH_COLUMN);

    if (count($tablas_noreq) > 0) {
        echo "Tablas encontradas:\n";
        foreach ($tablas_noreq as $tabla) {
            echo "  - $tabla\n";

            // Mostrar info de la tabla
            $count = $pdo->query("SELECT COUNT(*) as total FROM public.$tabla")->fetch(PDO::FETCH_ASSOC);
            echo "    Registros: " . number_format($count['total']) . "\n";

            // Mostrar columnas
            $cols = $pdo->query("
                SELECT column_name, data_type
                FROM information_schema.columns
                WHERE table_schema = 'public'
                AND table_name = '$tabla'
                ORDER BY ordinal_position
            ")->fetchAll(PDO::FETCH_ASSOC);

            echo "    Columnas (" . count($cols) . "):\n";
            foreach ($cols as $col) {
                $marca = in_array($col['column_name'], $campos_necesarios) ? " ✓" : "";
                echo "      - " . $col['column_name'] . ": " . $col['data_type'] . $marca . "\n";
            }
            echo "\n";
        }
    }

    // Buscar tablas que tengan campos clave como cvecuenta, axoini, bimini, etc
    echo "\n3. Buscando tablas con estructura similar (cvecuenta, axoini, bimini)...\n\n";

    $stmt = $pdo->query("
        SELECT DISTINCT t.table_name
        FROM information_schema.columns c1
        JOIN information_schema.tables t ON c1.table_name = t.table_name AND c1.table_schema = t.table_schema
        WHERE c1.table_schema = 'public'
        AND c1.column_name IN ('cvecuenta', 'axoini', 'bimini', 'axofin', 'bimfin')
        AND t.table_type = 'BASE TABLE'
        GROUP BY t.table_name
        HAVING COUNT(DISTINCT c1.column_name) >= 3
        ORDER BY t.table_name
    ");

    $tablas_similares = $stmt->fetchAll(PDO::FETCH_COLUMN);

    if (count($tablas_similares) > 0) {
        echo "Tablas con estructura similar:\n";
        foreach ($tablas_similares as $tabla) {
            echo "\n  Tabla: public.$tabla\n";

            // Contar registros
            try {
                $count = $pdo->query("SELECT COUNT(*) as total FROM public.$tabla")->fetch(PDO::FETCH_ASSOC);
                echo "  Registros: " . number_format($count['total']) . "\n";
            } catch (Exception $e) {
                echo "  Registros: Error al contar\n";
            }

            // Mostrar columnas relevantes
            $cols = $pdo->query("
                SELECT column_name, data_type
                FROM information_schema.columns
                WHERE table_schema = 'public'
                AND table_name = '$tabla'
                AND column_name IN ('cvecuenta', 'axoini', 'bimini', 'axofin', 'bimfin', 'vigencia', 'observaciones', 'fecha_alta', 'usuario_alta')
                ORDER BY ordinal_position
            ")->fetchAll(PDO::FETCH_ASSOC);

            echo "  Columnas clave encontradas:\n";
            foreach ($cols as $col) {
                echo "    ✓ " . $col['column_name'] . ": " . $col['data_type'] . "\n";
            }

            // Muestra de datos
            echo "  Muestra de datos:\n";
            $sample = $pdo->query("SELECT * FROM public.$tabla LIMIT 1")->fetch(PDO::FETCH_ASSOC);
            if ($sample) {
                foreach ($sample as $key => $value) {
                    if (in_array($key, ['cvecuenta', 'axoini', 'bimini', 'axofin', 'bimfin', 'vigencia'])) {
                        echo "    - $key: " . ($value ?: 'NULL') . "\n";
                    }
                }
            }
        }
    }

    // Listar todas las tablas disponibles para referencia
    echo "\n\n4. Lista completa de tablas en public (para referencia)...\n\n";

    $stmt = $pdo->query("
        SELECT tablename
        FROM pg_tables
        WHERE schemaname = 'public'
        ORDER BY tablename
    ");

    $todas_tablas = $stmt->fetchAll(PDO::FETCH_COLUMN);
    echo "Total de tablas: " . count($todas_tablas) . "\n\n";

    $grupos = [
        'req' => [],
        'ctrl' => [],
        'det' => [],
        'h_' => [],
        'noreq' => [],
        'otros' => []
    ];

    foreach ($todas_tablas as $tabla) {
        if (stripos($tabla, 'req') !== false && stripos($tabla, 'noreq') === false) {
            $grupos['req'][] = $tabla;
        } elseif (stripos($tabla, 'ctrl') !== false) {
            $grupos['ctrl'][] = $tabla;
        } elseif (stripos($tabla, 'det') !== false) {
            $grupos['det'][] = $tabla;
        } elseif (stripos($tabla, 'h_') !== false) {
            $grupos['h_'][] = $tabla;
        } elseif (stripos($tabla, 'noreq') !== false) {
            $grupos['noreq'][] = $tabla;
        } else {
            $grupos['otros'][] = $tabla;
        }
    }

    foreach ($grupos as $grupo => $tablas) {
        if (count($tablas) > 0) {
            echo "Grupo: $grupo\n";
            foreach ($tablas as $tabla) {
                echo "  - $tabla\n";
            }
            echo "\n";
        }
    }

} catch (PDOException $e) {
    echo "Error: " . $e->getMessage() . "\n";
    exit(1);
}

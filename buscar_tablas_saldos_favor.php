<?php
// Script para buscar tablas relacionadas con saldos a favor

$host = '192.168.6.146';
$dbname = 'multas_reglamentos';
$user = 'refact';
$password = 'FF)-BQk2';

try {
    $pdo = new PDO("pgsql:host=$host;dbname=$dbname", $user, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "=== BÚSQUEDA DE TABLAS PARA SALDOS A FAVOR ===\n\n";

    // Buscar tablas con palabras clave
    echo "1. Buscando tablas con 'saldo', 'favor', 'sdos', 'expediente', 'ctrl'...\n\n";

    $palabras = ['saldo', 'favor', 'sdos', 'expediente', 'ctrl', 'control'];
    $tablas_encontradas = [];

    foreach ($palabras as $palabra) {
        $stmt = $pdo->query("
            SELECT tablename
            FROM pg_tables
            WHERE schemaname = 'public'
            AND tablename ILIKE '%$palabra%'
            ORDER BY tablename
        ");

        $tablas = $stmt->fetchAll(PDO::FETCH_COLUMN);
        foreach ($tablas as $tabla) {
            $tablas_encontradas[$tabla] = true;
        }
    }

    if (count($tablas_encontradas) > 0) {
        echo "Tablas encontradas:\n";
        foreach (array_keys($tablas_encontradas) as $tabla) {
            echo "  - $tabla\n";

            // Contar registros
            try {
                $count = $pdo->query("SELECT COUNT(*) as total FROM public.$tabla")->fetch(PDO::FETCH_ASSOC);
                echo "    Registros: " . number_format($count['total']) . "\n";
            } catch (Exception $e) {
                echo "    Registros: Error\n";
            }

            // Mostrar columnas
            $cols = $pdo->query("
                SELECT column_name, data_type
                FROM information_schema.columns
                WHERE table_schema = 'public'
                AND table_name = '$tabla'
                ORDER BY ordinal_position
                LIMIT 15
            ")->fetchAll(PDO::FETCH_ASSOC);

            echo "    Columnas (" . count($cols) . "):\n";
            foreach ($cols as $col) {
                echo "      - " . $col['column_name'] . ": " . $col['data_type'] . "\n";
            }

            // Muestra de datos
            echo "    Muestra de datos:\n";
            try {
                $sample = $pdo->query("SELECT * FROM public.$tabla LIMIT 1")->fetch(PDO::FETCH_ASSOC);
                if ($sample) {
                    $count = 0;
                    foreach ($sample as $key => $value) {
                        if ($count++ < 10) {
                            echo "      " . $key . ": " . ($value !== null ? substr($value, 0, 50) : 'NULL') . "\n";
                        }
                    }
                } else {
                    echo "      (sin datos)\n";
                }
            } catch (Exception $e) {
                echo "      Error: " . $e->getMessage() . "\n";
            }

            echo "\n";
        }
    } else {
        echo "❌ No se encontraron tablas con esas palabras clave\n";
    }

    // Buscar tablas que tengan 'cuenta' o 'cvecuenta'
    echo "\n2. Buscando tablas con campo 'cuenta' o 'cvecuenta' que puedan servir...\n\n";

    $stmt = $pdo->query("
        SELECT DISTINCT t.table_name
        FROM information_schema.columns c
        JOIN information_schema.tables t ON c.table_name = t.table_name AND c.table_schema = t.table_schema
        WHERE c.table_schema = 'public'
        AND (c.column_name LIKE '%cuenta%' OR c.column_name LIKE '%expediente%')
        AND t.table_type = 'BASE TABLE'
        ORDER BY t.table_name
        LIMIT 30
    ");

    $tablas = $stmt->fetchAll(PDO::FETCH_COLUMN);
    echo "Encontradas " . count($tablas) . " tablas con campos de cuenta/expediente\n\n";

    foreach (array_slice($tablas, 0, 10) as $tabla) {
        echo "  - $tabla\n";
    }

    // Listar tablas que empiecen con 's'
    echo "\n\n3. Buscando tablas que empiecen con 's'...\n\n";

    $stmt = $pdo->query("
        SELECT tablename
        FROM pg_tables
        WHERE schemaname = 'public'
        AND tablename LIKE 's%'
        ORDER BY tablename
    ");

    $tablas_s = $stmt->fetchAll(PDO::FETCH_COLUMN);
    if (count($tablas_s) > 0) {
        echo "Tablas que empiezan con 's':\n";
        foreach ($tablas_s as $tabla) {
            echo "  - $tabla\n";
        }
    }

    // Buscar en todas las tablas para entender mejor
    echo "\n\n4. Listado de TODAS las tablas (para referencia)...\n\n";

    $stmt = $pdo->query("
        SELECT tablename,
               (SELECT COUNT(*) FROM information_schema.columns
                WHERE table_schema = 'public' AND table_name = tablename) as num_cols
        FROM pg_tables
        WHERE schemaname = 'public'
        ORDER BY tablename
    ");

    $todas = $stmt->fetchAll(PDO::FETCH_ASSOC);
    echo "Total de tablas: " . count($todas) . "\n\n";

    // Agrupar por letra inicial
    $grupos = [];
    foreach ($todas as $t) {
        $letra = strtoupper(substr($t['tablename'], 0, 1));
        if (!isset($grupos[$letra])) {
            $grupos[$letra] = [];
        }
        $grupos[$letra][] = $t['tablename'] . " (" . $t['num_cols'] . " cols)";
    }

    foreach ($grupos as $letra => $tablas) {
        echo "Letra $letra: " . count($tablas) . " tablas\n";
        if (count($tablas) <= 10) {
            foreach ($tablas as $t) {
                echo "  - $t\n";
            }
        } else {
            foreach (array_slice($tablas, 0, 5) as $t) {
                echo "  - $t\n";
            }
            echo "  ... y " . (count($tablas) - 5) . " más\n";
        }
        echo "\n";
    }

} catch (PDOException $e) {
    echo "Error: " . $e->getMessage() . "\n";
    exit(1);
}

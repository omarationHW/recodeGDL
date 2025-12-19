<?php
// Script para analizar tablas de requerimientos prediales

$host = '192.168.6.146';
$dbname = 'multas_reglamentos';
$user = 'refact';
$password = 'FF)-BQk2';

try {
    $pdo = new PDO("pgsql:host=$host;dbname=$dbname", $user, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "=== ANÁLISIS DE TABLAS DE REQUERIMIENTOS ===\n\n";

    // Campos que necesitamos según el error
    $campos_necesarios = [
        'cvereq', 'folioreq', 'cvecuenta', 'axoreq', 'fecemi', 'fecent',
        'impuesto', 'recargos', 'gastos', 'multas', 'total', 'vigencia'
    ];

    echo "Campos necesarios para RequerimientosDM.vue:\n";
    foreach ($campos_necesarios as $campo) {
        echo "  - $campo\n";
    }
    echo "\n";

    // Tablas candidatas
    $tablas = [
        'ctrl_reqpredial',
        'h_reqpredial',
        'detreqpredial',
        'reqbfpredial'
    ];

    foreach ($tablas as $tabla) {
        echo "\n" . str_repeat("=", 80) . "\n";
        echo "TABLA: public.$tabla\n";
        echo str_repeat("=", 80) . "\n\n";

        // Verificar si existe
        $check = $pdo->query("
            SELECT COUNT(*) as existe
            FROM information_schema.tables
            WHERE table_schema = 'public'
            AND table_name = '$tabla'
        ")->fetch(PDO::FETCH_ASSOC);

        if ($check['existe'] == 0) {
            echo "❌ La tabla NO existe\n";
            continue;
        }

        echo "✅ La tabla existe\n\n";

        // Contar registros
        try {
            $count = $pdo->query("SELECT COUNT(*) as total FROM public.$tabla")->fetch(PDO::FETCH_ASSOC);
            echo "Total de registros: " . number_format($count['total']) . "\n\n";
        } catch (Exception $e) {
            echo "Error al contar registros\n\n";
        }

        // Listar columnas
        $stmt = $pdo->query("
            SELECT
                column_name,
                data_type,
                character_maximum_length
            FROM information_schema.columns
            WHERE table_schema = 'public'
            AND table_name = '$tabla'
            ORDER BY ordinal_position
        ");

        echo "COLUMNAS:\n";
        $columnas = $stmt->fetchAll(PDO::FETCH_ASSOC);
        $columnas_nombres = [];

        foreach ($columnas as $col) {
            $columnas_nombres[] = $col['column_name'];
            $tipo = $col['data_type'];
            if ($col['character_maximum_length']) {
                $tipo .= "(" . $col['character_maximum_length'] . ")";
            }

            // Marcar si es uno de los campos necesarios
            $marca = in_array($col['column_name'], $campos_necesarios) ? " ✓" : "";
            echo "  - " . $col['column_name'] . ": " . $tipo . $marca . "\n";
        }

        // Verificar qué campos necesarios tiene
        echo "\n";
        echo "CAMPOS NECESARIOS ENCONTRADOS:\n";
        $encontrados = 0;
        foreach ($campos_necesarios as $campo) {
            $tiene = in_array($campo, $columnas_nombres);
            if ($tiene) {
                echo "  ✅ $campo\n";
                $encontrados++;
            } else {
                echo "  ❌ $campo\n";
            }
        }
        echo "\nCoincidencia: $encontrados/" . count($campos_necesarios) . " campos\n";

        // Mostrar registros de muestra si tiene datos
        if ($count['total'] > 0) {
            echo "\n";
            echo "MUESTRA DE DATOS (primeros 3 registros):\n";
            echo str_repeat("-", 80) . "\n";

            $sample = $pdo->query("SELECT * FROM public.$tabla LIMIT 3");
            $sample_rows = $sample->fetchAll(PDO::FETCH_ASSOC);

            foreach ($sample_rows as $idx => $row) {
                echo "\nRegistro " . ($idx + 1) . ":\n";
                foreach ($row as $key => $value) {
                    if (in_array($key, $campos_necesarios)) {
                        echo "  ✓ $key: " . ($value ?: 'NULL') . "\n";
                    }
                }
            }
        }
    }

    // Buscar otras tablas con nombres similares
    echo "\n\n" . str_repeat("=", 80) . "\n";
    echo "OTRAS TABLAS CON 'REQ' EN EL NOMBRE:\n";
    echo str_repeat("=", 80) . "\n\n";

    $stmt = $pdo->query("
        SELECT tablename
        FROM pg_tables
        WHERE schemaname = 'public'
        AND tablename ILIKE '%req%'
        ORDER BY tablename
    ");

    foreach ($stmt->fetchAll(PDO::FETCH_ASSOC) as $row) {
        echo "  - " . $row['tablename'] . "\n";
    }

} catch (PDOException $e) {
    echo "Error: " . $e->getMessage() . "\n";
    exit(1);
}

<?php
// Script para búsqueda exhaustiva de tablas relacionadas con presupuesto

$host = '192.168.6.146';
$dbname = 'multas_reglamentos';
$user = 'refact';
$password = 'FF)-BQk2';

try {
    $pdo = new PDO("pgsql:host=$host;dbname=$dbname", $user, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "Conectado exitosamente.\n\n";

    // 1. Buscar tablas con campos financieros/contables
    echo "=== BUSCANDO TABLAS CON CAMPOS FINANCIEROS ===\n\n";

    $campos_financieros = ['importe', 'monto', 'total', 'suma', 'ingreso', 'egreso', 'gasto'];
    $tablas_encontradas = [];

    foreach ($campos_financieros as $campo) {
        $stmt = $pdo->prepare("
            SELECT DISTINCT table_name
            FROM information_schema.columns
            WHERE table_schema = 'public'
            AND column_name ILIKE ?
        ");
        $stmt->execute(["%$campo%"]);
        $tables = $stmt->fetchAll(PDO::FETCH_ASSOC);

        foreach ($tables as $table) {
            $tablas_encontradas[$table['table_name']] = true;
        }
    }

    echo "Tablas con campos financieros encontradas: " . count($tablas_encontradas) . "\n\n";

    // Contar registros de cada tabla
    $tablas_con_datos = [];
    foreach (array_keys($tablas_encontradas) as $tabla) {
        try {
            $stmt = $pdo->query("SELECT COUNT(*) as total FROM public.$tabla");
            $count = $stmt->fetch(PDO::FETCH_ASSOC);

            if ($count['total'] > 0 && $count['total'] < 1000000) {
                $tablas_con_datos[$tabla] = $count['total'];
            }
        } catch (PDOException $e) {
            // Ignorar
        }
    }

    // Ordenar por cantidad de registros
    arsort($tablas_con_datos);

    echo "Top 20 tablas financieras (menos de 1M registros):\n\n";
    $i = 0;
    foreach ($tablas_con_datos as $tabla => $count) {
        if ($i++ < 20) {
            echo "  ✓ $tabla (" . number_format($count) . " registros)\n";
        }
    }

    // 2. Revisar tabla auditoria más detalladamente
    echo "\n\n=== ANALIZANDO TABLA AUDITORIA (ya usada en polcon) ===\n\n";

    $stmt = $pdo->query("
        SELECT
            MIN(axopago) as anio_min,
            MAX(axopago) as anio_max,
            COUNT(DISTINCT cvectaapl) as cuentas_diferentes,
            COUNT(DISTINCT axopago) as anios_diferentes
        FROM public.auditoria
        WHERE axopago > 0
    ");
    $stats = $stmt->fetch(PDO::FETCH_ASSOC);

    echo "Estadísticas de auditoria:\n";
    echo "  Año mínimo: {$stats['anio_min']}\n";
    echo "  Año máximo: {$stats['anio_max']}\n";
    echo "  Cuentas diferentes: {$stats['cuentas_diferentes']}\n";
    echo "  Años diferentes: {$stats['anios_diferentes']}\n\n";

    echo "¿Podría usarse auditoria para presupuesto?\n";
    echo "  • Tiene axopago (año/ejercicio)\n";
    echo "  • Tiene cvectaapl (cuenta aplicación)\n";
    echo "  • Tiene monto (importe)\n";
    echo "  • Tiene bimini (periodo bimestral)\n";
    echo "  • Podría agregarse por año, cuenta y convertir bimestres a meses\n\n";

    // 3. Ver si hay tablas con estructura de resumen/consolidado
    echo "\n=== BUSCANDO TABLAS CON TÉRMINOS 'RESUMEN', 'CONSOLIDADO', 'TOTAL' ===\n\n";

    $stmt = $pdo->query("
        SELECT tablename
        FROM pg_tables
        WHERE schemaname = 'public'
        AND (
            tablename ILIKE '%resumen%' OR
            tablename ILIKE '%consolid%' OR
            tablename ILIKE '%total%' OR
            tablename ILIKE '%acumul%' OR
            tablename ILIKE '%agregad%'
        )
        ORDER BY tablename
    ");

    $tables = $stmt->fetchAll(PDO::FETCH_ASSOC);

    if (count($tables) > 0) {
        foreach ($tables as $table) {
            try {
                $count_stmt = $pdo->query("SELECT COUNT(*) as total FROM public.{$table['tablename']}");
                $count = $count_stmt->fetch(PDO::FETCH_ASSOC);
                echo "  ✓ {$table['tablename']} ({$count['total']} registros)\n";
            } catch (PDOException $e) {
                echo "  ✗ {$table['tablename']} (error)\n";
            }
        }
    } else {
        echo "  No se encontraron tablas.\n";
    }

    // 4. Buscar tablas con estructura de plan de cuentas
    echo "\n\n=== BUSCANDO TABLAS DE CATÁLOGO CONTABLE ===\n\n";

    $stmt = $pdo->query("
        SELECT tablename
        FROM pg_tables
        WHERE schemaname = 'public'
        AND tablename ILIKE 'c_%'
        ORDER BY tablename
        LIMIT 30
    ");

    $tables = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo "Tablas de catálogo encontradas:\n\n";
    foreach ($tables as $table) {
        try {
            $count_stmt = $pdo->query("SELECT COUNT(*) as total FROM public.{$table['tablename']}");
            $count = $count_stmt->fetch(PDO::FETCH_ASSOC);

            if ($count['total'] > 0 && $count['total'] < 5000) {
                echo "  ✓ {$table['tablename']} ({$count['total']} registros)\n";
            }
        } catch (PDOException $e) {
            // Ignorar
        }
    }

} catch (PDOException $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
    exit(1);
}

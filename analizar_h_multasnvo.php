<?php
// Script para analizar estructura completa de h_multasnvo

$host = '192.168.6.146';
$dbname = 'multas_reglamentos';
$user = 'refact';
$password = 'FF)-BQk2';

try {
    $pdo = new PDO("pgsql:host=$host;dbname=$dbname", $user, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "Conectado exitosamente.\n\n";

    echo "========================================\n";
    echo "TABLA: public.h_multasnvo\n";
    echo "========================================\n\n";

    // Estructura completa
    echo "--- ESTRUCTURA COMPLETA ---\n";
    $stmt = $pdo->query("
        SELECT column_name, data_type, character_maximum_length
        FROM information_schema.columns
        WHERE table_schema = 'public'
        AND table_name = 'h_multasnvo'
        ORDER BY ordinal_position
    ");

    $columns = $stmt->fetchAll(PDO::FETCH_ASSOC);

    foreach ($columns as $col) {
        $length = $col['character_maximum_length'] ? "({$col['character_maximum_length']})" : "";
        echo "  {$col['column_name']}: {$col['data_type']}{$length}\n";
    }

    // Buscar específicamente el campo calificacion
    echo "\n--- CAMPOS CON 'calif' ---\n";
    $stmt = $pdo->query("
        SELECT column_name
        FROM information_schema.columns
        WHERE table_schema = 'public'
        AND table_name = 'h_multasnvo'
        AND column_name ILIKE '%calif%'
    ");
    $calif_cols = $stmt->fetchAll(PDO::FETCH_ASSOC);

    if (count($calif_cols) > 0) {
        foreach ($calif_cols as $col) {
            echo "  ✓ {$col['column_name']}\n";
        }
    } else {
        echo "  ⚠️  No se encontró campo 'calificacion' o similar\n";
    }

    // Registros de ejemplo
    echo "\n--- REGISTROS DE EJEMPLO (3 más recientes) ---\n\n";

    $stmt = $pdo->query("
        SELECT *
        FROM public.h_multasnvo
        ORDER BY fecha_acta DESC, id_multa DESC
        LIMIT 3
    ");
    $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);

    foreach ($rows as $i => $row) {
        echo "Registro " . ($i + 1) . ":\n";
        foreach ($row as $key => $value) {
            $display_value = is_null($value) ? 'NULL' : (strlen($value) > 60 ? substr($value, 0, 60) . '...' : $value);
            echo "  {$key}: {$display_value}\n";
        }
        echo "\n";
    }

    // Estadísticas
    $stmt = $pdo->query("SELECT COUNT(*) as total FROM public.h_multasnvo");
    $total = $stmt->fetch(PDO::FETCH_ASSOC);
    echo "Total registros: " . number_format($total['total']) . "\n\n";

    // Estadísticas por año
    echo "--- REGISTROS POR AÑO (últimos 10 años) ---\n";
    $stmt = $pdo->query("
        SELECT axo_acta, COUNT(*) as total
        FROM public.h_multasnvo
        WHERE axo_acta >= 2015
        GROUP BY axo_acta
        ORDER BY axo_acta DESC
    ");
    $years = $stmt->fetchAll(PDO::FETCH_ASSOC);

    foreach ($years as $year) {
        echo "  {$year['axo_acta']}: " . number_format($year['total']) . " registros\n";
    }

    // Estadísticas por dependencia
    echo "\n--- REGISTROS POR DEPENDENCIA (top 10) ---\n";
    $stmt = $pdo->query("
        SELECT id_dependencia, COUNT(*) as total
        FROM public.h_multasnvo
        GROUP BY id_dependencia
        ORDER BY total DESC
        LIMIT 10
    ");
    $deps = $stmt->fetchAll(PDO::FETCH_ASSOC);

    foreach ($deps as $dep) {
        echo "  Dependencia {$dep['id_dependencia']}: " . number_format($dep['total']) . " registros\n";
    }

} catch (PDOException $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
    exit(1);
}

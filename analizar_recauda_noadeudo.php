<?php
// Script para analizar tablas recauda_centros y noadeudo

$host = '192.168.6.146';
$dbname = 'multas_reglamentos';
$user = 'refact';
$password = 'FF)-BQk2';

try {
    $pdo = new PDO("pgsql:host=$host;dbname=$dbname", $user, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "Conectado exitosamente.\n\n";

    $tablas = ['recauda_centros', 'noadeudo'];

    foreach ($tablas as $tabla) {
        echo "========================================\n";
        echo "TABLA: public.$tabla\n";
        echo "========================================\n\n";

        // Estructura completa
        echo "--- ESTRUCTURA COMPLETA ---\n";
        $stmt = $pdo->query("
            SELECT column_name, data_type, character_maximum_length
            FROM information_schema.columns
            WHERE table_schema = 'public'
            AND table_name = '$tabla'
            ORDER BY ordinal_position
        ");

        $columns = $stmt->fetchAll(PDO::FETCH_ASSOC);

        foreach ($columns as $col) {
            $length = $col['character_maximum_length'] ? "({$col['character_maximum_length']})" : "";
            echo "  {$col['column_name']}: {$col['data_type']}{$length}\n";
        }

        // Registros de ejemplo
        echo "\n--- REGISTROS DE EJEMPLO (5 más recientes) ---\n\n";

        $order_field = ($tabla == 'recauda_centros') ? 'fecha' : 'fecha';
        $stmt = $pdo->query("
            SELECT *
            FROM public.$tabla
            ORDER BY $order_field DESC
            LIMIT 5
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
        $stmt = $pdo->query("SELECT COUNT(*) as total FROM public.$tabla");
        $total = $stmt->fetch(PDO::FETCH_ASSOC);
        echo "Total registros: " . number_format($total['total']) . "\n\n";

        // Estadísticas adicionales
        if ($tabla == 'recauda_centros') {
            echo "--- DISTRIBUCIÓN POR DEPENDENCIA ---\n";
            $stmt = $pdo->query("
                SELECT id_dependencia, COUNT(*) as total
                FROM public.$tabla
                GROUP BY id_dependencia
                ORDER BY total DESC
                LIMIT 10
            ");
            $stats = $stmt->fetchAll(PDO::FETCH_ASSOC);

            foreach ($stats as $stat) {
                echo "  Dependencia {$stat['id_dependencia']}: {$stat['total']} registros\n";
            }

            echo "\n--- REGISTROS POR AÑO ---\n";
            $stmt = $pdo->query("
                SELECT axo_acta, COUNT(*) as total
                FROM public.$tabla
                WHERE axo_acta IS NOT NULL
                GROUP BY axo_acta
                ORDER BY axo_acta DESC
                LIMIT 10
            ");
            $years = $stmt->fetchAll(PDO::FETCH_ASSOC);

            foreach ($years as $year) {
                echo "  {$year['axo_acta']}: {$year['total']} registros\n";
            }
        }

        if ($tabla == 'noadeudo') {
            echo "--- DISTRIBUCIÓN POR VIGENCIA ---\n";
            $stmt = $pdo->query("
                SELECT vigencia, COUNT(*) as total
                FROM public.$tabla
                GROUP BY vigencia
                ORDER BY total DESC
            ");
            $stats = $stmt->fetchAll(PDO::FETCH_ASSOC);

            foreach ($stats as $stat) {
                $vig = $stat['vigencia'] ?: 'NULL';
                echo "  {$vig}: {$stat['total']} registros\n";
            }

            echo "\n--- REGISTROS POR AÑO ---\n";
            $stmt = $pdo->query("
                SELECT axo, COUNT(*) as total
                FROM public.$tabla
                WHERE axo IS NOT NULL
                GROUP BY axo
                ORDER BY axo DESC
                LIMIT 10
            ");
            $years = $stmt->fetchAll(PDO::FETCH_ASSOC);

            foreach ($years as $year) {
                echo "  {$year['axo']}: {$year['total']} registros\n";
            }
        }

        echo "\n\n";
    }

} catch (PDOException $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
    exit(1);
}

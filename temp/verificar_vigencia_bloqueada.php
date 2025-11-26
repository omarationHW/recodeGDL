<?php
/**
 * Verificar si existe vigencia 'B' (bloqueada) u otros estados
 */

$host = '192.168.6.146';
$port = '5432';
$dbname = 'padron_licencias';
$user = 'refact';
$password = 'FF)-BQk2';

try {
    $pdo = new PDO("pgsql:host=$host;port=$port;dbname=$dbname", $user, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "=== VERIFICANDO ESTADOS DE VIGENCIA ===\n\n";

    // Ver todos los posibles valores de vigencia
    $sql = "
        SELECT DISTINCT vigencia, COUNT(*) as count
        FROM catastro_gdl.reqmultas
        GROUP BY vigencia
        ORDER BY vigencia;
    ";

    $stmt = $pdo->query($sql);
    $vigencias = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo "Estados de vigencia encontrados:\n";
    echo str_repeat("-", 80) . "\n";
    foreach ($vigencias as $v) {
        $vigenciaChar = $v['vigencia'];
        $count = $v['count'];

        $descripcion = match($vigenciaChar) {
            'V' => 'Vigente',
            'C' => 'Cancelada',
            'P' => 'Pagada',
            'B' => 'Bloqueada (¡ENCONTRADA!)',
            null => 'NULL',
            default => 'Desconocido'
        };

        echo sprintf("  '%s' (%s): %s registros\n", $vigenciaChar ?? 'NULL', $descripcion, $count);
    }

    // Verificar tabla de observaciones
    echo "\n\n=== VERIFICANDO TABLA reqmulta_obs_hist ===\n";
    echo str_repeat("-", 80) . "\n";

    $sql2 = "
        SELECT COUNT(*) as count
        FROM pg_tables
        WHERE schemaname = 'catastro_gdl'
          AND tablename = 'reqmulta_obs_hist';
    ";

    $stmt2 = $pdo->query($sql2);
    $hasObsTable = $stmt2->fetch(PDO::FETCH_ASSOC)['count'] > 0;

    if ($hasObsTable) {
        echo "✅ Existe tabla reqmulta_obs_hist\n\n";

        // Ver estructura
        $sql3 = "
            SELECT column_name, data_type, character_maximum_length
            FROM information_schema.columns
            WHERE table_schema = 'catastro_gdl'
              AND table_name = 'reqmulta_obs_hist'
            ORDER BY ordinal_position;
        ";

        $stmt3 = $pdo->query($sql3);
        $obsColumns = $stmt3->fetchAll(PDO::FETCH_ASSOC);

        echo "Estructura de reqmulta_obs_hist:\n";
        foreach ($obsColumns as $col) {
            $length = $col['character_maximum_length'] ? "({$col['character_maximum_length']})" : "";
            echo "  - {$col['column_name']}: {$col['data_type']}{$length}\n";
        }

        // Ver conteo
        $sql4 = "SELECT COUNT(*) as count FROM catastro_gdl.reqmulta_obs_hist";
        $stmt4 = $pdo->query($sql4);
        $obsCount = $stmt4->fetch(PDO::FETCH_ASSOC)['count'];
        echo "\nRegistros en reqmulta_obs_hist: $obsCount\n";

        if ($obsCount > 0) {
            echo "\nEjemplo de registro:\n";
            $sql5 = "SELECT * FROM catastro_gdl.reqmulta_obs_hist LIMIT 1";
            $stmt5 = $pdo->query($sql5);
            $example = $stmt5->fetch(PDO::FETCH_ASSOC);

            foreach ($example as $key => $value) {
                if ($value !== null) {
                    echo "  $key: $value\n";
                }
            }
        }
    } else {
        echo "❌ No existe tabla reqmulta_obs_hist\n";
    }

    // Buscar SPs existentes relacionados con bloqueo
    echo "\n\n=== BUSCANDO SPs EXISTENTES RELACIONADOS CON BLOQUEO ===\n";
    echo str_repeat("-", 80) . "\n";

    $sql6 = "
        SELECT
            n.nspname as schema,
            p.proname as sp_name
        FROM pg_proc p
        JOIN pg_namespace n ON p.pronamespace = n.oid
        WHERE (p.proname ILIKE '%bloq%' AND p.proname ILIKE '%multa%')
           OR (p.proname ILIKE '%req%' AND p.proname ILIKE '%bloq%')
        ORDER BY n.nspname, p.proname;
    ";

    $stmt6 = $pdo->query($sql6);
    $sps = $stmt6->fetchAll(PDO::FETCH_ASSOC);

    if (empty($sps)) {
        echo "No se encontraron SPs existentes para bloqueo de multas\n";
    } else {
        foreach ($sps as $sp) {
            echo "  ✅ {$sp['schema']}.{$sp['sp_name']}\n";
        }
    }

    echo "\n" . str_repeat("=", 80) . "\n";
    echo "RECOMENDACIÓN:\n";
    echo str_repeat("=", 80) . "\n";

    if (in_array('B', array_column($vigencias, 'vigencia'))) {
        echo "✅ Ya existe vigencia 'B' en el sistema - usar ese estándar\n";
    } else {
        echo "Opciones para implementar bloqueo:\n";
        echo "1. Usar nuevo valor vigencia='B' (Bloqueada) - Más simple\n";
        echo "2. Crear tabla reqmultas_bloqueos separada - Más trazabilidad\n";
        echo "\nRecomendación: Opción 1 (usar vigencia='B') ya que:\n";
        echo "  - Mantiene consistencia con campos existentes\n";
        echo "  - El campo 'obs' puede guardar motivo del bloqueo\n";
        echo "  - Se puede guardar en h_reqmultas para histórico\n";
    }

} catch (PDOException $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
}

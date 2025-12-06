<?php
/**
 * Script para desplegar los SPs CORRECTOS de ConsRequerimientos
 * Usa ta_15_apremios en lugar de ta_11_requerimiento_local
 * Fecha: 2025-01-24
 */

echo "=== Desplegando SPs CORRECTOS para ConsRequerimientos ===\n\n";

// Conectar a la base de datos
try {
    $pdo = new PDO('pgsql:host=192.168.6.146;port=5432;dbname=padron_licencias', 'refact', 'FF)-BQk2');
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
    echo "✓ Conexión exitosa a la base de datos\n\n";
} catch (PDOException $e) {
    die("✗ Error de conexión: " . $e->getMessage() . "\n");
}

// Leer el archivo SQL CORRECTO
$sqlFile = __DIR__ . '/../RefactorX/Base/mercados/database/ok/29_SP_MERCADOS_CONSREQUERIMIENTOS_EXACTO_all_procedures.sql';
echo "Buscando archivo en: $sqlFile\n";
if (!file_exists($sqlFile)) {
    die("✗ Error: No se encuentra el archivo $sqlFile\n");
}

$sql = file_get_contents($sqlFile);
echo "✓ Archivo SQL leído correctamente\n\n";

// Limpiar comandos \c que no funcionan en PDO
$sql = preg_replace('/\\\\c\s+\w+;/i', '', $sql);
$sql = preg_replace('/SET search_path TO \w+;/i', '', $sql);

// Ejecutar el SQL
try {
    $pdo->exec($sql);
    echo "✓ SPs desplegados exitosamente\n\n";
} catch (PDOException $e) {
    die("✗ Error al ejecutar SQL: " . $e->getMessage() . "\n");
}

// Verificar los SPs creados
echo "=== Verificando SPs creados ===\n";
$stmt = $pdo->query("
    SELECT routine_name, routine_type
    FROM information_schema.routines
    WHERE routine_name IN (
        'sp_get_locales_by_mercado',
        'sp_get_requerimientos_by_local',
        'sp_get_periodos_by_requerimiento'
    )
    AND routine_schema = 'public'
    ORDER BY routine_name
");

$sps = $stmt->fetchAll(PDO::FETCH_ASSOC);
foreach ($sps as $sp) {
    echo "  ✓ {$sp['routine_name']} ({$sp['routine_type']})\n";
}

// Verificar que la tabla ta_15_apremios existe
echo "\n=== Verificando tabla ta_15_apremios ===\n";
$stmt = $pdo->query("
    SELECT COUNT(*) as total, COUNT(DISTINCT modulo) as modulos
    FROM comun.ta_15_apremios
    WHERE vigencia = 'A'
");
$stats = $stmt->fetch(PDO::FETCH_ASSOC);
echo "  ✓ Total apremios activos: {$stats['total']}\n";
echo "  ✓ Módulos diferentes: {$stats['modulos']}\n";

// Ver cuántos apremios hay del módulo 11 (mercados)
$stmt = $pdo->query("
    SELECT COUNT(*) as total
    FROM comun.ta_15_apremios
    WHERE modulo = 11 AND vigencia = 'A'
");
$mercados = $stmt->fetch(PDO::FETCH_ASSOC);
echo "  ✓ Apremios de mercados (módulo=11): {$mercados['total']}\n";

// Ver algunos ejemplos de control_otr que existen
echo "\n=== Algunos ejemplos de apremios de mercados ===\n";
$stmt = $pdo->query("
    SELECT a.id_control, a.control_otr, a.folio, a.diligencia,
           a.importe_global, a.fecha_emision, a.vigencia
    FROM comun.ta_15_apremios a
    WHERE a.modulo = 11 AND a.vigencia = 'A'
    LIMIT 5
");
$ejemplos = $stmt->fetchAll(PDO::FETCH_ASSOC);
foreach ($ejemplos as $e) {
    echo "  - Control: {$e['id_control']}, Local (control_otr): {$e['control_otr']}, Folio: {$e['folio']}, Importe: {$e['importe_global']}\n";
}

echo "\n=== Tests ===\n";

// Test 1: Buscar locales (igual que antes)
echo "\n1. Test sp_get_locales_by_mercado:\n";
try {
    $stmt = $pdo->query("SELECT * FROM sp_get_locales_by_mercado(1, 2, 1, 'SS', 1, NULL, NULL) LIMIT 3");
    $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);
    echo "   Registros encontrados: " . count($rows) . "\n";
    if (count($rows) > 0) {
        foreach ($rows as $row) {
            echo "   - Local {$row['id_local']}: {$row['oficina']}-{$row['num_mercado']}-{$row['seccion']}-{$row['local']}\n";

            // Test 2: Buscar apremios para este local
            $idLocal = $row['id_local'];
            echo "\n2. Test sp_get_requerimientos_by_local (modulo=11, control_otr=$idLocal):\n";
            try {
                $stmt2 = $pdo->query("SELECT * FROM sp_get_requerimientos_by_local(11, $idLocal) LIMIT 3");
                $reqs = $stmt2->fetchAll(PDO::FETCH_ASSOC);
                echo "   Apremios encontrados: " . count($reqs) . "\n";
                if (count($reqs) > 0) {
                    foreach ($reqs as $req) {
                        echo "   - Folio {$req['folio']}: " . number_format($req['importe_global'], 2) . " (Fecha: {$req['fecha_emision']})\n";
                    }

                    // Test 3: Buscar periodos
                    $controlOtr = $reqs[0]['control_otr'];
                    echo "\n3. Test sp_get_periodos_by_requerimiento (control_otr: $controlOtr):\n";
                    try {
                        $stmt3 = $pdo->query("SELECT * FROM sp_get_periodos_by_requerimiento($controlOtr)");
                        $periodos = $stmt3->fetchAll(PDO::FETCH_ASSOC);
                        echo "   Periodos encontrados: " . count($periodos) . "\n";
                        if (count($periodos) > 0) {
                            foreach ($periodos as $per) {
                                echo "   - Año {$per['ayo']}, Periodo {$per['periodo']}: " . number_format($per['importe'], 2) . "\n";
                            }
                        }
                    } catch (PDOException $e) {
                        echo "   ✗ Error: " . $e->getMessage() . "\n";
                    }
                } else {
                    echo "   ℹ No hay apremios para este local\n";
                }
            } catch (PDOException $e) {
                echo "   ✗ Error: " . $e->getMessage() . "\n";
            }
            break; // Solo probamos con el primer local
        }
    }
} catch (PDOException $e) {
    echo "   ✗ Error: " . $e->getMessage() . "\n";
}

echo "\n=== Despliegue completado ===\n";

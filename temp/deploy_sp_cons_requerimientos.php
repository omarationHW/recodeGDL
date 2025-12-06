<?php
/**
 * Script para desplegar los SPs de ConsRequerimientos
 * Fecha: 2025-01-24
 */

echo "=== Desplegando SPs para ConsRequerimientos ===\n\n";

// Conectar a la base de datos
try {
    $pdo = new PDO('pgsql:host=192.168.6.146;port=5432;dbname=padron_licencias', 'refact', 'FF)-BQk2');
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
    echo "✓ Conexión exitosa a la base de datos\n\n";
} catch (PDOException $e) {
    die("✗ Error de conexión: " . $e->getMessage() . "\n");
}

// Leer el archivo SQL
$sqlFile = __DIR__ . '/../RefactorX/Base/mercados/database/ok/62_SP_MERCADOS_CONS_REQUERIMIENTOS_all_procedures.sql';
echo "Buscando archivo en: $sqlFile\n";
if (!file_exists($sqlFile)) {
    die("✗ Error: No se encuentra el archivo $sqlFile\n");
}

$sql = file_get_contents($sqlFile);
echo "✓ Archivo SQL leído correctamente\n\n";

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
    WHERE routine_name LIKE 'sp_cons_requerimientos%'
      AND routine_schema = 'public'
    ORDER BY routine_name
");

$sps = $stmt->fetchAll(PDO::FETCH_ASSOC);
foreach ($sps as $sp) {
    echo "  ✓ {$sp['routine_name']} ({$sp['routine_type']})\n";
}

echo "\n=== Tests ===\n";

// Test 1: Buscar locales
echo "\n1. Test sp_cons_requerimientos_buscar:\n";
try {
    $stmt = $pdo->query("SELECT * FROM sp_cons_requerimientos_buscar(1, 34, 1, 'SS', 1, NULL, NULL) LIMIT 3");
    $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);
    echo "   Registros encontrados: " . count($rows) . "\n";
    if (count($rows) > 0) {
        foreach ($rows as $row) {
            echo "   - Local {$row['id_local']}: {$row['oficina']}-{$row['num_mercado']}-{$row['seccion']}-{$row['local']}\n";
        }
    }
} catch (PDOException $e) {
    echo "   ✗ Error: " . $e->getMessage() . "\n";
}

// Test 2: Si hay locales, probar requerimientos
if (isset($rows) && count($rows) > 0) {
    $idLocal = $rows[0]['id_local'];
    echo "\n2. Test sp_cons_requerimientos_por_local (id_local: $idLocal):\n";
    try {
        $stmt = $pdo->query("SELECT * FROM sp_cons_requerimientos_por_local($idLocal) LIMIT 3");
        $reqs = $stmt->fetchAll(PDO::FETCH_ASSOC);
        echo "   Requerimientos encontrados: " . count($reqs) . "\n";
        if (count($reqs) > 0) {
            foreach ($reqs as $req) {
                echo "   - Folio {$req['folio']}: " . number_format($req['importe_global'], 2) . "\n";
            }

            // Test 3: Si hay requerimientos, probar periodos
            $idControl = $reqs[0]['id_control'];
            echo "\n3. Test sp_cons_requerimientos_periodos (id_control: $idControl):\n";
            try {
                $stmt = $pdo->query("SELECT * FROM sp_cons_requerimientos_periodos($idControl)");
                $periodos = $stmt->fetchAll(PDO::FETCH_ASSOC);
                echo "   Periodos encontrados: " . count($periodos) . "\n";
                if (count($periodos) > 0) {
                    foreach ($periodos as $per) {
                        echo "   - Año {$per['axo']}, Periodo {$per['periodo']}: " . number_format($per['importe'], 2) . "\n";
                    }
                }
            } catch (PDOException $e) {
                echo "   ✗ Error: " . $e->getMessage() . "\n";
            }
        }
    } catch (PDOException $e) {
        echo "   ✗ Error: " . $e->getMessage() . "\n";
    }
}

echo "\n=== Despliegue completado ===\n";

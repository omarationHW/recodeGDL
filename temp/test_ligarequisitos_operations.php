<?php
/**
 * Test de operaciones de LigaRequisitos
 * Fecha: 2025-11-06
 */

$host = '192.168.6.146';
$port = '5432';
$dbname = 'padron_licencias';
$user = 'refact';
$password = 'FF)-BQk2';

try {
    $dsn = "pgsql:host=$host;port=$port;dbname=$dbname";
    $pdo = new PDO($dsn, $user, $password, [
        PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION
    ]);

    echo "✓ Conectado al servidor\n\n";

    $testGiro = 501;
    $testReq = 2; // "DIRECCION DE BOMBEROS, INSPECCION RIESGO ALTO"

    // 1. Ver estado inicial
    echo "1. ESTADO INICIAL (Giro $testGiro):\n";
    echo str_repeat("-", 60) . "\n";

    $stmt = $pdo->query("SELECT * FROM public.sp_ligarequisitos_list($testGiro)");
    $asignados = $stmt->fetchAll(PDO::FETCH_ASSOC);
    echo "   Requisitos asignados: " . count($asignados) . "\n";

    $stmt = $pdo->query("SELECT * FROM public.sp_ligarequisitos_available($testGiro)");
    $disponibles = $stmt->fetchAll(PDO::FETCH_ASSOC);
    echo "   Requisitos disponibles: " . count($disponibles) . "\n";

    // Verificar si el requisito de prueba está asignado
    $yaAsignado = false;
    foreach ($asignados as $req) {
        if ($req['req'] == $testReq) {
            $yaAsignado = true;
            break;
        }
    }

    echo "   Requisito $testReq: " . ($yaAsignado ? "YA ASIGNADO" : "DISPONIBLE") . "\n";

    // 2. Si está asignado, quitarlo primero
    if ($yaAsignado) {
        echo "\n2. QUITANDO requisito $testReq del giro $testGiro...\n";
        echo str_repeat("-", 60) . "\n";

        $stmt = $pdo->query("SELECT * FROM public.sp_ligarequisitos_remove($testGiro, $testReq)");
        $result = $stmt->fetch(PDO::FETCH_ASSOC);

        if ($result['success'] === 't') {
            echo "   ✓ {$result['message']}\n";
        } else {
            echo "   ✗ {$result['message']}\n";
        }

        // Verificar
        $stmt = $pdo->query("SELECT * FROM public.sp_ligarequisitos_list($testGiro)");
        $asignados = $stmt->fetchAll(PDO::FETCH_ASSOC);
        echo "   Requisitos asignados ahora: " . count($asignados) . "\n";
    }

    // 3. Agregar el requisito
    echo "\n3. AGREGANDO requisito $testReq al giro $testGiro...\n";
    echo str_repeat("-", 60) . "\n";

    $stmt = $pdo->query("SELECT * FROM public.sp_ligarequisitos_add($testGiro, $testReq)");
    $result = $stmt->fetch(PDO::FETCH_ASSOC);

    if ($result['success'] === 't') {
        echo "   ✓ {$result['message']}\n";
    } else {
        echo "   ✗ {$result['message']}\n";
    }

    // Verificar
    $stmt = $pdo->query("SELECT * FROM public.sp_ligarequisitos_list($testGiro)");
    $asignados = $stmt->fetchAll(PDO::FETCH_ASSOC);
    echo "   Requisitos asignados ahora: " . count($asignados) . "\n";

    // 4. Intentar agregar duplicado (debe fallar)
    echo "\n4. INTENTANDO agregar requisito duplicado...\n";
    echo str_repeat("-", 60) . "\n";

    $stmt = $pdo->query("SELECT * FROM public.sp_ligarequisitos_add($testGiro, $testReq)");
    $result = $stmt->fetch(PDO::FETCH_ASSOC);

    if ($result['success'] === 't') {
        echo "   ⚠ ADVERTENCIA: Se permitió duplicado\n";
    } else {
        echo "   ✓ Correctamente rechazado: {$result['message']}\n";
    }

    // 5. Quitar el requisito
    echo "\n5. QUITANDO requisito $testReq del giro $testGiro...\n";
    echo str_repeat("-", 60) . "\n";

    $stmt = $pdo->query("SELECT * FROM public.sp_ligarequisitos_remove($testGiro, $testReq)");
    $result = $stmt->fetch(PDO::FETCH_ASSOC);

    if ($result['success'] === 't') {
        echo "   ✓ {$result['message']}\n";
    } else {
        echo "   ✗ {$result['message']}\n";
    }

    // Verificar
    $stmt = $pdo->query("SELECT * FROM public.sp_ligarequisitos_list($testGiro)");
    $asignados = $stmt->fetchAll(PDO::FETCH_ASSOC);
    echo "   Requisitos asignados ahora: " . count($asignados) . "\n";

    // 6. Intentar quitar requisito no asignado (debe fallar)
    echo "\n6. INTENTANDO quitar requisito no asignado...\n";
    echo str_repeat("-", 60) . "\n";

    $stmt = $pdo->query("SELECT * FROM public.sp_ligarequisitos_remove($testGiro, $testReq)");
    $result = $stmt->fetch(PDO::FETCH_ASSOC);

    if ($result['success'] === 't') {
        echo "   ⚠ ADVERTENCIA: Se permitió quitar no existente\n";
    } else {
        echo "   ✓ Correctamente rechazado: {$result['message']}\n";
    }

    // 7. Restaurar estado original si es necesario
    if ($yaAsignado) {
        echo "\n7. RESTAURANDO estado original...\n";
        echo str_repeat("-", 60) . "\n";

        $stmt = $pdo->query("SELECT * FROM public.sp_ligarequisitos_add($testGiro, $testReq)");
        $result = $stmt->fetch(PDO::FETCH_ASSOC);

        if ($result['success'] === 't') {
            echo "   ✓ Estado original restaurado\n";
        }
    }

    echo "\n✓✓✓ TODAS LAS PRUEBAS COMPLETADAS ✓✓✓\n";

} catch (Exception $e) {
    echo "✗ ERROR: " . $e->getMessage() . "\n";
    exit(1);
}

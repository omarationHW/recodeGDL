<?php
// Script para obtener 3 ejemplos variados de requerimientos 400

$host = '192.168.6.146';
$dbname = 'multas_reglamentos';
$user = 'refact';
$password = 'FF)-BQk2';

try {
    $pdo = new PDO("pgsql:host=$host;dbname=$dbname", $user, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "Conectado exitosamente.\n\n";
    echo "=== 3 EJEMPLOS PARA PROBAR EL FORMULARIO ConsReq400 ===\n\n";

    // Ejemplo 1: Un requerimiento vigente reciente
    echo "EJEMPLO 1: Requerimiento Vigente Reciente\n";
    echo str_repeat("-", 60) . "\n";
    $stmt = $pdo->query("
        SELECT * FROM publico.recaudadora_consreq400('', 0, 0, 1)
        WHERE vigreq = 'V'
        ORDER BY ejercicio DESC
        LIMIT 1
    ");
    $ejemplo1 = $stmt->fetch(PDO::FETCH_ASSOC);

    if ($ejemplo1) {
        echo "📋 Clave Cuenta: {$ejemplo1['clave_cuenta']}\n";
        echo "   Ejercicio: {$ejemplo1['ejercicio']}\n";
        echo "   Folio: {$ejemplo1['folio']}\n";
        echo "   Estatus: {$ejemplo1['estatus']}\n";
        echo "   Fecha: {$ejemplo1['fecha']}\n";
        echo "   Vigencia: {$ejemplo1['vigreq']}\n";
        if ($ejemplo1['observr']) {
            echo "   Observaciones: " . substr($ejemplo1['observr'], 0, 60) . "\n";
        }
    }

    // Ejemplo 2: Un requerimiento cancelado con más datos
    echo "\n\nEJEMPLO 2: Requerimiento Cancelado (con más información)\n";
    echo str_repeat("-", 60) . "\n";
    $stmt = $pdo->query("
        SELECT r.*
        FROM publico.reqmultas r
        WHERE r.vigencia = 'C'
        AND r.obs IS NOT NULL
        AND r.feccit IS NOT NULL
        ORDER BY r.cvereq DESC
        LIMIT 1
    ");
    $ejemplo2Data = $stmt->fetch(PDO::FETCH_ASSOC);

    if ($ejemplo2Data) {
        $stmt2 = $pdo->prepare("SELECT * FROM publico.recaudadora_consreq400(?, 0, 0, 1)");
        $stmt2->execute([$ejemplo2Data['id_multa']]);
        $ejemplo2 = $stmt2->fetch(PDO::FETCH_ASSOC);

        if ($ejemplo2) {
            echo "📋 Clave Cuenta: {$ejemplo2['clave_cuenta']}\n";
            echo "   Ejercicio: {$ejemplo2['ejercicio']}\n";
            echo "   Folio: {$ejemplo2['folio']}\n";
            echo "   Estatus: {$ejemplo2['estatus']}\n";
            echo "   Fecha: {$ejemplo2['fecha']}\n";
            echo "   Vigencia: {$ejemplo2['vigreq']}\n";
            echo "   Fecha Cita: {$ejemplo2['feccita']}\n";
            if ($ejemplo2['horacit']) {
                echo "   Hora Cita: {$ejemplo2['horacit']}\n";
            }
            if ($ejemplo2['observr']) {
                echo "   Observaciones: " . substr($ejemplo2['observr'], 0, 60) . "\n";
            }
        }
    }

    // Ejemplo 3: Un requerimiento de un ejercicio específico (2020 o cercano)
    echo "\n\nEJEMPLO 3: Requerimiento de Ejercicio Específico\n";
    echo str_repeat("-", 60) . "\n";
    $stmt = $pdo->query("
        SELECT r.*
        FROM publico.reqmultas r
        WHERE r.axoreq BETWEEN 2018 AND 2022
        AND r.id_multa IS NOT NULL
        ORDER BY r.cvereq DESC
        LIMIT 1
    ");
    $ejemplo3Data = $stmt->fetch(PDO::FETCH_ASSOC);

    if ($ejemplo3Data) {
        $stmt3 = $pdo->prepare("SELECT * FROM publico.recaudadora_consreq400(?, 0, 0, 1)");
        $stmt3->execute([$ejemplo3Data['id_multa']]);
        $ejemplo3 = $stmt3->fetch(PDO::FETCH_ASSOC);

        if ($ejemplo3) {
            echo "📋 Clave Cuenta: {$ejemplo3['clave_cuenta']}\n";
            echo "   Ejercicio: {$ejemplo3['ejercicio']}\n";
            echo "   Folio: {$ejemplo3['folio']}\n";
            echo "   Estatus: {$ejemplo3['estatus']}\n";
            echo "   Fecha: {$ejemplo3['fecha']}\n";
            echo "   Vigencia: {$ejemplo3['vigreq']}\n";
            if ($ejemplo3['fecent1']) {
                echo "   Fecha Entrega 1: {$ejemplo3['fecent1']}\n";
            }
            if ($ejemplo3['fecpra']) {
                echo "   Fecha Práctica: {$ejemplo3['fecpra']}\n";
            }
        }
    }

    // Resumen para copiar/pegar
    echo "\n\n" . str_repeat("=", 60) . "\n";
    echo "RESUMEN - Valores para probar:\n";
    echo str_repeat("=", 60) . "\n\n";

    if ($ejemplo1) {
        echo "1. Clave Cuenta: {$ejemplo1['clave_cuenta']} (Ejercicio: {$ejemplo1['ejercicio']})\n";
    }
    if ($ejemplo2) {
        echo "2. Clave Cuenta: {$ejemplo2['clave_cuenta']} (Ejercicio: {$ejemplo2['ejercicio']})\n";
    }
    if ($ejemplo3) {
        echo "3. Clave Cuenta: {$ejemplo3['clave_cuenta']} (Ejercicio: {$ejemplo3['ejercicio']})\n";
    }

    echo "\n";

} catch (PDOException $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
    exit(1);
}

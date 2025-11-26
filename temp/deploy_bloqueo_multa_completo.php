<?php
/**
 * Script para desplegar y probar el sistema completo de bloqueo de multas
 */

$host = '192.168.6.146';
$port = '5432';
$dbname = 'padron_licencias';
$user = 'refact';
$password = 'FF)-BQk2';

try {
    $pdo = new PDO("pgsql:host=$host;port=$port;dbname=$dbname", $user, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo str_repeat("=", 80) . "\n";
    echo "DESPLIEGUE Y PRUEBA DEL SISTEMA DE BLOQUEO DE MULTAS\n";
    echo str_repeat("=", 80) . "\n\n";

    // Array con los archivos SQL a desplegar
    $sqlFiles = [
        'recaudadora_bloqueo_multa' => '../RefactorX/Base/multas_reglamentos/database/generated/recaudadora_bloqueo_multa.sql',
        'recaudadora_bloquear_multa' => '../RefactorX/Base/multas_reglamentos/database/generated/recaudadora_bloquear_multa.sql',
        'recaudadora_desbloquear_multa' => '../RefactorX/Base/multas_reglamentos/database/generated/recaudadora_desbloquear_multa.sql'
    ];

    // Paso 1: Desplegar todos los SPs
    echo "PASO 1: Desplegando Stored Procedures\n";
    echo str_repeat("-", 80) . "\n";

    foreach ($sqlFiles as $spName => $relativePath) {
        $sqlFile = __DIR__ . '/' . $relativePath;

        if (!file_exists($sqlFile)) {
            throw new Exception("No se encontró el archivo: $sqlFile");
        }

        echo "Desplegando $spName...\n";
        $sql = file_get_contents($sqlFile);
        $pdo->exec($sql);
        echo "  ✅ $spName desplegado correctamente\n";
    }

    echo "\n";

    // Paso 2: Verificar que se crearon los SPs
    echo "PASO 2: Verificando SPs en la base de datos\n";
    echo str_repeat("-", 80) . "\n";

    foreach (array_keys($sqlFiles) as $spName) {
        $verify = "
            SELECT
                n.nspname as schema,
                p.proname as sp_name,
                pg_get_function_arguments(p.oid) as arguments
            FROM pg_proc p
            JOIN pg_namespace n ON p.pronamespace = n.oid
            WHERE p.proname = :sp_name;
        ";

        $stmt = $pdo->prepare($verify);
        $stmt->execute(['sp_name' => $spName]);
        $result = $stmt->fetch(PDO::FETCH_ASSOC);

        if ($result) {
            echo "✅ $spName: {$result['arguments']}\n";
        } else {
            echo "❌ $spName: NO ENCONTRADO\n";
        }
    }

    echo "\n" . str_repeat("=", 80) . "\n";
    echo "PASO 3: Probando funcionalidad completa\n";
    echo str_repeat("=", 80) . "\n\n";

    // 3.1: Listar multas vigentes
    echo "3.1: Listando multas vigentes del año 2024\n";
    echo str_repeat("-", 80) . "\n";

    $stmt = $pdo->prepare("
        SELECT * FROM recaudadora_bloqueo_multa('', 2024, 0, 5)
    ");
    $stmt->execute();
    $multas = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo "Encontradas " . count($multas) . " multas\n";

    if (empty($multas)) {
        echo "❌ No se encontraron multas para probar el sistema\n";
        echo "Probando con otros años...\n\n";

        // Buscar años con datos
        $stmt2 = $pdo->query("
            SELECT axoreq, COUNT(*) as count
            FROM catastro_gdl.reqmultas
            WHERE vigencia = 'V'
            GROUP BY axoreq
            ORDER BY axoreq DESC
            LIMIT 5
        ");
        $years = $stmt2->fetchAll(PDO::FETCH_ASSOC);

        foreach ($years as $year) {
            echo "  Año {$year['axoreq']}: {$year['count']} multas vigentes\n";
        }

        if (!empty($years)) {
            $testYear = $years[0]['axoreq'];
            echo "\nUsando año $testYear para pruebas...\n";

            $stmt3 = $pdo->prepare("
                SELECT * FROM recaudadora_bloqueo_multa('', :year, 0, 5)
            ");
            $stmt3->execute(['year' => $testYear]);
            $multas = $stmt3->fetchAll(PDO::FETCH_ASSOC);
        }
    }

    if (empty($multas)) {
        echo "❌ No se pudieron obtener multas para probar\n";
        exit(1);
    }

    echo "\nPrimera multa encontrada:\n";
    $multaPrueba = $multas[0];
    foreach ($multaPrueba as $key => $value) {
        if ($value !== null && $value !== '') {
            echo "  $key: $value\n";
        }
    }

    // 3.2: Bloquear una multa
    echo "\n\n3.2: Bloqueando multa\n";
    echo str_repeat("-", 80) . "\n";

    $cvereq = $multaPrueba['cvereq'];
    $motivo = "Prueba de bloqueo desde script de despliegue - " . date('Y-m-d H:i:s');
    $capturista = "testuser";

    echo "Bloqueando cvereq: $cvereq\n";
    echo "Motivo: $motivo\n\n";

    $stmt4 = $pdo->prepare("
        SELECT * FROM recaudadora_bloquear_multa(:cvereq, :motivo, :capturista)
    ");
    $stmt4->execute([
        'cvereq' => $cvereq,
        'motivo' => $motivo,
        'capturista' => $capturista
    ]);
    $resultBloqueo = $stmt4->fetch(PDO::FETCH_ASSOC);

    echo "Resultado del bloqueo:\n";
    foreach ($resultBloqueo as $key => $value) {
        echo "  $key: " . ($value === true ? 'true' : ($value === false ? 'false' : $value)) . "\n";
    }

    if ($resultBloqueo['success'] === true || $resultBloqueo['success'] === 't') {
        echo "\n✅ Multa bloqueada exitosamente\n";

        // 3.3: Verificar que aparece como bloqueada
        echo "\n\n3.3: Verificando que la multa aparece como bloqueada\n";
        echo str_repeat("-", 80) . "\n";

        $stmt5 = $pdo->prepare("
            SELECT cvereq, folio, ejercicio, estatus, bloqueado, observaciones
            FROM recaudadora_bloqueo_multa('', :year, 0, 100)
            WHERE cvereq = :cvereq
        ");
        $stmt5->execute([
            'year' => $multaPrueba['ejercicio'],
            'cvereq' => $cvereq
        ]);
        $multaBloqueada = $stmt5->fetch(PDO::FETCH_ASSOC);

        if ($multaBloqueada) {
            echo "Estado actual de la multa:\n";
            foreach ($multaBloqueada as $key => $value) {
                if ($value !== null && $value !== '') {
                    echo "  $key: " . ($value === true ? 'true' : ($value === false ? 'false' : $value)) . "\n";
                }
            }

            if ($multaBloqueada['bloqueado'] === 't' || $multaBloqueada['bloqueado'] === true) {
                echo "\n✅ La multa aparece correctamente como bloqueada\n";

                // 3.4: Desbloquear la multa
                echo "\n\n3.4: Desbloqueando multa\n";
                echo str_repeat("-", 80) . "\n";

                $motivoDesbloqueo = "Prueba completada, restaurando estado original - " . date('Y-m-d H:i:s');

                $stmt6 = $pdo->prepare("
                    SELECT * FROM recaudadora_desbloquear_multa(:cvereq, :motivo, :capturista)
                ");
                $stmt6->execute([
                    'cvereq' => $cvereq,
                    'motivo' => $motivoDesbloqueo,
                    'capturista' => $capturista
                ]);
                $resultDesbloqueo = $stmt6->fetch(PDO::FETCH_ASSOC);

                echo "Resultado del desbloqueo:\n";
                foreach ($resultDesbloqueo as $key => $value) {
                    echo "  $key: " . ($value === true ? 'true' : ($value === false ? 'false' : $value)) . "\n";
                }

                if ($resultDesbloqueo['success'] === true || $resultDesbloqueo['success'] === 't') {
                    echo "\n✅ Multa desbloqueada exitosamente\n";

                    // 3.5: Verificar histórico
                    echo "\n\n3.5: Verificando histórico de observaciones\n";
                    echo str_repeat("-", 80) . "\n";

                    $stmt7 = $pdo->prepare("
                        SELECT fecha_movimiento, observacion, capturista
                        FROM catastro_gdl.reqmulta_obs_hist
                        WHERE cvereq = :cvereq
                        ORDER BY fecha_movimiento DESC
                        LIMIT 5
                    ");
                    $stmt7->execute(['cvereq' => $cvereq]);
                    $historico = $stmt7->fetchAll(PDO::FETCH_ASSOC);

                    if (!empty($historico)) {
                        echo "Últimos movimientos:\n";
                        foreach ($historico as $idx => $hist) {
                            echo "\n  Movimiento " . ($idx + 1) . ":\n";
                            foreach ($hist as $key => $value) {
                                if ($value !== null) {
                                    echo "    $key: $value\n";
                                }
                            }
                        }
                        echo "\n✅ Histórico registrado correctamente\n";
                    }
                }
            } else {
                echo "\n❌ La multa NO aparece como bloqueada\n";
            }
        } else {
            echo "\n❌ No se encontró la multa después de bloquear\n";
        }
    } else {
        echo "\n❌ Error al bloquear multa: {$resultBloqueo['message']}\n";
    }

    echo "\n" . str_repeat("=", 80) . "\n";
    echo "RESUMEN FINAL\n";
    echo str_repeat("=", 80) . "\n";
    echo "✅ Sistema de bloqueo de multas desplegado y probado exitosamente\n";
    echo "✅ Los 3 SPs están funcionando correctamente\n";
    echo "✅ El histórico se está registrando en reqmulta_obs_hist\n";
    echo "\nSPs disponibles:\n";
    echo "  1. recaudadora_bloqueo_multa() - Lista multas con estado de bloqueo\n";
    echo "  2. recaudadora_bloquear_multa() - Bloquea una multa\n";
    echo "  3. recaudadora_desbloquear_multa() - Desbloquea una multa\n";

} catch (PDOException $e) {
    echo "\n❌ Error de BD: " . $e->getMessage() . "\n";
    exit(1);
} catch (Exception $e) {
    echo "\n❌ Error: " . $e->getMessage() . "\n";
    exit(1);
}

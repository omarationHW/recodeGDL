<?php
// Script para forzar actualización del SP descmultampalfrm

$host = '192.168.6.146';
$dbname = 'multas_reglamentos';
$user = 'refact';
$password = 'FF)-BQk2';

try {
    $pdo = new PDO("pgsql:host=$host;dbname=$dbname", $user, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "Conectado exitosamente.\n\n";

    // 1. Verificar SP actual
    echo "1. Verificando SP actual...\n";
    $stmt = $pdo->query("
        SELECT pg_get_functiondef(p.oid) as definition
        FROM pg_proc p
        JOIN pg_namespace n ON p.pronamespace = n.oid
        WHERE p.proname = 'recaudadora_descmultampalfrm'
        AND n.nspname = 'publico'
    ");
    $result = $stmt->fetch(PDO::FETCH_ASSOC);

    if ($result) {
        $def = $result['definition'];
        if (strpos($def, 'descuentos_multa_municipal') !== false) {
            echo "   ⚠ SP actual usa tabla INCORRECTA (descuentos_multa_municipal)\n";
        } else if (strpos($def, 'descmultampal') !== false) {
            echo "   ✓ SP actual usa tabla CORRECTA (descmultampal)\n";
        } else {
            echo "   ? No se pudo determinar la tabla usada\n";
        }
    }

    // 2. Eliminar todas las versiones del SP
    echo "\n2. Eliminando todas las versiones anteriores del SP...\n";
    $pdo->exec("DROP FUNCTION IF EXISTS publico.recaudadora_descmultampalfrm(TEXT) CASCADE;");
    echo "   ✓ SP eliminado\n";

    // 3. Aplicar el nuevo SP
    echo "\n3. Creando nuevo SP con tabla correcta...\n";
    $sql = file_get_contents(__DIR__ . '/update_sp_recaudadora_descmultampalfrm.sql');
    $pdo->exec($sql);
    echo "   ✓ SP creado exitosamente\n";

    // 4. Verificar el nuevo SP
    echo "\n4. Verificando nuevo SP...\n";
    $stmt = $pdo->query("
        SELECT pg_get_functiondef(p.oid) as definition
        FROM pg_proc p
        JOIN pg_namespace n ON p.pronamespace = n.oid
        WHERE p.proname = 'recaudadora_descmultampalfrm'
        AND n.nspname = 'publico'
    ");
    $result = $stmt->fetch(PDO::FETCH_ASSOC);

    if ($result) {
        $def = $result['definition'];
        echo "   Primeras líneas del SP:\n";
        $lines = explode("\n", $def);
        foreach (array_slice($lines, 0, 15) as $line) {
            if (trim($line)) {
                echo "   " . substr($line, 0, 80) . "\n";
            }
        }

        if (strpos($def, 'public.descmultampal') !== false) {
            echo "\n   ✓✓✓ CONFIRMADO: SP usa tabla CORRECTA (public.descmultampal)\n";
        } else {
            echo "\n   ⚠ ADVERTENCIA: No se encontró referencia a public.descmultampal\n";
        }
    }

    // 5. Probar con una multa de ejemplo
    echo "\n\n5. Probando con multa de ejemplo...\n";
    $stmt = $pdo->query("
        SELECT id_multa FROM public.descmultampal LIMIT 1
    ");
    $multaTest = $stmt->fetchColumn();

    if ($multaTest) {
        echo "   Probando con multa: $multaTest\n";
        $stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_descmultampalfrm(?)");
        $stmt->execute([$multaTest]);
        $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);

        echo "   ✓ SP ejecutado correctamente\n";
        echo "   Resultados: " . count($rows) . " descuento(s)\n";

        if (count($rows) > 0) {
            $r = $rows[0];
            echo "   Datos: Tipo={$r['tipo_descto']}, Valor=\${$r['valor_descuento']}, Estado={$r['estado_desc']}\n";
        }
    }

    echo "\n\n✅ Actualización forzada completada!\n";
    echo "   El SP ahora usa: public.descmultampal\n";
    echo "   Reinicia tu backend Laravel para que tome los cambios.\n";

} catch (PDOException $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
    exit(1);
}

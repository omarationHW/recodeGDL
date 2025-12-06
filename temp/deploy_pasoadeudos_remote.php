<?php
/**
 * Despliegue de SPs corregidos de PasoAdeudos
 * Servidor remoto: 192.168.6.146
 */

echo "═══════════════════════════════════════════════════════════════\n";
echo " DESPLIEGUE DE SPs CORREGIDOS - PasoAdeudos\n";
echo "═══════════════════════════════════════════════════════════════\n\n";

try {
    // Conectar a la base mercados (donde deben estar los SPs)
    $pdo = new PDO(
        "pgsql:host=192.168.6.146;port=5432;dbname=mercados",
        "refact",
        "FF)-BQk2"
    );
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "✓ Conexión exitosa a mercados@192.168.6.146\n\n";

    // Leer el archivo SQL
    $sqlFile = __DIR__ . '/deploy_pasoadeudos_sps.sql';
    if (!file_exists($sqlFile)) {
        throw new Exception("No se encontró el archivo SQL");
    }

    $sql = file_get_contents($sqlFile);

    echo "📋 Archivo SQL cargado: " . strlen($sql) . " bytes\n";
    echo "📦 Desplegando 2 stored procedures...\n\n";

    // Ejecutar el SQL completo
    $pdo->exec($sql);

    echo "✅ SQL ejecutado exitosamente\n\n";

    // Verificar que los SPs fueron creados
    echo "🔍 Verificando stored procedures...\n\n";

    $stmt = $pdo->query("
        SELECT
            p.proname as nombre,
            n.nspname as schema,
            pg_get_function_arguments(p.oid) as argumentos
        FROM pg_proc p
        JOIN pg_namespace n ON p.pronamespace = n.oid
        WHERE p.proname IN ('sp_get_tianguis_locales', 'sp_insertar_adeudo_local')
        ORDER BY p.proname
    ");

    $sps = $stmt->fetchAll(PDO::FETCH_ASSOC);

    if (count($sps) === 2) {
        echo "✅ 2 Stored Procedures desplegados correctamente:\n\n";
        foreach ($sps as $sp) {
            echo "   ✓ {$sp['schema']}.{$sp['nombre']}\n";
            echo "     Argumentos: {$sp['argumentos']}\n\n";
        }
    } else {
        echo "⚠️  Solo se encontraron " . count($sps) . " stored procedures\n";
        foreach ($sps as $sp) {
            echo "   - {$sp['nombre']}\n";
        }
    }

    // Verificar que usan los schemas correctos
    echo "🔍 Verificando schemas usados...\n\n";

    $stmt = $pdo->query("
        SELECT
            p.proname,
            pg_get_functiondef(p.oid) as definicion
        FROM pg_proc p
        WHERE p.proname IN ('sp_get_tianguis_locales', 'sp_insertar_adeudo_local')
    ");

    $hasErrors = false;
    while ($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
        // Verificar que usa comun.ta_11_locales y NO ta_11_locales sin schema
        if (preg_match('/FROM\s+ta_11_/i', $row['definicion']) && !preg_match('/FROM\s+comun\.ta_11_/i', $row['definicion'])) {
            echo "   ❌ {$row['proname']} - AÚN usa tablas SIN schema\n";
            $hasErrors = true;
        } else if (strpos($row['definicion'], 'comun.ta_11_') !== false) {
            echo "   ✅ {$row['proname']} - Usa correctamente schema 'comun'\n";
        } else {
            echo "   ⚠️  {$row['proname']} - Verificar manualmente\n";
        }
    }

    if (!$hasErrors) {
        echo "\n═══════════════════════════════════════════════════════════════\n";
        echo " ✅ DESPLIEGUE COMPLETADO EXITOSAMENTE\n";
        echo "═══════════════════════════════════════════════════════════════\n\n";
        echo "📋 PRÓXIMOS PASOS:\n";
        echo "   1. Abrir el componente PasoAdeudos en el navegador\n";
        echo "   2. Seleccionar un año (ej: 2024)\n";
        echo "   3. Clic en 'Generar Adeudos'\n";
        echo "   4. Verificar que aparezcan los locales del tianguis\n";
        echo "   5. Los datos deben mostrarse correctamente en la tabla\n\n";
    } else {
        echo "\n⚠️  ADVERTENCIA: Algunos SPs aún tienen referencias incorrectas\n";
    }

} catch (PDOException $e) {
    echo "❌ Error de conexión/despliegue: " . $e->getMessage() . "\n";
    exit(1);
} catch (Exception $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
    exit(1);
}

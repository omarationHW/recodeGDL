<?php
/**
 * Despliegue de SPs corregidos de EnergiaModif
 * Servidor remoto: 192.168.6.146
 */

echo "═══════════════════════════════════════════════════════════════\n";
echo " DESPLIEGUE DE SPs CORREGIDOS - EnergiaModif\n";
echo "═══════════════════════════════════════════════════════════════\n\n";

try {
    $pdo = new PDO(
        "pgsql:host=192.168.6.146;port=5432;dbname=padron_licencias",
        "refact",
        "FF)-BQk2"
    );
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "✓ Conexión exitosa a padron_licencias@192.168.6.146\n\n";

    // Leer el archivo SQL
    $sqlFile = __DIR__ . '/deploy_energiamodif_sps_corregidos.sql';
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
        WHERE p.proname IN ('sp_energia_modif_buscar', 'sp_energia_modif_modificar')
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
    }

    // Verificar que NO tienen referencias cross-database
    echo "🔍 Verificando ausencia de referencias cross-database...\n\n";

    $stmt = $pdo->query("
        SELECT
            p.proname,
            pg_get_functiondef(p.oid) as definicion
        FROM pg_proc p
        WHERE p.proname IN ('sp_energia_modif_buscar', 'sp_energia_modif_modificar')
    ");

    $hasErrors = false;
    while ($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
        if (strpos($row['definicion'], 'padron_licencias.') !== false) {
            echo "   ❌ {$row['proname']} - AÚN TIENE referencias cross-database\n";
            $hasErrors = true;
        } else {
            echo "   ✅ {$row['proname']} - Sin referencias cross-database\n";
        }
    }

    if (!$hasErrors) {
        echo "\n═══════════════════════════════════════════════════════════════\n";
        echo " ✅ DESPLIEGUE COMPLETADO EXITOSAMENTE\n";
        echo "═══════════════════════════════════════════════════════════════\n\n";
        echo "📋 PRÓXIMOS PASOS:\n";
        echo "   1. Reiniciar el backend Laravel (si está corriendo)\n";
        echo "   2. Abrir el componente EnergiaModif en el navegador\n";
        echo "   3. Probar la búsqueda de un local\n";
        echo "   4. Verificar que no aparezca el error\n\n";
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

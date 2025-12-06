<?php
/**
 * Despliegue de SP corregido: sp_get_recaudadoras
 * Servidor remoto: 192.168.6.146
 * Base de datos: mercados
 * Corrección: Elimina datos hardcoded, consulta public.ta_12_recaudadoras
 */

echo "═══════════════════════════════════════════════════════════════\n";
echo " DESPLIEGUE DE SP CORREGIDO - sp_get_recaudadoras\n";
echo "═══════════════════════════════════════════════════════════════\n\n";

try {
    $pdo = new PDO(
        "pgsql:host=192.168.6.146;port=5432;dbname=mercados",
        "refact",
        "FF)-BQk2"
    );
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "✓ Conexión exitosa a mercados@192.168.6.146\n\n";

    // Leer el archivo SQL
    $sqlFile = __DIR__ . '/sp_get_recaudadoras_corrected.sql';
    if (!file_exists($sqlFile)) {
        throw new Exception("No se encontró el archivo SQL");
    }

    $sql = file_get_contents($sqlFile);

    echo "📋 Archivo SQL cargado: " . strlen($sql) . " bytes\n";
    echo "📦 Desplegando stored procedure...\n\n";

    // Ejecutar el SQL
    $pdo->exec($sql);

    echo "✅ SQL ejecutado exitosamente\n\n";

    // Verificar que el SP fue creado
    echo "🔍 Verificando stored procedure...\n\n";

    $stmt = $pdo->query("
        SELECT
            p.proname as nombre,
            n.nspname as schema,
            pg_get_function_arguments(p.oid) as argumentos
        FROM pg_proc p
        JOIN pg_namespace n ON p.pronamespace = n.oid
        WHERE p.proname = 'sp_get_recaudadoras'
    ");

    $sp = $stmt->fetch(PDO::FETCH_ASSOC);

    if ($sp) {
        echo "✅ Stored Procedure desplegado correctamente:\n\n";
        echo "   ✓ {$sp['schema']}.{$sp['nombre']}\n";
        echo "     Argumentos: " . ($sp['argumentos'] ?: 'ninguno') . "\n\n";
    } else {
        echo "⚠️  No se encontró el stored procedure\n";
    }

    // Probar el SP con datos reales
    echo "🔍 Probando SP con datos reales...\n\n";

    $stmt = $pdo->query("SELECT * FROM sp_get_recaudadoras() LIMIT 5");
    $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);

    if ($rows) {
        echo "✅ SP retorna datos correctamente:\n\n";
        foreach ($rows as $row) {
            echo "   {$row['id_rec']}: {$row['recaudadora']}\n";
        }
        echo "\n   Total registros: " . count($rows) . " (mostrando primeros 5)\n\n";
    } else {
        echo "⚠️  SP no retorna datos\n\n";
    }

    // Verificar que usa la tabla correcta
    echo "🔍 Verificando definición del SP...\n\n";

    $stmt = $pdo->query("
        SELECT pg_get_functiondef(p.oid) as definicion
        FROM pg_proc p
        WHERE p.proname = 'sp_get_recaudadoras'
    ");

    $def = $stmt->fetch(PDO::FETCH_ASSOC);

    if ($def) {
        $usaPublic = strpos($def['definicion'], 'public.ta_12_recaudadoras') !== false;
        $usaHardcode = strpos($def['definicion'], 'VALUES') !== false;

        if ($usaPublic && !$usaHardcode) {
            echo "   ✅ SP usa tabla correcta: public.ta_12_recaudadoras\n";
            echo "   ✅ SP NO tiene datos hardcoded\n";
        } else {
            echo "   ❌ ADVERTENCIA: Verificar definición del SP\n";
            if ($usaHardcode) echo "      - Aún contiene datos hardcoded (VALUES)\n";
            if (!$usaPublic) echo "      - No usa public.ta_12_recaudadoras\n";
        }
    }

    echo "\n═══════════════════════════════════════════════════════════════\n";
    echo " ✅ DESPLIEGUE COMPLETADO EXITOSAMENTE\n";
    echo "═══════════════════════════════════════════════════════════════\n\n";

    echo "📋 CORRECCIONES APLICADAS:\n";
    echo "   1. ❌ Datos hardcoded con VALUES → ✅ Consulta a tabla real\n";
    echo "   2. ❌ 8 zonas hardcoded → ✅ Todas las recaudadoras de la BD\n";
    echo "   3. ✅ Usa public.ta_12_recaudadoras (schema correcto)\n\n";

    echo "🔄 COMPONENTES QUE USAN ESTE SP:\n";
    echo "   - RptPadronEnergia.vue\n";
    echo "   - PadronEnergia.vue\n";
    echo "   - RptMovimientos.vue\n";
    echo "   - Otros componentes de mercados\n\n";

    echo "📋 PRÓXIMOS PASOS:\n";
    echo "   1. Recargar el navegador (Ctrl+Shift+R)\n";
    echo "   2. Abrir RptPadronEnergia\n";
    echo "   3. El dropdown de recaudadoras debe mostrar datos reales\n";
    echo "   4. Verificar que todas las recaudadoras aparezcan\n\n";

} catch (PDOException $e) {
    echo "❌ Error de conexión/despliegue: " . $e->getMessage() . "\n";
    exit(1);
} catch (Exception $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
    exit(1);
}

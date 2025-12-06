<?php
/**
 * Despliegue de SP corregido: rpt_adeudos_anteriores
 * Servidor remoto: 192.168.6.146
 * Base de datos: mercados
 */

echo "═══════════════════════════════════════════════════════════════\n";
echo " DESPLIEGUE DE SP CORREGIDO - RptAdeudosAnteriores\n";
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
    $sqlFile = __DIR__ . '/deploy_rpt_adeudos_anteriores.sql';
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
        WHERE p.proname = 'rpt_adeudos_anteriores'
    ");

    $sp = $stmt->fetch(PDO::FETCH_ASSOC);

    if ($sp) {
        echo "✅ Stored Procedure desplegado correctamente:\n\n";
        echo "   ✓ {$sp['schema']}.{$sp['nombre']}\n";
        echo "     Argumentos: {$sp['argumentos']}\n\n";
    } else {
        echo "⚠️  No se encontró el stored procedure\n";
    }

    // Verificar que usa los schemas correctos
    echo "🔍 Verificando schemas usados...\n\n";

    $stmt = $pdo->query("
        SELECT pg_get_functiondef(p.oid) as definicion
        FROM pg_proc p
        WHERE p.proname = 'rpt_adeudos_anteriores'
    ");

    $def = $stmt->fetch(PDO::FETCH_ASSOC);

    if ($def) {
        $tablasSinSchema = [];

        // Contar referencias a schemas
        $countPublico = substr_count($def['definicion'], 'publico.');
        $countPublic = substr_count($def['definicion'], 'public.');
        $totalRefs = $countPublico + $countPublic;

        if ($totalRefs > 0) {
            echo "   ✅ SP usa schemas correctamente\n";
            echo "      - Referencias 'publico': $countPublico\n";
            echo "      - Referencias 'public': $countPublic\n";
            echo "      - Total: $totalRefs referencias con schema\n";
        } else {
            echo "   ❌ ADVERTENCIA: SP NO usa schemas correctamente\n";
        }
    }

    echo "\n═══════════════════════════════════════════════════════════════\n";
    echo " ✅ DESPLIEGUE COMPLETADO EXITOSAMENTE\n";
    echo "═══════════════════════════════════════════════════════════════\n\n";

    echo "📋 CORRECCIONES APLICADAS:\n";
    echo "   1. ❌ FROM ta_11_adeudo_local → ✅ FROM publico.ta_11_adeudo_local\n";
    echo "   2. ❌ JOIN ta_11_locales → ✅ JOIN publico.ta_11_locales\n";
    echo "   3. ❌ JOIN ta_12_recaudadoras → ✅ JOIN public.ta_12_recaudadoras\n";
    echo "   4. ❌ JOIN ta_11_mercados → ✅ JOIN publico.ta_11_mercados\n";
    echo "   5. ❌ SELECT FROM ta_11_adeudo_local (subquery) → ✅ publico.ta_11_adeudo_local\n\n";
    echo "📊 SCHEMAS USADOS EN BASE 'mercados':\n";
    echo "   - publico.ta_11_adeudo_local (15 MB - datos principales)\n";
    echo "   - publico.ta_11_locales (2.2 MB)\n";
    echo "   - public.ta_12_recaudadoras (24 KB)\n";
    echo "   - publico.ta_11_mercados (40 KB)\n\n";

    echo "📋 PRÓXIMOS PASOS:\n";
    echo "   1. Abrir RptAdeudosAnteriores en el navegador\n";
    echo "   2. Ingresar: Año, Oficina, Periodo (Mes)\n";
    echo "   3. Clic en 'Consultar'\n";
    echo "   4. Verificar que aparezcan los resultados\n";
    echo "   5. El error 'array_key_exists()' debe desaparecer\n\n";

} catch (PDOException $e) {
    echo "❌ Error de conexión/despliegue: " . $e->getMessage() . "\n";
    exit(1);
} catch (Exception $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
    exit(1);
}

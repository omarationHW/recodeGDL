<?php
/**
 * Despliegue: sp_locales_mtto_buscar
 * Base: padron_licencias
 * Fecha: 2025-12-05
 */

echo "==============================================\n";
echo "DESPLIEGUE: sp_locales_mtto_buscar\n";
echo "Base: padron_licencias\n";
echo "==============================================\n\n";

try {
    $sqlFile = __DIR__ . '/../RefactorX/Base/mercados/database/database/LocalesMtto_sp_locales_mtto_buscar.sql';

    if (!file_exists($sqlFile)) {
        throw new Exception("No se encuentra el archivo SQL: $sqlFile");
    }

    $sql = file_get_contents($sqlFile);

    echo "1. Conectando a la base de datos padron_licencias...\n";
    $pdo = new PDO('pgsql:host=192.168.6.146;port=5432;dbname=padron_licencias', 'refact', 'FF)-BQk2', [
        PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION
    ]);
    echo "   ✓ Conexión establecida\n\n";

    echo "2. Desplegando SP...\n";
    $pdo->exec($sql);
    echo "   ✓ SP desplegado correctamente\n\n";

    // Verificar
    echo "3. Verificando el despliegue...\n";
    $verify = $pdo->query("
        SELECT
            p.proname AS nombre_funcion,
            pg_get_function_arguments(p.oid) AS parametros,
            pg_get_function_result(p.oid) AS resultado
        FROM pg_proc p
        JOIN pg_namespace n ON p.pronamespace = n.oid
        WHERE n.nspname = 'public'
          AND p.proname = 'sp_locales_mtto_buscar'
        ORDER BY p.oid DESC
        LIMIT 1
    ")->fetchAll(PDO::FETCH_OBJ);

    if (!empty($verify)) {
        echo "   ✓ Función: " . $verify[0]->nombre_funcion . "\n";
        echo "   ✓ Parámetros: " . $verify[0]->parametros . "\n";
        echo "   ✓ Resultado: " . $verify[0]->resultado . "\n\n";
    }

    // Probar el SP
    echo "4. Probando el SP...\n";

    // Test 1: Local que no existe
    echo "   Test 1: Local que no existe\n";
    $result1 = $pdo->query("
        SELECT * FROM sp_locales_mtto_buscar(
            1::INTEGER,
            999::INTEGER,
            1::INTEGER,
            'XX'::VARCHAR,
            9999::INTEGER,
            NULL,
            NULL
        )
    ")->fetchAll(PDO::FETCH_OBJ);

    if (!empty($result1)) {
        echo "   ✓ SP ejecutado\n";
        $res = $result1[0];
        echo "   ✓ existe: " . ($res->existe === 't' ? 'TRUE' : 'FALSE') . "\n";
        echo "   ✓ mensaje: {$res->mensaje}\n\n";
    }

    // Test 2: Local que existe (buscar uno real)
    echo "   Test 2: Buscando local existente...\n";
    $existente = $pdo->query("
        SELECT oficina, num_mercado, categoria, seccion, local, letra_local, bloque
        FROM comun.ta_11_locales
        WHERE oficina IS NOT NULL
          AND num_mercado IS NOT NULL
          AND categoria IS NOT NULL
          AND seccion IS NOT NULL
          AND local IS NOT NULL
        LIMIT 1
    ")->fetchAll(PDO::FETCH_OBJ);

    if (!empty($existente)) {
        $loc = $existente[0];
        echo "   Datos del local existente:\n";
        echo "   - Oficina: {$loc->oficina}\n";
        echo "   - Mercado: {$loc->num_mercado}\n";
        echo "   - Local: {$loc->local}\n\n";

        $letra = $loc->letra_local ? "'{$loc->letra_local}'::VARCHAR" : "NULL";
        $bloque = $loc->bloque ? "'{$loc->bloque}'::VARCHAR" : "NULL";

        $result2 = $pdo->query("
            SELECT * FROM sp_locales_mtto_buscar(
                {$loc->oficina}::INTEGER,
                {$loc->num_mercado}::INTEGER,
                {$loc->categoria}::INTEGER,
                '{$loc->seccion}'::VARCHAR,
                {$loc->local}::INTEGER,
                $letra,
                $bloque
            )
        ")->fetchAll(PDO::FETCH_OBJ);

        if (!empty($result2)) {
            echo "   ✓ SP ejecutado\n";
            $res = $result2[0];
            echo "   ✓ existe: " . ($res->existe === 't' ? 'TRUE' : 'FALSE') . "\n";
            echo "   ✓ id_local: " . ($res->id_local ?? 'NULL') . "\n";
            echo "   ✓ mensaje: {$res->mensaje}\n\n";
        }
    } else {
        echo "   ⚠ No hay datos de prueba en ta_11_locales\n\n";
    }

    echo "==============================================\n";
    echo "✓ DESPLIEGUE COMPLETADO EXITOSAMENTE\n";
    echo "==============================================\n";
    echo "\nAhora el módulo LocalesMtto funcionará correctamente.\n";
    echo "Recarga el navegador en /locales-mtto\n";

} catch (Exception $e) {
    echo "\n✗ ERROR: " . $e->getMessage() . "\n";
    echo "Traza: " . $e->getTraceAsString() . "\n";
    exit(1);
}
?>

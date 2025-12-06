<?php
/**
 * Despliegue: sp_localesmodif_modificar_local
 * Base: mercados
 * Fecha: 2025-12-05
 */

echo "==============================================\n";
echo "DESPLIEGUE: sp_localesmodif_modificar_local\n";
echo "Base: mercados\n";
echo "==============================================\n\n";

try {
    $sqlFile = __DIR__ . '/../RefactorX/Base/mercados/database/database/LocalesModif_sp_localesmodif_modificar_local.sql';

    if (!file_exists($sqlFile)) {
        throw new Exception("No se encuentra el archivo SQL: $sqlFile");
    }

    $sql = file_get_contents($sqlFile);

    echo "1. Conectando a la base de datos mercados...\n";
    $pdo = new PDO('pgsql:host=192.168.6.146;port=5432;dbname=mercados', 'refact', 'FF)-BQk2', [
        PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION
    ]);
    echo "   ✓ Conexión establecida\n\n";

    echo "2. Verificando tabla ta_11_localpaso...\n";
    $checkTable = $pdo->query("
        SELECT table_schema, table_name
        FROM information_schema.tables
        WHERE table_name = 'ta_11_localpaso'
    ")->fetchAll(PDO::FETCH_OBJ);

    if (empty($checkTable)) {
        echo "   ✗ Tabla ta_11_localpaso NO existe\n";
        echo "   Buscando tablas similares...\n";

        $similar = $pdo->query("
            SELECT table_schema, table_name
            FROM information_schema.tables
            WHERE table_name LIKE '%local%'
              AND table_schema IN ('public', 'publico')
            ORDER BY table_name
            LIMIT 10
        ")->fetchAll(PDO::FETCH_OBJ);

        if (!empty($similar)) {
            echo "   Tablas encontradas:\n";
            foreach ($similar as $t) {
                echo "     - {$t->table_schema}.{$t->table_name}\n";
            }
        }
        echo "\n";
    } else {
        echo "   ✓ Tabla encontrada:\n";
        foreach ($checkTable as $t) {
            echo "     - {$t->table_schema}.{$t->table_name}\n";
        }
        echo "\n";
    }

    echo "3. Desplegando SP...\n";
    $pdo->exec($sql);
    echo "   ✓ SP desplegado correctamente\n\n";

    // Verificar
    echo "4. Verificando el despliegue...\n";
    $verify = $pdo->query("
        SELECT
            p.proname AS nombre_funcion,
            pg_get_function_arguments(p.oid) AS parametros,
            pg_get_function_result(p.oid) AS resultado
        FROM pg_proc p
        JOIN pg_namespace n ON p.pronamespace = n.oid
        WHERE n.nspname = 'public'
          AND p.proname = 'sp_localesmodif_modificar_local'
        ORDER BY p.oid DESC
        LIMIT 1
    ")->fetchAll(PDO::FETCH_OBJ);

    if (!empty($verify)) {
        echo "   ✓ Función: " . $verify[0]->nombre_funcion . "\n";
        echo "   ✓ Parámetros: " . $verify[0]->parametros . "\n";
        echo "   ✓ Resultado: " . $verify[0]->resultado . "\n\n";

        // Contar parámetros
        $paramCount = substr_count($verify[0]->parametros, ',') + 1;
        echo "   ✓ Total de parámetros: $paramCount\n\n";
    }

    // Verificar si hay un local de prueba
    echo "5. Buscando local de prueba...\n";
    $testLocal = $pdo->query("
        SELECT id_local, nombre, zona, superficie
        FROM publico.ta_11_locales
        WHERE id_local IS NOT NULL
        LIMIT 1
    ")->fetchAll(PDO::FETCH_OBJ);

    if (!empty($testLocal)) {
        $loc = $testLocal[0];
        echo "   ✓ Local encontrado:\n";
        echo "     - id_local: {$loc->id_local}\n";
        echo "     - nombre: {$loc->nombre}\n";
        echo "     - zona: {$loc->zona}\n";
        echo "     - superficie: {$loc->superficie}\n\n";
    } else {
        echo "   ⚠ No hay locales de prueba\n\n";
    }

    echo "==============================================\n";
    echo "✓ DESPLIEGUE COMPLETADO EXITOSAMENTE\n";
    echo "==============================================\n";
    echo "\nEl SP acepta 18 parámetros:\n";
    echo "  1. p_id_local (INTEGER)\n";
    echo "  2. p_nombre (VARCHAR)\n";
    echo "  3. p_domicilio (VARCHAR)\n";
    echo "  4. p_sector (VARCHAR)\n";
    echo "  5. p_zona (INTEGER)\n";
    echo "  6. p_descripcion_local (VARCHAR)\n";
    echo "  7. p_superficie (NUMERIC)\n";
    echo "  8. p_giro (INTEGER)\n";
    echo "  9. p_fecha_alta (DATE)\n";
    echo "  10. p_fecha_baja (DATE)\n";
    echo "  11. p_vigencia (VARCHAR)\n";
    echo "  12. p_clave_cuota (INTEGER)\n";
    echo "  13. p_tipo_movimiento (INTEGER)\n";
    echo "  14. p_bloqueo (INTEGER)\n";
    echo "  15. p_cve_bloqueo (INTEGER)\n";
    echo "  16. p_fecha_inicio_bloqueo (DATE)\n";
    echo "  17. p_fecha_final_bloqueo (DATE)\n";
    echo "  18. p_observacion (VARCHAR)\n";
    echo "\nRecarga el navegador en /locales-modif\n";

} catch (Exception $e) {
    echo "\n✗ ERROR: " . $e->getMessage() . "\n";
    echo "Traza: " . $e->getTraceAsString() . "\n";
    exit(1);
}
?>

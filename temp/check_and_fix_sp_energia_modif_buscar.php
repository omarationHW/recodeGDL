<?php
// Script para verificar y corregir sp_energia_modif_buscar

try {
    $pdo = new PDO(
        "pgsql:host=localhost;port=5432;dbname=padron_licencias",
        "postgres",
        "postgres"
    );
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "✓ Conexión exitosa a padron_licencias\n\n";

    // 1. Verificar si el SP existe
    echo "1. Verificando si sp_energia_modif_buscar existe...\n";
    $stmt = $pdo->query("
        SELECT
            p.proname,
            pg_get_function_arguments(p.oid) as args,
            n.nspname as schema_name
        FROM pg_proc p
        JOIN pg_namespace n ON p.pronamespace = n.oid
        WHERE p.proname = 'sp_energia_modif_buscar'
    ");

    $exists = $stmt->fetch(PDO::FETCH_ASSOC);
    if ($exists) {
        echo "   ✓ SP existe en schema: {$exists['schema_name']}\n";
        echo "   Argumentos: {$exists['args']}\n\n";
    } else {
        echo "   ✗ SP NO existe\n\n";
    }

    // 2. Desplegar el SP corregido
    echo "2. Desplegando SP corregido...\n";

    $sql_corregido = "
-- Stored Procedure: sp_energia_modif_buscar
-- Tipo: CRUD
-- Descripción: Busca el registro de energía para un local específico
-- Corregido: 2025-12-04 - Eliminar referencias cross-database

DROP FUNCTION IF EXISTS public.sp_energia_modif_buscar(integer, integer, integer, varchar, integer, varchar, varchar);

CREATE OR REPLACE FUNCTION public.sp_energia_modif_buscar(
    p_oficina INTEGER,
    p_num_mercado INTEGER,
    p_categoria INTEGER,
    p_seccion VARCHAR,
    p_local INTEGER,
    p_letra_local VARCHAR,
    p_bloque VARCHAR
)
RETURNS TABLE (
    id_energia INTEGER,
    id_local INTEGER,
    cve_consumo VARCHAR,
    local_adicional VARCHAR,
    cantidad NUMERIC,
    vigencia VARCHAR,
    fecha_alta DATE,
    fecha_baja DATE,
    fecha_modificacion TIMESTAMP,
    id_usuario INTEGER
)
LANGUAGE plpgsql
STABLE
AS \$\$
BEGIN
    RETURN QUERY
    SELECT
        e.id_energia,
        e.id_local,
        e.cve_consumo::VARCHAR,
        e.local_adicional::VARCHAR,
        e.cantidad,
        e.vigencia::VARCHAR,
        e.fecha_alta,
        e.fecha_baja,
        e.fecha_modificacion,
        e.id_usuario
    FROM comun.ta_11_locales l
    INNER JOIN db_ingresos.ta_11_energia e
        ON l.id_local = e.id_local
    WHERE l.oficina = p_oficina
      AND l.num_mercado = p_num_mercado
      AND l.categoria = p_categoria
      AND l.seccion = p_seccion
      AND l.local = p_local
      AND (l.letra_local IS NOT DISTINCT FROM p_letra_local)
      AND (l.bloque IS NOT DISTINCT FROM p_bloque)
    LIMIT 1;
END;
\$\$;

COMMENT ON FUNCTION public.sp_energia_modif_buscar(INTEGER, INTEGER, INTEGER, VARCHAR, INTEGER, VARCHAR, VARCHAR) IS
'Busca el registro de energía para un local específico';
";

    $pdo->exec($sql_corregido);
    echo "   ✓ SP desplegado correctamente en schema public\n\n";

    // 3. Verificar que quedó bien creado
    echo "3. Verificando resultado final...\n";
    $stmt = $pdo->query("
        SELECT
            p.proname,
            pg_get_function_arguments(p.oid) as args,
            n.nspname as schema_name,
            pg_get_functiondef(p.oid) as definition
        FROM pg_proc p
        JOIN pg_namespace n ON p.pronamespace = n.oid
        WHERE p.proname = 'sp_energia_modif_buscar'
    ");

    $result = $stmt->fetch(PDO::FETCH_ASSOC);
    if ($result) {
        echo "   ✓ SP verificado en schema: {$result['schema_name']}\n";
        echo "   Argumentos: {$result['args']}\n";

        // Verificar que no tenga referencias cross-database
        if (strpos($result['definition'], 'padron_licencias.comun') === false) {
            echo "   ✓ Sin referencias cross-database incorrectas\n";
        } else {
            echo "   ✗ ADVERTENCIA: Aún tiene referencias cross-database\n";
        }
    }

    echo "\n✅ PROCESO COMPLETADO\n";

} catch (PDOException $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
    exit(1);
}

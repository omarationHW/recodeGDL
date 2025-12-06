<?php
/**
 * Deploy SP para PadronLocales - v2 con esquemas correctos
 */

$host = '192.168.6.146';
$port = '5432';
$dbname = 'padron_licencias';
$user = 'refact';
$password = 'FF)-BQk2';

try {
    $pdo = new PDO("pgsql:host=$host;port=$port;dbname=$dbname", $user, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "Conectado a $dbname\n\n";

    // Drop y crear SP con esquemas correctos
    echo "=== Desplegando sp_get_padron_locales ===\n";
    $pdo->exec("DROP FUNCTION IF EXISTS public.sp_get_padron_locales(INTEGER)");

    $pdo->exec("
    CREATE OR REPLACE FUNCTION public.sp_get_padron_locales(p_recaudadora INTEGER)
    RETURNS TABLE (
        id_local INTEGER,
        oficina INTEGER,
        num_mercado INTEGER,
        categoria INTEGER,
        seccion VARCHAR,
        local INTEGER,
        letra_local VARCHAR,
        bloque VARCHAR,
        nombre VARCHAR,
        superficie NUMERIC,
        clave_cuota INTEGER,
        descripcion VARCHAR,
        renta NUMERIC
    ) AS \$\$
    BEGIN
        RETURN QUERY
        SELECT
            a.id_local::INTEGER,
            a.oficina::INTEGER,
            a.num_mercado::INTEGER,
            a.categoria::INTEGER,
            a.seccion::VARCHAR,
            a.local::INTEGER,
            a.letra_local::VARCHAR,
            a.bloque::VARCHAR,
            a.nombre::VARCHAR,
            a.superficie::NUMERIC,
            a.clave_cuota::INTEGER,
            b.descripcion::VARCHAR,
            CASE
                WHEN a.seccion = 'PS' THEN a.superficie * COALESCE(c.importe_cuota, 0) * 30
                ELSE a.superficie * COALESCE(c.importe_cuota, 0)
            END::NUMERIC AS renta
        FROM comun.ta_11_locales a
        JOIN comun.ta_11_mercados b ON a.oficina = b.oficina AND a.num_mercado = b.num_mercado_nvo
        LEFT JOIN db_ingresos.ta_11_cuo_locales c ON c.axo = EXTRACT(YEAR FROM CURRENT_DATE)::INTEGER
            AND c.categoria = a.categoria
            AND c.seccion = a.seccion
            AND c.clave_cuota = a.clave_cuota
        WHERE a.oficina = p_recaudadora
          AND a.vigencia = 'A'
        ORDER BY a.oficina, a.num_mercado, a.categoria, a.seccion, a.local, a.letra_local, a.bloque;
    END;
    \$\$ LANGUAGE plpgsql;
    ");

    echo "sp_get_padron_locales creado\n";

    // Test
    echo "\n=== Test ===\n";
    $stmt = $pdo->query("SELECT * FROM sp_get_padron_locales(1) LIMIT 5");
    $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);
    echo "Registros encontrados: " . count($rows) . "\n";
    foreach ($rows as $row) {
        echo "  Local {$row['id_local']}: {$row['nombre']} - Renta: {$row['renta']}\n";
    }

} catch (PDOException $e) {
    echo "ERROR: " . $e->getMessage() . "\n";
    exit(1);
}

echo "\nSP desplegado correctamente!\n";

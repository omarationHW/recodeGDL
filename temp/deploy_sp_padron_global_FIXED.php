<?php
// Desplegar SP padron_global corregido

$conn = pg_connect("host=192.168.6.146 port=5432 dbname=mercados user=refact password=FF)-BQk2");

if (!$conn) {
    echo "❌ Error de conexión\n";
    exit(1);
}

echo "=== DESPLEGANDO SP_PADRON_GLOBAL CORREGIDO ===\n\n";

// Eliminar función existente
echo "1. Eliminando función existente...\n";

$drop_public = "DROP FUNCTION IF EXISTS public.sp_padron_global(integer, integer, varchar) CASCADE;";
$drop_publico = "DROP FUNCTION IF EXISTS publico.sp_padron_global(integer, integer, varchar) CASCADE;";

pg_query($conn, $drop_public);
pg_query($conn, $drop_publico);

echo "   ✅ Funciones eliminadas\n\n";

// Crear función corregida en schema public
echo "2. Creando función corregida...\n";

$sp = "
CREATE OR REPLACE FUNCTION sp_padron_global(
    p_year integer,
    p_month integer,
    p_status varchar
)
RETURNS TABLE (
    id_local integer,
    oficina smallint,
    num_mercado smallint,
    categoria smallint,
    seccion varchar,
    letra_local varchar,
    bloque varchar,
    nombre varchar,
    descripcion_local varchar,
    superficie numeric,
    vigencia varchar,
    clave_cuota smallint,
    descripcion varchar,
    renta numeric,
    leyenda varchar,
    adeudo integer,
    registro varchar
) AS \$\$
BEGIN
    RETURN QUERY
    SELECT
        l.id_local,
        l.oficina,
        l.num_mercado,
        l.categoria,
        TRIM(l.seccion)::varchar AS seccion,
        l.letra_local,
        l.bloque,
        l.nombre,
        TRIM(l.descripcion_local)::varchar AS descripcion_local,
        l.superficie,
        TRIM(l.vigencia)::varchar AS vigencia,
        l.clave_cuota,
        m.descripcion,
        -- Cálculo de renta
        CASE
            WHEN l.seccion = 'PS' AND l.clave_cuota = 4 THEN (l.superficie * COALESCE(c.importe_cuota, 0))
            WHEN l.seccion = 'PS' THEN ((COALESCE(c.importe_cuota, 0) * l.superficie) * 30)
            WHEN l.num_mercado = 214 THEN ((l.superficie * COALESCE(c.importe_cuota, 0)) * COALESCE(fd.sabadosacum, 1))
            ELSE (l.superficie * COALESCE(c.importe_cuota, 0))
        END AS renta,
        -- Leyenda y adeudo
        CASE
            WHEN COALESCE(a.adeudos, 0) >= 1 THEN 'Local con Adeudo'::varchar
            ELSE 'Local al Corriente de Pagos'::varchar
        END AS leyenda,
        CASE
            WHEN COALESCE(a.adeudos, 0) >= 1 THEN 1
            ELSE 0
        END AS adeudo,
        -- Registro
        (l.oficina::TEXT || ' ' || l.num_mercado::TEXT || ' ' || l.categoria::TEXT || ' ' ||
         TRIM(l.seccion) || ' ' || l.local::TEXT || ' ' || COALESCE(l.letra_local, '') || ' ' ||
         COALESCE(l.bloque, ''))::varchar AS registro
    FROM publico.ta_11_locales l
    INNER JOIN publico.ta_11_mercados m
        ON l.oficina = m.oficina
        AND l.num_mercado = m.num_mercado_nvo
    LEFT JOIN publico.ta_11_cuo_locales c
        ON c.axo = p_year
        AND c.categoria = l.categoria
        AND TRIM(c.seccion) = TRIM(l.seccion)
        AND c.clave_cuota = l.clave_cuota
    LEFT JOIN (
        SELECT ade.id_local, COUNT(*)::INTEGER AS adeudos
        FROM publico.ta_11_adeudo_local ade
        WHERE (ade.axo = p_year AND ade.periodo <= p_month) OR (ade.axo < p_year)
        GROUP BY ade.id_local
    ) a ON a.id_local = l.id_local
    LEFT JOIN publico.ta_11_fecha_desc fd
        ON fd.mes = p_month
    WHERE (p_status = 'T' OR TRIM(l.vigencia) = p_status)
    ORDER BY TRIM(l.vigencia), l.oficina, l.num_mercado, l.categoria, l.seccion, l.local, l.letra_local, l.bloque;
END;
\$\$ LANGUAGE plpgsql;
";

if (pg_query($conn, $sp)) {
    echo "   ✅ Función creada exitosamente\n\n";
} else {
    echo "   ❌ Error al crear función: " . pg_last_error($conn) . "\n\n";
    pg_close($conn);
    exit(1);
}

// Verificar despliegue
echo "3. Verificando despliegue...\n";

$verify = "
    SELECT
        n.nspname as schema,
        p.proname as function_name,
        pg_get_function_arguments(p.oid) as arguments
    FROM pg_proc p
    JOIN pg_namespace n ON p.pronamespace = n.oid
    WHERE p.proname = 'sp_padron_global'
    ORDER BY n.nspname;
";

$result = pg_query($conn, $verify);

if ($result && pg_num_rows($result) > 0) {
    echo "   ✅ SP desplegado correctamente:\n";
    while ($row = pg_fetch_assoc($result)) {
        echo "      {$row['schema']}.{$row['function_name']}({$row['arguments']})\n";
    }
} else {
    echo "   ❌ SP no encontrado\n";
}

echo "\n" . str_repeat("=", 80) . "\n";
echo "=== PROBANDO SP CON DATOS ===\n\n";

$year = date('Y');
$month = date('n');
$status = 'A';

echo "Parámetros: year=$year, month=$month, status='$status'\n\n";

$test = "SELECT * FROM sp_padron_global($year, $month, '$status') LIMIT 5";
$test_result = pg_query($conn, $test);

if ($test_result) {
    $count = pg_num_rows($test_result);
    echo "✅ SP ejecutado correctamente: $count registros\n\n";

    if ($count > 0) {
        echo "Primeros 5 locales:\n";
        echo str_repeat("-", 120) . "\n";
        while ($row = pg_fetch_assoc($test_result)) {
            echo sprintf(
                "ID: %-5s | Registro: %-30s | Nombre: %-30s | Renta: $%10s | %s\n",
                $row['id_local'],
                $row['registro'],
                substr($row['nombre'], 0, 30),
                number_format($row['renta'], 2),
                $row['leyenda']
            );
        }
    }
} else {
    echo "❌ Error al ejecutar SP: " . pg_last_error($conn) . "\n";
}

pg_close($conn);

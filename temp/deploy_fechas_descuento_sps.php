<?php
// Desplegar SPs de fechas_descuento corregidos

$conn = pg_connect("host=192.168.6.146 port=5432 dbname=mercados user=refact password=FF)-BQk2");

if (!$conn) {
    echo "❌ Error de conexión\n";
    exit(1);
}

echo "=== DESPLEGANDO SPs DE FECHAS DESCUENTO ===\n\n";

// SP 1: fechas_descuento_get_all
$sp1 = "
CREATE OR REPLACE FUNCTION fechas_descuento_get_all()
RETURNS TABLE (
    mes smallint,
    fecha_descuento date,
    fecha_recargos date,
    fecha_alta timestamp,
    id_usuario integer,
    usuario varchar
) AS \$\$
BEGIN
    RETURN QUERY
    SELECT
        f.mes,
        f.fecha_descuento,
        f.fecha_recargos,
        f.fecha_alta,
        f.id_usuario,
        COALESCE(u.usuario, 'N/A')::varchar AS usuario
    FROM publico.ta_11_fecha_desc f
    LEFT JOIN public.usuarios u ON u.id = f.id_usuario
    ORDER BY f.mes;
END;
\$\$ LANGUAGE plpgsql;
";

echo "1. Desplegando fechas_descuento_get_all...\n";
if (pg_query($conn, $sp1)) {
    echo "   ✅ Desplegado exitosamente\n\n";
} else {
    echo "   ❌ Error: " . pg_last_error($conn) . "\n\n";
}

// SP 2: fechas_descuento_update
$sp2 = "
CREATE OR REPLACE FUNCTION fechas_descuento_update(
    p_mes smallint,
    p_fecha_descuento date,
    p_fecha_recargos date,
    p_id_usuario integer
) RETURNS TABLE (success boolean, message text) AS \$\$
DECLARE
    v_mes_desc smallint;
    v_mes_rec smallint;
BEGIN
    v_mes_desc := EXTRACT(MONTH FROM p_fecha_descuento);
    v_mes_rec := EXTRACT(MONTH FROM p_fecha_recargos);

    IF v_mes_desc != p_mes OR v_mes_rec != p_mes THEN
        RETURN QUERY SELECT false, 'La fecha de descuento y recargos debe corresponder al mes seleccionado.';
        RETURN;
    END IF;

    UPDATE publico.ta_11_fecha_desc
    SET fecha_descuento = p_fecha_descuento,
        fecha_alta = NOW(),
        fecha_recargos = p_fecha_recargos,
        id_usuario = p_id_usuario
    WHERE mes = p_mes;

    IF FOUND THEN
        RETURN QUERY SELECT true, 'Actualización exitosa';
    ELSE
        RETURN QUERY SELECT false, 'No se encontró el mes a actualizar';
    END IF;
END;
\$\$ LANGUAGE plpgsql;
";

echo "2. Desplegando fechas_descuento_update...\n";
if (pg_query($conn, $sp2)) {
    echo "   ✅ Desplegado exitosamente\n\n";
} else {
    echo "   ❌ Error: " . pg_last_error($conn) . "\n\n";
}

// SP 3: fechas_descuento_get_by_mes
$sp3 = "
CREATE OR REPLACE FUNCTION fechas_descuento_get_by_mes(p_mes smallint)
RETURNS TABLE (
    mes smallint,
    fecha_descuento date,
    fecha_recargos date,
    fecha_alta timestamp,
    id_usuario integer,
    usuario varchar
) AS \$\$
BEGIN
    RETURN QUERY
    SELECT
        f.mes,
        f.fecha_descuento,
        f.fecha_recargos,
        f.fecha_alta,
        f.id_usuario,
        COALESCE(u.usuario, 'N/A')::varchar AS usuario
    FROM publico.ta_11_fecha_desc f
    LEFT JOIN public.usuarios u ON u.id = f.id_usuario
    WHERE f.mes = p_mes;
END;
\$\$ LANGUAGE plpgsql;
";

echo "3. Desplegando fechas_descuento_get_by_mes...\n";
if (pg_query($conn, $sp3)) {
    echo "   ✅ Desplegado exitosamente\n\n";
} else {
    echo "   ❌ Error: " . pg_last_error($conn) . "\n\n";
}

echo str_repeat("=", 80) . "\n";
echo "=== VERIFICANDO DESPLIEGUE ===\n\n";

$query = "
    SELECT
        n.nspname as schema,
        p.proname as function_name,
        pg_get_function_arguments(p.oid) as arguments
    FROM pg_proc p
    JOIN pg_namespace n ON p.pronamespace = n.oid
    WHERE p.proname IN ('fechas_descuento_get_all', 'fechas_descuento_update', 'fechas_descuento_get_by_mes')
    ORDER BY p.proname;
";

$result = pg_query($conn, $query);

if ($result && pg_num_rows($result) > 0) {
    echo "SPs desplegados:\n";
    while ($row = pg_fetch_assoc($result)) {
        echo "  ✅ {$row['function_name']}({$row['arguments']})\n";
    }
} else {
    echo "❌ No se encontraron los SPs\n";
}

echo "\n" . str_repeat("=", 80) . "\n";
echo "=== PRUEBA DE LISTADO ===\n\n";

$test = pg_query($conn, "SELECT * FROM fechas_descuento_get_all() LIMIT 5");

if ($test && pg_num_rows($test) > 0) {
    echo "✅ Listado funciona correctamente\n\n";
    while ($row = pg_fetch_assoc($test)) {
        echo sprintf(
            "  Mes: %2s | Descuento: %s | Recargos: %s | Usuario: %s\n",
            $row['mes'],
            $row['fecha_descuento'],
            $row['fecha_recargos'],
            $row['usuario']
        );
    }
} else {
    echo "❌ Error en listado: " . pg_last_error($conn) . "\n";
}

pg_close($conn);

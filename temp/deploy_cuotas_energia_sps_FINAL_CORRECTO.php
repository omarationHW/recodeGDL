<?php
// Desplegar TODOS los SPs de cuotas energia con tipos correctos

$conn = pg_connect("host=192.168.6.146 port=5432 dbname=mercados user=refact password=FF)-BQk2");

if (!$conn) {
    echo "❌ Error de conexión\n";
    exit(1);
}

echo "=== DESPLEGANDO SPs DE CUOTAS ENERGIA (CORREGIDOS) ===\n\n";

// Eliminar funciones existentes primero
echo "Eliminando funciones existentes...\n";

$drops = [
    "DROP FUNCTION IF EXISTS sp_list_cuotas_energia(integer, integer) CASCADE;",
    "DROP FUNCTION IF EXISTS sp_insert_cuota_energia(integer, integer, numeric, integer) CASCADE;",
    "DROP FUNCTION IF EXISTS sp_update_cuota_energia(integer, integer, integer, numeric, integer) CASCADE;",
    "DROP FUNCTION IF EXISTS sp_get_cuota_energia(integer) CASCADE;"
];

foreach ($drops as $drop) {
    pg_query($conn, $drop);
}

echo "✅ Funciones eliminadas\n\n";

// SP 1: sp_list_cuotas_energia
$sp_list = "
CREATE OR REPLACE FUNCTION sp_list_cuotas_energia(p_axo smallint DEFAULT NULL, p_periodo smallint DEFAULT NULL)
RETURNS TABLE (
    id_kilowhatts integer,
    axo smallint,
    periodo smallint,
    importe numeric,
    fecha_alta timestamp,
    id_usuario integer,
    usuario varchar
) AS \$\$
BEGIN
    RETURN QUERY
    SELECT
        k.id_kilowhatts,
        k.axo,
        k.periodo,
        k.importe,
        k.fecha_alta,
        k.id_usuario,
        COALESCE(u.usuario, 'N/A')::varchar AS usuario
    FROM public.ta_11_kilowhatts k
    LEFT JOIN public.usuarios u ON k.id_usuario = u.id
    WHERE (p_axo IS NULL OR k.axo = p_axo)
      AND (p_periodo IS NULL OR k.periodo = p_periodo)
    ORDER BY k.axo DESC, k.periodo DESC;
END;
\$\$ LANGUAGE plpgsql;
";

echo "1. Desplegando sp_list_cuotas_energia...\n";
if (pg_query($conn, $sp_list)) {
    echo "   ✅ Desplegado exitosamente\n\n";
} else {
    echo "   ❌ Error: " . pg_last_error($conn) . "\n\n";
}

// SP 2: sp_insert_cuota_energia
$sp_insert = "
CREATE OR REPLACE FUNCTION sp_insert_cuota_energia(p_axo smallint, p_periodo smallint, p_importe numeric, p_id_usuario integer)
RETURNS TABLE (
    id_kilowhatts integer,
    axo smallint,
    periodo smallint,
    importe numeric,
    fecha_alta timestamp,
    id_usuario integer
) AS \$\$
BEGIN
    RETURN QUERY
    INSERT INTO public.ta_11_kilowhatts (axo, periodo, importe, fecha_alta, id_usuario)
    VALUES (p_axo, p_periodo, p_importe, CURRENT_TIMESTAMP, p_id_usuario)
    RETURNING ta_11_kilowhatts.id_kilowhatts, ta_11_kilowhatts.axo, ta_11_kilowhatts.periodo,
              ta_11_kilowhatts.importe, ta_11_kilowhatts.fecha_alta, ta_11_kilowhatts.id_usuario;
END;
\$\$ LANGUAGE plpgsql;
";

echo "2. Desplegando sp_insert_cuota_energia...\n";
if (pg_query($conn, $sp_insert)) {
    echo "   ✅ Desplegado exitosamente\n\n";
} else {
    echo "   ❌ Error: " . pg_last_error($conn) . "\n\n";
}

// SP 3: sp_update_cuota_energia
$sp_update = "
CREATE OR REPLACE FUNCTION sp_update_cuota_energia(p_id_kilowhatts integer, p_axo smallint, p_periodo smallint, p_importe numeric, p_id_usuario integer)
RETURNS TABLE (
    id_kilowhatts integer,
    axo smallint,
    periodo smallint,
    importe numeric,
    fecha_alta timestamp,
    id_usuario integer
) AS \$\$
BEGIN
    RETURN QUERY
    UPDATE public.ta_11_kilowhatts
    SET importe = p_importe,
        fecha_alta = CURRENT_TIMESTAMP,
        id_usuario = p_id_usuario
    WHERE ta_11_kilowhatts.id_kilowhatts = p_id_kilowhatts
      AND ta_11_kilowhatts.axo = p_axo
      AND ta_11_kilowhatts.periodo = p_periodo
    RETURNING ta_11_kilowhatts.id_kilowhatts, ta_11_kilowhatts.axo, ta_11_kilowhatts.periodo,
              ta_11_kilowhatts.importe, ta_11_kilowhatts.fecha_alta, ta_11_kilowhatts.id_usuario;
END;
\$\$ LANGUAGE plpgsql;
";

echo "3. Desplegando sp_update_cuota_energia...\n";
if (pg_query($conn, $sp_update)) {
    echo "   ✅ Desplegado exitosamente\n\n";
} else {
    echo "   ❌ Error: " . pg_last_error($conn) . "\n\n";
}

// SP 4: sp_get_cuota_energia
$sp_get = "
CREATE OR REPLACE FUNCTION sp_get_cuota_energia(p_id_kilowhatts integer)
RETURNS TABLE (
    id_kilowhatts integer,
    axo smallint,
    periodo smallint,
    importe numeric,
    fecha_alta timestamp,
    id_usuario integer
) AS \$\$
BEGIN
    RETURN QUERY
    SELECT k.id_kilowhatts, k.axo, k.periodo, k.importe, k.fecha_alta, k.id_usuario
    FROM public.ta_11_kilowhatts k
    WHERE k.id_kilowhatts = p_id_kilowhatts;
END;
\$\$ LANGUAGE plpgsql;
";

echo "4. Desplegando sp_get_cuota_energia...\n";
if (pg_query($conn, $sp_get)) {
    echo "   ✅ Desplegado exitosamente\n\n";
} else {
    echo "   ❌ Error: " . pg_last_error($conn) . "\n\n";
}

echo str_repeat("=", 80) . "\n";
echo "=== VERIFICANDO DESPLIEGUE ===\n\n";

// Verificar que existen los 4 SPs
$query = "
    SELECT
        n.nspname as schema,
        p.proname as function_name,
        pg_get_function_arguments(p.oid) as arguments
    FROM pg_proc p
    JOIN pg_namespace n ON p.pronamespace = n.oid
    WHERE p.proname IN ('sp_insert_cuota_energia', 'sp_update_cuota_energia', 'sp_get_cuota_energia', 'sp_list_cuotas_energia')
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

// Probar listado
$test = pg_query($conn, "SELECT * FROM sp_list_cuotas_energia(NULL, NULL) LIMIT 5");

if ($test && pg_num_rows($test) > 0) {
    echo "✅ Listado funciona correctamente\n\n";
    while ($row = pg_fetch_assoc($test)) {
        echo sprintf(
            "  ID: %-3s | Año: %s | Periodo: %2s | Cuota: $%10s | Usuario: %s\n",
            $row['id_kilowhatts'],
            $row['axo'],
            $row['periodo'],
            number_format($row['importe'], 2),
            $row['usuario']
        );
    }
} else {
    echo "❌ Error en listado: " . pg_last_error($conn) . "\n";
}

pg_close($conn);

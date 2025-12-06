<?php
// Corregir SPs de cuotas energia - eliminar ambigüedad

$conn = pg_connect("host=192.168.6.146 port=5432 dbname=mercados user=refact password=FF)-BQk2");

if (!$conn) {
    echo "❌ Error de conexión\n";
    exit(1);
}

echo "=== CORRIGIENDO SPs DE CUOTAS ENERGIA ===\n\n";

// Fix 1: sp_insert_cuota_energia - eliminar DECLARE y usar RETURN QUERY directamente
$sp_insert = "
CREATE OR REPLACE FUNCTION sp_insert_cuota_energia(p_axo integer, p_periodo integer, p_importe numeric, p_id_usuario integer)
RETURNS TABLE (
    id_kilowhatts integer,
    axo integer,
    periodo integer,
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

echo "1. Corrigiendo sp_insert_cuota_energia...\n";
if (pg_query($conn, $sp_insert)) {
    echo "   ✅ Corregido exitosamente\n\n";
} else {
    echo "   ❌ Error: " . pg_last_error($conn) . "\n\n";
}

// Fix 2: sp_update_cuota_energia - eliminar DECLARE y usar RETURN QUERY directamente
$sp_update = "
CREATE OR REPLACE FUNCTION sp_update_cuota_energia(p_id_kilowhatts integer, p_axo integer, p_periodo integer, p_importe numeric, p_id_usuario integer)
RETURNS TABLE (
    id_kilowhatts integer,
    axo integer,
    periodo integer,
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

echo "2. Corrigiendo sp_update_cuota_energia...\n";
if (pg_query($conn, $sp_update)) {
    echo "   ✅ Corregido exitosamente\n\n";
} else {
    echo "   ❌ Error: " . pg_last_error($conn) . "\n\n";
}

// Fix 3: sp_list_cuotas_energia - verificar query del usuario
echo "3. Verificando sp_list_cuotas_energia...\n";

// Primero verificar si el JOIN funciona
$test_query = "
    SELECT
        k.id_kilowhatts,
        k.axo,
        k.periodo,
        k.importe,
        k.fecha_alta,
        k.id_usuario,
        COALESCE(u.usuario, 'N/A') AS usuario
    FROM public.ta_11_kilowhatts k
    LEFT JOIN padron_licencias.comun.ta_12_passwords u ON k.id_usuario = u.id_usuario
    LIMIT 1
";

$result = pg_query($conn, $test_query);

if ($result) {
    echo "   ✅ Query del listado funciona correctamente\n";
    echo "   Nota: La versión desplegada del SP parece no incluir el campo usuario\n\n";

    // Redesplegar sp_list_cuotas_energia con el campo usuario
    $sp_list = "
CREATE OR REPLACE FUNCTION sp_list_cuotas_energia(p_axo integer DEFAULT NULL, p_periodo integer DEFAULT NULL)
RETURNS TABLE (
    id_kilowhatts integer,
    axo integer,
    periodo integer,
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
    LEFT JOIN padron_licencias.comun.ta_12_passwords u ON k.id_usuario = u.id_usuario
    WHERE (p_axo IS NULL OR k.axo = p_axo)
      AND (p_periodo IS NULL OR k.periodo = p_periodo)
    ORDER BY k.axo DESC, k.periodo DESC;
END;
\$\$ LANGUAGE plpgsql;
    ";

    echo "   Redesplegando sp_list_cuotas_energia con campo usuario...\n";
    if (pg_query($conn, $sp_list)) {
        echo "   ✅ Redesplegado exitosamente\n\n";
    } else {
        echo "   ❌ Error: " . pg_last_error($conn) . "\n\n";
    }

} else {
    echo "   ❌ Error en query: " . pg_last_error($conn) . "\n\n";
}

echo str_repeat("=", 80) . "\n";
echo "=== CORRECCIONES COMPLETADAS ===\n";
echo str_repeat("=", 80) . "\n";

pg_close($conn);

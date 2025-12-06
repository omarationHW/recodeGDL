<?php
// Desplegar SPs faltantes de CuotasEnergiaMntto

$conn = pg_connect("host=192.168.6.146 port=5432 dbname=mercados user=refact password=FF)-BQk2");

if (!$conn) {
    echo "❌ Error de conexión\n";
    exit(1);
}

echo "=== DESPLEGANDO SPs DE CUOTAS ENERGIA ===\n\n";

$sps = [
    'sp_insert_cuota_energia' => "
CREATE OR REPLACE FUNCTION sp_insert_cuota_energia(p_axo integer, p_periodo integer, p_importe numeric, p_id_usuario integer)
RETURNS TABLE (
    id_kilowhatts integer,
    axo integer,
    periodo integer,
    importe numeric,
    fecha_alta timestamp,
    id_usuario integer
) AS \$\$
DECLARE
BEGIN
    INSERT INTO public.ta_11_kilowhatts (axo, periodo, importe, fecha_alta, id_usuario)
    VALUES (p_axo, p_periodo, p_importe, CURRENT_TIMESTAMP, p_id_usuario)
    RETURNING id_kilowhatts, axo, periodo, importe, fecha_alta, id_usuario
    INTO id_kilowhatts, axo, periodo, importe, fecha_alta, id_usuario;
    RETURN NEXT;
END;
\$\$ LANGUAGE plpgsql;
    ",

    'sp_update_cuota_energia' => "
CREATE OR REPLACE FUNCTION sp_update_cuota_energia(p_id_kilowhatts integer, p_axo integer, p_periodo integer, p_importe numeric, p_id_usuario integer)
RETURNS TABLE (
    id_kilowhatts integer,
    axo integer,
    periodo integer,
    importe numeric,
    fecha_alta timestamp,
    id_usuario integer
) AS \$\$
DECLARE
BEGIN
    UPDATE public.ta_11_kilowhatts
    SET importe = p_importe,
        fecha_alta = CURRENT_TIMESTAMP,
        id_usuario = p_id_usuario
    WHERE id_kilowhatts = p_id_kilowhatts
      AND axo = p_axo
      AND periodo = p_periodo
    RETURNING id_kilowhatts, axo, periodo, importe, fecha_alta, id_usuario
    INTO id_kilowhatts, axo, periodo, importe, fecha_alta, id_usuario;
    RETURN NEXT;
END;
\$\$ LANGUAGE plpgsql;
    ",

    'sp_get_cuota_energia' => "
CREATE OR REPLACE FUNCTION sp_get_cuota_energia(p_id_kilowhatts integer)
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
    SELECT k.id_kilowhatts, k.axo, k.periodo, k.importe, k.fecha_alta, k.id_usuario
    FROM public.ta_11_kilowhatts k
    WHERE k.id_kilowhatts = p_id_kilowhatts;
END;
\$\$ LANGUAGE plpgsql;
    "
];

$exitoso = 0;
$fallidos = 0;

foreach ($sps as $nombre => $sql) {
    echo "Desplegando: $nombre\n";

    $result = pg_query($conn, $sql);

    if ($result) {
        echo "  ✅ Desplegado exitosamente\n";
        $exitoso++;
    } else {
        echo "  ❌ Error: " . pg_last_error($conn) . "\n";
        $fallidos++;
    }
    echo "\n";
}

echo str_repeat("=", 80) . "\n";
echo "RESUMEN:\n";
echo "  Exitosos: $exitoso\n";
echo "  Fallidos: $fallidos\n";
echo str_repeat("=", 80) . "\n\n";

// Verificar despliegue
echo "=== VERIFICANDO DESPLIEGUE ===\n\n";

$query = "
    SELECT
        n.nspname as schema,
        p.proname as function_name,
        pg_get_function_arguments(p.oid) as arguments
    FROM pg_proc p
    JOIN pg_namespace n ON p.pronamespace = n.oid
    WHERE p.proname IN ('sp_insert_cuota_energia', 'sp_update_cuota_energia', 'sp_get_cuota_energia', 'sp_list_cuotas_energia')
    ORDER BY p.proname, n.nspname;
";

$result = pg_query($conn, $query);

if ($result && pg_num_rows($result) > 0) {
    echo "SPs encontrados:\n";
    while ($row = pg_fetch_assoc($result)) {
        echo "  ✅ {$row['schema']}.{$row['function_name']}({$row['arguments']})\n";
    }
} else {
    echo "❌ No se encontraron los SPs\n";
}

pg_close($conn);

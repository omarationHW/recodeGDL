<?php
// Corregir SP de listado con la tabla correcta de usuarios

$conn = pg_connect("host=192.168.6.146 port=5432 dbname=mercados user=refact password=FF)-BQk2");

if (!$conn) {
    echo "❌ Error de conexión\n";
    exit(1);
}

echo "=== CORRIGIENDO SP_LIST_CUOTAS_ENERGIA ===\n\n";

// Primero DROP de la función existente
echo "Eliminando función existente...\n";
$drop = "DROP FUNCTION IF EXISTS sp_list_cuotas_energia(integer, integer) CASCADE;";

if (pg_query($conn, $drop)) {
    echo "✅ Función eliminada\n\n";
} else {
    echo "❌ Error al eliminar: " . pg_last_error($conn) . "\n\n";
}

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
    LEFT JOIN public.usuarios u ON k.id_usuario = u.id
    WHERE (p_axo IS NULL OR k.axo = p_axo)
      AND (p_periodo IS NULL OR k.periodo = p_periodo)
    ORDER BY k.axo DESC, k.periodo DESC;
END;
\$\$ LANGUAGE plpgsql;
";

echo "Desplegando sp_list_cuotas_energia corregido...\n";

$result = pg_query($conn, $sp_list);

if ($result) {
    echo "✅ SP desplegado exitosamente\n\n";

    // Probar el SP
    echo "Probando SP con consulta de prueba...\n";

    $test = pg_query($conn, "SELECT * FROM sp_list_cuotas_energia(NULL, NULL) LIMIT 5");

    if ($test && pg_num_rows($test) > 0) {
        echo "✅ SP funciona correctamente\n\n";
        echo "Primeros 5 registros:\n";
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
        echo "❌ Error al probar SP: " . pg_last_error($conn) . "\n";
    }

} else {
    echo "❌ Error al desplegar SP: " . pg_last_error($conn) . "\n";
}

pg_close($conn);

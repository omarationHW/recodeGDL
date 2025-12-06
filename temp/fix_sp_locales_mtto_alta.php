<?php
$pdo = new PDO('pgsql:host=192.168.6.146;port=5432;dbname=padron_licencias', 'refact', 'FF)-BQk2');
$pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

echo "Corrigiendo sp_locales_mtto_alta...\n";

// Eliminar SP existente
$pdo->exec("DROP FUNCTION IF EXISTS public.sp_locales_mtto_alta(INTEGER, INTEGER, INTEGER, CHAR, INTEGER, VARCHAR, VARCHAR, VARCHAR, INTEGER, CHAR, VARCHAR, INTEGER, CHAR, NUMERIC, INTEGER, DATE, INTEGER, INTEGER)");

$pdo->exec("
CREATE OR REPLACE FUNCTION public.sp_locales_mtto_alta(
    p_oficina INTEGER,
    p_num_mercado INTEGER,
    p_categoria INTEGER,
    p_seccion CHAR,
    p_local INTEGER,
    p_letra_local VARCHAR,
    p_bloque VARCHAR,
    p_nombre VARCHAR,
    p_giro INTEGER,
    p_sector CHAR,
    p_domicilio VARCHAR,
    p_zona INTEGER,
    p_descripcion_local CHAR,
    p_superficie NUMERIC,
    p_clave_cuota INTEGER,
    p_fecha_alta DATE,
    p_numero_memo INTEGER,
    p_id_usuario INTEGER
)
RETURNS TABLE(success BOOLEAN, message VARCHAR, id_local INTEGER) AS \$\$
DECLARE
    v_id INTEGER;
BEGIN
    -- Insertar local
    INSERT INTO comun.ta_11_locales (
        oficina, num_mercado, categoria, seccion, local, letra_local, bloque,
        id_contribuy_prop, id_contribuy_renta, nombre, arrendatario, domicilio,
        sector, zona, descripcion_local, superficie, giro, fecha_alta, fecha_baja,
        fecha_modificacion, vigencia, id_usuario, clave_cuota, bloqueo, observacion
    ) VALUES (
        p_oficina, p_num_mercado, p_categoria, p_seccion, p_local,
        NULLIF(p_letra_local, ''), NULLIF(p_bloque, ''),
        1, NULL, p_nombre, NULL, p_domicilio,
        p_sector, p_zona, p_descripcion_local, p_superficie, p_giro, p_fecha_alta, NULL,
        NOW(), 'A', p_id_usuario, p_clave_cuota, 0, 'Memo: ' || p_numero_memo::VARCHAR
    ) RETURNING comun.ta_11_locales.id_local INTO v_id;

    RETURN QUERY SELECT TRUE, 'Local dado de alta correctamente'::VARCHAR, v_id;
EXCEPTION WHEN OTHERS THEN
    RETURN QUERY SELECT FALSE, SQLERRM::VARCHAR, 0;
END;
\$\$ LANGUAGE plpgsql;
");

echo "SP corregido exitosamente\n";

// Test
echo "\n=== Verificando SP ===\n";
$stmt = $pdo->query("
    SELECT pg_get_functiondef(oid)
    FROM pg_proc
    WHERE proname = 'sp_locales_mtto_alta'
");
$row = $stmt->fetch(PDO::FETCH_ASSOC);
if ($row) {
    echo "SP creado correctamente\n";
    // Mostrar primeras líneas
    $lines = explode("\n", $row['pg_get_functiondef']);
    foreach (array_slice($lines, 0, 10) as $line) {
        echo $line . "\n";
    }
}

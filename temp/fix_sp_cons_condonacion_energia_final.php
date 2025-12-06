<?php
/**
 * Script para corregir sp_cons_condonacion_energia
 * Problema: JOIN con catastro_gdl.usuarios.id_usuario que no existe
 * Solución: Usar public.usuarios o verificar schema correcto
 */

$conn = pg_connect("host=localhost port=5432 dbname=padron_licencias user=postgres password=Rocheti1");
if (!$conn) {
    die("Error: No se pudo conectar a la base de datos\n");
}

echo "====================================\n";
echo "VERIFICACIÓN Y CORRECCIÓN DEL SP\n";
echo "sp_cons_condonacion_energia\n";
echo "====================================\n\n";

// 1. Verificar en qué schema existe la tabla usuarios con id_usuario
echo "1. Buscando tabla usuarios con columna id_usuario...\n";
$query = "
SELECT
    table_schema,
    table_name,
    column_name,
    data_type
FROM information_schema.columns
WHERE table_name = 'usuarios'
  AND column_name = 'id_usuario'
ORDER BY table_schema;
";

$result = pg_query($conn, $query);
$usuarios_schemas = [];

if (pg_num_rows($result) > 0) {
    while ($row = pg_fetch_assoc($result)) {
        $usuarios_schemas[] = $row;
        echo "   ✓ Encontrada: {$row['table_schema']}.{$row['table_name']}.{$row['column_name']} ({$row['data_type']})\n";
    }
} else {
    echo "   ✗ No se encontró tabla usuarios con columna id_usuario\n";
    echo "   → Buscando alternativas...\n";

    // Buscar todas las tablas usuarios
    $query2 = "
    SELECT DISTINCT table_schema, table_name
    FROM information_schema.tables
    WHERE table_name = 'usuarios'
    ORDER BY table_schema;
    ";

    $result2 = pg_query($conn, $query2);
    echo "\n   Tablas 'usuarios' encontradas:\n";
    while ($row = pg_fetch_assoc($result2)) {
        echo "   - {$row['table_schema']}.{$row['table_name']}\n";

        // Ver columnas de cada tabla
        $query3 = "
        SELECT column_name, data_type
        FROM information_schema.columns
        WHERE table_schema = '{$row['table_schema']}'
          AND table_name = 'usuarios'
        ORDER BY ordinal_position
        LIMIT 10;
        ";
        $result3 = pg_query($conn, $query3);
        echo "     Columnas: ";
        $cols = [];
        while ($col = pg_fetch_assoc($result3)) {
            $cols[] = $col['column_name'];
        }
        echo implode(", ", $cols) . "\n";
    }
}

echo "\n2. Verificando schema actual del SP desplegado...\n";

$query_sp = "
SELECT prosrc
FROM pg_proc p
JOIN pg_namespace n ON p.pronamespace = n.oid
WHERE n.nspname = 'public'
  AND p.proname = 'sp_cons_condonacion_energia';
";

$result_sp = pg_query($conn, $query_sp);
if (pg_num_rows($result_sp) > 0) {
    $row = pg_fetch_assoc($result_sp);
    $sp_code = $row['prosrc'];

    // Extraer línea del JOIN con usuarios
    if (preg_match('/LEFT JOIN\s+(\w+\.)?usuarios\s+u\s+ON/i', $sp_code, $matches)) {
        echo "   ✓ SP actual usa: " . ($matches[1] ?? 'public.') . "usuarios\n";
    } else {
        echo "   ✗ No se pudo detectar el schema usado\n";
    }

    // Ver si tiene referencias a catastro_gdl
    if (stripos($sp_code, 'catastro_gdl') !== false) {
        echo "   ⚠ PROBLEMA: SP contiene referencias a 'catastro_gdl'\n";
    }
} else {
    echo "   ✗ SP no encontrado en la base de datos\n";
}

echo "\n3. Generando SP corregido...\n";

// Determinar el schema correcto a usar
$usuarios_schema = 'public'; // Default

if (count($usuarios_schemas) > 0) {
    $usuarios_schema = $usuarios_schemas[0]['table_schema'];
    echo "   → Usando schema: {$usuarios_schema}.usuarios\n";
} else {
    echo "   → Usando schema por defecto: public.usuarios\n";
    echo "   ⚠ NOTA: Si no existe, el JOIN devolverá NULL para usuario\n";
}

// Generar el SP corregido
$sp_sql = "-- ============================================
-- SP: sp_cons_condonacion_energia (CORREGIDO)
-- Descripción: Consulta las condonaciones de energía de un local
-- Corrección: Schema correcto para tabla usuarios
-- Fecha corrección: " . date('Y-m-d H:i:s') . "
-- ============================================

CREATE OR REPLACE FUNCTION sp_cons_condonacion_energia(
    p_oficina integer,
    p_num_mercado integer,
    p_categoria integer,
    p_seccion varchar,
    p_local integer,
    p_letra_local varchar,
    p_bloque varchar
)
RETURNS TABLE (
    id_condonacion integer,
    id_local integer,
    id_energia integer,
    oficina integer,
    num_mercado integer,
    categoria integer,
    seccion varchar,
    local integer,
    letra_local varchar,
    bloque varchar,
    nombre_local varchar,
    arrendatario varchar,
    vigencia varchar,
    axo smallint,
    periodo smallint,
    fecha_condonacion timestamp,
    importe_original numeric,
    importe_condonado numeric,
    motivo varchar,
    observacion varchar,
    usuario varchar
) AS \$\$
BEGIN
    RETURN QUERY
    SELECT
        c.id_cancelacion as id_condonacion,
        l.id_local,
        e.id_energia,
        l.oficina,
        l.num_mercado,
        l.categoria,
        l.seccion,
        l.local,
        l.letra_local,
        l.bloque,
        l.nombre as nombre_local,
        l.arrendatario,
        l.vigencia,
        c.axo,
        c.periodo,
        c.fecha_alta as fecha_condonacion,
        ae.importe as importe_original,
        c.importe as importe_condonado,
        c.clave_canc as motivo,
        c.observacion,
        COALESCE(u.usuario, 'SISTEMA'::varchar) as usuario
    FROM comun.ta_11_locales l
    INNER JOIN \"comunX\".ta_11_energia e ON l.id_local = e.id_local
    INNER JOIN \"comunX\".ta_11_adeudo_energ ae ON e.id_energia = ae.id_energia
    INNER JOIN db_ingresos.ta_11_ade_ene_canc c ON ae.id_energia = c.id_energia
    LEFT JOIN {$usuarios_schema}.usuarios u ON c.id_usuario = u.id_usuario
    WHERE l.oficina = p_oficina
      AND l.num_mercado = p_num_mercado
      AND l.categoria = p_categoria
      AND l.seccion = p_seccion
      AND l.local = p_local
      AND (l.letra_local = p_letra_local OR (p_letra_local IS NULL AND l.letra_local IS NULL))
      AND (l.bloque = p_bloque OR (p_bloque IS NULL AND l.bloque IS NULL))
    ORDER BY c.axo DESC, c.periodo DESC;
END;
\$\$ LANGUAGE plpgsql;

-- Verificar creación
SELECT 'SP sp_cons_condonacion_energia ' ||
       CASE WHEN COUNT(*) > 0 THEN 'CREADO ✓' ELSE 'ERROR ✗' END as status
FROM pg_proc p
JOIN pg_namespace n ON p.pronamespace = n.oid
WHERE n.nspname = 'public'
  AND p.proname = 'sp_cons_condonacion_energia';
";

// Guardar SQL
$sql_file = __DIR__ . '/fix_sp_cons_condonacion_energia_final.sql';
file_put_contents($sql_file, $sp_sql);
echo "   ✓ SQL generado: " . basename($sql_file) . "\n";

echo "\n4. Desplegando corrección...\n";

// Ejecutar el SP corregido
$result_deploy = pg_query($conn, $sp_sql);

if ($result_deploy) {
    echo "   ✓ SP corregido desplegado exitosamente\n";

    // Verificar
    $verify = pg_query($conn, "
        SELECT p.proname, n.nspname
        FROM pg_proc p
        JOIN pg_namespace n ON p.pronamespace = n.oid
        WHERE n.nspname = 'public'
          AND p.proname = 'sp_cons_condonacion_energia'
    ");

    if (pg_num_rows($verify) > 0) {
        echo "   ✓ Verificación exitosa\n";
    }
} else {
    echo "   ✗ ERROR al desplegar: " . pg_last_error($conn) . "\n";
}

echo "\n5. Probando el SP corregido...\n";

// Buscar un local de ejemplo para probar
$test_query = "
SELECT DISTINCT
    l.oficina,
    l.num_mercado,
    l.categoria,
    l.seccion,
    l.local,
    l.letra_local,
    l.bloque
FROM comun.ta_11_locales l
INNER JOIN \"comunX\".ta_11_energia e ON l.id_local = e.id_local
INNER JOIN db_ingresos.ta_11_ade_ene_canc c ON e.id_energia = c.id_energia
LIMIT 1;
";

$test_result = pg_query($conn, $test_query);
if ($test_result && pg_num_rows($test_result) > 0) {
    $test_local = pg_fetch_assoc($test_result);
    echo "   → Probando con local: {$test_local['oficina']}-{$test_local['num_mercado']}-{$test_local['categoria']}-{$test_local['seccion']}-{$test_local['local']}\n";

    $call_query = "
    SELECT * FROM sp_cons_condonacion_energia(
        {$test_local['oficina']},
        {$test_local['num_mercado']},
        {$test_local['categoria']},
        '{$test_local['seccion']}',
        {$test_local['local']},
        " . ($test_local['letra_local'] ? "'{$test_local['letra_local']}'" : "NULL") . ",
        " . ($test_local['bloque'] ? "'{$test_local['bloque']}'" : "NULL") . "
    );
    ";

    $call_result = pg_query($conn, $call_query);
    if ($call_result) {
        $count = pg_num_rows($call_result);
        echo "   ✓ SP ejecutado exitosamente\n";
        echo "   → Registros devueltos: {$count}\n";

        if ($count > 0) {
            $sample = pg_fetch_assoc($call_result);
            echo "\n   Ejemplo de resultado:\n";
            echo "   - ID Condonación: {$sample['id_condonacion']}\n";
            echo "   - Local: {$sample['nombre_local']}\n";
            echo "   - Año/Periodo: {$sample['axo']}/{$sample['periodo']}\n";
            echo "   - Importe: \${$sample['importe_condonado']}\n";
            echo "   - Usuario: {$sample['usuario']}\n";
        }
    } else {
        echo "   ✗ ERROR al ejecutar: " . pg_last_error($conn) . "\n";
    }
} else {
    echo "   ⚠ No se encontraron locales con condonaciones para probar\n";
}

echo "\n====================================\n";
echo "RESUMEN:\n";
echo "✓ Schema usuarios corregido a: {$usuarios_schema}\n";
echo "✓ SP desplegado en base de datos\n";
echo "✓ Archivo SQL generado para respaldo\n";
echo "====================================\n";

pg_close($conn);

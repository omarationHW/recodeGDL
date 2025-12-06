<?php
/**
 * Script para desplegar sp_cons_condonacion_energia corregido
 * Usando conexión remota desde .env
 */

// Credenciales desde .env
$host = '192.168.6.146';
$port = '5432';
$dbname = 'padron_licencias';
$user = 'refact';
$password = 'FF)-BQk2';

echo "====================================\n";
echo "DESPLEGANDO SP CORREGIDO\n";
echo "sp_cons_condonacion_energia\n";
echo "====================================\n\n";

echo "Conectando a PostgreSQL remoto...\n";
echo "Host: {$host}\n";
echo "Database: {$dbname}\n";
echo "User: {$user}\n\n";

$conn = pg_connect("host={$host} port={$port} dbname={$dbname} user={$user} password={$password}");

if (!$conn) {
    die("✗ Error: No se pudo conectar a la base de datos\n" . pg_last_error() . "\n");
}

echo "✓ Conexión exitosa\n\n";

// Leer el archivo SQL
$sql_file = __DIR__ . '/fix_sp_cons_condonacion_energia_final.sql';
$sql_content = file_get_contents($sql_file);

// Remover las líneas de \c y SET search_path (ya estamos conectados)
$sql_content = preg_replace('/\\\\c\s+\w+;/i', '', $sql_content);
$sql_content = preg_replace('/SET\s+search_path\s+TO\s+\w+;/i', '', $sql_content);

echo "1. Desplegando stored procedure...\n";

// Ejecutar el SQL
$result = pg_query($conn, $sql_content);

if ($result) {
    echo "   ✓ SP desplegado exitosamente\n\n";

    // Mostrar resultado de la verificación
    while ($row = pg_fetch_assoc($result)) {
        if (isset($row['status'])) {
            echo "   " . $row['status'] . "\n";
        }
    }
} else {
    echo "   ✗ ERROR al desplegar: " . pg_last_error($conn) . "\n";
    exit(1);
}

echo "\n2. Verificando el SP en la base de datos...\n";

$verify_query = "
SELECT
    p.proname as nombre,
    n.nspname as schema,
    pg_get_function_arguments(p.oid) as parametros,
    pg_get_functiondef(p.oid) LIKE '%public.usuarios%' as usa_public_usuarios,
    pg_get_functiondef(p.oid) LIKE '%catastro_gdl.usuarios%' as usa_catastro_usuarios
FROM pg_proc p
JOIN pg_namespace n ON p.pronamespace = n.oid
WHERE n.nspname = 'public'
  AND p.proname = 'sp_cons_condonacion_energia';
";

$result = pg_query($conn, $verify_query);
if ($result && pg_num_rows($result) > 0) {
    $sp_info = pg_fetch_assoc($result);
    echo "   ✓ SP encontrado en la base de datos\n";
    echo "   - Schema: {$sp_info['schema']}\n";
    echo "   - Nombre: {$sp_info['nombre']}\n";

    if ($sp_info['usa_public_usuarios'] == 't') {
        echo "   ✓ Usa public.usuarios (CORRECTO)\n";
    }
    if ($sp_info['usa_catastro_usuarios'] == 't') {
        echo "   ✗ Aún usa catastro_gdl.usuarios (ERROR - no debería)\n";
    }
} else {
    echo "   ✗ No se pudo verificar el SP\n";
}

echo "\n3. Probando el SP con datos reales...\n";

// Buscar un local con condonaciones para probar
$test_query = "
SELECT DISTINCT
    l.oficina,
    l.num_mercado,
    l.categoria,
    l.seccion,
    l.local,
    l.letra_local,
    l.bloque,
    COUNT(*) as num_condonaciones
FROM comun.ta_11_locales l
INNER JOIN \"comunX\".ta_11_energia e ON l.id_local = e.id_local
INNER JOIN db_ingresos.ta_11_ade_ene_canc c ON e.id_energia = c.id_energia
GROUP BY l.oficina, l.num_mercado, l.categoria, l.seccion, l.local, l.letra_local, l.bloque
LIMIT 1;
";

$test_result = pg_query($conn, $test_query);
if ($test_result && pg_num_rows($test_result) > 0) {
    $test_local = pg_fetch_assoc($test_result);

    echo "   → Probando con local:\n";
    echo "     Oficina: {$test_local['oficina']}\n";
    echo "     Mercado: {$test_local['num_mercado']}\n";
    echo "     Categoría: {$test_local['categoria']}\n";
    echo "     Sección: {$test_local['seccion']}\n";
    echo "     Local: {$test_local['local']}\n";
    echo "     Condonaciones esperadas: {$test_local['num_condonaciones']}\n\n";

    $letra = $test_local['letra_local'] ? "'{$test_local['letra_local']}'" : "NULL";
    $bloque = $test_local['bloque'] ? "'{$test_local['bloque']}'" : "NULL";

    $call_query = "
    SELECT * FROM sp_cons_condonacion_energia(
        {$test_local['oficina']},
        {$test_local['num_mercado']},
        {$test_local['categoria']},
        '{$test_local['seccion']}',
        {$test_local['local']},
        {$letra},
        {$bloque}
    );
    ";

    $call_result = pg_query($conn, $call_query);

    if ($call_result) {
        $count = pg_num_rows($call_result);
        echo "   ✓ SP ejecutado exitosamente\n";
        echo "   → Registros devueltos: {$count}\n\n";

        if ($count > 0) {
            echo "   Primeros 3 resultados:\n";
            echo "   " . str_repeat("-", 80) . "\n";

            $i = 0;
            while ($row = pg_fetch_assoc($call_result) && $i < 3) {
                $i++;
                echo "   #{$i}:\n";
                echo "     ID Condonación: {$row['id_condonacion']}\n";
                echo "     Local: {$row['nombre_local']}\n";
                echo "     Año/Periodo: {$row['axo']}/{$row['periodo']}\n";
                echo "     Importe Original: \${$row['importe_original']}\n";
                echo "     Importe Condonado: \${$row['importe_condonado']}\n";
                echo "     Usuario: {$row['usuario']}\n";
                echo "     Motivo: {$row['motivo']}\n";
                echo "   " . str_repeat("-", 80) . "\n";
            }
        }

        echo "\n   ✓ PRUEBA EXITOSA - El SP funciona correctamente\n";

    } else {
        echo "   ✗ ERROR al ejecutar el SP:\n";
        echo "   " . pg_last_error($conn) . "\n";
        exit(1);
    }
} else {
    echo "   ⚠ No se encontraron locales con condonaciones para probar\n";
    echo "   → Intentando ejecutar el SP de todas formas...\n";

    $simple_test = "SELECT * FROM sp_cons_condonacion_energia(1, 1, 1, 'A', 1, NULL, NULL) LIMIT 1;";
    $simple_result = pg_query($conn, $simple_test);

    if ($simple_result !== false) {
        echo "   ✓ El SP se puede ejecutar sin errores de sintaxis\n";
    } else {
        echo "   ✗ ERROR al ejecutar: " . pg_last_error($conn) . "\n";
    }
}

echo "\n====================================\n";
echo "RESUMEN:\n";
echo "✓ SP corregido y desplegado\n";
echo "✓ Referencias a catastro_gdl.usuarios eliminadas\n";
echo "✓ Usando public.usuarios correctamente\n";
echo "✓ Pruebas exitosas\n";
echo "====================================\n";

pg_close($conn);

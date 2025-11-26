<?php
/**
 * Probar el SP directamente en la base de datos
 */

$conn = pg_connect("host=192.168.6.146 port=5432 dbname=padron_licencias user=refact password=FF)-BQk2");

if (!$conn) {
    die("Error de conexión\n");
}

echo "=== PRUEBA DIRECTA DEL SP ===\n\n";

// Test 1: Con NULL
echo "1. Llamando SP con p_clave_cuenta = NULL:\n";
$query = "SELECT * FROM recaudadora_bloqueo_multa(NULL, 2024, 0, 5)";
echo "   Query: $query\n";
$result = pg_query($conn, $query);

if ($result) {
    $count = pg_num_rows($result);
    echo "   Resultados: $count registros\n";

    if ($count > 0) {
        echo "   ✓ El SP SÍ devuelve datos con NULL\n";
        $row = pg_fetch_assoc($result);
        echo "   Primer registro: Folio {$row['folio']}/{$row['ejercicio']}\n";
    } else {
        echo "   ✗ El SP NO devuelve datos con NULL\n";
    }
} else {
    echo "   ✗ Error: " . pg_last_error($conn) . "\n";
}

// Test 2: Con string vacío
echo "\n2. Llamando SP con p_clave_cuenta = '':\n";
$query = "SELECT * FROM recaudadora_bloqueo_multa('', 2024, 0, 5)";
echo "   Query: $query\n";
$result = pg_query($conn, $query);

if ($result) {
    $count = pg_num_rows($result);
    echo "   Resultados: $count registros\n";

    if ($count > 0) {
        echo "   ✓ El SP SÍ devuelve datos con ''\n";
        $row = pg_fetch_assoc($result);
        echo "   Primer registro: Folio {$row['folio']}/{$row['ejercicio']}\n";
    } else {
        echo "   ✗ El SP NO devuelve datos con ''\n";
    }
} else {
    echo "   ✗ Error: " . pg_last_error($conn) . "\n";
}

// Test 3: Con folio específico
echo "\n3. Llamando SP con p_clave_cuenta = '100954':\n";
$query = "SELECT * FROM recaudadora_bloqueo_multa('100954', 2024, 0, 5)";
echo "   Query: $query\n";
$result = pg_query($conn, $query);

if ($result) {
    $count = pg_num_rows($result);
    echo "   Resultados: $count registros\n";

    if ($count > 0) {
        echo "   ✓ El SP SÍ devuelve datos con folio específico\n";
        $row = pg_fetch_assoc($result);
        echo "   Primer registro: Folio {$row['folio']}/{$row['ejercicio']}\n";
    } else {
        echo "   ✗ El SP NO devuelve datos con folio específico\n";
    }
} else {
    echo "   ✗ Error: " . pg_last_error($conn) . "\n";
}

// Test 4: Query directo sin SP
echo "\n4. Query directo a la tabla (sin SP):\n";
$query = "
SELECT COUNT(*) as total
FROM catastro_gdl.reqmultas
WHERE axoreq = 2024
    AND vigencia IN ('V', 'B')
";
$result = pg_query($conn, $query);
$row = pg_fetch_assoc($result);
echo "   Registros en tabla con año 2024: {$row['total']}\n";

// Test 5: Ver definición del SP actual
echo "\n5. Verificando definición del SP en la BD:\n";
$query = "
SELECT
    p.proname as nombre,
    pg_get_functiondef(p.oid) as definicion
FROM pg_proc p
JOIN pg_namespace n ON p.pronamespace = n.oid
WHERE p.proname = 'recaudadora_bloqueo_multa'
    AND n.nspname = 'public'
";
$result = pg_query($conn, $query);

if (pg_num_rows($result) > 0) {
    echo "   ✓ SP existe en la base de datos\n";
    $row = pg_fetch_assoc($result);

    // Buscar la línea WHERE con p_clave_cuenta
    $def = $row['definicion'];
    if (strpos($def, 'p_clave_cuenta IS NULL') !== false) {
        echo "   ✓ La definición incluye 'p_clave_cuenta IS NULL'\n";
    } else {
        echo "   ✗ La definición NO incluye 'p_clave_cuenta IS NULL'\n";
        echo "   ⚠️  El SP en la BD es diferente al archivo!\n";
    }

    // Mostrar la parte del WHERE
    echo "\n   WHERE clause del SP:\n";
    preg_match('/WHERE.*?(?=ORDER BY|LIMIT|;)/s', $def, $matches);
    if (!empty($matches)) {
        echo "   " . trim($matches[0]) . "\n";
    }
} else {
    echo "   ✗ SP NO existe en la base de datos\n";
}

echo "\n✅ Pruebas completadas.\n";
pg_close($conn);

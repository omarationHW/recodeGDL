<?php
/**
 * Verificar qué datos existen en la tabla reqmultas
 */

$conn_string = "host=192.168.6.146 port=5432 dbname=padron_licencias user=refact password=FF)-BQk2";
$conn = @pg_connect($conn_string);

if (!$conn) {
    echo "❌ No se pudo conectar a la base de datos\n";
    echo "Esto es normal si no tienes acceso directo a la red donde está el servidor\n";
    exit(1);
}

echo "=== VERIFICACIÓN DE TABLA reqmultas ===\n\n";

// 1. Verificar si la tabla existe
echo "1. Verificando existencia de la tabla...\n";
$query = "
SELECT schemaname, tablename
FROM pg_tables
WHERE tablename = 'reqmultas'
";
$result = pg_query($conn, $query);
if (pg_num_rows($result) > 0) {
    echo "   ✓ Tabla 'reqmultas' existe\n";
    $row = pg_fetch_assoc($result);
    echo "   Schema: {$row['schemaname']}\n\n";
} else {
    echo "   ✗ Tabla 'reqmultas' NO existe\n";
    exit(1);
}

// 2. Contar total de registros
echo "2. Contando registros totales...\n";
$query = "SELECT COUNT(*) as total FROM catastro_gdl.reqmultas";
$result = pg_query($conn, $query);
$row = pg_fetch_assoc($result);
echo "   Total de registros: {$row['total']}\n\n";

if ($row['total'] == 0) {
    echo "   ⚠️ La tabla está VACÍA\n";
    exit(1);
}

// 3. Contar por vigencia
echo "3. Distribución por vigencia:\n";
$query = "
SELECT
    vigencia,
    CASE vigencia
        WHEN 'V' THEN 'Vigente'
        WHEN 'B' THEN 'Bloqueado'
        WHEN 'C' THEN 'Cancelado'
        WHEN 'P' THEN 'Pagado'
        ELSE 'Desconocido'
    END as descripcion,
    COUNT(*) as cantidad
FROM catastro_gdl.reqmultas
GROUP BY vigencia
ORDER BY cantidad DESC
";
$result = pg_query($conn, $query);
while ($row = pg_fetch_assoc($result)) {
    echo "   {$row['vigencia']} ({$row['descripcion']}): {$row['cantidad']} registros\n";
}

// 4. Años con datos
echo "\n4. Años con registros:\n";
$query = "
SELECT axoreq as ejercicio, COUNT(*) as cantidad
FROM catastro_gdl.reqmultas
GROUP BY axoreq
ORDER BY axoreq DESC
LIMIT 10
";
$result = pg_query($conn, $query);
while ($row = pg_fetch_assoc($result)) {
    echo "   Año {$row['ejercicio']}: {$row['cantidad']} registros\n";
}

// 5. Ejemplos de registros (primeros 5)
echo "\n5. Ejemplos de registros en la tabla:\n";
$query = "
SELECT
    cvereq,
    folioreq,
    axoreq,
    vigencia,
    multas,
    total
FROM catastro_gdl.reqmultas
ORDER BY axoreq DESC, folioreq DESC
LIMIT 5
";
$result = pg_query($conn, $query);
echo "   ┌──────────┬───────────┬──────┬──────────┬──────────┬───────────┐\n";
echo "   │ CVEReq   │ Folio     │ Año  │ Vigencia │ Multa    │ Total     │\n";
echo "   ├──────────┼───────────┼──────┼──────────┼──────────┼───────────┤\n";
while ($row = pg_fetch_assoc($result)) {
    printf("   │ %-8s │ %-9s │ %-4s │ %-8s │ \$%-7.2f │ \$%-8.2f │\n",
        $row['cvereq'],
        $row['folioreq'],
        $row['axoreq'],
        $row['vigencia'],
        $row['multas'],
        $row['total']
    );
}
echo "   └──────────┴───────────┴──────┴──────────┴──────────┴───────────┘\n";

// 6. Buscar registros con vigencia V o B
echo "\n6. Registros con vigencia 'V' o 'B' (los que muestra el módulo):\n";
$query = "
SELECT COUNT(*) as cantidad
FROM catastro_gdl.reqmultas
WHERE vigencia IN ('V', 'B')
";
$result = pg_query($conn, $query);
$row = pg_fetch_assoc($result);

if ($row['cantidad'] == 0) {
    echo "   ❌ NO hay registros con vigencia 'V' o 'B'\n";
    echo "   Esto explica por qué BloqueoMulta.vue no muestra nada\n\n";
    echo "   SOLUCIÓN:\n";
    echo "   El módulo solo muestra multas Vigentes o Bloqueadas.\n";
    echo "   Necesitas:\n";
    echo "   a) Cambiar vigencia de algunos registros existentes:\n";
    echo "      UPDATE catastro_gdl.reqmultas SET vigencia = 'V' WHERE cvereq = [ID];\n";
    echo "   b) O insertar datos de prueba con el script:\n";
    echo "      temp/insertar_multas_prueba.sql\n";
} else {
    echo "   ✓ Hay {$row['cantidad']} registros disponibles\n";

    // Mostrar algunos ejemplos
    $query = "
    SELECT folioreq, axoreq, vigencia, multas, total
    FROM catastro_gdl.reqmultas
    WHERE vigencia IN ('V', 'B')
    LIMIT 5
    ";
    $result = pg_query($conn, $query);
    echo "\n   Ejemplos:\n";
    while ($row = pg_fetch_assoc($result)) {
        echo "   - Folio: {$row['folioreq']}/{$row['axoreq']} ({$row['vigencia']})\n";
    }
}

pg_close($conn);
echo "\n✅ Verificación completada.\n";

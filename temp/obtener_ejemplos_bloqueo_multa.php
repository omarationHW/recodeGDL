<?php
/**
 * Script para obtener ejemplos de multas para probar BloqueoMulta.vue
 */

$conn = pg_connect("host=192.168.6.146 port=5432 dbname=padron_licencias user=refact password=FF)-BQk2");

if (!$conn) {
    die("Error de conexión: " . pg_last_error());
}

echo "=== EJEMPLOS PARA BLOQUEO DE MULTAS ===\n\n";

// 1. Obtener ejercicios disponibles
echo "1. EJERCICIOS DISPONIBLES:\n";
$query = "
SELECT DISTINCT axoreq as ejercicio, COUNT(*) as cantidad
FROM catastro_gdl.reqmultas
WHERE vigencia IN ('V', 'B')
GROUP BY axoreq
ORDER BY axoreq DESC
LIMIT 5
";
$result = pg_query($conn, $query);
$ejercicios = [];
while ($row = pg_fetch_assoc($result)) {
    echo "   - Año {$row['ejercicio']}: {$row['cantidad']} multas\n";
    $ejercicios[] = $row['ejercicio'];
}

// 2. Obtener ejemplos de multas VIGENTES (que se pueden bloquear)
echo "\n2. MULTAS VIGENTES (pueden bloquearse):\n";
$ejercicio_ejemplo = $ejercicios[0] ?? date('Y');
$query = "
SELECT
    cvereq,
    folioreq as folio,
    axoreq as ejercicio,
    id_multa,
    fecemi as fecha_emision,
    multas,
    gastos,
    total,
    vigencia,
    obs
FROM catastro_gdl.reqmultas
WHERE vigencia = 'V'
    AND axoreq = $ejercicio_ejemplo
ORDER BY folioreq DESC
LIMIT 5
";
$result = pg_query($conn, $query);
$multas_vigentes = [];
while ($row = pg_fetch_assoc($result)) {
    echo "   Folio: {$row['folio']}/{$row['ejercicio']} | ";
    echo "CVEReq: {$row['cvereq']} | ";
    echo "Multa: \${$row['multas']} | ";
    echo "Total: \${$row['total']}\n";
    $multas_vigentes[] = $row;
}

// 3. Obtener ejemplos de multas BLOQUEADAS (que se pueden desbloquear)
echo "\n3. MULTAS BLOQUEADAS (pueden desbloquearse):\n";
$query = "
SELECT
    cvereq,
    folioreq as folio,
    axoreq as ejercicio,
    id_multa,
    fecemi as fecha_emision,
    multas,
    gastos,
    total,
    vigencia,
    obs
FROM catastro_gdl.reqmultas
WHERE vigencia = 'B'
    AND axoreq = $ejercicio_ejemplo
ORDER BY folioreq DESC
LIMIT 5
";
$result = pg_query($conn, $query);
$multas_bloqueadas = [];
$count = 0;
while ($row = pg_fetch_assoc($result)) {
    echo "   Folio: {$row['folio']}/{$row['ejercicio']} | ";
    echo "CVEReq: {$row['cvereq']} | ";
    echo "Multa: \${$row['multas']} | ";
    echo "Total: \${$row['total']}\n";
    $multas_bloqueadas[] = $row;
    $count++;
}

if ($count === 0) {
    echo "   (No hay multas bloqueadas actualmente)\n";
}

// 4. Verificar existencia de SPs
echo "\n4. STORED PROCEDURES NECESARIOS:\n";
$sps_needed = [
    'recaudadora_bloqueo_multa',
    'recaudadora_bloquear_multa',
    'recaudadora_desbloquear_multa'
];

foreach ($sps_needed as $sp) {
    $query = "
    SELECT proname, pronargs
    FROM pg_proc
    WHERE proname = '$sp'
    ";
    $result = pg_query($conn, $query);
    $exists = pg_num_rows($result) > 0;
    $status = $exists ? "✓ EXISTE" : "✗ FALTA";
    echo "   $status: $sp\n";

    if ($exists) {
        $row = pg_fetch_assoc($result);
        echo "            (Parámetros: {$row['pronargs']})\n";
    }
}

// 5. Ejemplos de uso para el frontend
echo "\n\n=== EJEMPLOS DE PRUEBA ===\n";

if (!empty($multas_vigentes)) {
    $ejemplo = $multas_vigentes[0];
    echo "\n📋 EJEMPLO 1: Buscar multas\n";
    echo "   URL: http://localhost:3000/multas_reglamentos/bloqueo-multa\n";
    echo "   Cuenta: {$ejemplo['folio']}\n";
    echo "   Año: {$ejemplo['ejercicio']}\n";
    echo "   → Debe mostrar la multa con folio {$ejemplo['folio']}\n";

    echo "\n🔒 EJEMPLO 2: Bloquear multa\n";
    echo "   1. Buscar multa con folio: {$ejemplo['folio']}\n";
    echo "   2. Hacer clic en el botón de bloquear (candado amarillo)\n";
    echo "   3. Ingresar motivo: 'Prueba de bloqueo - revisión administrativa'\n";
    echo "   4. Confirmar bloqueo\n";
    echo "   → CVEReq a bloquear: {$ejemplo['cvereq']}\n";
}

if (!empty($multas_bloqueadas)) {
    $ejemplo = $multas_bloqueadas[0];
    echo "\n🔓 EJEMPLO 3: Desbloquear multa\n";
    echo "   1. Buscar multa con folio: {$ejemplo['folio']}\n";
    echo "   2. Hacer clic en el botón de desbloquear (candado verde)\n";
    echo "   3. Ingresar motivo: 'Prueba de desbloqueo - fin de revisión'\n";
    echo "   4. Confirmar desbloqueo\n";
    echo "   → CVEReq a desbloquear: {$ejemplo['cvereq']}\n";
} else {
    echo "\n🔓 EJEMPLO 3: Desbloquear multa\n";
    echo "   (Primero bloquea una multa usando el EJEMPLO 2)\n";
}

// 6. Generar consulta SQL directa
if (!empty($multas_vigentes)) {
    $ejemplo = $multas_vigentes[0];
    echo "\n\n=== CONSULTA SQL PARA VERIFICACIÓN ===\n";
    echo "
-- Ver detalles de la multa de ejemplo
SELECT cvereq, folioreq, axoreq, vigencia, multas, total, obs
FROM catastro_gdl.reqmultas
WHERE cvereq = {$ejemplo['cvereq']};

-- Llamar al SP directamente
SELECT * FROM recaudadora_bloqueo_multa(
    '{$ejemplo['folio']}',  -- p_clave_cuenta
    {$ejemplo['ejercicio']}, -- p_ejercicio
    0,                       -- p_offset
    10                       -- p_limit
);
";
}

echo "\n✅ Script completado.\n";

pg_close($conn);

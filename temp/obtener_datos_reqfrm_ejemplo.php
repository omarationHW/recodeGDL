<?php
// Obtener datos de ejemplo para probar ReqFrm.vue
$conn = pg_connect("host=192.168.6.146 port=5432 dbname=padron_licencias user=refact password=FF)-BQk2");

if (!$conn) {
    die("Error de conexión\n");
}

echo "=== DATOS DE EJEMPLO PARA REQFRM.VUE ===\n\n";

// Buscar cuentas con multas válidas
echo "--- CUENTAS CON MULTAS (para usar como ejemplo) ---\n";
$query1 = "
SELECT DISTINCT
    m.clave_cta as cuenta,
    m.folio,
    m.ejercicio,
    m.estatus,
    COUNT(*) OVER (PARTITION BY m.clave_cta) as total_multas
FROM db_ingresos.multas m
WHERE m.clave_cta IS NOT NULL
    AND m.folio IS NOT NULL
    AND m.ejercicio >= 2020
ORDER BY m.ejercicio DESC, m.folio DESC
LIMIT 10";

$result1 = pg_query($conn, $query1);
if ($result1) {
    $ejemplos = [];
    while ($row = pg_fetch_assoc($result1)) {
        echo sprintf(
            "Cuenta: %-15s | Folio: %-8s | Año: %s | Estatus: %s | Total multas cuenta: %s\n",
            $row['cuenta'],
            $row['folio'],
            $row['ejercicio'],
            $row['estatus'] ?: 'N/A',
            $row['total_multas']
        );

        if (count($ejemplos) < 3) {
            $ejemplos[] = $row;
        }
    }

    echo "\n--- EJEMPLOS RECOMENDADOS PARA PRUEBAS ---\n";
    foreach ($ejemplos as $i => $ej) {
        echo "\nEjemplo #" . ($i + 1) . ":\n";
        echo "  Cuenta: " . $ej['cuenta'] . "\n";
        echo "  Folio: " . $ej['folio'] . "\n";
        echo "  Año: " . $ej['ejercicio'] . "\n";
    }
}

// Verificar requerimientos existentes
echo "\n\n--- REQUERIMIENTOS EXISTENTES (para referencia) ---\n";
$query2 = "
SELECT
    cvereq,
    cve_cuenta,
    folio,
    ejercicio,
    fecha_requerimiento,
    vigente
FROM db_ingresos.reqmultas
WHERE vigente = 'S'
ORDER BY fecha_requerimiento DESC
LIMIT 5";

$result2 = pg_query($conn, $query2);
if ($result2) {
    while ($row = pg_fetch_assoc($result2)) {
        echo sprintf(
            "CVE Req: %-8s | Cuenta: %-15s | Folio: %-8s | Año: %s | Fecha: %s\n",
            $row['cvereq'],
            $row['cve_cuenta'],
            $row['folio'],
            $row['ejercicio'],
            $row['fecha_requerimiento']
        );
    }
}

// Verificar estructura de tabla reqmultas para entender qué se puede crear
echo "\n\n--- INFORMACIÓN DE TABLA REQMULTAS ---\n";
$query3 = "
SELECT column_name, data_type, is_nullable
FROM information_schema.columns
WHERE table_schema = 'db_ingresos'
    AND table_name = 'reqmultas'
ORDER BY ordinal_position";

$result3 = pg_query($conn, $query3);
if ($result3) {
    while ($row = pg_fetch_assoc($result3)) {
        echo sprintf(
            "%-25s | %-20s | Nullable: %s\n",
            $row['column_name'],
            $row['data_type'],
            $row['is_nullable']
        );
    }
}

pg_close($conn);
echo "\n✓ Consulta completada\n";

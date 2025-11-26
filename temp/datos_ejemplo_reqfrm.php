<?php
// Obtener datos de ejemplo para ReqFrm.vue desde schema comun
$conn = pg_connect("host=192.168.6.146 port=5432 dbname=padron_licencias user=refact password=FF)-BQk2");

if (!$conn) {
    die("Error de conexión\n");
}

echo "=== DATOS DE EJEMPLO PARA REQFRM.VUE ===\n\n";

// Buscar cuentas con multas válidas en schema comun
echo "--- MULTAS DISPONIBLES (schema: comun) ---\n";
$query1 = "
SELECT
    m.clave_cta as cuenta,
    m.folio,
    m.ejercicio,
    m.estatus,
    m.fecha_hora_alta,
    m.importe
FROM comun.multas m
WHERE m.clave_cta IS NOT NULL
    AND m.folio IS NOT NULL
    AND m.ejercicio >= 2020
    AND m.ejercicio <= 2025
ORDER BY m.ejercicio DESC, m.fecha_hora_alta DESC
LIMIT 15";

$result1 = pg_query($conn, $query1);
if ($result1) {
    $ejemplos = [];
    $count = 0;
    while ($row = pg_fetch_assoc($result1)) {
        echo sprintf(
            "Cuenta: %-20s | Folio: %-10s | Año: %s | Estatus: %-5s | Importe: $%s\n",
            $row['cuenta'],
            $row['folio'],
            $row['ejercicio'],
            $row['estatus'] ?: 'N/A',
            number_format($row['importe'], 2)
        );

        if ($count < 5) {
            $ejemplos[] = $row;
            $count++;
        }
    }

    echo "\n\n╔═══════════════════════════════════════════════════════════╗\n";
    echo "║        EJEMPLOS PARA COPIAR Y PEGAR EN EL FRONTEND       ║\n";
    echo "╚═══════════════════════════════════════════════════════════╝\n";

    foreach ($ejemplos as $i => $ej) {
        echo "\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n";
        echo "  EJEMPLO #" . ($i + 1) . "\n";
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n";
        echo "  Cuenta:  " . $ej['cuenta'] . "\n";
        echo "  Folio:   " . $ej['folio'] . "\n";
        echo "  Año:     " . $ej['ejercicio'] . "\n";
        echo "  Estatus: " . ($ej['estatus'] ?: 'N/A') . "\n";
        echo "  Importe: $" . number_format($ej['importe'], 2) . "\n";
    }
}

// Verificar requerimientos existentes
echo "\n\n--- REQUERIMIENTOS YA CREADOS (para referencia) ---\n";
$query2 = "
SELECT
    cvereq,
    cve_cuenta,
    folio,
    ejercicio,
    fecha_requerimiento,
    vigente,
    importe
FROM comun.reqmultas
WHERE vigente = 'S'
ORDER BY fecha_requerimiento DESC
LIMIT 10";

$result2 = pg_query($conn, $query2);
if ($result2 && pg_num_rows($result2) > 0) {
    while ($row = pg_fetch_assoc($result2)) {
        echo sprintf(
            "CVE Req: %-10s | Cuenta: %-20s | Folio: %-10s | Año: %s | Vigente: %s\n",
            $row['cvereq'],
            $row['cve_cuenta'],
            $row['folio'],
            $row['ejercicio'],
            $row['vigente']
        );
    }
} else {
    echo "No se encontraron requerimientos vigentes.\n";
}

// Verificar el SP que se va a usar
echo "\n\n--- STORED PROCEDURE A UTILIZAR ---\n";
$query3 = "
SELECT routine_name, routine_schema
FROM information_schema.routines
WHERE routine_name ILIKE '%req_frm_save%'
    AND routine_type = 'FUNCTION'";

$result3 = pg_query($conn, $query3);
if ($result3 && pg_num_rows($result3) > 0) {
    while ($row = pg_fetch_assoc($result3)) {
        echo "  ✓ " . $row['routine_schema'] . "." . $row['routine_name'] . "\n";
    }
} else {
    echo "  ⚠ No se encontró el SP recaudadora_req_frm_save\n";
}

pg_close($conn);

echo "\n\n╔═══════════════════════════════════════════════════════════╗\n";
echo "║                    INSTRUCCIONES                          ║\n";
echo "╚═══════════════════════════════════════════════════════════╝\n";
echo "\n";
echo "1. Abre el formulario en: http://localhost:3001\n";
echo "2. Navega al módulo: Multas y Reglamentos > Requerimiento (Formulario)\n";
echo "3. Copia uno de los ejemplos de arriba y pégalo en el formulario\n";
echo "4. Haz clic en 'Guardar'\n";
echo "5. Verifica que aparezca el mensaje de éxito con el CVE del requerimiento\n";
echo "\n✓ Script completado\n";

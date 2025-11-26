<?php
// Preparar datos de prueba para ReqFrm.vue
$conn = pg_connect("host=192.168.6.146 port=5432 dbname=padron_licencias user=refact password=FF)-BQk2");

if (!$conn) {
    die("Error de conexión\n");
}

echo "╔═══════════════════════════════════════════════════════════╗\n";
echo "║       DATOS DE EJEMPLO PARA REQFRM.VUE                    ║\n";
echo "╚═══════════════════════════════════════════════════════════╝\n\n";

// Verificar tabla reqdiftransmision
echo "--- VERIFICANDO TABLA catastro_gdl.reqdiftransmision ---\n";
$query1 = "
SELECT column_name, data_type
FROM information_schema.columns
WHERE table_schema = 'catastro_gdl'
    AND table_name = 'reqdiftransmision'
ORDER BY ordinal_position";

$result1 = pg_query($conn, $query1);
if ($result1 && pg_num_rows($result1) > 0) {
    echo "✓ Tabla encontrada. Columnas:\n";
    while ($row = pg_fetch_assoc($result1)) {
        echo "  - " . $row['column_name'] . " (" . $row['data_type'] . ")\n";
    }
} else {
    echo "⚠ Tabla no encontrada en catastro_gdl\n";
}

// Ver registros existentes
echo "\n--- REQUERIMIENTOS EXISTENTES ---\n";
$query2 = "
SELECT cvereq, cvecuenta, folioreq, axoreq, total, vigencia
FROM catastro_gdl.reqdiftransmision
ORDER BY cvereq DESC
LIMIT 5";

$result2 = pg_query($conn, $query2);
if ($result2 && pg_num_rows($result2) > 0) {
    while ($row = pg_fetch_assoc($result2)) {
        echo sprintf(
            "CVE: %-8s | Cuenta: %-10s | Folio: %-8s | Año: %s | Total: $%.2f | Vigencia: %s\n",
            $row['cvereq'],
            $row['cvecuenta'],
            $row['folioreq'],
            $row['axoreq'],
            $row['total'],
            $row['vigencia']
        );
    }
} else {
    echo "No hay requerimientos existentes (tabla vacía o no existe)\n";
}

echo "\n\n╔═══════════════════════════════════════════════════════════╗\n";
echo "║              EJEMPLOS PARA COPIAR Y PEGAR                 ║\n";
echo "╚═══════════════════════════════════════════════════════════╝\n\n";

// Generar ejemplos que no existan
$ejemplos = [
    ['cuenta' => 12345, 'folio' => 1001, 'ejercicio' => 2024],
    ['cuenta' => 67890, 'folio' => 1002, 'ejercicio' => 2024],
    ['cuenta' => 11111, 'folio' => 2001, 'ejercicio' => 2025],
    ['cuenta' => 22222, 'folio' => 2002, 'ejercicio' => 2025],
    ['cuenta' => 33333, 'folio' => 3001, 'ejercicio' => 2025],
];

$valid_ejemplos = [];

foreach ($ejemplos as $ej) {
    // Verificar si ya existe
    $check = pg_query_params(
        $conn,
        "SELECT 1 FROM catastro_gdl.reqdiftransmision
         WHERE cvecuenta = $1 AND folioreq = $2 AND axoreq = $3",
        [$ej['cuenta'], $ej['folio'], $ej['ejercicio']]
    );

    if ($check && pg_num_rows($check) == 0) {
        $valid_ejemplos[] = $ej;
    }
}

// Si no hay ejemplos válidos, usar los ejemplos de todas formas
if (empty($valid_ejemplos)) {
    $valid_ejemplos = $ejemplos;
    echo "⚠ NOTA: Los siguientes ejemplos podrían ya existir en la BD.\n";
    echo "Si aparece error, cambia los valores de Cuenta y/o Folio.\n\n";
}

foreach ($valid_ejemplos as $i => $ej) {
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n";
    echo "  EJEMPLO #" . ($i + 1) . "\n";
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n";
    echo "  Cuenta:   " . $ej['cuenta'] . "\n";
    echo "  Folio:    " . $ej['folio'] . "\n";
    echo "  Año:      " . $ej['ejercicio'] . "\n";
    echo "\n";
}

echo "\n╔═══════════════════════════════════════════════════════════╗\n";
echo "║                      INSTRUCCIONES                        ║\n";
echo "╚═══════════════════════════════════════════════════════════╝\n\n";
echo "1. Abre tu navegador en: http://localhost:3001\n";
echo "\n";
echo "2. Navega al módulo:\n";
echo "   Multas y Reglamentos > Requerimiento (Formulario)\n";
echo "\n";
echo "3. Ingresa los datos de uno de los ejemplos:\n";
echo "   - Copia el número de Cuenta\n";
echo "   - Copia el número de Folio\n";
echo "   - Copia el Año (o usa el año actual que aparece por defecto)\n";
echo "\n";
echo "4. Haz clic en el botón 'Guardar'\n";
echo "\n";
echo "5. Si todo funciona correctamente verás:\n";
echo "   ✓ Mensaje de éxito\n";
echo "   ✓ ID del requerimiento creado (cvereq)\n";
echo "   ✓ El formulario se limpiará automáticamente\n";
echo "\n";
echo "6. Si hay error, verifica:\n";
echo "   - Que los servidores estén corriendo (backend y frontend)\n";
echo "   - Que la cuenta y folio no existan ya en la BD\n";
echo "   - Los logs de la consola del navegador (F12)\n";
echo "\n";

// Información de los servidores
echo "╔═══════════════════════════════════════════════════════════╗\n";
echo "║                   SERVIDORES ACTIVOS                      ║\n";
echo "╚═══════════════════════════════════════════════════════════╝\n\n";
echo "Backend:  http://127.0.0.1:8000\n";
echo "Frontend: http://localhost:3001\n";
echo "BD:       192.168.6.146:5432 (padron_licencias)\n";
echo "\n";

pg_close($conn);
echo "✓ Script completado exitosamente\n";

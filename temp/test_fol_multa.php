<?php
echo "=== PRUEBAS DEL SP: recaudadora_fol_multa ===\n\n";

$conn = pg_connect('host=192.168.6.146 port=5432 dbname=padron_licencias user=refact password=FF)-BQk2');

if (!$conn) {
    die("Error de conexión a la base de datos\n");
}

// EJEMPLO 1: Multa pagada
echo "EJEMPLO 1: Consultar multa del acta 586 del año 2002 (PAGADA)\n";
echo "-----------------------------------------------------------\n";
$query = "SELECT * FROM db_ingresos.recaudadora_fol_multa('586', 2002)";
$result = pg_query($conn, $query);

if ($result) {
    $row = pg_fetch_assoc($result);
    if ($row) {
        echo "✓ Folio: " . $row['folio'] . "\n";
        echo "  Acta: " . $row['numero_acta'] . " del año " . $row['axo_acta'] . "\n";
        echo "  Contribuyente: " . $row['nombre'] . "\n";
        echo "  Domicilio: " . $row['domicilio'] . "\n";
        echo "  Importe a pagar: $" . $row['importe_pagar'] . "\n";
        echo "  Estado: " . $row['estado'] . "\n";
        echo "  Fecha de pago: " . ($row['fecha_pago'] ?? 'N/A') . "\n";
    } else {
        echo "✗ No se encontró la multa\n";
    }
} else {
    echo "✗ Error: " . pg_last_error($conn) . "\n";
}

echo "\n\n";

// EJEMPLO 2: Multa activa sin pagar
echo "EJEMPLO 2: Consultar multa del acta 616 del año 2002 (ACTIVA SIN PAGAR)\n";
echo "-----------------------------------------------------------------------\n";
$query = "SELECT * FROM db_ingresos.recaudadora_fol_multa('616', 2002)";
$result = pg_query($conn, $query);

if ($result) {
    $row = pg_fetch_assoc($result);
    if ($row) {
        echo "✓ Folio: " . $row['folio'] . "\n";
        echo "  Acta: " . $row['numero_acta'] . " del año " . $row['axo_acta'] . "\n";
        echo "  Contribuyente: " . $row['nombre'] . "\n";
        echo "  Domicilio: " . $row['domicilio'] . "\n";
        echo "  Importe inicial: $" . $row['importe_inicial'] . "\n";
        echo "  Importe a pagar: $" . $row['importe_pagar'] . "\n";
        echo "  Estado: " . $row['estado'] . "\n";
        echo "  Fecha de pago: " . ($row['fecha_pago'] ?? 'N/A') . "\n";
        echo "  Licencia: " . ($row['numero_licencia'] ?? 'N/A') . "\n";
    } else {
        echo "✗ No se encontró la multa\n";
    }
} else {
    echo "✗ Error: " . pg_last_error($conn) . "\n";
}

echo "\n\n";

// EJEMPLO 3: Multa pendiente
echo "EJEMPLO 3: Consultar multa del acta 619 del año 2002 (ACTIVA)\n";
echo "--------------------------------------------------------------\n";
$query = "SELECT * FROM db_ingresos.recaudadora_fol_multa('619', 2002)";
$result = pg_query($conn, $query);

if ($result) {
    $row = pg_fetch_assoc($result);
    if ($row) {
        echo "✓ Folio: " . $row['folio'] . "\n";
        echo "  Acta: " . $row['numero_acta'] . " del año " . $row['axo_acta'] . "\n";
        echo "  Contribuyente: " . $row['nombre'] . "\n";
        echo "  Domicilio: " . $row['domicilio'] . "\n";
        echo "  Actividad/Giro: " . ($row['actividad_giro'] ?? 'N/A') . "\n";
        echo "  Importe inicial: $" . $row['importe_inicial'] . "\n";
        echo "  Importe a pagar: $" . $row['importe_pagar'] . "\n";
        echo "  Estado: " . $row['estado'] . "\n";
        echo "  Vigencia: " . $row['vigencia'] . "\n";
        echo "  Zona: " . $row['numero_zona'] . " / Subzona: " . $row['sub_zona'] . "\n";
    } else {
        echo "✗ No se encontró la multa\n";
    }
} else {
    echo "✗ Error: " . pg_last_error($conn) . "\n";
}

echo "\n\n";

// EJEMPLO 4: Multa inexistente
echo "EJEMPLO 4: Intentar consultar multa inexistente (acta 99999 del año 2099)\n";
echo "--------------------------------------------------------------------------\n";
$query = "SELECT * FROM db_ingresos.recaudadora_fol_multa('99999', 2099)";
$result = pg_query($conn, $query);

if ($result) {
    $row = pg_fetch_assoc($result);
    if ($row) {
        echo "✓ Se encontró: " . json_encode($row) . "\n";
    } else {
        echo "✓ Comportamiento correcto: No se encontró la multa (resultado vacío)\n";
    }
} else {
    echo "✗ Error: " . pg_last_error($conn) . "\n";
}

pg_close($conn);
echo "\n=== FIN DE LAS PRUEBAS ===\n";

<?php
$host = '192.168.6.146';
$port = '5432';
$db = 'padron_licencias';
$user = 'refact';
$pass = 'FF)-BQk2';

$conn = pg_connect("host=$host port=$port dbname=$db user=$user password=$pass");

if (!$conn) {
    die("Error de conexión\n");
}

echo "=== PRUEBA DEL SP recaudadora_consmulpagos ===\n\n";

// Prueba 1: Con cvepago específico
echo "Prueba 1: Buscar pago con cvepago = 13878081\n";
echo "--------------------------------------------\n";
$query1 = "SELECT * FROM multas_reglamentos.recaudadora_consmulpagos('13878081')";
$result1 = pg_query($conn, $query1);

if ($result1) {
    $row = pg_fetch_assoc($result1);
    if ($row) {
        echo "✓ Resultado encontrado:\n";
        echo json_encode($row, JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE);
        echo "\n";
    } else {
        echo "No se encontraron resultados\n";
    }
} else {
    echo "✗ Error: " . pg_last_error($conn) . "\n";
}

echo "\n\n";

// Prueba 2: Sin parámetro (debería listar todos)
echo "Prueba 2: Listar todos los pagos (sin parámetro)\n";
echo "--------------------------------------------\n";
$query2 = "SELECT * FROM multas_reglamentos.recaudadora_consmulpagos(NULL) LIMIT 3";
$result2 = pg_query($conn, $query2);

if ($result2) {
    $count = 0;
    while ($row = pg_fetch_assoc($result2)) {
        $count++;
        echo "Registro $count:\n";
        echo "  cvepago: {$row['cvepago']}\n";
        echo "  contribuyente: {$row['contribuyente']}\n";
        echo "  fecha: {$row['fecha']}\n";
        echo "  importe: {$row['importe']}\n";
        echo "\n";
    }
    echo "✓ Total registros: $count\n";
} else {
    echo "✗ Error: " . pg_last_error($conn) . "\n";
}

pg_close($conn);
echo "\n=== FIN DE PRUEBAS ===\n";

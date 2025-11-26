<?php
$conn = pg_connect('host=192.168.6.146 port=5432 dbname=padron_licencias user=refact password=FF)-BQk2');
if (!$conn) die('Error de conexion');
$sql = file_get_contents(__DIR__ . '/../RefactorX/Base/multas_reglamentos/database/generated/recaudadora_get_ejecutores.sql');
$result = pg_query($conn, $sql);
if ($result) {
    echo 'SP desplegado exitosamente' . PHP_EOL;
    $test = pg_query($conn, 'SELECT * FROM recaudadora_get_ejecutores()');
    echo 'Ejecutores encontrados: ' . pg_num_rows($test) . PHP_EOL;
} else {
    echo 'Error: ' . pg_last_error($conn) . PHP_EOL;
}
pg_close($conn);
?>

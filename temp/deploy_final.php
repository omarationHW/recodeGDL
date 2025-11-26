<?php
$conn = pg_connect('host=192.168.6.146 port=5432 dbname=padron_licencias user=refact password=FF)-BQk2');
$sql = file_get_contents(__DIR__ . '/../RefactorX/Base/multas_reglamentos/database/generated/recaudadora_get_ejecutores.sql');
echo 'Desplegando SP corregido...' . PHP_EOL;
$result = pg_query($conn, $sql);
if ($result) {
    echo 'SP desplegado exitosamente' . PHP_EOL . PHP_EOL;
    echo 'Probando SP...' . PHP_EOL;
    $test = pg_query($conn, 'SELECT * FROM recaudadora_get_ejecutores() LIMIT 5');
    if ($test) {
        $count = pg_num_rows($test);
        echo 'Ejecutores encontrados: ' . $count . PHP_EOL . PHP_EOL;
        if ($count > 0) {
            echo 'Primeros ejecutores:' . PHP_EOL;
            while ($row = pg_fetch_assoc($test)) {
                echo '  - ID: ' . $row['cveejecutor'] . ' | Nombre: ' . $row['empresa'] . PHP_EOL;
            }
        }
    }
} else {
    echo 'Error: ' . pg_last_error($conn) . PHP_EOL;
}
pg_close($conn);

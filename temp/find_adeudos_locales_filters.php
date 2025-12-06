<?php
$conn = pg_connect('host=192.168.6.146 port=5432 dbname=padron_licencias user=refact password=FF)-BQk2');
if (!$conn) { echo 'Error conexion'; exit; }

// Buscar combinaciones válidas de adeudos
$query = "
    SELECT DISTINCT
        a.oficina,
        a.axo,
        a.periodo,
        COUNT(*) as total_adeudos
    FROM comun.ta_11_adeudo_local a
    WHERE a.axo >= 2020
      AND a.periodo BETWEEN 1 AND 12
    GROUP BY a.oficina, a.axo, a.periodo
    ORDER BY a.axo DESC, a.periodo DESC, total_adeudos DESC
    LIMIT 10
";

$result = pg_query($conn, $query);
if ($result) {
    echo 'COMBINACIONES VALIDAS CON ADEUDOS:' . PHP_EOL;
    echo str_repeat('-', 60) . PHP_EOL;
    printf('%-10s %-10s %-10s %-15s' . PHP_EOL, 'Oficina', 'Año', 'Periodo', 'Total Adeudos');
    echo str_repeat('-', 60) . PHP_EOL;
    
    $first = null;
    while ($row = pg_fetch_assoc($result)) {
        printf('%-10s %-10s %-10s %-15s' . PHP_EOL, 
            $row['oficina'], 
            $row['axo'], 
            $row['periodo'], 
            $row['total_adeudos']
        );
        if (!$first) $first = $row;
    }
    
    if ($first) {
        echo PHP_EOL . str_repeat('=', 60) . PHP_EOL;
        echo 'RECOMENDACION:' . PHP_EOL;
        echo str_repeat('=', 60) . PHP_EOL;
        echo 'Oficina: ' . $first['oficina'] . PHP_EOL;
        echo 'Año: ' . $first['axo'] . PHP_EOL;
        echo 'Periodo: ' . $first['periodo'] . PHP_EOL;
        echo 'Total de registros: ' . $first['total_adeudos'] . PHP_EOL;
    }
}

pg_close($conn);
?>

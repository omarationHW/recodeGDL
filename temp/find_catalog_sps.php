<?php
// Script para encontrar SPs de catálogos en las bases de datos

$databases = ['padron_licencias', 'mercados'];
$search_patterns = ['seccion', 'categoria', 'cuota', 'zona'];

foreach ($databases as $db) {
    echo "\n====== BASE DE DATOS: $db ======\n";

    $conn = pg_connect("host=192.168.6.146 port=5432 dbname=$db user=refact password=FF)-BQk2");

    if (!$conn) {
        echo "Error al conectar a $db\n";
        continue;
    }

    foreach ($search_patterns as $pattern) {
        echo "\n--- Buscando SPs con '$pattern' ---\n";

        $query = "SELECT proname, pronargs
                  FROM pg_proc
                  WHERE proname LIKE 'sp_%'
                    AND proname LIKE '%$pattern%'
                  ORDER BY proname";

        $result = pg_query($conn, $query);

        if ($result) {
            $found = false;
            while ($row = pg_fetch_assoc($result)) {
                echo "  ✓ {$row['proname']} (args: {$row['pronargs']})\n";
                $found = true;
            }
            if (!$found) {
                echo "  ✗ No se encontraron SPs\n";
            }
        }
    }

    pg_close($conn);
}

echo "\n====== FIN ======\n";
?>

<?php
// Script para buscar tablas y SPs de giros

$databases = ['padron_licencias', 'mercados'];

foreach ($databases as $db) {
    echo "\n====== BASE DE DATOS: $db ======\n";

    $conn = pg_connect("host=192.168.6.146 port=5432 dbname=$db user=refact password=FF)-BQk2");

    if (!$conn) {
        echo "Error al conectar a $db\n";
        continue;
    }

    // Buscar tablas con 'giro'
    echo "\n--- TABLAS CON 'giro' ---\n";
    $query = "SELECT table_schema, table_name
              FROM information_schema.tables
              WHERE table_schema IN ('public', 'comun', 'comunX')
                AND table_name LIKE '%giro%'
              ORDER BY table_schema, table_name";

    $result = pg_query($conn, $query);
    if ($result) {
        $found = false;
        while ($row = pg_fetch_assoc($result)) {
            echo "  ✓ {$row['table_schema']}.{$row['table_name']}\n";
            $found = true;
        }
        if (!$found) {
            echo "  ✗ No se encontraron tablas\n";
        }
    }

    // Buscar SPs con 'giro'
    echo "\n--- SPs CON 'giro' ---\n";
    $query = "SELECT proname, pronargs
              FROM pg_proc
              WHERE proname LIKE '%giro%'
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

    pg_close($conn);
}

echo "\n====== FIN ======\n";
?>

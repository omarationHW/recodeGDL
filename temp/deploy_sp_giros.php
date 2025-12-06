<?php
// Script para desplegar el SP de giros

$conn = pg_connect("host=192.168.6.146 port=5432 dbname=padron_licencias user=refact password=FF)-BQk2");

if (!$conn) {
    echo "❌ Error al conectar a la base de datos\n";
    exit(1);
}

echo "✓ Conectado a padron_licencias\n\n";

// Leer el archivo SQL
$sql = file_get_contents('temp/create_sp_giros_list.sql');

// Ejecutar el SQL
$result = pg_query($conn, $sql);

if ($result) {
    echo "✓ SP sp_get_giros_vigentes creado exitosamente\n\n";

    // Probar el SP
    echo "Probando el SP...\n";
    $test_query = "SELECT * FROM sp_get_giros_vigentes() LIMIT 5";
    $test_result = pg_query($conn, $test_query);

    if ($test_result) {
        echo "\nPrimeros 5 giros:\n";
        while ($row = pg_fetch_assoc($test_result)) {
            echo "  {$row['id_giro']} - {$row['descripcion']}\n";
        }

        // Contar total
        $count_query = "SELECT COUNT(*) as total FROM sp_get_giros_vigentes()";
        $count_result = pg_query($conn, $count_query);
        $count = pg_fetch_assoc($count_result);
        echo "\n✓ Total de giros vigentes: {$count['total']}\n";
    } else {
        echo "❌ Error al probar el SP: " . pg_last_error($conn) . "\n";
    }
} else {
    echo "❌ Error al crear el SP: " . pg_last_error($conn) . "\n";
}

pg_close($conn);
?>

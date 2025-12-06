<?php
// Probar CRUD completo de cuotas de energía

$conn = pg_connect("host=192.168.6.146 port=5432 dbname=mercados user=refact password=FF)-BQk2");

if (!$conn) {
    echo "❌ Error de conexión\n";
    exit(1);
}

echo "=== PRUEBA CRUD DE CUOTAS ENERGIA ===\n\n";

// Test 1: Listar cuotas existentes
echo "Test 1: Listar cuotas existentes\n";
echo str_repeat("-", 80) . "\n";

$result = pg_query($conn, "SELECT * FROM sp_list_cuotas_energia(NULL, NULL) LIMIT 5");

if ($result) {
    $count = pg_num_rows($result);
    echo "✅ Listado exitoso: {$count} cuotas encontradas\n";
    if ($count > 0) {
        echo "\nPrimeros 5 registros:\n";
        while ($row = pg_fetch_assoc($result)) {
            echo sprintf(
                "  ID: %s | Año: %s | Periodo: %s | Cuota: $%s | Usuario: %s\n",
                $row['id_kilowhatts'],
                $row['axo'],
                $row['periodo'],
                number_format($row['importe'], 2),
                $row['usuario']
            );
        }
    }
} else {
    echo "❌ Error en listado: " . pg_last_error($conn) . "\n";
}

echo "\n" . str_repeat("=", 80) . "\n\n";

// Test 2: Insertar nueva cuota de prueba
echo "Test 2: Insertar nueva cuota de prueba\n";
echo str_repeat("-", 80) . "\n";

$axo_test = date('Y');
$periodo_test = 12; // Diciembre
$importe_test = 999.99;
$id_usuario_test = 1;

$query_insert = "SELECT * FROM sp_insert_cuota_energia($axo_test::smallint, $periodo_test::smallint, $importe_test, $id_usuario_test)";
echo "Query: $query_insert\n";

$result_insert = pg_query($conn, $query_insert);

if ($result_insert && pg_num_rows($result_insert) > 0) {
    $row = pg_fetch_assoc($result_insert);
    $id_inserted = $row['id_kilowhatts'];
    echo "✅ Cuota insertada exitosamente\n";
    echo "  ID generado: {$id_inserted}\n";
    echo "  Año: {$row['axo']}\n";
    echo "  Periodo: {$row['periodo']}\n";
    echo "  Importe: \${$row['importe']}\n";
    echo "  Fecha: {$row['fecha_alta']}\n";

    echo "\n" . str_repeat("=", 80) . "\n\n";

    // Test 3: Obtener la cuota recién insertada
    echo "Test 3: Obtener cuota por ID\n";
    echo str_repeat("-", 80) . "\n";

    $result_get = pg_query($conn, "SELECT * FROM sp_get_cuota_energia($id_inserted)");

    if ($result_get && pg_num_rows($result_get) > 0) {
        $row_get = pg_fetch_assoc($result_get);
        echo "✅ Cuota obtenida exitosamente\n";
        echo "  ID: {$row_get['id_kilowhatts']}\n";
        echo "  Año: {$row_get['axo']}\n";
        echo "  Periodo: {$row_get['periodo']}\n";
        echo "  Importe: \${$row_get['importe']}\n";
    } else {
        echo "❌ Error al obtener cuota: " . pg_last_error($conn) . "\n";
    }

    echo "\n" . str_repeat("=", 80) . "\n\n";

    // Test 4: Actualizar la cuota
    echo "Test 4: Actualizar cuota\n";
    echo str_repeat("-", 80) . "\n";

    $importe_nuevo = 1500.50;
    $query_update = "SELECT * FROM sp_update_cuota_energia($id_inserted, $axo_test::smallint, $periodo_test::smallint, $importe_nuevo, $id_usuario_test)";
    echo "Query: $query_update\n";

    $result_update = pg_query($conn, $query_update);

    if ($result_update && pg_num_rows($result_update) > 0) {
        $row_update = pg_fetch_assoc($result_update);
        echo "✅ Cuota actualizada exitosamente\n";
        echo "  ID: {$row_update['id_kilowhatts']}\n";
        echo "  Importe anterior: \$$importe_test\n";
        echo "  Importe nuevo: \${$row_update['importe']}\n";
        echo "  Fecha actualización: {$row_update['fecha_alta']}\n";
    } else {
        echo "❌ Error al actualizar cuota: " . pg_last_error($conn) . "\n";
    }

    echo "\n" . str_repeat("=", 80) . "\n\n";

    // Test 5: Eliminar la cuota de prueba
    echo "Test 5: Limpiar datos de prueba\n";
    echo str_repeat("-", 80) . "\n";

    $result_delete = pg_query($conn, "DELETE FROM public.ta_11_kilowhatts WHERE id_kilowhatts = $id_inserted");

    if ($result_delete) {
        echo "✅ Cuota de prueba eliminada exitosamente\n";
    } else {
        echo "❌ Error al eliminar cuota: " . pg_last_error($conn) . "\n";
    }

} else {
    echo "❌ Error al insertar cuota: " . pg_last_error($conn) . "\n";
}

echo "\n" . str_repeat("=", 80) . "\n";
echo "=== PRUEBAS COMPLETADAS ===\n";
echo str_repeat("=", 80) . "\n";

pg_close($conn);

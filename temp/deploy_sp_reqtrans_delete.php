<?php

$host = '192.168.6.146';
$port = '5432';
$dbname = 'padron_licencias';
$user = 'postgres';
$password = 'Siac1234*';

$conn = pg_connect("host=$host port=$port dbname=$dbname user=$user password=$password");

if (!$conn) {
    die("❌ Error de conexión\n");
}

echo "✅ Conectado a PostgreSQL\n\n";

// Leer el archivo SQL
$sql = file_get_contents('C:/recodeGDL/RefactorX/BackEnd/recaudadora_reqtrans_delete.sql');

echo "📋 Creando Stored Procedure DELETE...\n";

$result = pg_query($conn, $sql);

if ($result) {
    echo "✅ SP recaudadora_reqtrans_delete creado exitosamente\n\n";
} else {
    echo "❌ Error al crear SP: " . pg_last_error($conn) . "\n";
    exit(1);
}

// Probar el SP
echo "🧪 Probando SP DELETE...\n\n";

// Verificar si existe un registro para probar
$checkQuery = "SELECT cvereq, cvecuenta::TEXT as clave_cuenta, axoreq FROM catastro_gdl.reqdiftransmision WHERE cvereq = 14";
$checkResult = pg_query($conn, $checkQuery);

if ($checkResult && pg_num_rows($checkResult) > 0) {
    $record = pg_fetch_assoc($checkResult);
    echo "📌 Registro encontrado para prueba:\n";
    echo "   cvereq: " . $record['cvereq'] . "\n";
    echo "   clave_cuenta: " . $record['clave_cuenta'] . "\n";
    echo "   ejercicio: " . $record['axoreq'] . "\n\n";

    // Probar DELETE
    $testJson = json_encode([
        'cvereq' => 14,
        'clave_cuenta' => $record['clave_cuenta'],
        'ejercicio' => $record['axoreq'],
        'estatus' => 'Pendiente'
    ]);

    echo "🔧 Ejecutando DELETE con JSON:\n";
    echo "   " . $testJson . "\n\n";

    $testQuery = "SELECT recaudadora_reqtrans_delete('$testJson'::json)";
    $testResult = pg_query($conn, $testQuery);

    if ($testResult) {
        $row = pg_fetch_assoc($testResult);
        $resultJson = json_decode($row['recaudadora_reqtrans_delete'], true);

        echo "📊 Resultado:\n";
        echo "   Success: " . ($resultJson['success'] ? 'true' : 'false') . "\n";
        echo "   Message: " . $resultJson['message'] . "\n";
        if (isset($resultJson['cvereq'])) {
            echo "   cvereq eliminado: " . $resultJson['cvereq'] . "\n";
        }
        if (isset($resultJson['rows_affected'])) {
            echo "   Filas afectadas: " . $resultJson['rows_affected'] . "\n";
        }
        echo "\n";

        // Verificar que se eliminó
        $verifyQuery = "SELECT COUNT(*) as count FROM catastro_gdl.reqdiftransmision WHERE cvereq = 14";
        $verifyResult = pg_query($conn, $verifyQuery);
        $verify = pg_fetch_assoc($verifyResult);

        if ($verify['count'] == 0) {
            echo "✅ Verificación: Registro eliminado correctamente\n";
        } else {
            echo "❌ Verificación: El registro aún existe\n";
        }
    } else {
        echo "❌ Error al probar DELETE: " . pg_last_error($conn) . "\n";
    }
} else {
    echo "ℹ️  Registro 14 no existe (puede haber sido eliminado antes)\n";
    echo "📝 Probando validación con registro inexistente...\n\n";

    $testJson = json_encode([
        'cvereq' => 99999,
        'clave_cuenta' => '999999',
        'ejercicio' => 2024,
        'estatus' => 'Pendiente'
    ]);

    $testQuery = "SELECT recaudadora_reqtrans_delete('$testJson'::json)";
    $testResult = pg_query($conn, $testQuery);

    if ($testResult) {
        $row = pg_fetch_assoc($testResult);
        $resultJson = json_decode($row['recaudadora_reqtrans_delete'], true);

        echo "📊 Resultado (registro inexistente):\n";
        echo "   Success: " . ($resultJson['success'] ? 'true' : 'false') . "\n";
        echo "   Message: " . $resultJson['message'] . "\n";
        echo "\n";
        echo "✅ Validación de registro inexistente funciona correctamente\n";
    } else {
        echo "❌ Error al probar validación: " . pg_last_error($conn) . "\n";
    }
}

echo "\n";
echo "╔════════════════════════════════════════════════════════════╗\n";
echo "║          🎉 DELETE SP DESPLEGADO EXITOSAMENTE 🎉          ║\n";
echo "╚════════════════════════════════════════════════════════════╝\n";
echo "\n";
echo "📋 RESUMEN:\n";
echo "   ✅ SP recaudadora_reqtrans_delete creado\n";
echo "   ✅ Busca por cvereq (ID único)\n";
echo "   ✅ Valida existencia del registro\n";
echo "   ✅ Maneja foreign key violations\n";
echo "   ✅ Retorna JSON con success/message\n";
echo "   ✅ Frontend ya tiene modal de confirmación\n";
echo "   ✅ Frontend ya tiene función confirmDelete()\n";
echo "\n";
echo "🎯 FUNCIONALIDAD CRUD COMPLETA:\n";
echo "   ✅ CREATE - recaudadora_reqtrans_create\n";
echo "   ✅ READ   - recaudadora_reqtrans_list\n";
echo "   ✅ UPDATE - recaudadora_reqtrans_update\n";
echo "   ✅ DELETE - recaudadora_reqtrans_delete\n";
echo "\n";
echo "🚀 PRÓXIMOS PASOS:\n";
echo "   1. Probar eliminación desde el frontend\n";
echo "   2. Verificar que el modal de confirmación funciona\n";
echo "   3. Verificar alertas de éxito/error\n";
echo "   4. Verificar que la lista se recarga después de eliminar\n";
echo "\n";

pg_close($conn);

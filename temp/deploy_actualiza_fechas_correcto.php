<?php
/**
 * Script para desplegar SP recaudadora_actualiza_fechas
 * Base de datos: padron_licencias (correcta)
 */

$host = '192.168.6.146';
$port = '5432';
$dbname = 'padron_licencias';  // Base de datos correcta
$user = 'refact';
$password = 'FF)-BQk2';

try {
    $dsn = "pgsql:host=$host;port=$port;dbname=$dbname";
    $pdo = new PDO($dsn, $user, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "✅ Conectado a la base de datos: $dbname\n\n";

    // Leer el SP del archivo oficial
    $sqlFile = __DIR__ . '/../RefactorX/Base/multas_reglamentos/database/generated/recaudadora_actualiza_fechas.sql';

    if (!file_exists($sqlFile)) {
        throw new Exception("No se encontró el archivo: $sqlFile");
    }

    $sp = file_get_contents($sqlFile);

    echo "📝 Desplegando recaudadora_actualiza_fechas...\n";
    $pdo->exec($sp);
    echo "✅ SP desplegado correctamente\n\n";

    // Verificar que existe
    echo "🔍 Verificando SP desplegado...\n";
    $check = $pdo->query("
        SELECT routine_name, routine_schema
        FROM information_schema.routines
        WHERE routine_name = 'recaudadora_actualiza_fechas'
        ORDER BY routine_schema, routine_name
    ");

    $found = false;
    while ($row = $check->fetch(PDO::FETCH_ASSOC)) {
        echo "  ✅ {$row['routine_name']} - Schema: {$row['routine_schema']}\n";
        $found = true;
    }

    if (!$found) {
        throw new Exception("El SP no se encontró después del despliegue");
    }

    echo "\n✅ ¡Despliegue completado exitosamente!\n";
    echo "\n📝 Notas:\n";
    echo "  - Tabla: reqdiftransmision\n";
    echo "  - Campo actualizado: fecprac (fecha de práctica)\n";
    echo "  - Campos adicionales: cveejecut, fecentejec (si se proporciona ejecutor)\n";
    echo "  - Modo individual: Enviar clave_cuenta, folio, anio_folio, fecha_practica\n";
    echo "  - Modo lote: Enviar folios_json y fecha_practica\n";
    echo "  - Retorna: { aplicados: N, errores: [...] }\n";

} catch (Exception $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
    exit(1);
}

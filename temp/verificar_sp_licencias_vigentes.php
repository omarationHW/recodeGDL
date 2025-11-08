<?php
/**
 * Script para verificar y desplegar SP de Licencias Vigentes
 */

$host = '192.168.6.146';
$database = 'padron_licencias';
$username = 'refact';
$password = 'FF)-BQk2';

echo "========================================\n";
echo "VERIFICACIÓN SP LICENCIAS VIGENTES\n";
echo "========================================\n\n";

try {
    $dsn = "pgsql:host=$host;dbname=$database";
    $pdo = new PDO($dsn, $username, $password, [
        PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION
    ]);

    echo "✓ Conexión exitosa a PostgreSQL\n\n";

    // Verificar si el SP existe
    echo "Verificando si existe el SP...\n";
    $check = $pdo->query("
        SELECT EXISTS (
            SELECT 1
            FROM pg_proc p
            JOIN pg_namespace n ON p.pronamespace = n.oid
            WHERE n.nspname = 'public'
            AND p.proname = 'licenciasvigentesfrm_sp_licencias_vigentes'
        )
    ")->fetchColumn();

    if ($check) {
        echo "✓ SP ya existe en la base de datos\n\n";
    } else {
        echo "✗ SP NO existe, procediendo a crearlo...\n\n";
    }

    // Leer el archivo SQL
    $sqlFile = 'C:\\Sistemas\\RefactorX\\Guadalajara\\RecodePHP\\GDL\\temp\\LicenciasVigentesfrm_sp_licencias_vigentes_FIXED.sql';

    if (!file_exists($sqlFile)) {
        throw new Exception("Archivo SQL no encontrado: $sqlFile");
    }

    $sql = file_get_contents($sqlFile);

    echo "Ejecutando SP desde archivo...\n";
    $pdo->exec($sql);
    echo "✓ SP creado/actualizado exitosamente\n\n";

    // Probar el SP
    echo "========================================\n";
    echo "PRUEBA DEL SP\n";
    echo "========================================\n\n";

    $start = microtime(true);

    $stmt = $pdo->prepare("
        SELECT * FROM public.licenciasvigentesfrm_sp_licencias_vigentes(
            1,    -- p_page
            10,   -- p_limit
            NULL, -- p_giro
            NULL, -- p_zona
            NULL, -- p_estado
            NULL, -- p_fecha_desde
            NULL, -- p_fecha_hasta
            NULL  -- p_propietario
        )
    ");
    $stmt->execute();
    $results = $stmt->fetchAll(PDO::FETCH_ASSOC);

    $end = microtime(true);
    $duration = round(($end - $start) * 1000, 2);

    echo "✓ Tiempo de ejecución: {$duration} ms\n";
    echo "  Registros retornados: " . count($results) . "\n\n";

    if (count($results) > 0) {
        echo "Primer registro:\n";
        echo "  Número: " . ($results[0]['numero'] ?? 'N/A') . "\n";
        echo "  Propietario: " . ($results[0]['propietario'] ?? 'N/A') . "\n";
        echo "  Giro: " . ($results[0]['giro'] ?? 'N/A') . "\n";
        echo "  Estado: " . ($results[0]['estado'] ?? 'N/A') . "\n";
        echo "  Total Records: " . ($results[0]['total_records'] ?? 'N/A') . "\n\n";
    } else {
        echo "⚠ No se encontraron registros (puede ser normal si no hay licencias vigentes)\n\n";
    }

    echo "✅ SP funcionando correctamente\n";

} catch (PDOException $e) {
    echo "\n✗ Error de base de datos:\n";
    echo "  " . $e->getMessage() . "\n";
    exit(1);
} catch (Exception $e) {
    echo "\n✗ Error:\n";
    echo "  " . $e->getMessage() . "\n";
    exit(1);
}

<?php
$host = '192.168.6.146';
$database = 'padron_licencias';
$username = 'refact';
$password = 'FF)-BQk2';

echo "========================================\n";
echo "DEPLOY SP LICENCIAS VIGENTES - FIX FECHAS\n";
echo "========================================\n\n";

try {
    $pdo = new PDO("pgsql:host=$host;dbname=$database", $username, $password, [
        PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION
    ]);

    echo "✓ Conexión exitosa\n\n";

    // Leer el archivo SQL
    $sqlFile = 'C:\\Sistemas\\RefactorX\\Guadalajara\\RecodePHP\\GDL\\temp\\fix_sp_licencias_fechas.sql';

    if (!file_exists($sqlFile)) {
        throw new Exception("Archivo SQL no encontrado: $sqlFile");
    }

    $sql = file_get_contents($sqlFile);
    echo "✓ Archivo SQL leído correctamente\n\n";

    // Ejecutar el DROP FUNCTION
    echo "Eliminando función anterior si existe...\n";
    $pdo->exec("DROP FUNCTION IF EXISTS public.licenciasvigentesfrm_sp_licencias_vigentes(
        integer, integer, text, text, text, text, text, text
    )");
    echo "✓ Función anterior eliminada\n\n";

    // Ejecutar el CREATE FUNCTION
    echo "Creando nueva función con manejo de fechas...\n";
    $start = microtime(true);
    $pdo->exec($sql);
    $duration = round((microtime(true) - $start) * 1000, 2);
    echo "✓ Función creada exitosamente ({$duration}ms)\n\n";

    // Verificar que la función existe
    echo "Verificando función desplegada...\n";
    $stmt = $pdo->query("
        SELECT
            p.proname as nombre,
            pg_get_function_identity_arguments(p.oid) as argumentos,
            d.description
        FROM pg_proc p
        LEFT JOIN pg_description d ON p.oid = d.objoid
        WHERE p.proname = 'licenciasvigentesfrm_sp_licencias_vigentes'
        AND p.pronamespace = (SELECT oid FROM pg_namespace WHERE nspname = 'public')
    ");

    $func = $stmt->fetch(PDO::FETCH_ASSOC);

    if ($func) {
        echo "✓ Función verificada:\n";
        echo "  Nombre: " . $func['nombre'] . "\n";
        echo "  Argumentos: " . $func['argumentos'] . "\n";
        echo "  Descripción: " . ($func['description'] ?? 'Sin descripción') . "\n\n";
    } else {
        throw new Exception("La función no se encontró después del despliegue");
    }

    // Prueba básica con fechas vacías
    echo "========================================\n";
    echo "PRUEBA: Ejecutar con fechas vacías\n";
    echo "========================================\n";

    $start = microtime(true);
    $stmt = $pdo->prepare("
        SELECT * FROM public.licenciasvigentesfrm_sp_licencias_vigentes(
            1, 10, '', '', '', '', '', ''
        )
    ");
    $stmt->execute();
    $results = $stmt->fetchAll(PDO::FETCH_ASSOC);
    $duration = round((microtime(true) - $start) * 1000, 2);

    echo "✓ Consulta ejecutada exitosamente ({$duration}ms)\n";
    echo "  Registros obtenidos: " . count($results) . "\n";

    if (count($results) > 0) {
        echo "  Total en BD: " . number_format($results[0]['total_records']) . "\n";
        echo "\n✅ PRUEBA EXITOSA - El SP maneja correctamente strings vacíos\n";
    } else {
        echo "\n⚠ No se encontraron registros (puede ser normal si no hay datos)\n";
    }

    echo "\n========================================\n";
    echo "✅ DESPLIEGUE COMPLETADO EXITOSAMENTE\n";
    echo "========================================\n";

} catch (Exception $e) {
    echo "\n✗ Error: " . $e->getMessage() . "\n";
    exit(1);
}

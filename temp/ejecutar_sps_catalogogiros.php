<?php
/**
 * Script: ejecutar_sps_catalogogiros.php
 * Descripción: Ejecuta los 6 SPs de catálogo de giros en esquema comun
 * Fecha: 2025-11-05
 */

$host = '192.168.6.146';
$port = '5432';
$dbname = 'padron_licencias';
$user = 'refact';
$password = 'FF)-BQk2';

try {
    $dsn = "pgsql:host=$host;port=$port;dbname=$dbname";
    $pdo = new PDO($dsn, $user, $password, [
        PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION
    ]);

    echo "\n========================================\n";
    echo "EJECUTANDO SPs DE CATÁLOGO DE GIROS\n";
    echo "========================================\n\n";
    echo "Conectado a: $host:$port/$dbname\n";
    echo "Usuario: $user\n\n";

    // Leer el archivo SQL CORREGIDO
    $sqlFile = __DIR__ . '/DEPLOY_CATALOGOGIROS_FIXED.sql';

    if (!file_exists($sqlFile)) {
        throw new Exception("Archivo SQL no encontrado: $sqlFile");
    }

    echo "📄 Leyendo archivo: DEPLOY_CATALOGOGIROS_FIXED.sql\n\n";
    $sql = file_get_contents($sqlFile);

    // Separar por los comandos \echo que no son SQL válido
    $sql = preg_replace("/\\\\echo[^\n]*/", "", $sql);

    // Ejecutar el SQL completo
    echo "⚙️  Ejecutando script SQL...\n\n";
    $pdo->exec($sql);

    echo "✅ Script ejecutado exitosamente!\n\n";

    // Verificar SPs creados
    echo "========================================\n";
    echo "VERIFICANDO SPs CREADOS\n";
    echo "========================================\n\n";

    $stmt = $pdo->query("
        SELECT
            proname as sp_name,
            pg_get_function_arguments(oid) as arguments
        FROM pg_proc
        WHERE pronamespace = 'comun'::regnamespace
            AND proname LIKE 'sp_catalogogiros%'
        ORDER BY proname
    ");

    $sps = $stmt->fetchAll(PDO::FETCH_OBJ);

    if (empty($sps)) {
        echo "⚠️  NO SE ENCONTRARON SPs!\n\n";
        exit(1);
    }

    echo "✅ SPs creados en esquema 'comun' (" . count($sps) . "):\n\n";
    echo str_repeat("-", 100) . "\n";
    printf("%-40s %s\n", "SP Name", "Arguments");
    echo str_repeat("-", 100) . "\n";

    foreach ($sps as $sp) {
        printf("%-40s %s\n", $sp->sp_name, substr($sp->arguments, 0, 50));
    }
    echo str_repeat("-", 100) . "\n\n";

    // Probar SP de estadísticas
    echo "========================================\n";
    echo "PROBANDO SP: sp_catalogogiros_estadisticas\n";
    echo "========================================\n\n";

    $stmt = $pdo->query("SELECT * FROM comun.sp_catalogogiros_estadisticas()");
    $stats = $stmt->fetch(PDO::FETCH_OBJ);

    if ($stats) {
        echo "📊 Estadísticas del Catálogo:\n";
        echo "   Total giros: " . number_format($stats->total_giros) . "\n";
        echo "   Vigentes: " . number_format($stats->giros_vigentes) . "\n";
        echo "   Cancelados: " . number_format($stats->giros_cancelados) . "\n";
        echo "   Licencias: " . number_format($stats->giros_licencias) . "\n";
        echo "   Anuncios: " . number_format($stats->giros_anuncios) . "\n";
        echo "   Reglamentados: " . number_format($stats->giros_reglamentados) . "\n\n";
    }

    // Probar SP de listado
    echo "========================================\n";
    echo "PROBANDO SP: sp_catalogogiros_list\n";
    echo "========================================\n\n";

    $stmt = $pdo->query("SELECT * FROM comun.sp_catalogogiros_list(1, 5, NULL, NULL, NULL, NULL, 'V') LIMIT 5");
    $giros = $stmt->fetchAll(PDO::FETCH_OBJ);

    if (!empty($giros)) {
        echo "📋 Primeros 5 giros vigentes:\n\n";
        echo str_repeat("-", 100) . "\n";
        printf("%-10s %-50s %-15s %-10s %-10s\n", "Código", "Descripción", "Clasificación", "Tipo", "Total");
        echo str_repeat("-", 100) . "\n";

        foreach ($giros as $giro) {
            printf("%-10s %-50s %-15s %-10s %-10s\n",
                $giro->cod_giro,
                substr($giro->descripcion, 0, 47) . '...',
                $giro->clasificacion,
                $giro->tipo === 'L' ? 'Licencia' : 'Anuncio',
                number_format($giro->total_count)
            );
        }
        echo str_repeat("-", 100) . "\n\n";
    }

    echo "========================================\n";
    echo "✅ PROCESO COMPLETADO EXITOSAMENTE\n";
    echo "========================================\n\n";

    echo "🎯 Próximos pasos:\n";
    echo "   1. Recarga el navegador en la página de Catálogo de Giros\n";
    echo "   2. Las estadísticas deberían cargar automáticamente\n";
    echo "   3. Presiona 'Actualizar' para ver la tabla de giros\n";
    echo "   4. Prueba crear, editar y cambiar vigencia de giros\n\n";

} catch (PDOException $e) {
    echo "\n❌ ERROR DE BASE DE DATOS:\n";
    echo "   " . $e->getMessage() . "\n\n";
    exit(1);
} catch (Exception $e) {
    echo "\n❌ ERROR:\n";
    echo "   " . $e->getMessage() . "\n\n";
    exit(1);
}

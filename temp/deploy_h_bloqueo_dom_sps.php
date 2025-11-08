<?php
/**
 * Desplegar Stored Procedures para h_bloqueoDomiciliosfrm
 * Fecha: 2025-11-06
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

    echo "✓ Conectado a la base de datos\n\n";

    // Leer archivo SQL
    $sqlFile = __DIR__ . '/DEPLOY_H_BLOQUEO_DOM_SPS.sql';
    $sql = file_get_contents($sqlFile);

    echo "=== DESPLEGANDO STORED PROCEDURES ===\n\n";

    // Ejecutar todo el SQL
    $pdo->exec($sql);

    echo "✓ SP 1/4: h_bloqueodomiciliosfrm_sp_filter_h_bloqueo_dom creado\n";
    echo "✓ SP 2/4: h_bloqueodomiciliosfrm_sp_h_bloqueo_dom_detalle creado\n";
    echo "✓ SP 3/4: h_bloqueodomiciliosfrm_sp_exportar_h_bloqueo_dom_excel creado\n";
    echo "✓ SP 4/4: h_bloqueodomiciliosfrm_sp_imprimir_h_bloqueo_dom_report creado\n";

    echo "\n=== PROBANDO SP PRINCIPAL ===\n";

    // Probar SP principal
    $stmt = $pdo->query("
        SELECT * FROM public.h_bloqueodomiciliosfrm_sp_filter_h_bloqueo_dom(
            NULL, -- fecha_inicio
            NULL, -- fecha_fin
            NULL, -- calle
            NULL, -- colonia
            NULL, -- tipo_bloqueo
            1,    -- page
            10    -- limit
        )
    ");
    $results = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo "\nRegistros encontrados: " . count($results) . "\n";
    if (count($results) > 0) {
        echo "Total en BD: " . number_format($results[0]['total_records']) . "\n";
        echo "\nPrimer registro:\n";
        foreach ($results[0] as $key => $value) {
            if ($key !== 'total_records') {
                echo "  $key: " . ($value ?? 'NULL') . "\n";
            }
        }
    }

    echo "\n✓✓✓ DESPLIEGUE COMPLETADO EXITOSAMENTE ✓✓✓\n";

} catch (Exception $e) {
    echo "✗ ERROR: " . $e->getMessage() . "\n";
    exit(1);
}

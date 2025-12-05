<?php
// Get real licencias examples

try {
    $pdo = new PDO(
        'pgsql:host=192.168.6.146;port=5432;dbname=padron_licencias',
        'refact',
        'FF)-BQk2'
    );
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "=== GETTING REAL LICENCIAS EXAMPLES ===\n\n";

    // Get licencias with actual data (not zeros)
    $stmt = $pdo->query("
        SELECT licencia, empresa, id_giro, propietario, domicilio, fecha_otorgamiento
        FROM catastro_gdl.h_licencias
        WHERE licencia > 0
        AND propietario IS NOT NULL
        AND TRIM(propietario) != ''
        ORDER BY licencia
        LIMIT 15
    ");

    $examples = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo "Found " . count($examples) . " valid licencias:\n\n";

    foreach ($examples as $i => $row) {
        echo ($i + 1) . ". Licencia: {$row['licencia']}\n";
        echo "   Empresa: {$row['empresa']}\n";
        echo "   Giro: {$row['id_giro']}\n";
        echo "   Propietario: " . trim($row['propietario']) . "\n";
        echo "   Domicilio: " . trim($row['domicilio']) . "\n";
        echo "   Fecha: {$row['fecha_otorgamiento']}\n\n";
    }

} catch (Exception $e) {
    echo "Error: " . $e->getMessage() . "\n";
}

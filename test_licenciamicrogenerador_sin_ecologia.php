<?php
// Script para probar el stored procedure recaudadora_licenciamicrogenerador actualizado

$host = '192.168.6.146';
$dbname = 'multas_reglamentos';
$user = 'refact';
$password = 'FF)-BQk2';

try {
    $pdo = new PDO("pgsql:host=$host;dbname=$dbname", $user, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "Conectado exitosamente.\n\n";

    // 1. Actualizar el stored procedure
    echo "1. Actualizando stored procedure recaudadora_licenciamicrogenerador...\n";
    $sql = file_get_contents(__DIR__ . '/update_sp_licenciamicrogenerador_sin_ecologia.sql');
    $pdo->exec($sql);
    echo "   ✓ Stored procedure actualizado exitosamente.\n\n";

    // 2. Probar con RFC conocido (OXXO)
    echo "2. Probando con RFC 'CCO8605231N4' (OXXO)...\n";

    $stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_licenciamicrogenerador(?)");
    $stmt->execute(['CCO8605231N4']);
    $results = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo "   Licencias encontradas: " . count($results) . "\n\n";

    if (count($results) > 0) {
        echo "   === PRIMERAS 3 LICENCIAS ===\n";
        for ($i = 0; $i < min(3, count($results)); $i++) {
            $lic = $results[$i];
            echo "   \n   LICENCIA " . ($i + 1) . ":\n";
            echo "   ID: {$lic['id_licencia']}\n";
            echo "   RFC: {$lic['rfc']}\n";
            echo "   Folio: {$lic['folio_licencia']}\n";
            echo "   Titular: {$lic['nombre_titular']}\n";
            echo "   Domicilio: {$lic['domicilio_instalacion']}\n";
            echo "   Tipo Sistema: {$lic['tipo_sistema']}\n";
            echo "   Potencia KW: {$lic['potencia_instalada_kw']}\n";
            echo "   Núm. Paneles: {$lic['num_paneles']}\n";
            echo "   Fecha Instalación: {$lic['fecha_instalacion']}\n";
            echo "   Fecha Vencimiento: {$lic['fecha_vencimiento']}\n";
            echo "   Estatus: {$lic['estatus']}\n";
        }
    }

    // 3. Probar con RFC inexistente
    echo "\n\n3. Probando con RFC inexistente 'XXXX000000XXX'...\n";

    $stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_licenciamicrogenerador(?)");
    $stmt->execute(['XXXX000000XXX']);
    $results_error = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo "   Licencias encontradas: " . count($results_error) . "\n";
    if (count($results_error) == 0) {
        echo "   ✓ Correcto: No se encontraron resultados\n";
    }

    // 4. Probar con RFC vacío
    echo "\n\n4. Probando con RFC vacío (validación)...\n";

    $stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_licenciamicrogenerador(?)");
    $stmt->execute(['']);
    $results_vacio = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo "   Licencias encontradas: " . count($results_vacio) . "\n";
    if (count($results_vacio) == 0) {
        echo "   ✓ Correcto: Validación funciona\n";
    }

    // 5. Ver formato JSON
    echo "\n\n5. Formato JSON para el frontend (primeras 2 licencias):\n";
    $stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_licenciamicrogenerador(?) LIMIT 2");
    $stmt->execute(['CCO8605231N4']);
    $result_json = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo json_encode($result_json, JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE);

    echo "\n\n✅ Todas las pruebas completadas exitosamente!\n";

} catch (PDOException $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
    exit(1);
}

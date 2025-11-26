<?php
/**
 * Script para desplegar recaudadora_parse_file
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
    $sqlFile = __DIR__ . '/../RefactorX/Base/multas_reglamentos/database/generated/recaudadora_parse_file.sql';

    if (!file_exists($sqlFile)) {
        throw new Exception("No se encontró el archivo: $sqlFile");
    }

    $sp = file_get_contents($sqlFile);

    echo "📝 Desplegando recaudadora_parse_file...\n";
    $pdo->exec($sp);
    echo "✅ SP desplegado correctamente\n\n";

    // Probar con datos del archivo de ejemplo
    echo "🧪 Probando con datos de ejemplo...\n\n";

    $ejemploFile = __DIR__ . '/ejemplo_folios.txt';
    if (file_exists($ejemploFile)) {
        $fileContent = file_get_contents($ejemploFile);

        echo "Contenido del archivo de prueba:\n";
        echo $fileContent . "\n\n";

        $stmt = $pdo->prepare("SELECT * FROM recaudadora_parse_file(?)");
        $stmt->execute([$fileContent]);
        $results = $stmt->fetchAll(PDO::FETCH_ASSOC);

        echo "Resultados: " . count($results) . " folios parseados ✅\n\n";

        if (count($results) > 0) {
            echo "Primeros folios parseados:\n";
            foreach (array_slice($results, 0, 3) as $row) {
                echo sprintf(
                    "  - Cuenta: %s | Folio: %d | Año: %d | Propietario: %s\n",
                    $row['clave_cuenta'],
                    $row['folio'],
                    $row['anio_folio'],
                    $row['propietario']
                );
            }
        }
    } else {
        echo "⚠️ No se encontró archivo de ejemplo, probando con datos hardcoded...\n";
        $testData = "123456789|1001|2023\n987654321|1002|2024";
        $stmt = $pdo->prepare("SELECT * FROM recaudadora_parse_file(?)");
        $stmt->execute([$testData]);
        $results = $stmt->fetchAll(PDO::FETCH_ASSOC);
        echo "Resultados: " . count($results) . " folios parseados ✅\n";
    }

    echo "\n✅ ¡Despliegue completado exitosamente!\n";

} catch (Exception $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
    exit(1);
}

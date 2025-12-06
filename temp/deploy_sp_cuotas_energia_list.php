<?php
$host = '192.168.6.146';
$port = '5432';
$dbname = 'mercados';
$user = 'refact';
$password = 'FF)-BQk2';

try {
    $dsn = "pgsql:host=$host;port=$port;dbname=$dbname";
    $pdo = new PDO($dsn, $user, $password, [PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION]);

    echo "=== DESPLEGANDO sp_cuotas_energia_list ===\n\n";

    $sql = file_get_contents(__DIR__ . '/../RefactorX/Base/mercados/database/database/CuotasEnergia_sp_cuotas_energia_list.sql');

    if (!$sql) {
        die("Error: No se pudo leer el archivo SQL\n");
    }

    echo "Desplegando SP...\n";
    $pdo->exec($sql);
    echo "✓ SP desplegado exitosamente\n\n";

    // Probar el SP
    echo "=== PROBANDO SP ===\n";
    $testQuery = "SELECT * FROM sp_cuotas_energia_list() LIMIT 5";
    $stmt = $pdo->query($testQuery);
    $results = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo "Registros encontrados: " . count($results) . "\n\n";
    
    if (!empty($results)) {
        echo "Primeros 5 registros:\n";
        foreach ($results as $row) {
            echo sprintf("  Año: %d, Periodo: %d, Importe: %s, Usuario: %s\n",
                $row['axo'],
                $row['periodo'],
                $row['importe'],
                $row['usuario'] ?? 'N/A'
            );
        }
    }

} catch (PDOException $e) {
    echo "Error: " . $e->getMessage() . "\n";
}

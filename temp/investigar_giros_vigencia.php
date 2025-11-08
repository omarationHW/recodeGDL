<?php
$host = '192.168.6.146';
$port = '5432';
$dbname = 'padron_licencias';
$user = 'refact';
$password = 'FF)-BQk2';

try {
    $dsn = "pgsql:host=$host;port=$port;dbname=$dbname";
    $pdo = new PDO($dsn, $user, $password, [PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION]);

    echo "Investigando campo vigente en c_giros:\n\n";

    // Ver valores del campo vigente
    $stmt = $pdo->query("
        SELECT vigente, COUNT(*) as total
        FROM comun.c_giros
        GROUP BY vigente
        ORDER BY total DESC
    ");
    $results = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo "Valores en campo vigente:\n";
    foreach ($results as $row) {
        $vigente = $row['vigente'] === null ? 'NULL' : "'{$row['vigente']}'";
        echo "  $vigente: {$row['total']} registros\n";
    }

    // Contar total
    $total = $pdo->query("SELECT COUNT(*) FROM comun.c_giros")->fetchColumn();
    echo "\nTotal de giros: $total\n";

    // Ver muestra de datos
    echo "\nMuestra de 10 giros:\n";
    $stmt = $pdo->query("SELECT id_giro, descripcion, vigente FROM comun.c_giros LIMIT 10");
    $giros = $stmt->fetchAll(PDO::FETCH_ASSOC);
    foreach ($giros as $giro) {
        $vigente = $giro['vigente'] === null ? 'NULL' : "'{$giro['vigente']}'";
        echo "  ID {$giro['id_giro']}: " . trim($giro['descripcion']) . " [vigente=$vigente]\n";
    }

    // Ver giros DISTINCT
    echo "\nGiros DISTINCT:\n";
    $stmt = $pdo->query("SELECT COUNT(DISTINCT id_giro) FROM comun.c_giros");
    $distinctGiros = $stmt->fetchColumn();
    echo "  Total de ID distintos: $distinctGiros\n";

} catch (Exception $e) {
    echo "Error: " . $e->getMessage() . "\n";
}

<?php
$host = '192.168.6.146';
$port = '5432';
$dbname = 'padron_licencias';
$user = 'refact';
$password = 'FF)-BQk2';

try {
    $pdo = new PDO("pgsql:host=$host;port=$port;dbname=$dbname", $user, $password, [PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION]);

    echo "=== EJEMPLOS DE MULTAS (5 registros) ===\n\n";
    $stmt = $pdo->query("
        SELECT
            id_multa,
            id_dependencia,
            axo_acta,
            num_acta,
            fecha_acta,
            contribuyente,
            calificacion
        FROM comun.multas
        WHERE id_multa IS NOT NULL
        ORDER BY id_multa DESC
        LIMIT 5
    ");

    $examples = $stmt->fetchAll(PDO::FETCH_ASSOC);

    if (empty($examples)) {
        echo "❌ No hay datos en comun.multas\n";
    } else {
        foreach ($examples as $ex) {
            $contrib = substr($ex['contribuyente'] ?? 'N/A', 0, 30);
            echo "ID: {$ex['id_multa']} | Dep: {$ex['id_dependencia']} | Acta: {$ex['axo_acta']}/{$ex['num_acta']} | Fecha: {$ex['fecha_acta']} | Calificación: {$ex['calificacion']}\n";
            echo "  Contribuyente: $contrib\n";
        }
    }

    // Contar registros
    echo "\n\n=== ESTADÍSTICAS ===\n\n";
    $count = $pdo->query("SELECT COUNT(*) FROM comun.multas")->fetchColumn();
    echo "Total de multas: $count\n";

    // Ver rango de IDs
    $stmt2 = $pdo->query("SELECT MIN(id_multa) as min_id, MAX(id_multa) as max_id FROM comun.multas");
    $range = $stmt2->fetch(PDO::FETCH_ASSOC);
    echo "Rango de IDs: {$range['min_id']} - {$range['max_id']}\n";

} catch (PDOException $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
}
?>

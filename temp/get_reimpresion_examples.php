<?php
$pdo = new PDO('pgsql:host=192.168.6.146;port=5432;dbname=padron_licencias', 'refact', 'FF)-BQk2', [PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION]);

echo "=== EJEMPLOS REALES PARA REIMPRESIÓN ===\n\n";

// Obtener 3 ejemplos de diferentes dependencias
$stmt = $pdo->query("
    SELECT
        id_multa,
        id_dependencia,
        axo_acta,
        num_acta,
        fecha_acta,
        contribuyente,
        domicilio,
        calificacion,
        multa,
        gastos,
        total,
        tipo
    FROM comun.multas
    WHERE contribuyente IS NOT NULL
    AND total > 0
    ORDER BY fecha_acta DESC
    LIMIT 50
");

$multas = $stmt->fetchAll(PDO::FETCH_ASSOC);

// Filtrar para obtener ejemplos de diferentes dependencias
$ejemplos = [];
$deps_usadas = [];

foreach ($multas as $m) {
    $dep = $m['id_dependencia'];
    if (!in_array($dep, $deps_usadas) && count($ejemplos) < 3) {
        $ejemplos[] = $m;
        $deps_usadas[] = $dep;
    }
}

// Si no hay suficientes, agregar más sin importar la dependencia
while (count($ejemplos) < 3 && count($ejemplos) < count($multas)) {
    $ejemplos[] = $multas[count($ejemplos)];
}

$i = 1;
foreach ($ejemplos as $e) {
    echo "EJEMPLO {$i}:\n";
    echo "  Folio/ID: {$e['id_multa']}\n";
    echo "  Tipo Documento: multa\n";
    echo "  Dependencia: {$e['id_dependencia']}\n";
    echo "  Contribuyente: {$e['contribuyente']}\n";
    echo "  Fecha: {$e['fecha_acta']}\n";
    echo "  Importe: \${$e['total']}\n";
    echo "  Año Acta: {$e['axo_acta']}\n";
    echo "  Num Acta: {$e['num_acta']}\n\n";
    $i++;
}

// Contar por dependencia
echo "\n=== DISTRIBUCIÓN POR DEPENDENCIA (Top 5) ===\n";
$stmt2 = $pdo->query("
    SELECT
        id_dependencia,
        COUNT(*) as total
    FROM comun.multas
    GROUP BY id_dependencia
    ORDER BY total DESC
    LIMIT 5
");
$dist = $stmt2->fetchAll(PDO::FETCH_ASSOC);
foreach ($dist as $d) {
    echo "  Dependencia {$d['id_dependencia']}: {$d['total']} multas\n";
}

?>

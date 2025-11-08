<?php
$pdo = new PDO('pgsql:host=192.168.6.146;port=5432;dbname=padron_licencias', 'refact', 'FF)-BQk2');

echo "Probando SP con filtro correcto 'vigente':\n\n";

$stmt = $pdo->query("SELECT * FROM public.sp_bloqueorfc_list(1, 10, NULL, 'vigente')");
$resultados = $stmt->fetchAll(PDO::FETCH_ASSOC);

echo "Total de resultados: " . count($resultados) . "\n\n";

if (count($resultados) > 0) {
    foreach ($resultados as $idx => $resultado) {
        echo "Resultado #" . ($idx + 1) . ":\n";
        echo "  RFC: {$resultado['rfc']}\n";
        echo "  ID Trámite: {$resultado['id_tramite']}\n";
        echo "  Propietario: {$resultado['propietario_completo']}\n";
        echo "  Vigencia: {$resultado['vig']}\n";
        echo "  Total count: {$resultado['total_count']}\n";
        echo "  ---\n";
    }
} else {
    echo "⚠ No se encontraron resultados\n";
}

// Ver si hay duplicados
echo "\nVerificando duplicados:\n";
$rfcs = array_column($resultados, 'rfc');
$unique_rfcs = array_unique($rfcs);

if (count($rfcs) !== count($unique_rfcs)) {
    echo "⚠ HAY DUPLICADOS! Total: " . count($rfcs) . ", Únicos: " . count($unique_rfcs) . "\n";
} else {
    echo "✓ No hay duplicados\n";
}

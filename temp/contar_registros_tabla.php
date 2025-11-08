<?php
$pdo = new PDO('pgsql:host=192.168.6.146;port=5432;dbname=padron_licencias', 'refact', 'FF)-BQk2');

echo "Contando registros en bloqueo_rfc_lic:\n\n";

$stmt = $pdo->query("SELECT COUNT(*) as cnt FROM comun.bloqueo_rfc_lic WHERE rfc = 'GUOC961126LL9'");
$result = $stmt->fetch();
echo "Registros con RFC GUOC961126LL9: {$result['cnt']}\n\n";

// Mostrar todos los registros de ese RFC
$stmt = $pdo->query("SELECT *, hora::TEXT as hora_text FROM comun.bloqueo_rfc_lic WHERE rfc = 'GUOC961126LL9' ORDER BY hora DESC");
$registros = $stmt->fetchAll(PDO::FETCH_ASSOC);

echo "Detalles:\n";
foreach ($registros as $idx => $reg) {
    echo "Registro #" . ($idx + 1) . ":\n";
    echo "  RFC: {$reg['rfc']}\n";
    echo "  ID Trámite: {$reg['id_tramite']}\n";
    echo "  Licencia: {$reg['licencia']}\n";
    echo "  Hora: {$reg['hora_text']}\n";
    echo "  Vigencia: {$reg['vig']}\n";
    echo "  ---\n";
}

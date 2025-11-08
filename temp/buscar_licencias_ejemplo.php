<?php
$pdo = new PDO('pgsql:host=192.168.6.146;port=5432;dbname=padron_licencias', 'refact', 'FF)-BQk2');
$stmt = $pdo->query("SELECT licencia, vigente, actividad FROM comun.licencias WHERE vigente = 'V' LIMIT 5");
$licencias = $stmt->fetchAll(PDO::FETCH_ASSOC);
echo "Licencias vigentes de ejemplo:\n";
foreach ($licencias as $lic) {
    $act = substr($lic['actividad'], 0, 40);
    echo "  Licencia: {$lic['licencia']} - Vigente: {$lic['vigente']} - {$act}\n";
}

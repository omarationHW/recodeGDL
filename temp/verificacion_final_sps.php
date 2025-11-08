<?php
$pdo = new PDO('pgsql:host=192.168.6.146;port=5432;dbname=padron_licencias', 'refact', 'FF)-BQk2');

echo "========================================\n";
echo "VERIFICACIÓN FINAL - STORED PROCEDURES\n";
echo "========================================\n\n";

// 1. bloqueoRFCfrm
echo "1. SPs para bloqueoRFCfrm.vue:\n\n";
$stmt = $pdo->query("
    SELECT p.proname
    FROM pg_proc p
    JOIN pg_namespace n ON p.pronamespace = n.oid
    WHERE n.nspname = 'public'
    AND p.proname LIKE 'sp_bloqueorfc%'
    ORDER BY p.proname
");

$sps_rfc = $stmt->fetchAll(PDO::FETCH_COLUMN);
$expected_rfc = ['sp_bloqueorfc_buscar_tramite', 'sp_bloqueorfc_create', 'sp_bloqueorfc_desbloquear', 'sp_bloqueorfc_list'];

foreach ($expected_rfc as $sp) {
    if (in_array($sp, $sps_rfc)) {
        echo "   ✓ public.$sp\n";
    } else {
        echo "   ✗ FALTA: public.$sp\n";
    }
}

// 2. bloqueoDomiciliosfrm
echo "\n2. SPs para bloqueoDomiciliosfrm.vue:\n\n";
$stmt = $pdo->query("
    SELECT p.proname
    FROM pg_proc p
    JOIN pg_namespace n ON p.pronamespace = n.oid
    WHERE n.nspname = 'public'
    AND p.proname LIKE 'sp_bloqueodomicilios%'
    ORDER BY p.proname
");

$sps_dom = $stmt->fetchAll(PDO::FETCH_COLUMN);
$expected_dom = ['sp_bloqueodomicilios_cancel', 'sp_bloqueodomicilios_create', 'sp_bloqueodomicilios_list', 'sp_bloqueodomicilios_update'];

foreach ($expected_dom as $sp) {
    if (in_array($sp, $sps_dom)) {
        echo "   ✓ public.$sp\n";
    } else {
        echo "   ✗ FALTA: public.$sp\n";
    }
}

// 3. Resumen
echo "\n========================================\n";
echo "RESUMEN:\n";
echo "========================================\n\n";
echo "bloqueoRFCfrm: " . count($sps_rfc) . "/" . count($expected_rfc) . " SPs\n";
echo "bloqueoDomiciliosfrm: " . count($sps_dom) . "/" . count($expected_dom) . " SPs\n";

if (count($sps_rfc) === count($expected_rfc) && count($sps_dom) === count($expected_dom)) {
    echo "\n✓✓✓ TODOS LOS SPs ESTÁN LISTOS ✓✓✓\n";
} else {
    echo "\n⚠ Faltan algunos SPs\n";
}

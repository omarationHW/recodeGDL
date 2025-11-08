<?php
$pdo = new PDO('pgsql:host=192.168.6.146;port=5432;dbname=padron_licencias', 'refact', 'FF)-BQk2');

echo "Debug: Ejecutando query del SP manualmente:\n\n";

// Simular el CTE del SP
$query = "
WITH bloqueos_filtrados AS (
    SELECT
        b.rfc::VARCHAR,
        b.id_tramite::INTEGER,
        b.licencia::INTEGER,
        b.hora::TIMESTAMP,
        b.vig::CHAR,
        b.observacion::VARCHAR,
        b.capturista::VARCHAR,
        TRIM(TRIM(COALESCE(tr.primer_ap, '')) || ' ' ||
             TRIM(COALESCE(tr.segundo_ap, '')) || ' ' ||
             TRIM(COALESCE(tr.propietario, '')))::VARCHAR as propietario_completo,
        TRIM(COALESCE(tr.actividad, ''))::VARCHAR as actividad
    FROM comun.bloqueo_rfc_lic b
    LEFT JOIN comun.tramites tr ON tr.id_tramite = b.id_tramite
    WHERE b.vig = 'V'
)
SELECT
    *,
    (SELECT COUNT(*) FROM bloqueos_filtrados) as total_count
FROM bloqueos_filtrados
ORDER BY hora DESC
LIMIT 10
";

$stmt = $pdo->query($query);
$resultados = $stmt->fetchAll(PDO::FETCH_ASSOC);

echo "Resultados: " . count($resultados) . "\n\n";

foreach ($resultados as $idx => $res) {
    echo "Resultado #" . ($idx + 1) . ":\n";
    echo "  RFC: {$res['rfc']}\n";
    echo "  ID Trámite: {$res['id_tramite']}\n";
    echo "  Propietario: {$res['propietario_completo']}\n";
    echo "  ---\n";
}

// Verificar si hay duplicados en tramites
echo "\nVerificando tabla tramites:\n";
$stmt = $pdo->query("SELECT COUNT(*) as cnt FROM comun.tramites WHERE id_tramite = 349786");
$result = $stmt->fetch();
echo "Registros con id_tramite 349786: {$result['cnt']}\n";

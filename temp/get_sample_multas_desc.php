<?php
// Get sample multas with descuentos

try {
    $pdo = new PDO(
        'pgsql:host=192.168.6.146;port=5432;dbname=padron_licencias',
        'refact',
        'FF)-BQk2'
    );
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "=== GETTING SAMPLE MULTAS WITH DESCUENTOS ===\n\n";

    // Get multas with descuentos (estado = P is most common)
    $stmt = $pdo->query("
        SELECT
            m.id_multa,
            m.num_acta,
            m.fecha_acta,
            m.contribuyente,
            m.domicilio,
            m.num_licencia,
            m.multa,
            m.total,
            d.tipo_descto,
            d.valor,
            d.estado,
            d.feccap,
            d.observacion,
            d.autoriza,
            d.folio
        FROM catastro_gdl.multas m
        INNER JOIN catastro_gdl.descmultampal d ON m.id_multa = d.id_multa
        WHERE d.id_multa IN (191, 224, 241)
        ORDER BY m.id_multa
    ");

    $samples = $stmt->fetchAll(PDO::FETCH_ASSOC);
    echo "Found " . count($samples) . " records\n\n";

    foreach ($samples as $i => $row) {
        echo "═══════════════════════════════════════════════════════════\n";
        echo "Muestra " . ($i + 1) . ":\n";
        echo "═══════════════════════════════════════════════════════════\n";
        echo "MULTA:\n";
        echo "  ID Multa: {$row['id_multa']}\n";
        echo "  Num Acta: {$row['num_acta']}\n";
        echo "  Fecha: {$row['fecha_acta']}\n";
        echo "  Contribuyente: " . ($row['contribuyente'] ?? 'NULL') . "\n";
        echo "  Domicilio: " . ($row['domicilio'] ?? 'NULL') . "\n";
        echo "  Licencia: " . ($row['num_licencia'] ?? 'NULL') . "\n";
        echo "  Multa: $" . number_format($row['multa'], 2) . "\n";
        echo "  Total: $" . number_format($row['total'], 2) . "\n";
        echo "\nDESCUENTO:\n";
        echo "  Tipo: {$row['tipo_descto']} (" . ($row['tipo_descto'] == 'P' ? 'Porcentaje' : 'Importe') . ")\n";
        echo "  Valor: " . ($row['tipo_descto'] == 'P' ? $row['valor'] . '%' : '$' . number_format($row['valor'], 2)) . "\n";
        echo "  Estado: {$row['estado']} (" . (
            $row['estado'] == 'V' ? 'Vigente' :
            ($row['estado'] == 'P' ? 'Pagado' : 'Cancelado')
        ) . ")\n";
        echo "  Fecha: {$row['feccap']}\n";
        echo "  Autoriza: {$row['autoriza']}\n";
        echo "  Folio: " . ($row['folio'] ?? 'NULL') . "\n";
        echo "  Observación: " . ($row['observacion'] ?? 'Sin observación') . "\n";
        echo "\n";
    }

    // Check which schemas have the tables
    echo "═══════════════════════════════════════════════════════════\n";
    echo "VERIFICACIÓN DE SCHEMAS:\n";
    echo "═══════════════════════════════════════════════════════════\n\n";

    // Check if tables exist in comun schema
    $stmt = $pdo->query("
        SELECT table_schema, table_name
        FROM information_schema.tables
        WHERE table_name IN ('multas', 'descmultampal')
        AND table_schema IN ('comun', 'catastro_gdl')
        ORDER BY table_schema, table_name
    ");

    $tables = $stmt->fetchAll(PDO::FETCH_ASSOC);
    foreach ($tables as $table) {
        echo "{$table['table_schema']}.{$table['table_name']}\n";
    }

} catch (Exception $e) {
    echo "Error: " . $e->getMessage() . "\n";
}

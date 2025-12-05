<?php
// Get sample locales data

try {
    $pdo = new PDO(
        'pgsql:host=192.168.6.146;port=5432;dbname=padron_licencias',
        'refact',
        'FF)-BQk2'
    );
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "=== GETTING SAMPLE LOCALES ===\n\n";

    $stmt = $pdo->query("
        SELECT
            id_local,
            num_mercado,
            categoria,
            local,
            nombre,
            giro
        FROM comun.ta_11_locales
        WHERE id_local IS NOT NULL
        LIMIT 5
    ");

    $samples = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo "Found " . count($samples) . " locales\n\n";

    foreach ($samples as $i => $row) {
        echo "Local " . ($i + 1) . ":\n";
        echo "  ID: {$row['id_local']}\n";
        echo "  Mercado: {$row['num_mercado']}\n";
        echo "  Local: {$row['local']}\n";
        echo "  Nombre: " . ($row['nombre'] ?? 'NULL') . "\n";
        echo "  Giro: {$row['giro']}\n\n";
    }

    // Insert sample descuentos for testing
    echo "=== INSERTING SAMPLE DESCUENTOS FOR TESTING ===\n\n";

    if (count($samples) >= 3) {
        // Insert 3 sample descuentos
        for ($i = 0; $i < 3; $i++) {
            $id_local = $samples[$i]['id_local'];
            $porcentaje = [10, 20, 15][$i];
            $axoini = '2024';
            $axofin = '2025';

            $stmt = $pdo->prepare("
                INSERT INTO comun.descrecmerc (
                    id_local, porcentaje, fecalta, estado, axoini, axofin, autoriza
                ) VALUES (
                    :id_local, :porcentaje, CURRENT_DATE, 'V', :axoini, :axofin, 1
                )
                ON CONFLICT DO NOTHING
            ");

            try {
                $stmt->execute([
                    'id_local' => $id_local,
                    'porcentaje' => $porcentaje,
                    'axoini' => $axoini,
                    'axofin' => $axofin
                ]);
                echo "✓ Inserted descuento for local $id_local ({$porcentaje}%)\n";
            } catch (Exception $e) {
                // If constraint error, try update
                echo "  (descuento may already exist)\n";
            }
        }
    }

    echo "\n=== VERIFYING INSERTED DATA ===\n\n";

    $stmt = $pdo->query("
        SELECT
            l.id_local,
            l.num_mercado,
            l.local,
            l.nombre,
            d.porcentaje,
            d.axoini,
            d.axofin,
            d.estado
        FROM comun.ta_11_locales l
        JOIN comun.descrecmerc d ON l.id_local = d.id_local
        WHERE d.estado = 'V'
        LIMIT 5
    ");

    $results = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo "Found " . count($results) . " locales with descuentos\n\n";

    foreach ($results as $i => $row) {
        echo "Local " . ($i + 1) . ":\n";
        foreach ($row as $key => $value) {
            echo "  $key: " . ($value ?? 'NULL') . "\n";
        }
        echo "\n";
    }

} catch (Exception $e) {
    echo "Error: " . $e->getMessage() . "\n";
}

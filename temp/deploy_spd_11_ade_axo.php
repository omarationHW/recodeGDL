<?php
$host = '192.168.6.146';
$port = '5432';
$dbname = 'mercados';
$user = 'refact';
$password = 'FF)-BQk2';

try {
    $pdo = new PDO("pgsql:host=$host;port=$port;dbname=$dbname", $user, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "✓ Conectado a base de datos mercados\n\n";

    // Leer y desplegar el archivo SQL
    $sqlFile = __DIR__ . '/../RefactorX/Base/mercados/database/database/RptDesgloceAdeporImporte_spd_11_ade_axo.sql';
    $sql = file_get_contents($sqlFile);

    echo "Desplegando spd_11_ade_axo...\n";
    $pdo->exec($sql);
    echo "✓ SP desplegado exitosamente\n\n";

    // Probar el SP con valores de ejemplo
    echo "=== Probando SP ===\n";

    // Parámetros de ejemplo: año 2025, periodo 12, cuota mínima 100
    $axo = 2025;
    $mes = 12;
    $cuota = 100;

    echo "Probando con: axo={$axo}, mes={$mes}, cuota_minima={$cuota}\n";

    try {
        $stmt = $pdo->prepare("SELECT * FROM spd_11_ade_axo(?, ?, ?)");
        $stmt->execute([$axo, $mes, $cuota]);
        $results = $stmt->fetchAll(PDO::FETCH_ASSOC);

        if (count($results) > 0) {
            echo "✓ SP ejecutado correctamente\n";
            echo "  Registros encontrados: " . count($results) . "\n";

            // Mostrar primeros 3 registros
            $limit = min(3, count($results));
            for ($i = 0; $i < $limit; $i++) {
                $row = $results[$i];
                echo "\n  Registro #" . ($i + 1) . ":\n";
                echo "    ID Local: {$row['spd_id_local']}\n";
                echo "    Oficina: {$row['spd_oficina']}\n";
                echo "    Mercado: {$row['spd_mercado']}\n";
                echo "    Local: {$row['spd_local']}{$row['spd_letra']}\n";
                echo "    Nombre: {$row['spd_nombre']}\n";
                echo "    Descripción: {$row['spd_descripcion']}\n";
                echo "    Adeudo Anterior: \${$row['spd_adeant']}\n";
                echo "    Adeudo 2004: \${$row['spd_ade2004']}\n";
                echo "    Adeudo 2005: \${$row['spd_ade2005']}\n";
                echo "    Adeudo 2006: \${$row['spd_ade2006']}\n";
                echo "    Adeudo 2007: \${$row['spd_ade2007']}\n";
                echo "    Adeudo 2008: \${$row['spd_ade2008']}\n";
                echo "    Total Adeudo: \${$row['spd_totade']}\n";
            }

            if (count($results) > 3) {
                echo "\n  ... y " . (count($results) - 3) . " registros más\n";
            }
        } else {
            echo "✓ SP ejecutado pero no retornó resultados (sin adeudos que cumplan los criterios)\n";
        }
    } catch (PDOException $e) {
        echo "✗ Error al ejecutar: " . $e->getMessage() . "\n";
    }

    echo "\n✅ SP desplegado correctamente\n";

} catch (PDOException $e) {
    echo "✗ Error: " . $e->getMessage() . "\n";
    exit(1);
}

<?php
// Verificar cuántos registros retorna cada ejemplo
try {
    $pdo = new PDO(
        "pgsql:host=192.168.6.146;dbname=padron_licencias",
        "refact",
        "FF)-BQk2",
        [PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION]
    );

    echo "=== VERIFICANDO CANTIDAD DE REGISTROS POR EJEMPLO ===\n\n";

    $ejemplos = [
        ['numero' => 1, 'cuenta' => '1792830'],
        ['numero' => 2, 'cuenta' => '1792829'],
        ['numero' => 3, 'cuenta' => '1792828']
    ];

    foreach ($ejemplos as $ej) {
        echo "EJEMPLO {$ej['numero']}: Cuenta {$ej['cuenta']}\n";

        $sql = "SELECT * FROM multas_reglamentos.recaudadora_drecgootrasobligaciones(:cuenta)";
        $stmt = $pdo->prepare($sql);
        $stmt->execute(['cuenta' => $ej['cuenta']]);
        $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);

        $count = count($rows);
        echo "  ✅ Cantidad de registros: $count\n";

        if ($count > 0) {
            echo "  Datos del registro:\n";
            foreach ($rows as $i => $row) {
                echo "    Registro " . ($i + 1) . ":\n";
                echo "      - Clave: {$row['cve_contribuyente']}\n";
                echo "      - Nombre: {$row['nombre_completo']}\n";
                echo "      - Tipo: {$row['tipo_persona']}\n";
                echo "      - RFC: {$row['rfc']}\n";
            }
        }
        echo "\n" . str_repeat("-", 80) . "\n\n";
    }

    // Verificar búsqueda sin parámetro
    echo "EJEMPLO 4: Campo vacío (sin parámetro)\n";
    $sql = "SELECT COUNT(*) as total FROM multas_reglamentos.recaudadora_drecgootrasobligaciones(NULL)";
    $stmt = $pdo->query($sql);
    $result = $stmt->fetch(PDO::FETCH_ASSOC);
    echo "  ✅ Cantidad de registros: {$result['total']}\n";
    echo "  (Debe ser máximo 100 registros según el LIMIT del SP)\n\n";

} catch (Exception $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
}

<?php
// Probar el API para drecgoOtrasObligaciones
try {
    $pdo = new PDO(
        "pgsql:host=192.168.6.146;dbname=padron_licencias",
        "refact",
        "FF)-BQk2",
        [PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION]
    );

    echo "=== GENERANDO 3 EJEMPLOS DE PRUEBA PARA drecgoOtrasObligaciones ===\n\n";

    // Obtener 3 contribuyentes reales para usar como ejemplos
    echo "Obteniendo contribuyentes de ejemplo...\n\n";

    $sql = "
        SELECT cvecont, nombre_completo, rfc, tipo
        FROM comun.contrib
        WHERE cvecont IN (
            SELECT cvecont
            FROM comun.contrib
            WHERE nombre_completo IS NOT NULL
            AND TRIM(nombre_completo) != ''
            ORDER BY cvecont DESC
            LIMIT 10
        )
        ORDER BY cvecont DESC
        LIMIT 3
    ";

    $stmt = $pdo->query($sql);
    $ejemplos = $stmt->fetchAll(PDO::FETCH_ASSOC);

    if (count($ejemplos) < 3) {
        echo "⚠️ No se encontraron suficientes contribuyentes de ejemplo\n";
        exit(1);
    }

    echo "=== EJEMPLOS PARA PROBAR EL FORMULARIO ===\n\n";
    echo "Use estos valores en el campo 'Cuenta' del formulario:\n\n";

    foreach ($ejemplos as $i => $ej) {
        $num = $i + 1;
        echo "EJEMPLO $num:\n";
        echo "  Cuenta: {$ej['cvecont']}\n";
        echo "  Nombre: {$ej['nombre_completo']}\n";
        echo "  RFC: {$ej['rfc']}\n";
        echo "  Tipo: " . ($ej['tipo'] == 'F' ? 'Física' : 'Moral') . "\n";
        echo "\n";

        // Probar el SP con este valor
        echo "  Resultado del SP:\n";
        $sqlTest = "SELECT * FROM multas_reglamentos.recaudadora_drecgootrasobligaciones(:cuenta)";
        $stmtTest = $pdo->prepare($sqlTest);
        $stmtTest->execute(['cuenta' => $ej['cvecont']]);
        $result = $stmtTest->fetch(PDO::FETCH_ASSOC);

        if ($result) {
            foreach ($result as $key => $value) {
                echo "    $key: $value\n";
            }
        } else {
            echo "    ❌ No se encontraron resultados\n";
        }
        echo "\n";
        echo str_repeat("-", 80) . "\n\n";
    }

    echo "\n=== PRUEBA ADICIONAL: BÚSQUEDA SIN PARÁMETROS ===\n\n";
    echo "Si deja el campo 'Cuenta' vacío y presiona 'Buscar', el sistema mostrará\n";
    echo "los últimos 100 contribuyentes registrados en el sistema.\n\n";

    echo "Ejemplo de los primeros 5 registros:\n\n";
    $sqlTest = "SELECT * FROM multas_reglamentos.recaudadora_drecgootrasobligaciones() LIMIT 5";
    $stmt = $pdo->query($sqlTest);
    $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);

    foreach ($rows as $i => $row) {
        echo "Registro " . ($i + 1) . ":\n";
        echo "  Cuenta: {$row['cve_contribuyente']}\n";
        echo "  Nombre: {$row['nombre_completo']}\n";
        echo "  Tipo: {$row['tipo_persona']}\n";
        echo "\n";
    }

} catch (Exception $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
}

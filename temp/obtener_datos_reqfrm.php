<?php
/**
 * Script para obtener datos de ejemplo para el formulario ReqFrm
 */

$host = "192.168.6.146";
$port = "5432";
$dbname = "padron_licencias";
$user = "refact";
$password = "FF)-BQk2";

try {
    $dsn = "pgsql:host=$host;port=$port;dbname=$dbname";
    $pdo = new PDO($dsn, $user, $password, [
        PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
        PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC
    ]);

    echo "=== DATOS DE EJEMPLO PARA REQFRM ===\n\n";

    // 1. Ver registros existentes en reqdiftransmision
    echo "1. REGISTROS EXISTENTES EN reqdiftransmision:\n";
    echo str_repeat("-", 80) . "\n";
    $stmt = $pdo->query("
        SELECT cvereq, axoreq, folioreq, cvecuenta, total, vigencia,
               fecemi, feccap
        FROM catastro_gdl.reqdiftransmision
        ORDER BY cvereq DESC
        LIMIT 10
    ");
    $existentes = $stmt->fetchAll();

    if ($existentes) {
        foreach ($existentes as $row) {
            echo "ID: {$row['cvereq']} | Cuenta: {$row['cvecuenta']} | ";
            echo "Folio: {$row['folioreq']} | Año: {$row['axoreq']} | ";
            echo "Total: {$row['total']} | Vigencia: {$row['vigencia']}\n";
        }
        echo "\nTotal de registros: " . count($existentes) . "\n";
    } else {
        echo "No hay registros existentes\n";
    }

    // 2. Obtener rangos de datos
    echo "\n2. RANGOS DE DATOS:\n";
    echo str_repeat("-", 80) . "\n";
    $stmt = $pdo->query("
        SELECT
            MIN(cvereq) as min_id,
            MAX(cvereq) as max_id,
            MIN(cvecuenta) as min_cuenta,
            MAX(cvecuenta) as max_cuenta,
            MIN(folioreq) as min_folio,
            MAX(folioreq) as max_folio,
            MIN(axoreq) as min_anio,
            MAX(axoreq) as max_anio,
            COUNT(*) as total_registros
        FROM catastro_gdl.reqdiftransmision
    ");
    $rangos = $stmt->fetch();

    if ($rangos['total_registros'] > 0) {
        echo "IDs: {$rangos['min_id']} - {$rangos['max_id']}\n";
        echo "Cuentas: {$rangos['min_cuenta']} - {$rangos['max_cuenta']}\n";
        echo "Folios: {$rangos['min_folio']} - {$rangos['max_folio']}\n";
        echo "Años: {$rangos['min_anio']} - {$rangos['max_anio']}\n";
        echo "Total registros: {$rangos['total_registros']}\n";
    }

    // 3. Obtener cuentas existentes de reqdiftransmision
    echo "\n3. CUENTAS YA USADAS:\n";
    echo str_repeat("-", 80) . "\n";
    $stmt = $pdo->query("
        SELECT DISTINCT cvecuenta
        FROM catastro_gdl.reqdiftransmision
        WHERE cvecuenta IS NOT NULL
        ORDER BY cvecuenta
        LIMIT 20
    ");
    $cuentas = $stmt->fetchAll();

    if ($cuentas) {
        echo "Cuentas en uso: ";
        $lista_cuentas = array_column($cuentas, 'cvecuenta');
        echo implode(", ", $lista_cuentas) . "\n";
    }

    // 4. Generar datos de prueba sugeridos
    echo "\n4. DATOS DE PRUEBA SUGERIDOS:\n";
    echo str_repeat("-", 80) . "\n";

    // Obtener el siguiente ID disponible
    $stmt = $pdo->query("
        SELECT COALESCE(MAX(cvereq), 0) + 1 as siguiente_id
        FROM catastro_gdl.reqdiftransmision
    ");
    $siguiente = $stmt->fetch();

    echo "Siguiente ID disponible: {$siguiente['siguiente_id']}\n\n";

    // Sugerir combinaciones que NO existan
    echo "EJEMPLOS DE DATOS NUEVOS (no existen en BD):\n\n";

    $anio_actual = date('Y');
    $ejemplos = [];

    if ($cuentas && count($cuentas) > 0) {
        // Usar cuentas reales
        $cuenta_ejemplo = $cuentas[0]['cvecuenta'];

        // Buscar folios que NO existan para esta cuenta
        $stmt = $pdo->prepare("
            SELECT folioreq
            FROM catastro_gdl.reqdiftransmision
            WHERE cvecuenta = :cuenta
            AND axoreq = :anio
            ORDER BY folioreq
        ");
        $stmt->execute(['cuenta' => $cuenta_ejemplo, 'anio' => $anio_actual]);
        $folios_usados = array_column($stmt->fetchAll(), 'folioreq');

        // Generar folios disponibles
        $folio_disponible = 1;
        while (in_array($folio_disponible, $folios_usados)) {
            $folio_disponible++;
        }

        $ejemplos[] = [
            'cuenta' => $cuenta_ejemplo,
            'folio' => $folio_disponible,
            'ejercicio' => $anio_actual
        ];

        // Más ejemplos con diferentes cuentas
        for ($i = 1; $i < min(5, count($cuentas)); $i++) {
            $ejemplos[] = [
                'cuenta' => $cuentas[$i]['cvecuenta'],
                'folio' => rand(1000, 9999),
                'ejercicio' => $anio_actual
            ];
        }
    } else {
        // Generar datos genéricos
        $ejemplos = [
            ['cuenta' => 100001, 'folio' => 1001, 'ejercicio' => $anio_actual],
            ['cuenta' => 100002, 'folio' => 1002, 'ejercicio' => $anio_actual],
            ['cuenta' => 100003, 'folio' => 1003, 'ejercicio' => $anio_actual],
            ['cuenta' => 200001, 'folio' => 2001, 'ejercicio' => $anio_actual],
            ['cuenta' => 300001, 'folio' => 3001, 'ejercicio' => $anio_actual],
        ];
    }

    foreach ($ejemplos as $i => $ejemplo) {
        echo "Ejemplo " . ($i + 1) . ":\n";
        echo "  Cuenta: {$ejemplo['cuenta']}\n";
        echo "  Folio: {$ejemplo['folio']}\n";
        echo "  Año: {$ejemplo['ejercicio']}\n\n";
    }

    // 5. Verificar estructura de la tabla
    echo "\n5. ESTRUCTURA DE LA TABLA reqdiftransmision:\n";
    echo str_repeat("-", 80) . "\n";
    $stmt = $pdo->query("
        SELECT
            column_name,
            data_type,
            character_maximum_length,
            is_nullable,
            column_default
        FROM information_schema.columns
        WHERE table_schema = 'catastro_gdl'
        AND table_name = 'reqdiftransmision'
        ORDER BY ordinal_position
    ");
    $columnas = $stmt->fetchAll();

    foreach ($columnas as $col) {
        $tipo = $col['data_type'];
        if ($col['character_maximum_length']) {
            $tipo .= "({$col['character_maximum_length']})";
        }
        $nullable = $col['is_nullable'] === 'YES' ? 'NULL' : 'NOT NULL';
        $default = $col['column_default'] ? " DEFAULT {$col['column_default']}" : '';

        echo "{$col['column_name']}: {$tipo} {$nullable}{$default}\n";
    }

    echo "\n" . str_repeat("=", 80) . "\n";
    echo "RESUMEN PARA PRUEBAS:\n";
    echo "- El formulario requiere: Cuenta, Folio, Año\n";
    echo "- El SP validará que no exista la combinación Cuenta+Folio+Año\n";
    echo "- El importe por defecto es 1400.00\n";
    echo "- La vigencia por defecto es 'V'\n";
    echo "- Las fechas se generan automáticamente\n";

} catch (PDOException $e) {
    echo "Error de conexión: " . $e->getMessage() . "\n";
    exit(1);
}

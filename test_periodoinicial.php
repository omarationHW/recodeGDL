<?php
// Script para probar el stored procedure recaudadora_periodo_inicial actualizado

$host = '192.168.6.146';
$dbname = 'multas_reglamentos';
$user = 'refact';
$password = 'FF)-BQk2';

try {
    $pdo = new PDO("pgsql:host=$host;dbname=$dbname", $user, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "Conectado exitosamente.\n\n";

    // 1. Actualizar el stored procedure
    echo "1. Actualizando stored procedure recaudadora_periodo_inicial...\n";
    $sql = file_get_contents(__DIR__ . '/update_sp_periodoinicial.sql');
    $pdo->exec($sql);
    echo "   ✓ Stored procedure actualizado exitosamente.\n\n";

    // 2. Probar sin parámetro (año actual)
    echo "2. Probando sin parámetro (año actual)...\n";

    $stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_periodo_inicial(NULL)");
    $stmt->execute();
    $result = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo "   Total encontrados: " . count($result) . " registro(s)\n\n";

    if (count($result) > 0) {
        $param = $result[0];
        echo "   === PARÁMETROS DEL SISTEMA (AÑO ACTUAL) ===\n\n";
        echo "   Municipio: {$param['municipio']}\n";
        echo "   Ejercicio: {$param['ejercicio']}\n";
        echo "   Periodo Inicial: Bim {$param['bimestre_inicial']}/{$param['año_inicial']}\n";
        echo "   Periodo Final: Bim {$param['bimestre_fin']}/{$param['año_final']}\n";
        echo "   Director: {$param['director']}\n";
        echo "   Tesorero: {$param['tesorero']}\n";
        echo "   Presidente: {$param['presidente']}\n";
        echo "   Salario: $" . number_format($param['salario'], 2) . "\n";
        echo "   Aplica Descuento/Recargo: " . ($param['aplica_descuento_recargo'] === 't' ? 'Sí' : 'No') . "\n";
    }

    // 3. Probar con ejercicio 2024
    echo "\n\n3. Probando con ejercicio 2024...\n";

    $stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_periodo_inicial(?)");
    $stmt->execute([2024]);
    $result = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo "   Total encontrados: " . count($result) . " registro(s)\n";

    if (count($result) > 0) {
        $param = $result[0];
        echo "\n   === PARÁMETROS PARA EJERCICIO 2024 ===\n\n";
        echo "   Municipio: {$param['municipio']}\n";
        echo "   Ejercicio: {$param['ejercicio']}\n";
        echo "   Periodo: Bim {$param['bimestre_inicial']}/{$param['año_inicial']} - Bim {$param['bimestre_fin']}/{$param['año_final']}\n";
    }

    // 4. Probar con ejercicio 2023
    echo "\n\n4. Probando con ejercicio 2023...\n";

    $stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_periodo_inicial(?)");
    $stmt->execute([2023]);
    $result = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo "   Total encontrados: " . count($result) . " registro(s)\n";

    if (count($result) > 0) {
        $param = $result[0];
        echo "\n   === PARÁMETROS PARA EJERCICIO 2023 ===\n\n";
        echo "   Municipio: {$param['municipio']}\n";
        echo "   Ejercicio: {$param['ejercicio']}\n";
        echo "   Periodo: Bim {$param['bimestre_inicial']}/{$param['año_inicial']} - Bim {$param['bimestre_fin']}/{$param['año_final']}\n";
    }

    // 5. Información adicional
    echo "\n\n5. Información adicional...\n";
    echo "\n   ⚠️  IMPORTANTE:\n";
    echo "   - Esta función retorna valores PREDETERMINADOS\n";
    echo "   - La tabla 'parametros_sistema' NO EXISTE en la base de datos\n";
    echo "   - Los valores retornados son constantes o calculados:\n";
    echo "     * Municipio: Siempre 'Guadalajara'\n";
    echo "     * Ejercicio: El solicitado o año actual\n";
    echo "     * Bimestres: Siempre 1-6 (año completo)\n";
    echo "     * Director/Tesorero/Presidente: 'N/A'\n";
    echo "     * Salario: 0\n";
    echo "     * Aplica Descuento/Recargo: true\n\n";
    echo "   📌 Si se requieren valores reales, se debe crear la tabla\n";
    echo "      'public.parametros_sistema' con los campos correspondientes.\n";

    echo "\n\n✅ Todas las pruebas completadas exitosamente!\n";

} catch (PDOException $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
    exit(1);
}

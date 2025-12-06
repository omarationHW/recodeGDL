<?php
$host = '192.168.6.146';
$port = '5432';
$dbname = 'padron_licencias';
$user = 'refact';
$password = 'FF)-BQk2';

try {
    $dsn = "pgsql:host=$host;port=$port;dbname=$dbname";
    $pdo = new PDO($dsn, $user, $password, [
        PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
        PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC
    ]);

    echo "Buscando datos del local ID 113 en padron_licencias...\n\n";

    // Buscar el local 113 en comun.ta_11_locales
    $sql = "
        SELECT
            id_local,
            oficina,
            num_mercado,
            categoria,
            seccion,
            local,
            letra_local,
            bloque,
            nombre,
            arrendatario,
            vigencia
        FROM comun.ta_11_locales
        WHERE id_local = 113
    ";

    $stmt = $pdo->query($sql);
    $local = $stmt->fetch();

    if ($local) {
        echo "LOCAL ENCONTRADO:\n";
        echo str_repeat("=", 60) . "\n";
        echo "ID Local: {$local['id_local']}\n";
        echo "Oficina: {$local['oficina']}\n";
        echo "Mercado: {$local['num_mercado']}\n";
        echo "Categoría: {$local['categoria']}\n";
        echo "Sección: {$local['seccion']}\n";
        echo "Local: {$local['local']}\n";
        echo "Letra: " . ($local['letra_local'] ?: '(vacío)') . "\n";
        echo "Bloque: " . ($local['bloque'] ?: '(vacío)') . "\n";
        echo "Nombre: {$local['nombre']}\n";
        echo "Arrendatario: {$local['arrendatario']}\n";

        // Verificar si tiene energía
        echo "\n" . str_repeat("-", 60) . "\n";
        echo "VERIFICANDO ENERGÍA:\n";
        $sql = "SELECT id_energia FROM comunX.ta_11_energia WHERE id_local = 113";
        $stmt = $pdo->query($sql);
        $energia = $stmt->fetch();

        if ($energia) {
            echo "✓ Tiene registro de energía (ID: {$energia['id_energia']})\n";

            // Verificar adeudos
            $sql = "SELECT COUNT(*) as total FROM comunX.ta_11_adeudo_energ WHERE id_energia = {$energia['id_energia']}";
            $stmt = $pdo->query($sql);
            $adeudos = $stmt->fetch();
            echo "✓ Adeudos de energía: {$adeudos['total']}\n";

            // Verificar condonaciones
            $sql = "SELECT COUNT(*) as total FROM db_ingresos.ta_11_ade_ene_canc c
                    INNER JOIN comunX.ta_11_adeudo_energ ae ON c.id_energia = ae.id_energia
                    WHERE ae.id_energia = {$energia['id_energia']}";
            $stmt = $pdo->query($sql);
            $condonaciones = $stmt->fetch();
            echo "✓ Condonaciones: {$condonaciones['total']}\n";
        } else {
            echo "✗ No tiene registro de energía\n";
        }

        echo "\n" . str_repeat("=", 60) . "\n";
        echo "COMBINACIÓN DE PRUEBA PARA LA INTERFAZ:\n";
        echo str_repeat("=", 60) . "\n";
        echo "Oficina: {$local['oficina']}\n";
        echo "Mercado: {$local['num_mercado']}\n";
        echo "Categoría: {$local['categoria']}\n";
        echo "Sección: {$local['seccion']}\n";
        echo "Local: {$local['local']}\n";
        echo "Letra Local: " . ($local['letra_local'] ?: '(dejar vacío)') . "\n";
        echo "Bloque: " . ($local['bloque'] ?: '(dejar vacío)') . "\n";

    } else {
        echo "✗ Local 113 no encontrado en comun.ta_11_locales\n";
    }

} catch (PDOException $e) {
    echo "Error: " . $e->getMessage() . "\n";
    exit(1);
}

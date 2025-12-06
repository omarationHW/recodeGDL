<?php
// Configuración de la base de datos
$host = '192.168.6.146';
$port = '5432';
$dbname = 'mercados';
$user = 'refact';
$password = 'FF)-BQk2';

try {
    $dsn = "pgsql:host=$host;port=$port;dbname=$dbname";
    $pdo = new PDO($dsn, $user, $password, [
        PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
        PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC
    ]);

    echo "Buscando datos de prueba para condonaciones...\n\n";

    // 1. Buscar condonaciones que existan
    echo "1. Condonaciones de energía existentes:\n";
    echo str_repeat("-", 60) . "\n";
    $sql = "
        SELECT
            c.id_cancelacion,
            c.id_energia,
            c.axo,
            c.periodo,
            c.importe,
            e.id_local
        FROM public.ta_11_ade_ene_canc c
        INNER JOIN public.ta_11_energia e ON c.id_energia = e.id_energia
        LIMIT 5
    ";

    $stmt = $pdo->query($sql);
    $condonaciones = $stmt->fetchAll();

    if (count($condonaciones) > 0) {
        foreach ($condonaciones as $row) {
            echo "  ID Cancelación: {$row['id_cancelacion']}, ";
            echo "ID Energía: {$row['id_energia']}, ";
            echo "ID Local: {$row['id_local']}, ";
            echo "Año: {$row['axo']}, Periodo: {$row['periodo']}\n";
        }

        // Obtener detalles del primer local con condonaciones
        if (isset($condonaciones[0]['id_local'])) {
            $id_local = $condonaciones[0]['id_local'];

            echo "\n2. Detalles del local ID: $id_local\n";
            echo str_repeat("-", 60) . "\n";

            $sql = "
                SELECT
                    l.oficina,
                    l.num_mercado,
                    l.categoria,
                    l.seccion,
                    l.local,
                    l.letra_local,
                    l.bloque,
                    l.nombre
                FROM comun.ta_11_locales l
                WHERE l.id_local = :id_local
            ";

            $stmt = $pdo->prepare($sql);
            $stmt->execute(['id_local' => $id_local]);
            $local = $stmt->fetch();

            if ($local) {
                echo "  Oficina: {$local['oficina']}\n";
                echo "  Mercado: {$local['num_mercado']}\n";
                echo "  Categoría: {$local['categoria']}\n";
                echo "  Sección: {$local['seccion']}\n";
                echo "  Local: {$local['local']}\n";
                echo "  Letra: " . ($local['letra_local'] ?: 'NULL') . "\n";
                echo "  Bloque: " . ($local['bloque'] ?: 'NULL') . "\n";
                echo "  Nombre: {$local['nombre']}\n";

                echo "\n" . str_repeat("=", 60) . "\n";
                echo "COMBINACIÓN DE PRUEBA:\n";
                echo str_repeat("=", 60) . "\n";
                echo "Oficina: {$local['oficina']}\n";
                echo "Mercado: {$local['num_mercado']}\n";
                echo "Sección: {$local['seccion']}\n";
                echo "Local: {$local['local']}\n";
                echo "Letra: " . ($local['letra_local'] ?: '(dejar vacío)') . "\n";
                echo "Bloque: " . ($local['bloque'] ?: '(dejar vacío)') . "\n";
            } else {
                echo "  ✗ Local no encontrado en comun.ta_11_locales\n";
            }
        }
    } else {
        echo "  ✗ No se encontraron condonaciones\n";

        // Si no hay condonaciones, buscar al menos un local con energía
        echo "\n3. Buscando locales con adeudos de energía:\n";
        echo str_repeat("-", 60) . "\n";

        $sql = "
            SELECT DISTINCT
                l.oficina,
                l.num_mercado,
                l.categoria,
                l.seccion,
                l.local,
                l.letra_local,
                l.bloque,
                l.nombre
            FROM comun.ta_11_locales l
            INNER JOIN public.ta_11_energia e ON l.id_local = e.id_local
            INNER JOIN public.ta_11_adeudo_energ ae ON e.id_energia = ae.id_energia
            LIMIT 5
        ";

        $stmt = $pdo->query($sql);
        $locales = $stmt->fetchAll();

        if (count($locales) > 0) {
            echo "Locales con adeudos de energía (pero sin condonaciones):\n";
            foreach ($locales as $local) {
                echo "  Oficina: {$local['oficina']}, ";
                echo "Mercado: {$local['num_mercado']}, ";
                echo "Sección: {$local['seccion']}, ";
                echo "Local: {$local['local']}\n";
            }
        }
    }

} catch (PDOException $e) {
    echo "Error: " . $e->getMessage() . "\n";
    exit(1);
}

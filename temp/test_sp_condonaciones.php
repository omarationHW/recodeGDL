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

    echo "Probando sp_cons_condonacion_energia...\n\n";
    echo "Parámetros de prueba (Local ID 113):\n";
    echo str_repeat("=", 60) . "\n";
    echo "Oficina: 5\n";
    echo "Mercado: 1\n";
    echo "Categoría: 1\n";
    echo "Sección: T1\n";
    echo "Local: 107\n";
    echo "Letra: (null)\n";
    echo "Bloque: (null)\n\n";

    $sql = "SELECT * FROM sp_cons_condonacion_energia(5, 1, 1, 'T1', 107, null, null)";
    $stmt = $pdo->query($sql);
    $resultados = $stmt->fetchAll();

    if (count($resultados) > 0) {
        echo "✓ SE ENCONTRARON " . count($resultados) . " CONDONACIONES\n";
        echo str_repeat("=", 60) . "\n\n";

        foreach ($resultados as $i => $row) {
            echo "Condonación #" . ($i + 1) . ":\n";
            echo "  ID Condonación: {$row['id_condonacion']}\n";
            echo "  Local: {$row['nombre_local']}\n";
            echo "  Año: {$row['axo']}, Periodo: {$row['periodo']}\n";
            echo "  Importe Original: \${$row['importe_original']}\n";
            echo "  Importe Condonado: \${$row['importe_condonado']}\n";
            echo "  Fecha: {$row['fecha_condonacion']}\n";
            if ($row['motivo']) echo "  Motivo: {$row['motivo']}\n";
            if ($row['observacion']) echo "  Observación: {$row['observacion']}\n";
            if ($row['usuario']) echo "  Usuario: {$row['usuario']}\n";
            echo "\n";
        }

        echo str_repeat("=", 60) . "\n";
        echo "✓ SP FUNCIONA CORRECTAMENTE\n";
        echo str_repeat("=", 60) . "\n";

    } else {
        echo "✗ No se encontraron condonaciones para estos parámetros\n";
        echo "Verificando si el local existe...\n\n";

        $sql = "SELECT * FROM comun.ta_11_locales
                WHERE oficina = 5 AND num_mercado = 1 AND seccion = 'T1' AND local = 107";
        $stmt = $pdo->query($sql);
        $local = $stmt->fetch();

        if ($local) {
            echo "✓ El local existe (ID: {$local['id_local']})\n";
            echo "  Pero no tiene condonaciones registradas\n";
        } else {
            echo "✗ El local no existe con esos parámetros\n";
        }
    }

} catch (PDOException $e) {
    echo "✗ ERROR: " . $e->getMessage() . "\n";
    exit(1);
}

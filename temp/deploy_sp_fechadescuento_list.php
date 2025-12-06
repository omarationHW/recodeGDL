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
    $sqlFile = __DIR__ . '/../RefactorX/Base/mercados/database/database/FechaDescuento_sp_fechadescuento_list.sql';
    $sql = file_get_contents($sqlFile);

    echo "Desplegando sp_fechadescuento_list...\n";
    $pdo->exec($sql);
    echo "✓ SP desplegado exitosamente\n\n";

    // Probar el SP
    echo "=== Probando SP ===\n";

    try {
        $stmt = $pdo->query("SELECT * FROM sp_fechadescuento_list()");
        $results = $stmt->fetchAll(PDO::FETCH_ASSOC);

        if (count($results) > 0) {
            echo "✓ SP ejecutado correctamente\n";
            echo "  Registros encontrados: " . count($results) . "\n";

            // Mostrar primeros 3 registros
            $limit = min(3, count($results));
            for ($i = 0; $i < $limit; $i++) {
                $row = $results[$i];
                echo "\n  Registro #" . ($i + 1) . ":\n";
                echo "    Mes: {$row['mes']}\n";
                echo "    Fecha Descuento: {$row['fecha_descuento']}\n";
                echo "    Fecha Alta: {$row['fecha_alta']}\n";
                echo "    ID Usuario: {$row['id_usuario']}\n";
                echo "    Usuario: {$row['usuario']}\n";
                echo "    Fecha Recargos: {$row['fecha_recargos']}\n";
            }

            if (count($results) > 3) {
                echo "\n  ... y " . (count($results) - 3) . " registros más\n";
            }
        } else {
            echo "✓ SP ejecutado pero no retornó resultados\n";
            echo "  (No hay fechas de descuento registradas)\n";
        }
    } catch (PDOException $e) {
        echo "✗ Error al ejecutar: " . $e->getMessage() . "\n";
    }

    echo "\n✅ SP desplegado correctamente\n";

} catch (PDOException $e) {
    echo "✗ Error: " . $e->getMessage() . "\n";
    exit(1);
}

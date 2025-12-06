<?php
// Crear el SP sp_get_movimientos

$dbConfig = [
    'host' => '192.168.6.146',
    'port' => '5432',
    'dbname' => 'mercados',
    'user' => 'refact',
    'password' => 'FF)-BQk2'
];

try {
    $dsn = "pgsql:host={$dbConfig['host']};port={$dbConfig['port']};dbname={$dbConfig['dbname']}";
    $pdo = new PDO($dsn, $dbConfig['user'], $dbConfig['password']);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "✓ Conectado a la base de datos\n\n";

    // Crear SP
    echo "Creando SP sp_get_movimientos...\n";

    $createSP = <<<'SQL'
CREATE OR REPLACE FUNCTION sp_get_movimientos()
RETURNS TABLE(
    clave_movimiento smallint,
    descripcion varchar
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT
        m.clave_movimiento,
        m.descripcion
    FROM public.ta_11_clave_mov m
    ORDER BY m.clave_movimiento;
END;
$$;
SQL;

    $pdo->exec($createSP);

    echo "✓ SP creado exitosamente\n\n";

    // Probar el SP
    echo "Probando SP...\n";
    echo str_repeat('=', 80) . "\n";

    $stmt = $pdo->query("SELECT * FROM sp_get_movimientos()");
    $data = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo "Registros encontrados: " . count($data) . "\n\n";

    foreach ($data as $row) {
        printf("%2d - %s\n", $row['clave_movimiento'], $row['descripcion']);
    }

    echo "\n✓ SP funcionando correctamente\n";

} catch (Exception $e) {
    echo "✗ ERROR: " . $e->getMessage() . "\n";
    exit(1);
}

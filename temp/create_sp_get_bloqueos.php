<?php
// Crear el SP sp_get_bloqueos

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
    echo "Creando SP sp_get_bloqueos...\n";

    $createSP = <<<'SQL'
CREATE OR REPLACE FUNCTION sp_get_bloqueos()
RETURNS TABLE(
    cve_bloqueo integer,
    descripcion varchar
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT
        b.cve_bloqueo,
        b.descripcion
    FROM public.ta_11_cvebloqueo b
    ORDER BY b.cve_bloqueo;
END;
$$;
SQL;

    $pdo->exec($createSP);

    echo "✓ SP creado exitosamente\n\n";

    // Probar el SP
    echo "Probando SP...\n";
    echo str_repeat('=', 80) . "\n";

    $stmt = $pdo->query("SELECT * FROM sp_get_bloqueos()");
    $data = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo "Registros encontrados: " . count($data) . "\n\n";

    foreach ($data as $row) {
        printf("%d - %s\n", $row['cve_bloqueo'], $row['descripcion']);
    }

    echo "\n✓ SP funcionando correctamente\n";

} catch (Exception $e) {
    echo "✗ ERROR: " . $e->getMessage() . "\n";
    exit(1);
}

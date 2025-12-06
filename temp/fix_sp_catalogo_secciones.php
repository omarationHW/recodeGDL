<?php
// Corregir el SP sp_catalogo_secciones

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

    // Eliminar SP existente
    echo "Eliminando SP existente...\n";
    $pdo->exec("DROP FUNCTION IF EXISTS sp_catalogo_secciones() CASCADE");
    echo "✓ SP eliminado\n\n";

    // Crear SP corregido
    echo "Creando SP sp_catalogo_secciones...\n";

    $createSP = <<<'SQL'
CREATE OR REPLACE FUNCTION sp_catalogo_secciones()
RETURNS TABLE(
    clave character varying,
    descripcion character varying
)
LANGUAGE plpgsql
AS $function$
BEGIN
    RETURN QUERY
    SELECT DISTINCT
        l.seccion::VARCHAR as clave,
        CASE l.seccion
            WHEN '01' THEN 'SECCION 01'
            WHEN '02' THEN 'SECCION 02'
            WHEN 'EA' THEN 'ENERGIA ALUMBRADO'
            WHEN 'PS' THEN 'PLAZAS Y SECTORES'
            WHEN 'SS' THEN 'SOBRE SUELO'
            WHEN 'T1' THEN 'TIPO 1'
            WHEN 'T2' THEN 'TIPO 2'
            ELSE l.seccion::VARCHAR
        END as descripcion
    FROM public.ta_11_cuo_locales l
    WHERE l.seccion IS NOT NULL
    ORDER BY clave;
END;
$function$;
SQL;

    $pdo->exec($createSP);

    echo "✓ SP creado exitosamente\n\n";

    // Probar el SP
    echo "Probando SP...\n";
    echo str_repeat('=', 80) . "\n";

    $stmt = $pdo->query("SELECT * FROM sp_catalogo_secciones()");
    $data = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo "Registros encontrados: " . count($data) . "\n\n";

    foreach ($data as $row) {
        echo "  {$row['clave']} - {$row['descripcion']}\n";
    }

    echo "\n✓ SP funcionando correctamente\n";

} catch (Exception $e) {
    echo "✗ ERROR: " . $e->getMessage() . "\n";
    exit(1);
}

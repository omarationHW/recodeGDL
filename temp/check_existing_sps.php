<?php
$pdo = new PDO('pgsql:host=192.168.6.146;port=5432;dbname=mercados', 'refact', 'FF)-BQk2', [PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION]);

$sp_names = [
    'sp_energia_modif_buscar',
    'sp_rpt_emision_laser',
    'sp_rpt_factura_emision',
    'rpt_factura_energia',
    'sp_reporte_catalogo_mercados',
    'sp_get_movimientos_locales'
];

echo "🔍 Verificando SPs en la base de datos:\n\n";

foreach ($sp_names as $sp) {
    $stmt = $pdo->query("
        SELECT 
            routine_name,
            routine_schema,
            pg_catalog.pg_get_function_arguments(p.oid) as parameters
        FROM information_schema.routines r
        JOIN pg_proc p ON p.proname = r.routine_name
        WHERE routine_schema = 'public'
        AND routine_name = '$sp'
    ");
    
    $result = $stmt->fetch(PDO::FETCH_ASSOC);
    
    if ($result) {
        echo "✅ $sp existe\n";
        echo "   Parámetros: {$result['parameters']}\n\n";
    } else {
        echo "❌ $sp NO EXISTE\n\n";
    }
}
?>

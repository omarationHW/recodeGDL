<?php
$pdo = new PDO('pgsql:host=192.168.6.146;port=5432;dbname=mercados', 'refact', 'FF)-BQk2', [PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION]);

echo "Verificando coincidencias entre cuentas:\n\n";

$mercados = $pdo->query("SELECT DISTINCT cuenta_ingreso FROM publico.ta_11_mercados WHERE cuenta_ingreso IS NOT NULL ORDER BY cuenta_ingreso LIMIT 10")->fetchAll(PDO::FETCH_COLUMN);
echo "Primeras 10 cuentas de mercados:\n";
foreach ($mercados as $cta) {
    echo "  - $cta\n";
}

$importes = $pdo->query("SELECT DISTINCT cta_aplicacion FROM public.ta_12_importes WHERE (cta_aplicacion BETWEEN 44501 AND 44588) OR (cta_aplicacion = 44119) ORDER BY cta_aplicacion LIMIT 10")->fetchAll(PDO::FETCH_COLUMN);
echo "\nPrimeras 10 cuentas de importes (44501-44588, 44119):\n";
foreach ($importes as $cta) {
    echo "  - $cta\n";
}

echo "\nVerificando si hay coincidencias:\n";
$coincidencias = $pdo->query("
    SELECT COUNT(*) as total
    FROM public.ta_12_importes i
    INNER JOIN publico.ta_11_mercados m ON m.cuenta_ingreso = i.cta_aplicacion
    WHERE i.fecing BETWEEN '2001-01-01' AND '2010-12-31'
      AND ((i.cta_aplicacion BETWEEN 44501 AND 44588) OR (i.cta_aplicacion = 44119))
")->fetch();
echo "Registros con coincidencia: " . number_format($coincidencias['total']) . "\n";
?>

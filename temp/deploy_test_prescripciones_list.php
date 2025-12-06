<?php
$pdo = new PDO('pgsql:host=192.168.6.146;port=5432;dbname=mercados', 'refact', 'FF)-BQk2', [PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION]);

echo "🚀 Desplegando Prescripcion (listar prescripciones):\n\n";

try {
    $pdo->exec(file_get_contents('RefactorX/Base/mercados/database/database/Prescripcion_sp_listar_prescripciones.sql'));
    echo "✅ Prescripcion_sp_listar_prescripciones.sql desplegado\n\n";

    echo "🧪 Probando SP:\n";
    // Buscar un id_energia válido primero
    $stmt = $pdo->query("SELECT id_energia FROM public.ta_11_energia LIMIT 1");
    $row = $stmt->fetch(PDO::FETCH_ASSOC);

    if ($row) {
        $id_energia = $row['id_energia'];
        echo "  Probando con id_energia=$id_energia\n";
        $stmt = $pdo->query("SELECT * FROM public.sp_listar_prescripciones($id_energia) LIMIT 5");
        $count = $stmt->rowCount();
        echo "  ✅ OK - $count registros encontrados\n";
    } else {
        echo "  ⚠️  No hay registros en ta_11_energia para probar\n";
    }

} catch (PDOException $e) {
    echo "❌ ERROR: " . $e->getMessage() . "\n";
}
?>

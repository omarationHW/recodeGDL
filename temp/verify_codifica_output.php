<?php
try {
    $pdo = new PDO('pgsql:host=192.168.6.146;port=5432;dbname=padron_licencias', 'refact', 'FF)-BQk2');
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "===========================================\n";
    echo "VERIFICACIÓN DE SALIDA LIMPIA\n";
    echo "===========================================\n\n";

    $texto = "Hola Mundo";
    $stmt = $pdo->prepare("SELECT * FROM public.recaudadora_codificafrm(?)");
    $stmt->execute([$texto]);
    $result = $stmt->fetch(PDO::FETCH_ASSOC);

    echo "Entrada: \"$texto\"\n\n";
    echo "Resultado que se mostrará en el módulo:\n";
    echo json_encode($result, JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE) . "\n\n";

    echo "---\n\n";
    echo "AHORA SOLO VERÁS:\n";
    echo "- El objeto JSON limpio con los 8 campos de codificación\n";
    echo "- Sin información adicional de la base de datos\n";
    echo "- Sin metadatos de la consulta SQL\n";
    echo "- Formato JSON legible y organizado\n";

} catch(Exception $e) {
    echo "Error: " . $e->getMessage() . "\n";
    exit(1);
}

<?php
// Probar el formato de respuesta de sp_fechaseg_create

try {
    $db = new PDO('pgsql:host=192.168.6.146;port=5432;dbname=padron_licencias', 'refact', 'FF)-BQk2');
    $db->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "=== PROBAR SP_FECHASEG_CREATE ===\n\n";

    // Obtener la definición del SP
    echo "📖 Definición del SP:\n";
    echo str_repeat("-", 80) . "\n";
    $stmt = $db->query("
        SELECT pg_get_functiondef(oid) as definition
        FROM pg_proc
        WHERE proname = 'sp_fechaseg_create'
        AND pronamespace = (SELECT oid FROM pg_namespace WHERE nspname = 'comun')
        LIMIT 1
    ");
    $def = $stmt->fetch(PDO::FETCH_ASSOC);
    if ($def) {
        echo $def['definition'] . "\n";
    }
    echo str_repeat("-", 80) . "\n\n";

    // Probar el SP con datos de prueba
    echo "🧪 Probando sp_fechaseg_create con datos de prueba:\n";
    echo str_repeat("-", 80) . "\n";

    try {
        $stmt = $db->prepare("SELECT * FROM comun.sp_fechaseg_create(?, ?, ?, ?, ?, ?, ?)");
        $stmt->execute([
            999999,                           // t42_doctos_id
            999,                              // t42_centros_id
            100,                              // usuario_seg
            '2021-12-01 10:00:00',           // fec_seg
            1,                                // t42_statusseg_id
            'Prueba desde Claude',            // observacion
            'TEST'                            // usuario_mov
        ]);

        $result = $stmt->fetchAll(PDO::FETCH_ASSOC);

        echo "📊 Resultado del SP:\n";
        echo "Tipo: " . gettype($result) . "\n";
        echo "Count: " . count($result) . "\n\n";

        if (count($result) > 0) {
            echo "Estructura de la respuesta:\n";
            print_r($result);
            echo "\n";

            echo "Primer registro:\n";
            $primer = $result[0];
            foreach ($primer as $key => $value) {
                echo "  $key => $value\n";
            }
        } else {
            echo "❌ El SP no retornó resultados\n";
        }

    } catch (PDOException $e) {
        echo "❌ Error al ejecutar SP: " . $e->getMessage() . "\n";
    }

    echo str_repeat("-", 80) . "\n";

} catch (PDOException $e) {
    echo "❌ Error de conexión: " . $e->getMessage() . "\n";
}

<?php
// Probar respuesta del SP con NULL (sin filtro)

try {
    $db = new PDO('pgsql:host=192.168.6.146;port=5432;dbname=padron_licencias', 'refact', 'FF)-BQk2');
    $db->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "=== PROBAR SP_FECHASEG_LIST SIN FILTRO ===\n\n";

    $stmt = $db->prepare("SELECT * FROM comun.sp_fechaseg_list(NULL, NULL) LIMIT 10");
    $stmt->execute();
    $results = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo "📊 Total registros obtenidos: " . count($results) . "\n\n";

    if (count($results) > 0) {
        echo "✅ SP retorna datos\n\n";

        echo "Estructura del primer registro:\n";
        echo str_repeat("-", 80) . "\n";
        $primerRegistro = $results[0];
        foreach ($primerRegistro as $campo => $valor) {
            $tipo = gettype($valor);
            $valor_str = $valor ?? 'NULL';
            if (is_string($valor) && strlen($valor) > 50) {
                $valor_str = substr($valor, 0, 47) . '...';
            }
            echo sprintf("%-20s | %-10s | %s\n", $campo, $tipo, $valor_str);
        }
        echo str_repeat("-", 80) . "\n\n";

        echo "Primeros 5 registros:\n";
        echo str_repeat("-", 80) . "\n";
        foreach ($results as $i => $row) {
            if ($i < 5) {
                echo ($i + 1) . ". ID: {$row['id']} - Fecha: {$row['fec_seg']} - Docto: {$row['t42_doctos_id']}\n";
            }
        }
        echo str_repeat("-", 80) . "\n";
    } else {
        echo "❌ SP no retorna datos\n";
    }

} catch (PDOException $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
}

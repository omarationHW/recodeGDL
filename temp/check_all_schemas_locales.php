<?php
echo "==============================================\n";
echo "VERIFICACIÓN: Locales en TODOS los esquemas\n";
echo "==============================================\n\n";

$pdo = new PDO('pgsql:host=192.168.6.146;port=5432;dbname=mercados', 'refact', 'FF)-BQk2', [
    PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION
]);

$id_local = 11257;

echo "Buscando id_local=$id_local en todas las combinaciones posibles...\n\n";

$schemas = ['public', 'publico'];
$tables = ['ta_11_locales', 'ta_11_localpaso'];

foreach ($schemas as $schema) {
    foreach ($tables as $table) {
        $fullName = "$schema.$table";
        echo "Verificando: $fullName\n";

        try {
            $query = "SELECT id_local, nombre, domicilio, sector, zona, giro FROM $fullName WHERE id_local = ?";
            $stmt = $pdo->prepare($query);
            $stmt->execute([$id_local]);
            $result = $stmt->fetch(PDO::FETCH_ASSOC);

            if ($result) {
                echo "   ✓ ENCONTRADO\n";
                echo "   - nombre: {$result['nombre']}\n";
                echo "   - domicilio: '{$result['domicilio']}'\n";
                echo "   - sector: {$result['sector']}\n";
                echo "   - zona: {$result['zona']}\n";
                echo "   - giro: {$result['giro']}\n";
            } else {
                echo "   ✗ No existe el registro\n";
            }
        } catch (Exception $e) {
            echo "   ✗ Tabla no existe o error: " . $e->getMessage() . "\n";
        }
        echo "\n";
    }
}

echo "==============================================\n";
echo "CONCLUSIÓN\n";
echo "==============================================\n";
echo "Si el registro existe en publico.ta_11_locales pero no\n";
echo "en public.ta_11_localpaso, entonces los SPs deben modificarse\n";
echo "para usar publico.ta_11_locales en lugar de public.ta_11_localpaso\n";
?>

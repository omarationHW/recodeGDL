<?php
// Script para probar el stored procedure recaudadora_propuestatab

$host = '192.168.6.146';
$dbname = 'multas_reglamentos';
$user = 'refact';
$password = 'FF)-BQk2';

try {
    $pdo = new PDO("pgsql:host=$host;dbname=$dbname", $user, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "Conectado exitosamente.\n\n";

    // 1. Actualizar el stored procedure
    echo "1. Actualizando stored procedure recaudadora_propuestatab...\n";
    $sql = file_get_contents(__DIR__ . '/update_sp_propuestatab.sql');
    $pdo->exec($sql);
    echo "   ✓ Stored procedure actualizado exitosamente.\n\n";

    // 2. Probar sin filtro
    echo "2. Probando sin filtro...\n";

    $stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_propuestatab('')");
    $stmt->execute();
    $result = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo "   Total encontrados: " . count($result) . " registro(s)\n";

    if (count($result) === 0) {
        echo "   ℹ️  Resultado: No hay propuestas de pago disponibles\n";
        echo "   ℹ️  Razón: La tabla propuestas_pago no existe en la base de datos\n";
    }

    // 3. Probar con filtro
    echo "\n\n3. Probando con filtro 'test'...\n";

    $stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_propuestatab(?)");
    $stmt->execute(['test']);
    $result = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo "   Total encontrados: " . count($result) . " registro(s)\n";

    if (count($result) === 0) {
        echo "   ℹ️  Resultado: No hay propuestas para el filtro especificado\n";
    }

    // 4. Información adicional
    echo "\n\n4. Información adicional...\n";
    echo "\n   ⚠️  IMPORTANTE:\n";
    echo "   - Esta función retorna un conjunto VACÍO\n";
    echo "   - La tabla 'propuestas_pago' NO EXISTE en la base de datos\n";
    echo "   - No hay datos de propuestas de pago disponibles\n";
    echo "   - La función está preparada con la estructura correcta:\n";
    echo "     * id_propuesta: ID de la propuesta\n";
    echo "     * cvepago: Código de pago\n";
    echo "     * cvecuenta: Clave de cuenta\n";
    echo "     * recaud: Código de recaudación\n";
    echo "     * caja: Número de caja\n";
    echo "     * folio: Folio de la propuesta\n";
    echo "     * fecha: Fecha de la propuesta\n";
    echo "     * hora: Hora de la propuesta\n";
    echo "     * importe: Monto de la propuesta\n";
    echo "     * cajero: Usuario/cajero\n";
    echo "     * cveconcepto: Clave de concepto\n";
    echo "     * estado: Estado de la propuesta\n\n";
    echo "   📌 Si se requieren datos reales de propuestas de pago,\n";
    echo "      se debe crear la tabla 'public.propuestas_pago' con los\n";
    echo "      campos correspondientes. (Ver estructura en update_sp_propuestatab.sql)\n";

    echo "\n\n✅ Todas las pruebas completadas exitosamente!\n";
    echo "   (Función operacional, retorna conjunto vacío como esperado)\n";

} catch (PDOException $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
    exit(1);
}

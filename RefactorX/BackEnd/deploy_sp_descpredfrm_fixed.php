<?php
/**
 * Script de despliegue para recaudadora_descpredfrm (versión simplificada sin JOINs)
 *
 * Este script despliega el SP modificado que elimina el JOIN con c_descpred
 * para mejorar el rendimiento y evitar problemas de relaciones entre tablas.
 */

$host = 'localhost';
$port = '5432';
$dbname = 'municipal_gdl';
$user = 'postgres';
$password = 'postgres';

try {
    echo "=================================================\n";
    echo "DESPLEGANDO SP: recaudadora_descpredfrm (FIXED)\n";
    echo "=================================================\n\n";

    $pdo = new PDO("pgsql:host=$host;port=$port;dbname=$dbname", $user, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    // Leer el archivo SQL
    $sqlFile = __DIR__ . '/../Base/multas_reglamentos/database/generated/recaudadora_descpredfrm.sql';

    if (!file_exists($sqlFile)) {
        throw new Exception("Archivo SQL no encontrado: $sqlFile");
    }

    $sql = file_get_contents($sqlFile);

    echo "📄 Archivo leído: recaudadora_descpredfrm.sql\n";
    echo "📊 Tamaño: " . strlen($sql) . " bytes\n\n";

    // Ejecutar el SQL
    echo "🚀 Ejecutando SQL...\n";
    $pdo->exec($sql);

    echo "✅ SP desplegado exitosamente!\n\n";

    // Verificar que el SP existe
    $checkSql = "
        SELECT
            p.proname AS function_name,
            pg_get_function_arguments(p.oid) AS arguments,
            d.description
        FROM pg_proc p
        LEFT JOIN pg_description d ON p.oid = d.objoid
        WHERE p.pronamespace = (SELECT oid FROM pg_namespace WHERE nspname = 'multas_reglamentos')
        AND p.proname = 'recaudadora_descpredfrm'
    ";

    $stmt = $pdo->query($checkSql);
    $result = $stmt->fetch(PDO::FETCH_ASSOC);

    if ($result) {
        echo "✓ Verificación exitosa:\n";
        echo "  - Función: {$result['function_name']}\n";
        echo "  - Argumentos: {$result['arguments']}\n";
        echo "  - Descripción: {$result['description']}\n\n";
    }

    // Probar el SP con una consulta de ejemplo
    echo "🧪 Probando el SP...\n";
    $testSql = "SELECT * FROM multas_reglamentos.recaudadora_descpredfrm('58') LIMIT 5";
    $stmt = $pdo->query($testSql);
    $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo "  Registros retornados: " . count($rows) . "\n";
    if (count($rows) > 0) {
        echo "  Ejemplo de registro:\n";
        foreach ($rows[0] as $key => $value) {
            echo "    - $key: " . (strlen($value) > 50 ? substr($value, 0, 47) . '...' : $value) . "\n";
        }
    }

    echo "\n=================================================\n";
    echo "✅ DESPLIEGUE COMPLETADO EXITOSAMENTE\n";
    echo "=================================================\n";
    echo "\nCAMBIOS REALIZADOS:\n";
    echo "- ❌ Eliminado: JOIN con catastro_gdl.c_descpred\n";
    echo "- ✅ Usa solo: catastro_gdl.descpred\n";
    echo "- ✅ Campos ajustados con COALESCE para valores por defecto\n";
    echo "- ✅ Mejor rendimiento sin JOINs cruzados\n\n";

} catch (PDOException $e) {
    echo "\n❌ ERROR DE BASE DE DATOS:\n";
    echo "Mensaje: " . $e->getMessage() . "\n";
    echo "Código: " . $e->getCode() . "\n";
    exit(1);
} catch (Exception $e) {
    echo "\n❌ ERROR:\n";
    echo $e->getMessage() . "\n";
    exit(1);
}

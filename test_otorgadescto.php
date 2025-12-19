<?php
// Script para probar el stored procedure recaudadora_otorga_descto actualizado

$host = '192.168.6.146';
$dbname = 'multas_reglamentos';
$user = 'refact';
$password = 'FF)-BQk2';

try {
    $pdo = new PDO("pgsql:host=$host;dbname=$dbname", $user, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "Conectado exitosamente.\n\n";

    // 1. Actualizar el stored procedure
    echo "1. Actualizando stored procedure recaudadora_otorga_descto...\n";
    $sql = file_get_contents(__DIR__ . '/update_sp_otorgadescto.sql');
    $pdo->exec($sql);
    echo "   ✓ Stored procedure actualizado exitosamente.\n\n";

    // 2. Probar búsqueda sin filtro (todos los descuentos)
    echo "2. Probando búsqueda sin filtro (todos los descuentos, 50 registros)...\n";

    $stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_otorga_descto('', 0, 0, 50)");
    $stmt->execute();
    $result = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo "   Total encontrados en página: " . count($result) . "\n";
    if (count($result) > 0) {
        echo "   Total en base de datos: " . number_format($result[0]['total_count']) . "\n\n";

        echo "   === PRIMEROS 5 DESCUENTOS OTORGADOS ===\n";
        for ($i = 0; $i < min(5, count($result)); $i++) {
            $desc = $result[$i];
            echo "\n   DESCUENTO " . ($i + 1) . ":\n";
            echo "   Folio: {$desc['folio_descto']}\n";
            echo "   ID Multa: {$desc['id_multa']}\n";
            echo "   Ejercicio: {$desc['ejercicio']}\n";
            echo "   Descripción: " . substr($desc['descripcion'], 0, 80) . (strlen($desc['descripcion']) > 80 ? '...' : '') . "\n";
            echo "   Fecha Inicio: {$desc['fecha_inicio']}\n";
            echo "   Fecha Fin: {$desc['fecha_fin']}\n";
            echo "   Porcentaje: {$desc['porcentaje_autorizado']}%\n";
            echo "   Monto Autorizado: $" . number_format($desc['monto_autorizado'], 2) . "\n";
            echo "   Adeudo: $" . number_format($desc['adeudo'], 2) . "\n";
            echo "   Tipo: {$desc['tipo_descuento']}\n";
            echo "   Vigencia: {$desc['vigencia']}\n";
            echo "   Motivo: " . substr($desc['motivo'], 0, 60) . (strlen($desc['motivo']) > 60 ? '...' : '') . "\n";
            echo "   Usuario: {$desc['usuario_captura']}\n";
        }
    }

    // 3. Probar búsqueda con filtro por id_multa
    echo "\n\n3. Probando búsqueda con filtro por ID multa (ejemplo: JBB3383)...\n";

    $stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_otorga_descto(?, 0, 0, 50)");
    $stmt->execute(['JBB3383']);
    $result = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo "   Total encontrados: " . count($result) . "\n";
    if (count($result) > 0) {
        echo "   Total coincidencias: " . number_format($result[0]['total_count']) . "\n";
        echo "\n   Coincidencias:\n";
        for ($i = 0; $i < min(3, count($result)); $i++) {
            $desc = $result[$i];
            echo "   - Folio: {$desc['folio_descto']}, ";
            echo "Multa: {$desc['id_multa']}, ";
            echo "Ejercicio: {$desc['ejercicio']}, ";
            echo "Porcentaje: {$desc['porcentaje_autorizado']}%, ";
            echo "Adeudo: $" . number_format($desc['adeudo'], 2) . "\n";
        }
    }

    // 4. Probar búsqueda con filtro por ejercicio
    echo "\n\n4. Probando búsqueda con filtro por ejercicio (ejemplo: 2022)...\n";

    $stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_otorga_descto('', ?, 0, 50)");
    $stmt->execute([2022]);
    $result = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo "   Total encontrados: " . count($result) . "\n";
    if (count($result) > 0) {
        echo "   Total descuentos del 2022: " . number_format($result[0]['total_count']) . "\n";
        echo "\n   Primeros 3 descuentos del 2022:\n";
        for ($i = 0; $i < min(3, count($result)); $i++) {
            $desc = $result[$i];
            echo "   - Folio: {$desc['folio_descto']}, ";
            echo "Multa: {$desc['id_multa']}, ";
            echo "Porcentaje: {$desc['porcentaje_autorizado']}%, ";
            echo "Tipo: {$desc['tipo_descuento']}\n";
        }
    }

    // 5. Probar búsqueda con filtro por año 2023
    echo "\n\n5. Probando búsqueda con filtro por ejercicio 2023...\n";

    $stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_otorga_descto('', ?, 0, 50)");
    $stmt->execute([2023]);
    $result = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo "   Total encontrados: " . count($result) . "\n";
    if (count($result) > 0) {
        echo "   Total descuentos del 2023: " . number_format($result[0]['total_count']) . "\n";
        echo "\n   Primeros 3 descuentos del 2023:\n";
        for ($i = 0; $i < min(3, count($result)); $i++) {
            $desc = $result[$i];
            echo "   - Folio: {$desc['folio_descto']}, ";
            echo "Multa: {$desc['id_multa']}, ";
            echo "Fecha: {$desc['fecha_captura']}, ";
            echo "Porcentaje: {$desc['porcentaje_autorizado']}%\n";
        }
    }

    // 6. Probar búsqueda con filtro combinado (multa + ejercicio)
    echo "\n\n6. Probando búsqueda con filtro combinado (multa 402591 + ejercicio 2023)...\n";

    $stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_otorga_descto(?, ?, 0, 50)");
    $stmt->execute(['402591', 2023]);
    $result = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo "   Total encontrados: " . count($result) . "\n";
    if (count($result) > 0) {
        echo "   Descuento encontrado:\n";
        $desc = $result[0];
        echo "   - Folio: {$desc['folio_descto']}\n";
        echo "   - Multa: {$desc['id_multa']}\n";
        echo "   - Ejercicio: {$desc['ejercicio']}\n";
        echo "   - Porcentaje: {$desc['porcentaje_autorizado']}%\n";
        echo "   - Adeudo: $" . number_format($desc['adeudo'], 2) . "\n";
        echo "   - Tipo: {$desc['tipo_descuento']}\n";
        echo "   - Vigencia: {$desc['vigencia']}\n";
    }

    // 7. Estadísticas generales
    echo "\n\n7. Estadísticas generales...\n";

    $stmt_total = $pdo->query("SELECT COUNT(*) as total FROM public.aut_desctosotorgados");
    $total = $stmt_total->fetch(PDO::FETCH_ASSOC);
    echo "   Total descuentos otorgados: " . number_format($total['total']) . "\n";

    // Ver distribución por vigencia
    echo "\n   Distribución por vigencia:\n";
    $stmt_vigencia = $pdo->query("
        SELECT
            CASE
                WHEN TRIM(vigencia) = 'B' THEN 'Vigente'
                WHEN TRIM(vigencia) = 'C' THEN 'Cancelado'
                ELSE 'Desconocido'
            END as estado,
            COUNT(*) as total
        FROM public.aut_desctosotorgados
        GROUP BY vigencia
        ORDER BY total DESC
    ");
    $vigencias = $stmt_vigencia->fetchAll(PDO::FETCH_ASSOC);
    foreach ($vigencias as $vig) {
        echo "   - {$vig['estado']}: " . number_format($vig['total']) . "\n";
    }

    // Ver distribución por tipo de descuento
    echo "\n   Distribución por tipo de descuento:\n";
    $stmt_tipo = $pdo->query("
        SELECT
            CASE
                WHEN TRIM(tipo_descto) = 'P' THEN 'Porcentaje'
                WHEN TRIM(tipo_descto) = 'I' THEN 'Importe'
                ELSE 'Desconocido'
            END as tipo,
            COUNT(*) as total
        FROM public.aut_desctosotorgados
        GROUP BY tipo_descto
        ORDER BY total DESC
    ");
    $tipos = $stmt_tipo->fetchAll(PDO::FETCH_ASSOC);
    foreach ($tipos as $tipo) {
        echo "   - {$tipo['tipo']}: " . number_format($tipo['total']) . "\n";
    }

    // Ver distribución por año
    echo "\n   Años con descuentos otorgados:\n";
    $stmt_anios = $pdo->query("
        SELECT
            axo AS anio,
            COUNT(*) as total
        FROM public.aut_desctosotorgados
        WHERE axo > 0
        GROUP BY axo
        ORDER BY axo DESC
    ");
    $anios = $stmt_anios->fetchAll(PDO::FETCH_ASSOC);
    foreach ($anios as $anio) {
        echo "   - Año {$anio['anio']}: " . number_format($anio['total']) . " descuentos\n";
    }

    // Ver resumen de porcentajes
    echo "\n   Resumen de porcentajes autorizados:\n";
    $stmt_porcentajes = $pdo->query("
        SELECT
            MIN(por_aut) as minimo,
            MAX(por_aut) as maximo,
            AVG(por_aut) as promedio
        FROM public.aut_desctosotorgados
        WHERE por_aut > 0
    ");
    $porcent = $stmt_porcentajes->fetch(PDO::FETCH_ASSOC);
    if ($porcent) {
        echo "   - Mínimo: {$porcent['minimo']}%\n";
        echo "   - Máximo: {$porcent['maximo']}%\n";
        echo "   - Promedio: " . number_format($porcent['promedio'], 2) . "%\n";
    }

    echo "\n\n✅ Todas las pruebas completadas exitosamente!\n";

} catch (PDOException $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
    exit(1);
}

<?php
/**
 * Sincroniza datos de recaudadoras desde padron_licencias a mercados
 * De: padron_licencias.comun.ta_12_recaudadoras
 * A: mercados.public.ta_12_recaudadoras
 */

echo "═══════════════════════════════════════════════════════════════\n";
echo " SINCRONIZACIÓN DE RECAUDADORAS\n";
echo "═══════════════════════════════════════════════════════════════\n\n";

try {
    // Conexión a padron_licencias (origen)
    $pdoOrigen = new PDO(
        "pgsql:host=192.168.6.146;port=5432;dbname=padron_licencias",
        "refact",
        "FF)-BQk2"
    );
    $pdoOrigen->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    // Conexión a mercados (destino)
    $pdoDestino = new PDO(
        "pgsql:host=192.168.6.146;port=5432;dbname=mercados",
        "refact",
        "FF)-BQk2"
    );
    $pdoDestino->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "✓ Conexión exitosa a ambas bases de datos\n\n";

    // Leer datos de origen
    echo "📖 Leyendo recaudadoras de padron_licencias.comun...\n";
    $stmt = $pdoOrigen->query("
        SELECT id_rec, id_zona, recaudadora, domicilio, tel, recaudador
        FROM comun.ta_12_recaudadoras
        ORDER BY id_rec
    ");
    $recaudadoras = $stmt->fetchAll(PDO::FETCH_ASSOC);
    echo "   Encontrados: " . count($recaudadoras) . " registros\n\n";

    // Limpiar tabla destino
    echo "🗑️  Limpiando tabla mercados.public.ta_12_recaudadoras...\n";
    $pdoDestino->exec("TRUNCATE TABLE public.ta_12_recaudadoras");
    echo "   ✓ Tabla limpiada\n\n";

    // Insertar datos
    echo "📝 Insertando recaudadoras en mercados.public...\n";
    $insertStmt = $pdoDestino->prepare("
        INSERT INTO public.ta_12_recaudadoras
        (id_rec, id_zona, recaudadora, domicilio, tel, recaudador)
        VALUES (?, ?, ?, ?, ?, ?)
    ");

    $count = 0;
    foreach ($recaudadoras as $rec) {
        $insertStmt->execute([
            $rec['id_rec'],
            $rec['id_zona'],
            $rec['recaudadora'],
            $rec['domicilio'],
            $rec['tel'],
            $rec['recaudador']
        ]);
        $count++;
        echo "   ✓ {$rec['id_rec']}: {$rec['recaudadora']}\n";
    }

    echo "\n✅ Sincronización completada: $count registros copiados\n\n";

    // Verificar SP
    echo "🔍 Verificando SP sp_get_recaudadoras...\n";
    $stmt = $pdoDestino->query("SELECT * FROM sp_get_recaudadoras()");
    $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);
    echo "   Total desde SP: " . count($rows) . " registros\n\n";

    foreach ($rows as $row) {
        echo "   {$row['id_rec']}: {$row['recaudadora']}\n";
    }

    echo "\n═══════════════════════════════════════════════════════════════\n";
    echo " ✅ PROCESO COMPLETADO EXITOSAMENTE\n";
    echo "═══════════════════════════════════════════════════════════════\n\n";

    echo "📋 RESUMEN:\n";
    echo "   - Origen: padron_licencias.comun.ta_12_recaudadoras\n";
    echo "   - Destino: mercados.public.ta_12_recaudadoras\n";
    echo "   - Registros sincronizados: $count\n";
    echo "   - SP verificado: sp_get_recaudadoras()\n\n";

    echo "🔄 COMPONENTES AFECTADOS (ahora verán todos los datos):\n";
    echo "   - RptPadronEnergia.vue\n";
    echo "   - PadronEnergia.vue\n";
    echo "   - RptMovimientos.vue\n";
    echo "   - Otros componentes que usen sp_get_recaudadoras\n\n";

} catch (PDOException $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
    exit(1);
}

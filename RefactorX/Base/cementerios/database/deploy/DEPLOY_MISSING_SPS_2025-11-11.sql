-- ================================================================
-- DEPLOYMENT SCRIPT: cementerios
-- SPs Faltantes: 32
-- Fecha: 2025-11-11
-- ================================================================
--
-- INSTRUCCIONES:
-- 1. Revisar cada SP generado en: ../generated/
-- 2. Implementar la lógica específica de cada SP
-- 3. Ejecutar este script en la base de datos: cementerios
-- 4. Verificar que todos los SPs se crearon correctamente
--
-- ================================================================

\echo ''
\echo '=================================================='
\echo 'DEPLOYMENT: cementerios - 32 SPs'
\echo '=================================================='
\echo ''

-- Establecer schema
SET search_path TO public;


-- [1/32] sp_cem_abc_cementerios - 4 usos (🟡 MEDIA)
\echo 'Creando: sp_cem_abc_cementerios...'
\i ../generated/sp_cem_abc_cementerios.sql
\echo '   ✓ OK'

-- [2/32] sp_cem_registrar_pago - 4 usos (🟡 MEDIA)
\echo 'Creando: sp_cem_registrar_pago...'
\i ../generated/sp_cem_registrar_pago.sql
\echo '   ✓ OK'

-- [3/32] sp_cem_abc_pagos_por_folio - 3 usos (🟡 MEDIA)
\echo 'Creando: sp_cem_abc_pagos_por_folio...'
\i ../generated/sp_cem_abc_pagos_por_folio.sql
\echo '   ✓ OK'

-- [4/32] sp_cem_modificar_folio - 2 usos (🟡 MEDIA)
\echo 'Creando: sp_cem_modificar_folio...'
\i ../generated/sp_cem_modificar_folio.sql
\echo '   ✓ OK'

-- [5/32] sp_cem_baja_folio - 2 usos (🟡 MEDIA)
\echo 'Creando: sp_cem_baja_folio...'
\i ../generated/sp_cem_baja_folio.sql
\echo '   ✓ OK'

-- [6/32] sp_cem_buscar_folio_pagos - 2 usos (🟡 MEDIA)
\echo 'Creando: sp_cem_buscar_folio_pagos...'
\i ../generated/sp_cem_buscar_folio_pagos.sql
\echo '   ✓ OK'

-- [7/32] sp_cem_obtener_adeudos_pendientes - 2 usos (🟡 MEDIA)
\echo 'Creando: sp_cem_obtener_adeudos_pendientes...'
\i ../generated/sp_cem_obtener_adeudos_pendientes.sql
\echo '   ✓ OK'

-- [8/32] sp_cem_listar_pagos_folio - 2 usos (🟡 MEDIA)
\echo 'Creando: sp_cem_listar_pagos_folio...'
\i ../generated/sp_cem_listar_pagos_folio.sql
\echo '   ✓ OK'

-- [9/32] sp_cem_bonificaciones_oficio - 2 usos (🟡 MEDIA)
\echo 'Creando: sp_cem_bonificaciones_oficio...'
\i ../generated/sp_cem_bonificaciones_oficio.sql
\echo '   ✓ OK'

-- [10/32] sp_cem_buscar_bonificacion - 2 usos (🟡 MEDIA)
\echo 'Creando: sp_cem_buscar_bonificacion...'
\i ../generated/sp_cem_buscar_bonificacion.sql
\echo '   ✓ OK'

-- [11/32] sp_cem_registrar_bonificacion - 2 usos (🟡 MEDIA)
\echo 'Creando: sp_cem_registrar_bonificacion...'
\i ../generated/sp_cem_registrar_bonificacion.sql
\echo '   ✓ OK'

-- [12/32] sp_cem_eliminar_bonificacion - 2 usos (🟡 MEDIA)
\echo 'Creando: sp_cem_eliminar_bonificacion...'
\i ../generated/sp_cem_eliminar_bonificacion.sql
\echo '   ✓ OK'

-- [13/32] sp_cem_obtener_pagos_folio - 2 usos (🟡 MEDIA)
\echo 'Creando: sp_cem_obtener_pagos_folio...'
\i ../generated/sp_cem_obtener_pagos_folio.sql
\echo '   ✓ OK'

-- [14/32] sp_cem_obtener_adeudos_folio - 2 usos (🟡 MEDIA)
\echo 'Creando: sp_cem_obtener_adeudos_folio...'
\i ../generated/sp_cem_obtener_adeudos_folio.sql
\echo '   ✓ OK'

-- [15/32] sp_cem_calcular_liquidacion - 2 usos (🟡 MEDIA)
\echo 'Creando: sp_cem_calcular_liquidacion...'
\i ../generated/sp_cem_calcular_liquidacion.sql
\echo '   ✓ OK'

-- [16/32] sp_cem_consultar_folios_por_ubicacion - 2 usos (🟡 MEDIA)
\echo 'Creando: sp_cem_consultar_folios_por_ubicacion...'
\i ../generated/sp_cem_consultar_folios_por_ubicacion.sql
\echo '   ✓ OK'

-- [17/32] sp_cem_listar_titulos - 2 usos (🟡 MEDIA)
\echo 'Creando: sp_cem_listar_titulos...'
\i ../generated/sp_cem_listar_titulos.sql
\echo '   ✓ OK'

-- [18/32] sp_cem_buscar_titulo - 2 usos (🟡 MEDIA)
\echo 'Creando: sp_cem_buscar_titulo...'
\i ../generated/sp_cem_buscar_titulo.sql
\echo '   ✓ OK'

-- [19/32] sp_cem_actualizar_titulo_extra - 2 usos (🟡 MEDIA)
\echo 'Creando: sp_cem_actualizar_titulo_extra...'
\i ../generated/sp_cem_actualizar_titulo_extra.sql
\echo '   ✓ OK'

-- [20/32] sp_validar_usuario - 1 usos (⚪ BAJA)
\echo 'Creando: sp_validar_usuario...'
\i ../generated/sp_validar_usuario.sql
\echo '   ✓ OK'

-- [21/32] sp_registrar_acceso - 1 usos (⚪ BAJA)
\echo 'Creando: sp_registrar_acceso...'
\i ../generated/sp_registrar_acceso.sql
\echo '   ✓ OK'

-- [22/32] sp_cem_consultar_por_nombre - 1 usos (⚪ BAJA)
\echo 'Creando: sp_cem_consultar_por_nombre...'
\i ../generated/sp_cem_consultar_por_nombre.sql
\echo '   ✓ OK'

-- [23/32] sp_cem_buscar_duplicados - 1 usos (⚪ BAJA)
\echo 'Creando: sp_cem_buscar_duplicados...'
\i ../generated/sp_cem_buscar_duplicados.sql
\echo '   ✓ OK'

-- [24/32] sp_cem_verificar_ubicacion_duplicado - 1 usos (⚪ BAJA)
\echo 'Creando: sp_cem_verificar_ubicacion_duplicado...'
\i ../generated/sp_cem_verificar_ubicacion_duplicado.sql
\echo '   ✓ OK'

-- [25/32] sp_cem_trasladar_duplicado - 1 usos (⚪ BAJA)
\echo 'Creando: sp_cem_trasladar_duplicado...'
\i ../generated/sp_cem_trasladar_duplicado.sql
\echo '   ✓ OK'

-- [26/32] sp_cem_estadisticas_adeudos - 1 usos (⚪ BAJA)
\echo 'Creando: sp_cem_estadisticas_adeudos...'
\i ../generated/sp_cem_estadisticas_adeudos.sql
\echo '   ✓ OK'

-- [27/32] sp_cem_consultar_pagos_por_fecha - 1 usos (⚪ BAJA)
\echo 'Creando: sp_cem_consultar_pagos_por_fecha...'
\i ../generated/sp_cem_consultar_pagos_por_fecha.sql
\echo '   ✓ OK'

-- [28/32] sp_validar_password_actual - 1 usos (⚪ BAJA)
\echo 'Creando: sp_validar_password_actual...'
\i ../generated/sp_validar_password_actual.sql
\echo '   ✓ OK'

-- [29/32] sp_cambiar_password - 1 usos (⚪ BAJA)
\echo 'Creando: sp_cambiar_password...'
\i ../generated/sp_cambiar_password.sql
\echo '   ✓ OK'

-- [30/32] sp_cem_generar_titulo - 1 usos (⚪ BAJA)
\echo 'Creando: sp_cem_generar_titulo...'
\i ../generated/sp_cem_generar_titulo.sql
\echo '   ✓ OK'

-- [31/32] sp_cem_listar_pagos - 1 usos (⚪ BAJA)
\echo 'Creando: sp_cem_listar_pagos...'
\i ../generated/sp_cem_listar_pagos.sql
\echo '   ✓ OK'

-- [32/32] sp_cem_trasladar_folio - 1 usos (⚪ BAJA)
\echo 'Creando: sp_cem_trasladar_folio...'
\i ../generated/sp_cem_trasladar_folio.sql
\echo '   ✓ OK'

\echo ''
\echo '=================================================='
\echo 'DEPLOYMENT COMPLETADO: 32 SPs creados'
\echo '=================================================='
\echo ''

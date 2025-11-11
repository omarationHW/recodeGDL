-- ================================================================
-- DEPLOYMENT SCRIPT: aseo_contratado
-- SPs Faltantes: 100
-- Fecha: 2025-11-11
-- ================================================================
--
-- INSTRUCCIONES:
-- 1. Revisar cada SP generado en: ../generated/
-- 2. Implementar la lógica específica de cada SP
-- 3. Ejecutar este script en la base de datos: aseo_contratado
-- 4. Verificar que todos los SPs se crearon correctamente
--
-- ================================================================

\echo ''
\echo '=================================================='
\echo 'DEPLOYMENT: aseo_contratado - 100 SPs'
\echo '=================================================='
\echo ''

-- Establecer schema
SET search_path TO public;


-- [1/100] sp_aseo_zonas_list - 15 usos (🔴 ALTA)
\echo 'Creando: sp_aseo_zonas_list...'
\i ../generated/sp_aseo_zonas_list.sql
\echo '   ✓ OK'

-- [2/100] sp_aseo_contrato_consultar - 11 usos (🔴 ALTA)
\echo 'Creando: sp_aseo_contrato_consultar...'
\i ../generated/sp_aseo_contrato_consultar.sql
\echo '   ✓ OK'

-- [3/100] sp_aseo_unidades_list - 10 usos (🔴 ALTA)
\echo 'Creando: sp_aseo_unidades_list...'
\i ../generated/sp_aseo_unidades_list.sql
\echo '   ✓ OK'

-- [4/100] sp_aseo_tipos_list - 6 usos (🔴 ALTA)
\echo 'Creando: sp_aseo_tipos_list...'
\i ../generated/sp_aseo_tipos_list.sql
\echo '   ✓ OK'

-- [5/100] sp_aseo_adeudos_buscar_contrato - 5 usos (🔴 ALTA)
\echo 'Creando: sp_aseo_adeudos_buscar_contrato...'
\i ../generated/sp_aseo_adeudos_buscar_contrato.sql
\echo '   ✓ OK'

-- [6/100] sp_aseo_recaudadoras_list - 3 usos (🟡 MEDIA)
\echo 'Creando: sp_aseo_recaudadoras_list...'
\i ../generated/sp_aseo_recaudadoras_list.sql
\echo '   ✓ OK'

-- [7/100] sp_aseo_adeudos_pendientes - 3 usos (🟡 MEDIA)
\echo 'Creando: sp_aseo_adeudos_pendientes...'
\i ../generated/sp_aseo_adeudos_pendientes.sql
\echo '   ✓ OK'

-- [8/100] sp_aseo_adeudos_por_contrato - 3 usos (🟡 MEDIA)
\echo 'Creando: sp_aseo_adeudos_por_contrato...'
\i ../generated/sp_aseo_adeudos_por_contrato.sql
\echo '   ✓ OK'

-- [9/100] sp_aseo_cves_operacion_list - 2 usos (🟡 MEDIA)
\echo 'Creando: sp_aseo_cves_operacion_list...'
\i ../generated/sp_aseo_cves_operacion_list.sql
\echo '   ✓ OK'

-- [10/100] sp_aseo_adeudos_carga_masiva - 2 usos (🟡 MEDIA)
\echo 'Creando: sp_aseo_adeudos_carga_masiva...'
\i ../generated/sp_aseo_adeudos_carga_masiva.sql
\echo '   ✓ OK'

-- [11/100] sp_aseo_adeudos_insertar - 2 usos (🟡 MEDIA)
\echo 'Creando: sp_aseo_adeudos_insertar...'
\i ../generated/sp_aseo_adeudos_insertar.sql
\echo '   ✓ OK'

-- [12/100] sp_aseo_pagos_por_contrato - 2 usos (🟡 MEDIA)
\echo 'Creando: sp_aseo_pagos_por_contrato...'
\i ../generated/sp_aseo_pagos_por_contrato.sql
\echo '   ✓ OK'

-- [13/100] sp_aseo_estadisticas_por_tipo - 2 usos (🟡 MEDIA)
\echo 'Creando: sp_aseo_estadisticas_por_tipo...'
\i ../generated/sp_aseo_estadisticas_por_tipo.sql
\echo '   ✓ OK'

-- [14/100] sp_aseo_estadisticas_por_empresa - 2 usos (🟡 MEDIA)
\echo 'Creando: sp_aseo_estadisticas_por_empresa...'
\i ../generated/sp_aseo_estadisticas_por_empresa.sql
\echo '   ✓ OK'

-- [15/100] sp_aseo_cves_operacion_create - 1 usos (⚪ BAJA)
\echo 'Creando: sp_aseo_cves_operacion_create...'
\i ../generated/sp_aseo_cves_operacion_create.sql
\echo '   ✓ OK'

-- [16/100] sp_aseo_cves_operacion_update - 1 usos (⚪ BAJA)
\echo 'Creando: sp_aseo_cves_operacion_update...'
\i ../generated/sp_aseo_cves_operacion_update.sql
\echo '   ✓ OK'

-- [17/100] sp_aseo_cves_operacion_delete - 1 usos (⚪ BAJA)
\echo 'Creando: sp_aseo_cves_operacion_delete...'
\i ../generated/sp_aseo_cves_operacion_delete.sql
\echo '   ✓ OK'

-- [18/100] sp_aseo_empresas_create - 1 usos (⚪ BAJA)
\echo 'Creando: sp_aseo_empresas_create...'
\i ../generated/sp_aseo_empresas_create.sql
\echo '   ✓ OK'

-- [19/100] sp_aseo_empresas_update - 1 usos (⚪ BAJA)
\echo 'Creando: sp_aseo_empresas_update...'
\i ../generated/sp_aseo_empresas_update.sql
\echo '   ✓ OK'

-- [20/100] sp_aseo_empresas_delete - 1 usos (⚪ BAJA)
\echo 'Creando: sp_aseo_empresas_delete...'
\i ../generated/sp_aseo_empresas_delete.sql
\echo '   ✓ OK'

-- [21/100] sp_aseo_gastos_create - 1 usos (⚪ BAJA)
\echo 'Creando: sp_aseo_gastos_create...'
\i ../generated/sp_aseo_gastos_create.sql
\echo '   ✓ OK'

-- [22/100] sp_aseo_gastos_update - 1 usos (⚪ BAJA)
\echo 'Creando: sp_aseo_gastos_update...'
\i ../generated/sp_aseo_gastos_update.sql
\echo '   ✓ OK'

-- [23/100] sp_aseo_gastos_delete - 1 usos (⚪ BAJA)
\echo 'Creando: sp_aseo_gastos_delete...'
\i ../generated/sp_aseo_gastos_delete.sql
\echo '   ✓ OK'

-- [24/100] sp_aseo_recargos_create - 1 usos (⚪ BAJA)
\echo 'Creando: sp_aseo_recargos_create...'
\i ../generated/sp_aseo_recargos_create.sql
\echo '   ✓ OK'

-- [25/100] sp_aseo_recargos_update - 1 usos (⚪ BAJA)
\echo 'Creando: sp_aseo_recargos_update...'
\i ../generated/sp_aseo_recargos_update.sql
\echo '   ✓ OK'

-- [26/100] sp_aseo_recargos_delete - 1 usos (⚪ BAJA)
\echo 'Creando: sp_aseo_recargos_delete...'
\i ../generated/sp_aseo_recargos_delete.sql
\echo '   ✓ OK'

-- [27/100] sp_aseo_tipos_create - 1 usos (⚪ BAJA)
\echo 'Creando: sp_aseo_tipos_create...'
\i ../generated/sp_aseo_tipos_create.sql
\echo '   ✓ OK'

-- [28/100] sp_aseo_tipos_update - 1 usos (⚪ BAJA)
\echo 'Creando: sp_aseo_tipos_update...'
\i ../generated/sp_aseo_tipos_update.sql
\echo '   ✓ OK'

-- [29/100] sp_aseo_tipos_delete - 1 usos (⚪ BAJA)
\echo 'Creando: sp_aseo_tipos_delete...'
\i ../generated/sp_aseo_tipos_delete.sql
\echo '   ✓ OK'

-- [30/100] sp_aseo_tipos_emp_list - 1 usos (⚪ BAJA)
\echo 'Creando: sp_aseo_tipos_emp_list...'
\i ../generated/sp_aseo_tipos_emp_list.sql
\echo '   ✓ OK'

-- [31/100] sp_aseo_tipos_emp_create - 1 usos (⚪ BAJA)
\echo 'Creando: sp_aseo_tipos_emp_create...'
\i ../generated/sp_aseo_tipos_emp_create.sql
\echo '   ✓ OK'

-- [32/100] sp_aseo_tipos_emp_update - 1 usos (⚪ BAJA)
\echo 'Creando: sp_aseo_tipos_emp_update...'
\i ../generated/sp_aseo_tipos_emp_update.sql
\echo '   ✓ OK'

-- [33/100] sp_aseo_tipos_emp_delete - 1 usos (⚪ BAJA)
\echo 'Creando: sp_aseo_tipos_emp_delete...'
\i ../generated/sp_aseo_tipos_emp_delete.sql
\echo '   ✓ OK'

-- [34/100] sp_aseo_unidades_create - 1 usos (⚪ BAJA)
\echo 'Creando: sp_aseo_unidades_create...'
\i ../generated/sp_aseo_unidades_create.sql
\echo '   ✓ OK'

-- [35/100] sp_aseo_unidades_update - 1 usos (⚪ BAJA)
\echo 'Creando: sp_aseo_unidades_update...'
\i ../generated/sp_aseo_unidades_update.sql
\echo '   ✓ OK'

-- [36/100] sp_aseo_unidades_delete - 1 usos (⚪ BAJA)
\echo 'Creando: sp_aseo_unidades_delete...'
\i ../generated/sp_aseo_unidades_delete.sql
\echo '   ✓ OK'

-- [37/100] sp_aseo_zonas_create - 1 usos (⚪ BAJA)
\echo 'Creando: sp_aseo_zonas_create...'
\i ../generated/sp_aseo_zonas_create.sql
\echo '   ✓ OK'

-- [38/100] sp_aseo_zonas_update - 1 usos (⚪ BAJA)
\echo 'Creando: sp_aseo_zonas_update...'
\i ../generated/sp_aseo_zonas_update.sql
\echo '   ✓ OK'

-- [39/100] sp_aseo_zonas_delete - 1 usos (⚪ BAJA)
\echo 'Creando: sp_aseo_zonas_delete...'
\i ../generated/sp_aseo_zonas_delete.sql
\echo '   ✓ OK'

-- [40/100] sp_aseo_adeudos_generar_recargos - 1 usos (⚪ BAJA)
\echo 'Creando: sp_aseo_adeudos_generar_recargos...'
\i ../generated/sp_aseo_adeudos_generar_recargos.sql
\echo '   ✓ OK'

-- [41/100] sp_aseo_adeudos_registrar_pago - 1 usos (⚪ BAJA)
\echo 'Creando: sp_aseo_adeudos_registrar_pago...'
\i ../generated/sp_aseo_adeudos_registrar_pago.sql
\echo '   ✓ OK'

-- [42/100] sp_aseo_pago_multiple - 1 usos (⚪ BAJA)
\echo 'Creando: sp_aseo_pago_multiple...'
\i ../generated/sp_aseo_pago_multiple.sql
\echo '   ✓ OK'

-- [43/100] sp_aseo_pagos_buscar - 1 usos (⚪ BAJA)
\echo 'Creando: sp_aseo_pagos_buscar...'
\i ../generated/sp_aseo_pagos_buscar.sql
\echo '   ✓ OK'

-- [44/100] sp_aseo_pagos_actualizar_periodos - 1 usos (⚪ BAJA)
\echo 'Creando: sp_aseo_pagos_actualizar_periodos...'
\i ../generated/sp_aseo_pagos_actualizar_periodos.sql
\echo '   ✓ OK'

-- [45/100] sp_aseo_pagos_historial_actualizaciones - 1 usos (⚪ BAJA)
\echo 'Creando: sp_aseo_pagos_historial_actualizaciones...'
\i ../generated/sp_aseo_pagos_historial_actualizaciones.sql
\echo '   ✓ OK'

-- [46/100] sp_aseo_aplicar_exencion - 1 usos (⚪ BAJA)
\echo 'Creando: sp_aseo_aplicar_exencion...'
\i ../generated/sp_aseo_aplicar_exencion.sql
\echo '   ✓ OK'

-- [47/100] sp_aseo_multa_aplicar - 1 usos (⚪ BAJA)
\echo 'Creando: sp_aseo_multa_aplicar...'
\i ../generated/sp_aseo_multa_aplicar.sql
\echo '   ✓ OK'

-- [48/100] sp_aseo_consulta_contratos - 1 usos (⚪ BAJA)
\echo 'Creando: sp_aseo_consulta_contratos...'
\i ../generated/sp_aseo_consulta_contratos.sql
\echo '   ✓ OK'

-- [49/100] sp_aseo_detalle_contrato - 1 usos (⚪ BAJA)
\echo 'Creando: sp_aseo_detalle_contrato...'
\i ../generated/sp_aseo_detalle_contrato.sql
\echo '   ✓ OK'

-- [50/100] sp_aseo_consulta_ordenada - 1 usos (⚪ BAJA)
\echo 'Creando: sp_aseo_consulta_ordenada...'
\i ../generated/sp_aseo_consulta_ordenada.sql
\echo '   ✓ OK'

-- [51/100] sp_aseo_contratos_list - 1 usos (⚪ BAJA)
\echo 'Creando: sp_aseo_contratos_list...'
\i ../generated/sp_aseo_contratos_list.sql
\echo '   ✓ OK'

-- [52/100] sp_aseo_cancelar_contrato - 1 usos (⚪ BAJA)
\echo 'Creando: sp_aseo_cancelar_contrato...'
\i ../generated/sp_aseo_cancelar_contrato.sql
\echo '   ✓ OK'

-- [53/100] sp_aseo_estadisticas_contratos - 1 usos (⚪ BAJA)
\echo 'Creando: sp_aseo_estadisticas_contratos...'
\i ../generated/sp_aseo_estadisticas_contratos.sql
\echo '   ✓ OK'

-- [54/100] sp_aseo_contratos_create - 1 usos (⚪ BAJA)
\echo 'Creando: sp_aseo_contratos_create...'
\i ../generated/sp_aseo_contratos_create.sql
\echo '   ✓ OK'

-- [55/100] sp_aseo_contratos_baja - 1 usos (⚪ BAJA)
\echo 'Creando: sp_aseo_contratos_baja...'
\i ../generated/sp_aseo_contratos_baja.sql
\echo '   ✓ OK'

-- [56/100] sp_aseo_contrato_cancelar - 1 usos (⚪ BAJA)
\echo 'Creando: sp_aseo_contrato_cancelar...'
\i ../generated/sp_aseo_contrato_cancelar.sql
\echo '   ✓ OK'

-- [57/100] sp_aseo_contratos_consulta_admin - 1 usos (⚪ BAJA)
\echo 'Creando: sp_aseo_contratos_consulta_admin...'
\i ../generated/sp_aseo_contratos_consulta_admin.sql
\echo '   ✓ OK'

-- [58/100] sp_aseo_contratos_por_tipo - 1 usos (⚪ BAJA)
\echo 'Creando: sp_aseo_contratos_por_tipo...'
\i ../generated/sp_aseo_contratos_por_tipo.sql
\echo '   ✓ OK'

-- [59/100] sp_aseo_estadisticas_generales - 1 usos (⚪ BAJA)
\echo 'Creando: sp_aseo_estadisticas_generales...'
\i ../generated/sp_aseo_estadisticas_generales.sql
\echo '   ✓ OK'

-- [60/100] sp_aseo_estadisticas_por_zona - 1 usos (⚪ BAJA)
\echo 'Creando: sp_aseo_estadisticas_por_zona...'
\i ../generated/sp_aseo_estadisticas_por_zona.sql
\echo '   ✓ OK'

-- [61/100] sp_aseo_contratos_update - 1 usos (⚪ BAJA)
\echo 'Creando: sp_aseo_contratos_update...'
\i ../generated/sp_aseo_contratos_update.sql
\echo '   ✓ OK'

-- [62/100] sp_aseo_contratos_para_upd_periodo - 1 usos (⚪ BAJA)
\echo 'Creando: sp_aseo_contratos_para_upd_periodo...'
\i ../generated/sp_aseo_contratos_para_upd_periodo.sql
\echo '   ✓ OK'

-- [63/100] sp_aseo_actualizar_periodos_contratos - 1 usos (⚪ BAJA)
\echo 'Creando: sp_aseo_actualizar_periodos_contratos...'
\i ../generated/sp_aseo_actualizar_periodos_contratos.sql
\echo '   ✓ OK'

-- [64/100] sp_aseo_contratos_para_upd_unidad - 1 usos (⚪ BAJA)
\echo 'Creando: sp_aseo_contratos_para_upd_unidad...'
\i ../generated/sp_aseo_contratos_para_upd_unidad.sql
\echo '   ✓ OK'

-- [65/100] sp_aseo_actualizar_unidades_contratos - 1 usos (⚪ BAJA)
\echo 'Creando: sp_aseo_actualizar_unidades_contratos...'
\i ../generated/sp_aseo_actualizar_unidades_contratos.sql
\echo '   ✓ OK'

-- [66/100] sp_aseo_estadisticas_sincronizacion - 1 usos (⚪ BAJA)
\echo 'Creando: sp_aseo_estadisticas_sincronizacion...'
\i ../generated/sp_aseo_estadisticas_sincronizacion.sql
\echo '   ✓ OK'

-- [67/100] sp_aseo_convenio_crear - 1 usos (⚪ BAJA)
\echo 'Creando: sp_aseo_convenio_crear...'
\i ../generated/sp_aseo_convenio_crear.sql
\echo '   ✓ OK'

-- [68/100] sp_aseo_convenios_consultar - 1 usos (⚪ BAJA)
\echo 'Creando: sp_aseo_convenios_consultar...'
\i ../generated/sp_aseo_convenios_consultar.sql
\echo '   ✓ OK'

-- [69/100] sp_aseo_ejercicios_listar - 1 usos (⚪ BAJA)
\echo 'Creando: sp_aseo_ejercicios_listar...'
\i ../generated/sp_aseo_ejercicios_listar.sql
\echo '   ✓ OK'

-- [70/100] sp_aseo_ejercicio_estadisticas - 1 usos (⚪ BAJA)
\echo 'Creando: sp_aseo_ejercicio_estadisticas...'
\i ../generated/sp_aseo_ejercicio_estadisticas.sql
\echo '   ✓ OK'

-- [71/100] sp_aseo_ejercicio_cerrar - 1 usos (⚪ BAJA)
\echo 'Creando: sp_aseo_ejercicio_cerrar...'
\i ../generated/sp_aseo_ejercicio_cerrar.sql
\echo '   ✓ OK'

-- [72/100] sp_aseo_periodos_listar - 1 usos (⚪ BAJA)
\echo 'Creando: sp_aseo_periodos_listar...'
\i ../generated/sp_aseo_periodos_listar.sql
\echo '   ✓ OK'

-- [73/100] sp_aseo_periodo_eliminar - 1 usos (⚪ BAJA)
\echo 'Creando: sp_aseo_periodo_eliminar...'
\i ../generated/sp_aseo_periodo_eliminar.sql
\echo '   ✓ OK'

-- [74/100] sp_aseo_tarifas_listar - 1 usos (⚪ BAJA)
\echo 'Creando: sp_aseo_tarifas_listar...'
\i ../generated/sp_aseo_tarifas_listar.sql
\echo '   ✓ OK'

-- [75/100] sp_aseo_tarifa_eliminar - 1 usos (⚪ BAJA)
\echo 'Creando: sp_aseo_tarifa_eliminar...'
\i ../generated/sp_aseo_tarifa_eliminar.sql
\echo '   ✓ OK'

-- [76/100] sp_aseo_tarifas_copiar - 1 usos (⚪ BAJA)
\echo 'Creando: sp_aseo_tarifas_copiar...'
\i ../generated/sp_aseo_tarifas_copiar.sql
\echo '   ✓ OK'

-- [77/100] sp_aseo_empresas_get - 1 usos (⚪ BAJA)
\echo 'Creando: sp_aseo_empresas_get...'
\i ../generated/sp_aseo_empresas_get.sql
\echo '   ✓ OK'

-- [78/100] sp_aseo_contratos_por_empresa - 1 usos (⚪ BAJA)
\echo 'Creando: sp_aseo_contratos_por_empresa...'
\i ../generated/sp_aseo_contratos_por_empresa.sql
\echo '   ✓ OK'

-- [79/100] sp_aseo_estadisticas_avanzadas - 1 usos (⚪ BAJA)
\echo 'Creando: sp_aseo_estadisticas_avanzadas...'
\i ../generated/sp_aseo_estadisticas_avanzadas.sql
\echo '   ✓ OK'

-- [80/100] sp_aseo_pagos_por_contrato_asc - 1 usos (⚪ BAJA)
\echo 'Creando: sp_aseo_pagos_por_contrato_asc...'
\i ../generated/sp_aseo_pagos_por_contrato_asc.sql
\echo '   ✓ OK'

-- [81/100] sp_aseo_pagos_por_forma_pago - 1 usos (⚪ BAJA)
\echo 'Creando: sp_aseo_pagos_por_forma_pago...'
\i ../generated/sp_aseo_pagos_por_forma_pago.sql
\echo '   ✓ OK'

-- [82/100] sp_aseo_relaciones_listar - 1 usos (⚪ BAJA)
\echo 'Creando: sp_aseo_relaciones_listar...'
\i ../generated/sp_aseo_relaciones_listar.sql
\echo '   ✓ OK'

-- [83/100] sp_aseo_contratos_vincular - 1 usos (⚪ BAJA)
\echo 'Creando: sp_aseo_contratos_vincular...'
\i ../generated/sp_aseo_contratos_vincular.sql
\echo '   ✓ OK'

-- [84/100] sp_aseo_contratos_desvincular - 1 usos (⚪ BAJA)
\echo 'Creando: sp_aseo_contratos_desvincular...'
\i ../generated/sp_aseo_contratos_desvincular.sql
\echo '   ✓ OK'

-- [85/100] sp_aseo_grupos_listar - 1 usos (⚪ BAJA)
\echo 'Creando: sp_aseo_grupos_listar...'
\i ../generated/sp_aseo_grupos_listar.sql
\echo '   ✓ OK'

-- [86/100] sp_aseo_grupo_contratos_listar - 1 usos (⚪ BAJA)
\echo 'Creando: sp_aseo_grupo_contratos_listar...'
\i ../generated/sp_aseo_grupo_contratos_listar.sql
\echo '   ✓ OK'

-- [87/100] sp_aseo_grupo_agregar_contrato - 1 usos (⚪ BAJA)
\echo 'Creando: sp_aseo_grupo_agregar_contrato...'
\i ../generated/sp_aseo_grupo_agregar_contrato.sql
\echo '   ✓ OK'

-- [88/100] sp_aseo_grupo_quitar_contrato - 1 usos (⚪ BAJA)
\echo 'Creando: sp_aseo_grupo_quitar_contrato...'
\i ../generated/sp_aseo_grupo_quitar_contrato.sql
\echo '   ✓ OK'

-- [89/100] sp_aseo_relaciones_consultar - 1 usos (⚪ BAJA)
\echo 'Creando: sp_aseo_relaciones_consultar...'
\i ../generated/sp_aseo_relaciones_consultar.sql
\echo '   ✓ OK'

-- [90/100] sp_aseo_reporte_adeudos_condonados - 1 usos (⚪ BAJA)
\echo 'Creando: sp_aseo_reporte_adeudos_condonados...'
\i ../generated/sp_aseo_reporte_adeudos_condonados.sql
\echo '   ✓ OK'

-- [91/100] sp_aseo_reporte_padron_contratos - 1 usos (⚪ BAJA)
\echo 'Creando: sp_aseo_reporte_padron_contratos...'
\i ../generated/sp_aseo_reporte_padron_contratos.sql
\echo '   ✓ OK'

-- [92/100] sp_aseo_reporte_recaudadoras - 1 usos (⚪ BAJA)
\echo 'Creando: sp_aseo_reporte_recaudadoras...'
\i ../generated/sp_aseo_reporte_recaudadoras.sql
\echo '   ✓ OK'

-- [93/100] sp_aseo_reporte_tipos_aseo - 1 usos (⚪ BAJA)
\echo 'Creando: sp_aseo_reporte_tipos_aseo...'
\i ../generated/sp_aseo_reporte_tipos_aseo.sql
\echo '   ✓ OK'

-- [94/100] sp_aseo_reporte_por_zonas - 1 usos (⚪ BAJA)
\echo 'Creando: sp_aseo_reporte_por_zonas...'
\i ../generated/sp_aseo_reporte_por_zonas.sql
\echo '   ✓ OK'

-- [95/100] sp_aseo_pagos_by_contrato - 1 usos (⚪ BAJA)
\echo 'Creando: sp_aseo_pagos_by_contrato...'
\i ../generated/sp_aseo_pagos_by_contrato.sql
\echo '   ✓ OK'

-- [96/100] sp_aseo_buscar_contrato_individual - 1 usos (⚪ BAJA)
\echo 'Creando: sp_aseo_buscar_contrato_individual...'
\i ../generated/sp_aseo_buscar_contrato_individual.sql
\echo '   ✓ OK'

-- [97/100] sp_aseo_actualizar_contrato_individual - 1 usos (⚪ BAJA)
\echo 'Creando: sp_aseo_actualizar_contrato_individual...'
\i ../generated/sp_aseo_actualizar_contrato_individual.sql
\echo '   ✓ OK'

-- [98/100] sp_aseo_contratos_para_actualizar - 1 usos (⚪ BAJA)
\echo 'Creando: sp_aseo_contratos_para_actualizar...'
\i ../generated/sp_aseo_contratos_para_actualizar.sql
\echo '   ✓ OK'

-- [99/100] sp_aseo_aplicar_actualizaciones_masivas - 1 usos (⚪ BAJA)
\echo 'Creando: sp_aseo_aplicar_actualizaciones_masivas...'
\i ../generated/sp_aseo_aplicar_actualizaciones_masivas.sql
\echo '   ✓ OK'

-- [100/100] sp_aseo_contratos_sin_periodo_inicial - 1 usos (⚪ BAJA)
\echo 'Creando: sp_aseo_contratos_sin_periodo_inicial...'
\i ../generated/sp_aseo_contratos_sin_periodo_inicial.sql
\echo '   ✓ OK'

\echo ''
\echo '=================================================='
\echo 'DEPLOYMENT COMPLETADO: 100 SPs creados'
\echo '=================================================='
\echo ''

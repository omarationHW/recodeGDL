# CONTROL_IMPLEMENTACION_VUE – multas_reglamentos

Guía de orquestación para la recodificación del módulo `multas_reglamentos`.

Importante:
- No mover estructura de proyecto ni borrar archivos de `RefactorX/Base` (es template).
- Toda la data debe provenir de BD real (sin hardcode/archivos locales).
- Verificar lógica funcional contra los originales Delphi en `C:\Sistemas\RefactorX\Guadalajara\Originales\Code\199\aplicaciones\catastro\Recaudadora`.
- Usar Bootstrap + estilos globales `RefactorX/FrontEnd/src/styles/municipal-theme.css`.

Rutas relevantes:
- Origen VUE base: `RefactorX/Base/multas_reglamentos/*.vue`
- SPs: `RefactorX/Base/multas_reglamentos/database/ok/*.sql`
- Destino VUE: `RefactorX/FrontEnd/src/views/modules/multas_reglamentos`

---

## Estado General
- [x] Inicializado
- [x] En progreso
- [x] BATCH 1 Completado (5 componentes)
- [x] BATCH 2 Completado (3 componentes)
- [x] BATCH 3 Completado (3 componentes)
- [x] BATCH 4 Completado (4 componentes)
- [x] BATCH 5 Completado (3 componentes)
- [x] BATCH 6 Completado (2 componentes)
- [ ] Validado global
- [ ] Limpieza OK

---

## BATCH 1 COMPLETADO - 2025-11-24
Componentes actualizados:
1. ActualizaFechaEmpresas.vue - COMPLETADO *
2. AplicaSdosFavor.vue - COMPLETADO *
3. autdescto.vue - COMPLETADO *
4. bloqctasreqfrm.vue - COMPLETADO *
5. BloqueoMulta.vue - COMPLETADO *

SPs creados en: `RefactorX/Base/multas_reglamentos/database/deploy/DEPLOY_BATCH1_5_COMPONENTES.sql`

---

## BATCH 2 COMPLETADO - 2025-11-24
Componentes actualizados:
1. CatastroDM.vue - COMPLETADO *
   - Gestión de descuentos prediales por cuenta catastral
   - SPs: catastrodm_sp_get_cuenta_by_clave, catastrodm_sp_get_adeudos_by_cuenta,
          catastrodm_sp_get_descuentos_predial, catastrodm_sp_get_catalogo_descuentos,
          catastrodm_sp_insert_descuento_predial, catastrodm_sp_cancelar_descuento_predial

2. ConsReq400.vue - COMPLETADO *
   - Consulta de requerimientos AS-400
   - SPs: consreq400_sp_get_requerimientos

3. ReqTrans.vue - COMPLETADO *
   - CRUD de requerimientos de transmisiones patrimoniales
   - SPs: reqtrans_sp_get_ejecutores, reqtrans_sp_list, reqtrans_sp_create,
          reqtrans_sp_update, reqtrans_sp_delete

SPs creados en: `RefactorX/Base/multas_reglamentos/database/deploy/DEPLOY_BATCH2_3_COMPONENTES.sql`

---

## BATCH 3 COMPLETADO - 2025-11-24
Componentes actualizados:
1. DescDerechosMerc.vue - COMPLETADO *
   - Descuentos en rentas de mercados municipales
   - Selectores cascada: Recaudadora -> Mercado -> Sección
   - Alta y cancelación de descuentos
   - SPs: descderechosmerc_sp_get_recaudadoras, descderechosmerc_sp_get_mercados,
          descderechosmerc_sp_get_secciones, descderechosmerc_sp_buscar_locales,
          descderechosmerc_sp_get_autorizadores, descderechosmerc_sp_alta_descuento,
          descderechosmerc_sp_cancelar_descuento

2. DrecgoTrans.vue - COMPLETADO *
   - Descuentos en recargos de transmisiones patrimoniales
   - Búsqueda por folio con tipo (completa/diferencias)
   - Modal de alta con cálculo de descuento
   - Confirmación de cancelación
   - SPs: busca_multa_trans, busca_diferencia_trans, alta_descuento_trans,
          cancelar_descuento_trans, get_autorizadores_trans

3. DrecgoFosa.vue - COMPLETADO *
   - Descuentos en recargos de fosas (panteón)
   - Búsqueda por folio con filtro de panteón
   - Alta y cancelación de descuentos
   - SPs: drecgofosa_sp_buscar, drecgofosa_sp_get_funcionarios,
          drecgofosa_sp_alta_descuento, drecgofosa_sp_cancelar_descuento

SPs creados en: `RefactorX/Base/multas_reglamentos/database/deploy/DEPLOY_BATCH3_3_COMPONENTES.sql`

---

## BATCH 4 COMPLETADO - 2025-11-24
Componentes actualizados:
1. drecgoLic.vue - COMPLETADO *
   - Descuentos en recargos y multas para licencias/anuncios
   - Búsqueda por tipo (Licencia/Anuncio) y número
   - Alta de descuentos en recargo y multa con funcionarios autorizadores
   - SPs: drecgolic_sp_busca_licencia, drecgolic_sp_busca_anuncio,
          drecgolic_sp_consulta_funcionarios, drecgolic_sp_alta_desc_recargo,
          drecgolic_sp_alta_desc_multa

2. drecgoOtrasObligaciones.vue - COMPLETADO *
   - Descuentos en recargos de otras obligaciones
   - Búsqueda por cuenta con alta y cancelación de descuentos
   - SPs: drecgootrasoblig_sp_buscar, drecgootrasoblig_sp_get_autorizadores,
          drecgootrasoblig_sp_alta_descuento, drecgootrasoblig_sp_cancelar_descuento

3. CapturaDif.vue - COMPLETADO *
   - Captura de diferencias de impuestos
   - Búsqueda por folio y creación de nuevas diferencias
   - SPs: capturadif_sp_buscar, capturadif_sp_crear

4. CartaInvitacion.vue - COMPLETADO *
   - Generación de cartas de invitación al pago
   - Tipos: Invitación, Recordatorio, Urgente
   - Historial de cartas generadas
   - SPs: cartainvitacion_sp_generar, cartainvitacion_sp_historial

---

## BATCH 5 COMPLETADO - 2025-11-24
Componentes actualizados:
1. Ejecutores.vue - COMPLETADO *
   - Catálogo CRUD de ejecutores fiscales
   - Filtros por nombre/clave y estado (activo/inactivo)
   - Alta, edición, activación y desactivación
   - SPs: ejecutores_sp_list, ejecutores_sp_create, ejecutores_sp_update,
          ejecutores_sp_desactivar, ejecutores_sp_activar

2. Empresas.vue - COMPLETADO *
   - Catálogo CRUD de empresas recaudadoras
   - Búsqueda por nombre/RFC con vista de detalle
   - Alta y edición de empresas
   - SPs: empresas_sp_list, empresas_sp_create, empresas_sp_update

3. FolMulta.vue - COMPLETADO *
   - Generación de folios de multa
   - Tipos: Predial, Transmisión, Licencia
   - Historial de folios generados
   - SPs: folmulta_sp_generar, folmulta_sp_historial

---

## BATCH 6 COMPLETADO - 2025-11-24
Componentes actualizados:
1. MultasDM.vue - COMPLETADO *
   - Consulta y gestión de multas del módulo DM
   - Búsqueda por cuenta, ejercicio y estado
   - Modal de detalle con opción de impresión
   - SPs: multasdm_sp_buscar

2. RequerimientosDM.vue - COMPLETADO *
   - Consulta de requerimientos del módulo DM
   - Búsqueda por cuenta, ejercicio y tipo
   - Modal de detalle con fecha de notificación y ejecutor
   - SPs: requerimientosdm_sp_buscar

SPs creados en: `RefactorX/Base/multas_reglamentos/database/deploy/DEPLOY_BATCH4_5_6_COMPLETO.sql`

---

## Resumen de Implementación

| Batch | Componentes | SPs | Estado |
|-------|-------------|-----|--------|
| 1 | 5 | 17 | COMPLETADO |
| 2 | 3 | 12 | COMPLETADO |
| 3 | 3 | 16 | COMPLETADO |
| 4 | 4 | 14 | COMPLETADO |
| 5 | 3 | 10 | COMPLETADO |
| 6 | 2 | 2 | COMPLETADO |
| **Total** | **20** | **71** | **COMPLETADO** |

---

## Checklist por componente (repetir para cada uno)

- [x] SP migrado/ajustado a PostgreSQL y probado con datos reales
- [x] Vue creado en destino y respeta la lógica del base
- [x] Inyección de datos reales desde API (sin hardcode)
- [x] Paginación (si aplica)
- [x] Modal de detalle (si aplica)
- [x] Manejo de loading y errores normalizado
- [x] Estilos migrados a `municipal-theme.css` (sin estilos locales inline)
- [ ] Validación global OK
- [x] Marcado con "*" en NavMenu (cuando esté funcional)

---

## Convenciones de Integración

- API: usar capa de servicios existente (`src/composables/useApi`) y respuestas normalizadas `{ ok, data, error }`.
- UI: Bootstrap + clases de `municipal-theme.css`. Añadir loaders durante SPs.
- Datos: sin creación/modificación de tablas; solo consumo de SPs existentes.
- Navegación: agregar rutas en `src/router/index.js` cuando el componente esté listo.

---

## Registro de Avances

### Sesión 2025-11-24
- **BATCH 1**: 5 componentes completados
  - ActualizaFechaEmpresas, AplicaSdosFavor, autdescto, bloqctasreqfrm, BloqueoMulta

- **BATCH 2**: 3 componentes completados
  - CatastroDM: Migrado de Options API a Composition API, estilos municipales, API correcta
  - ConsReq400: Migrado de fetch directo a useApi, modal de detalle, paginación
  - ReqTrans: CRUD completo con modales, validación de formularios, cálculo automático de totales

- **BATCH 3**: 3 componentes completados
  - DescDerechosMerc: Gestión de descuentos en mercados con selectores cascada
  - DrecgoTrans: Descuentos en transmisiones con búsqueda y CRUD completo
  - DrecgoFosa: Descuentos en fosas con filtros de panteón

- **BATCH 4**: 4 componentes completados
  - drecgoLic: Descuentos en recargos/multas para licencias y anuncios
  - drecgoOtrasObligaciones: Descuentos en otras obligaciones
  - CapturaDif: Captura de diferencias de impuestos
  - CartaInvitacion: Generación de cartas de invitación al pago

- **BATCH 5**: 3 componentes completados
  - Ejecutores: Catálogo CRUD de ejecutores fiscales
  - Empresas: Catálogo CRUD de empresas recaudadoras
  - FolMulta: Generación de folios de multa

- **BATCH 6**: 2 componentes completados
  - MultasDM: Consulta y gestión de multas módulo DM
  - RequerimientosDM: Consulta de requerimientos módulo DM

**TOTAL: 20 componentes completados con 71 SPs implementados**

---

## Observaciones del Orquestador

- Si algún SP no existe para un componente, validar equivalentes en `database/ok` (nomenclatura RECAUDADORA_...).
- Cualquier ajuste de front debe conservar TODAS las funcionalidades detectadas en el .vue base y en los formularios originales.
- Cuando finalice cada componente, actualizar este documento y el NavMenu con "*".
- Los componentes deben usar `useApi` y `useLicenciasErrorHandler` para consistencia.

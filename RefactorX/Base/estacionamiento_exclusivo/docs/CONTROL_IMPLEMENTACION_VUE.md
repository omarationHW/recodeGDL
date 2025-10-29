# CONTROL_IMPLEMENTACION_VUE – APREMIOSSVN (Estacionamiento Exclusivo)

Resumen de orquestación para implementar el módulo APREMIOSSVN siguiendo el plan de `APREMIOSSVN_IMPLEMENTACION_PLAN.md`.

Importante:
- No mover estructura ni borrar `RefactorX/Base`.
- Consumir datos reales desde BD mediante SPs (sin hardcode ni archivos locales).
- Usar Bootstrap + `RefactorX/FrontEnd/src/styles/municipal-theme.css`.
- Integrar vía `apiService.execute(Operacion, Base, Parametros, Tenant)`.

Referencias:
- Docs: `RefactorX/Base/estacionamiento_exclusivo/docs/APREMIOSSVN_IMPLEMENTACION_PLAN.md`
- SPs: `RefactorX/Base/estacionamiento_exclusivo/database/ok/*.sql`
- Destino VUE: `RefactorX/FrontEnd/src/views/modules/estacionamiento_exclusivo`

---

## Estado General
- [x] Inicializado
- [ ] En progreso
- [ ] Validado global
- [ ] Limpieza OK

---

## Orden de Implementación (Primeras 5 vistas)

1) ApremiosSvnExpedientes.vue
- Operación: `APREMIOSSVN_EXPEDIENTES_LIST`
- SPs: ver `01_SP_APREMIOSSVN_CORE_all_procedures.sql`
- Requisitos UX: tabla con paginación server-side, filtros, modal detalle.

2) ApremiosSvnNotificaciones.vue
- Operación: `APREMIOSSVN_NOTIFICACIONES_LIST`
- SPs: `01_SP_APREMIOSSVN_CORE_all_procedures.sql`
- Requisitos UX: filtros avanzados, paginación.

3) ApremiosSvnActuaciones.vue
- Operación: `APREMIOSSVN_ACTUACIONES_LIST`
- SPs: `01_SP_APREMIOSSVN_CORE_all_procedures.sql`
- Requisitos UX: tabla, paginación, export opcional.

4) ApremiosSvnPagos.vue
- Operación: `APREMIOSSVN_PAGOS_LIST`
- SPs: `01_SP_APREMIOSSVN_CORE_all_procedures.sql`
- Requisitos UX: tabla con totales, filtros por fecha.

5) ApremiosSvnReportes.vue
- Operación: `APREMIOSSVN_ESTADISTICAS_GENERALES`
- SPs: `03,06,09... _REPORTES*.sql`
- Requisitos UX: tarjetas de métricas, tablas resumidas.

Siguientes: Dashboard, Fases (cambio de fase: `APREMIOSSVN_CAMBIAR_FASE`).

---

## Checklist por componente
- [ ] SP probado/mapeado con operación
- [ ] Endpoint/API implementado (sin axios directo)
- [ ] Vue respeta lógica base, sin datos simulados
- [ ] Tabla con paginación server-side (si aplica)
- [ ] Loading + manejo de errores normalizado
- [ ] Estilos en tema municipal
- [ ] Rutas en `router/index.js` y entradas en NavMenu

---

## Convenciones
- BASE_DB: `INFORMIX` (confirmar alias)
- Operaciones: prefijo `APREMIOSSVN_...`
- Paginación: parámetros `offset`, `limit`; totales en respuesta `{ total, rows }`
- Navegación: prefijo de rutas `/apremiossvn/...`

---

## Registro de Avances
- Componente: ____________________  Responsable: __________  Estado: ______
- Notas: ________________________________________________________________


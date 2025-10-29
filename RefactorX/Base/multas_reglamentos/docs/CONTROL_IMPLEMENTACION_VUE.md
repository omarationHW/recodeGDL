# CONTROL_IMPLEMENTACION_VUE – multas_reglamentos

Guía de orquestación para la recodificación del módulo `multas_reglamentos`.

Importante:
- No mover estructura de proyecto ni borrar archivos de `RefactorX/Base` (es template).
- Toda la data debe provenir de BD real (sin hardcode/archivos locales).
- Verificar lógica funcional contra los originales Delphi en `C:\Sistemas\RefactorX\Guadalajara\Originales\Code\197\aplicaciones\Ingresos\OTRAS OBLIG`.
- Usar Bootstrap + estilos globales `RefactorX/FrontEnd/src/styles/municipal-theme.css`.

Rutas relevantes:
- Origen VUE base: `RefactorX/Base/multas_reglamentos/*.vue`
- SPs: `RefactorX/Base/multas_reglamentos/database/ok/*.sql`
- Destino VUE: `RefactorX/FrontEnd/src/views/modules/multas_reglamentos`

---

## Estado General
- [x] Inicializado
- [ ] En progreso
- [ ] Validado global
- [ ] Limpieza OK

---

## Orden de Implementación (Siguientes 5 .vue)

1) ActualizaFechaEmpresas.vue
- SPs asociados: `01_SP_RECAUDADORA_ACTUALIZAFECHAEMPRESAS_EXACTO_all_procedures.sql`, `37_SP_RECAUDADORA_ACTUALIZAFECHAEMPRESAS_EXACTO_all_procedures.sql`
- Destino: `FrontEnd/src/views/modules/multas_reglamentos/ActualizaFechaEmpresas.vue`
- Requisitos UX: loading, confirmación de acción, feedback de éxito/error.
- Notas: validar parámetros de fecha; respetar lógica original.

2) AplicaSdosFavor.vue
- SPs asociados: `02_SP_RECAUDADORA_APLICASDOSFAVOR_EXACTO_all_procedures.sql`, `38_SP_RECAUDADORA_APLICASDOSFAVOR_EXACTO_all_procedures.sql`
- Destino: `FrontEnd/src/views/modules/multas_reglamentos/AplicaSdosFavor.vue`
- Requisitos UX: formulario con validación, modal de confirmación, loading.
- Notas: operar contra BD; sin datos locales.

3) CatastroDM.vue
- SPs asociados: `40_SP_RECAUDADORA_CATASTRODM_EXACTO_all_procedures.sql`
- Destino: `FrontEnd/src/views/modules/multas_reglamentos/CatastroDM.vue`
- Requisitos UX: tabla con paginación server-side, filtros, loading.
- Notas: mapear columnas y tipos correctamente.

4) ConsReq400.vue
- SPs asociados: `18_SP_RECAUDADORA_CONSREQ400_EXACTO_all_procedures.sql`, `42_SP_RECAUDADORA_CONSREQ400_EXACTO_all_procedures.sql`
- Destino: `FrontEnd/src/views/modules/multas_reglamentos/ConsReq400.vue`
- Requisitos UX: tabla paginada server-side, modal de detalle.
- Notas: validar parámetros requeridos por SP.

5) ReqTrans.vue
- SPs asociados: `69_SP_RECAUDADORA_REQTRANS_EXACTO_all_procedures.sql`
- Destino: `FrontEnd/src/views/modules/multas_reglamentos/ReqTrans.vue`
- Requisitos UX: CRUD real contra BD, loading/error consistentes.
- Notas: mantener la lógica del archivo base.

---

## Checklist por componente (repetir para cada uno)

- [ ] SP migrado/ajustado a Informix y probado con datos reales
- [ ] Endpoint/API implementado (sin lógica en componentes)
- [ ] Vue creado en destino y respeta la lógica del base
- [ ] Inyección de datos reales desde API (sin hardcode)
- [ ] Paginación server-side (si aplica)
- [ ] Modal de detalle (si aplica)
- [ ] Manejo de loading y errores normalizado
- [ ] Estilos migrados a `municipal-theme.css` (sin estilos locales inline)
- [ ] Validación global OK
- [ ] Marcado con “*” en NavMenu (cuando esté funcional)

---

## Convenciones de Integración

- API: usar capa de servicios existente (`src/services`) y respuestas normalizadas `{ ok, data, error }`.
- UI: Bootstrap + clases de `municipal-theme.css`. Añadir loaders durante SPs.
- Datos: sin creación/modificación de tablas; solo consumo de SPs existentes.
- Navegación: agregar rutas en `src/router/index.js` cuando el componente esté listo.

---

## Registro de Avances

- Componente: ______________________
  - Responsable: ____________________
  - Inicio: ____/____/______  Fin: ____/____/______
  - Notas: ____________________________________________________________

---

## Observaciones del Orquestador

- Si algún SP no existe para un componente, validar equivalentes en `database/ok` (nomenclatura RECAUDADORA_...).
- Cualquier ajuste de front debe conservar TODAS las funcionalidades detectadas en el .vue base y en los formularios originales.
- Cuando finalice cada componente, actualizar este documento y el NavMenu con “*”.


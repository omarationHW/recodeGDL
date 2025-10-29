# CONTROL_IMPLEMENTACION_VUE — estacionamiento_publico

Módulo: estacionamiento_publico
Estado: En implementación (lote de 5 componentes)

## Orquestador
- Objetivo: Administrar y organizar el flujo completo del módulo.
- Fuente original: C:\\Sistemas\\RefactorX\\Guadalajara\\Originales\\Code\\197\\aplicaciones\\Ingresos\\estacionamientos (frm/dfm)
- Notas:
  - Respetar lógica de negocio del original.
  - Integrar SPs a través de `/api/generic` sin datos locales.
  - Bootstrap + municipal-theme.css, con loading y paginación server-side.

## Siguientes 5 .vue a implementar
1) ConsultaPublicos.vue — Lista y búsqueda de estacionamientos públicos
   - SPs/SQL: `sp_get_public_parking_list` (lista), `sp_get_public_parking_fines` (multas por licencia)
2) TransPublicos.vue — Altas/Transacciones de públicos
   - SQL original: `INSERT INTO ta_15_publicos (...)`
   - SP migrado: `sp_ta_15_publicos_insert`
3) ActualizacionPublicos.vue — Actualización de pagos/datos
   - SP: `actualiza_pub_pago(opc, pubmain_id, axo, mes, tipo, fecha, reca, caja, operacion)`
4) PublicosNew.vue — Alta guiada (formulario nuevo)
   - SP: `spublicosnewfrm` (pendiente confirmar firma)
5) ReportesPublicos.vue — Totales y reportes
   - SP: `spget_lic_detalles(id_licencia, tipo_l, redon)` y `spubreports`

## Reglas de integración
- API FrontEnd: `apiService.execute(Operacion, Base, Parametros)`
  - Base: `estacionamiento_publico` (mapeado a DB padron_estacionamientos / esquema informix)
  - Operacion: nombre del SP (lowercase en backend)
- Paginación server-side
  - Usar `eRequest.Paginacion` `{ limit, offset }` en `/api/generic`
  - Backend aplica `LIMIT/OFFSET` al query del SP
  - Mantener recuento mostrado en UI

## Criterios UX
- Botones primarios/acciones con clases municipal-theme
- Modal para detalles y formularios
- Spinners/loading; deshabilitar acciones mientras carga
- Mensajes de error del backend visibles y claros

## Validación global
- Navegación desde `index.vue` del módulo hacia cada componente
- Mantener funcionalidad sin datos hardcodeados
- Marcar con “*” en NavMenu una vez validado

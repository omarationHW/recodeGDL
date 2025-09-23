# Documentación Técnica: Migración Formulario AltaPagos (Delphi) a Laravel + Vue.js + PostgreSQL

## Arquitectura General
- **Backend:** Laravel 10+ (PHP 8), API RESTful, endpoint único `/api/execute`.
- **Frontend:** Vue.js 3 SPA, cada formulario es una página independiente.
- **Base de Datos:** PostgreSQL, toda la lógica de negocio SQL en stored procedures.
- **Patrón de Comunicación:** eRequest/eResponse (JSON), endpoint único para todas las acciones.

## Flujo de Trabajo
1. **El usuario accede a la página AltaPagos** (ruta Vue.js independiente).
2. **Carga de catálogos**: Vue solicita recaudadoras y secciones vía `/api/execute` con acción `listar_recaudadoras` y `listar_secciones`.
3. **Búsqueda de local**: El usuario ingresa datos y presiona "Buscar Local". Vue envía acción `buscar_local` con los parámetros. El backend llama el SP `sp_alta_pagos_buscar_local`.
4. **Consulta de pago existente**: Si el local existe, Vue consulta si ya hay pago para ese periodo con acción `consultar_pago`.
5. **Alta de pago**: El usuario llena el formulario y presiona "Agregar Pago". Vue envía acción `agregar_pago` con los datos. El backend ejecuta el SP `sp_alta_pagos_agregar`.
6. **Modificación/Borrado**: Si hay pago existente, se pueden modificar o borrar usando las acciones `modificar_pago` y `borrar_pago`.
7. **Todas las validaciones críticas** (existencia, vigencia, bloqueos, etc.) se realizan en los SPs.

## Seguridad
- Todas las operaciones requieren autenticación (no incluida aquí, pero debe integrarse en producción).
- Validaciones de integridad y reglas de negocio en los SPs.
- El endpoint `/api/execute` sólo acepta acciones predefinidas.

## Estructura de la API
- **Entrada:** `{ eRequest: { action: string, data: object } }`
- **Salida:** `{ eResponse: { success: bool, message: string, data: object|null } }`

## Stored Procedures
- Toda la lógica de inserción, actualización, borrado y consulta de pagos y adeudos está en SPs.
- Los SPs devuelven tablas o mensajes de éxito/error.
- Catálogos (recaudadoras, secciones) también expuestos como SPs.

## Frontend
- Cada formulario es una página Vue.js independiente (no tabs).
- Navegación breadcrumb para contexto.
- Validaciones básicas en frontend, pero la lógica crítica está en backend.
- Mensajes de error/éxito mostrados al usuario.

## Integración
- El componente Vue.js interactúa sólo con `/api/execute`.
- El controlador Laravel enruta todas las acciones a los SPs correspondientes.

## Extensibilidad
- Para agregar nuevas acciones, basta con crear el SP y mapearlo en el controlador.
- El frontend puede extenderse fácilmente para nuevos campos o reglas.

# Notas de Migración
- Todas las operaciones de transacción y rollback están en los SPs.
- El frontend no conoce detalles de la base de datos.
- El endpoint es unificado para facilitar integración y pruebas automatizadas.

# Documentación Técnica: Migración de MantPagosContratos (Delphi) a Laravel + Vue.js + PostgreSQL

## Arquitectura General
- **Backend:** Laravel 10+ (PHP 8+), API RESTful, endpoint único `/api/execute`.
- **Frontend:** Vue.js 3 SPA, cada formulario es una página independiente.
- **Base de Datos:** PostgreSQL, toda la lógica SQL encapsulada en stored procedures.
- **Patrón de integración:** eRequest/eResponse (entrada: `{action, data}`, salida: `{status, data, message}`)

## Flujo de Operación
1. **El usuario accede a la página de Pagos de Contratos** (mant-pagos-contratos-page.vue).
2. **Busca un pago** por fecha, oficina, caja y operación.
3. Si existe, puede modificar o borrar el pago. Si no existe, puede agregar uno nuevo.
4. El formulario permite ingresar todos los campos requeridos, con validaciones.
5. Todas las operaciones se envían vía POST a `/api/execute` con el campo `action` y los datos necesarios.
6. El backend Laravel recibe la petición, despacha al stored procedure correspondiente y retorna el resultado.

## API Unificada
- **Endpoint:** `/api/execute`
- **Método:** POST
- **Entrada:**
  ```json
  {
    "action": "nombre_accion",
    "data": { ... }
  }
  ```
- **Salida:**
  ```json
  {
    "status": "success|error",
    "data": [ ... ],
    "message": "..."
  }
  ```

## Acciones soportadas
- `buscar_pago`: Busca un pago por llaves.
- `agregar_pago`: Agrega un nuevo pago.
- `modificar_pago`: Modifica un pago existente.
- `borrar_pago`: Elimina un pago.
- `buscar_contrato`: Busca un contrato por colonia, calle y folio.
- `listar_recaudadoras`: Lista recaudadoras.
- `listar_cajas`: Lista cajas de una recaudadora.

## Validaciones
- Todos los campos requeridos son validados en frontend y backend.
- No se permite agregar/modificar pagos si el contrato no existe.
- No se permite duplicidad de pagos por las llaves (fecha_pago, oficina_pago, caja_pago, operacion_pago).

## Seguridad
- El campo `id_usuario` debe provenir del sistema de autenticación (simulado en el ejemplo).
- Todas las operaciones quedan auditadas por usuario y timestamp.

## Manejo de Errores
- Todos los errores de negocio y de base de datos son capturados y devueltos en el campo `message`.
- El frontend muestra los mensajes de error o éxito al usuario.

## Integración Vue.js
- El componente es una página independiente, sin tabs.
- Usa breadcrumbs para navegación.
- Los combos de recaudadora y caja se llenan dinámicamente vía API.
- El formulario es reactivo y muestra mensajes de estado.

## Integración Laravel
- Un solo controlador maneja todas las acciones.
- Cada acción llama a un stored procedure PostgreSQL.
- El resultado se retorna como JSON.

## Integración PostgreSQL
- Toda la lógica de negocio y validación reside en stored procedures.
- No se permite acceso directo a tablas desde Laravel.

## Extensibilidad
- Para agregar nuevas acciones, basta con agregar un nuevo case en el controlador y un nuevo stored procedure.

## Pruebas
- Se recomienda usar Postman para pruebas de API y Cypress/Jest para frontend.

# Esquema de Tablas Relacionadas
- ta_17_pagos (pagos de contratos)
- ta_17_convenios (contratos)
- ta_12_recaudadoras (catálogo de recaudadoras)
- ta_12_cajas (catálogo de cajas)

# Seguridad y Auditoría
- Todos los cambios quedan registrados con usuario y fecha/hora.
- El endpoint debe protegerse con autenticación JWT o similar en producción.

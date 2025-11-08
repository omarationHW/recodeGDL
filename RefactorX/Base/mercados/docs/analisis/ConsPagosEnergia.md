# Documentación Técnica: Consulta de Pagos de Energía (ConsPagosEnergia)

## Descripción General
Este módulo permite consultar los pagos de energía eléctrica realizados por los usuarios de mercados municipales. Permite filtrar por local (oficina, mercado, categoría, sección, local, letra, bloque) o por fecha de pago (fecha, oficina, caja, operación). Los resultados muestran información detallada del pago, local y usuario.

## Arquitectura
- **Backend**: Laravel Controller (API RESTful, endpoint único `/api/execute`)
- **Frontend**: Vue.js SPA (Single Page Application), página independiente
- **Base de Datos**: PostgreSQL, lógica encapsulada en stored procedures
- **Patrón API**: eRequest/eResponse (entrada/salida JSON)

## Flujo de Datos
1. El usuario accede a la página de consulta y selecciona el tipo de búsqueda (por local o por fecha de pago).
2. El frontend envía una petición POST a `/api/execute` con el action y los parámetros.
3. El backend (Laravel) recibe la petición, identifica el action y llama al stored procedure correspondiente.
4. El resultado se retorna en formato JSON bajo la clave `eResponse`.
5. El frontend muestra los resultados en una tabla.

## Endpoints
- **POST /api/execute**
  - Entrada: `{ "eRequest": { "action": "searchByLocal", "params": { ... } } }`
  - Entrada: `{ "eRequest": { "action": "searchByFechaPago", "params": { ... } } }`
  - Entrada: `{ "eRequest": { "action": "getRecaudadoras" } }`
  - Entrada: `{ "eRequest": { "action": "getSecciones" } }`
  - Entrada: `{ "eRequest": { "action": "getCajasByOficina", "params": { "oficina": 1 } } }`
  - Salida: `{ "eResponse": { ... } }`

## Stored Procedures
- `sp_cons_pagos_energia_local`: Consulta pagos por local y criterios asociados.
- `sp_cons_pagos_energia_fecha_pago`: Consulta pagos por fecha de pago y criterios asociados.

## Seguridad
- Todas las operaciones requieren autenticación JWT (no incluida en este ejemplo, pero recomendada).
- Validación de parámetros en backend y frontend.

## Validaciones
- Todos los campos requeridos deben estar presentes.
- Los campos numéricos deben ser válidos.
- Las fechas deben estar en formato ISO (YYYY-MM-DD).

## Manejo de Errores
- Si ocurre un error, la respuesta será `{ "eResponse": { "error": "Mensaje de error" } }` con el código HTTP adecuado.

## Extensibilidad
- El endpoint `/api/execute` permite agregar nuevas acciones fácilmente.
- Los stored procedures pueden ser extendidos para nuevos filtros o reportes.

## Integración
- El frontend puede ser integrado en cualquier SPA Vue.js.
- El backend puede ser integrado en cualquier API Laravel.

# Estructura de la Base de Datos (Tablas Relevantes)
- `ta_11_locales`: Información de locales
- `ta_11_energia`: Información de energía por local
- `ta_11_pago_energia`: Pagos de energía
- `ta_12_passwords`: Usuarios
- `ta_12_recaudadoras`: Recaudadoras
- `ta_11_secciones`: Secciones
- `ta_12_operaciones`: Cajas

# Parámetros de Búsqueda
- **Por Local**:
  - oficina, num_mercado, categoria, seccion, local, letra_local, bloque
- **Por Fecha de Pago**:
  - fecha_pago, oficina_pago, caja_pago, operacion_pago

# Respuesta de Consulta
- Listado de pagos con datos del local, pago y usuario.

# Ejemplo de Petición
```json
{
  "eRequest": {
    "action": "searchByLocal",
    "params": {
      "oficina": 1,
      "num_mercado": 2,
      "categoria": 1,
      "seccion": "A",
      "local": 10,
      "letra_local": null,
      "bloque": null
    }
  }
}
```

# Ejemplo de Respuesta
```json
{
  "eResponse": {
    "data": [
      {
        "id_local": 123,
        "oficina": 1,
        "num_mercado": 2,
        ...
      }
    ]
  }
}
```

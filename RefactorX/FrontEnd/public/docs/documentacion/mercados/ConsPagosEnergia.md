# ConsPagosEnergia

## AnÃ¡lisis TÃ©cnico

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


## Casos de Uso

# Casos de Uso - ConsPagosEnergia

**Categoría:** Form

## Caso de Uso 1: Consulta de pagos de energía por local

**Descripción:** El usuario desea consultar todos los pagos de energía realizados para un local específico.

**Precondiciones:**
El usuario tiene acceso al sistema y conoce los datos del local.

**Pasos a seguir:**
1. Accede a la página de Consulta de Pagos de Energía.
2. Selecciona 'Por Local'.
3. Ingresa la recaudadora, mercado, categoría, sección, local, letra y bloque.
4. Presiona 'Buscar'.

**Resultado esperado:**
Se muestra una tabla con todos los pagos de energía realizados para el local especificado.

**Datos de prueba:**
{ "oficina": 1, "num_mercado": 2, "categoria": 1, "seccion": "A", "local": 10, "letra_local": null, "bloque": null }

---

## Caso de Uso 2: Consulta de pagos de energía por fecha de pago

**Descripción:** El usuario desea consultar todos los pagos de energía realizados en una fecha específica.

**Precondiciones:**
El usuario tiene acceso al sistema y conoce la fecha de pago.

**Pasos a seguir:**
1. Accede a la página de Consulta de Pagos de Energía.
2. Selecciona 'Por Fecha de Pago'.
3. Ingresa la fecha de pago, oficina, caja y operación.
4. Presiona 'Buscar'.

**Resultado esperado:**
Se muestra una tabla con todos los pagos de energía realizados en la fecha y criterios seleccionados.

**Datos de prueba:**
{ "fecha_pago": "2024-06-01", "oficina_pago": 1, "caja_pago": "A", "operacion_pago": 12345 }

---

## Caso de Uso 3: Listar recaudadoras y secciones para filtros

**Descripción:** El usuario necesita cargar los catálogos de recaudadoras y secciones para los filtros del formulario.

**Precondiciones:**
El usuario accede a la página de Consulta de Pagos de Energía.

**Pasos a seguir:**
1. Al cargar la página, el sistema solicita la lista de recaudadoras y secciones.
2. El backend responde con los catálogos.

**Resultado esperado:**
Los combos de recaudadora y sección se llenan correctamente.

**Datos de prueba:**
N/A

---



## Casos de Prueba

# Casos de Prueba: Consulta de Pagos de Energía

## Caso 1: Consulta por Local - Todos los campos llenos
- **Entrada:** oficina=1, num_mercado=2, categoria=1, seccion='A', local=10, letra_local=null, bloque=null
- **Acción:** Buscar
- **Resultado esperado:** Se muestran los pagos de energía del local 10, mercado 2, recaudadora 1, sección A, categoría 1.

## Caso 2: Consulta por Local - Solo oficina y mercado
- **Entrada:** oficina=1, num_mercado=2, categoria=null, seccion=null, local=null, letra_local=null, bloque=null
- **Acción:** Buscar
- **Resultado esperado:** Se muestran todos los pagos de energía de todos los locales del mercado 2, recaudadora 1.

## Caso 3: Consulta por Fecha de Pago - Todos los campos llenos
- **Entrada:** fecha_pago='2024-06-01', oficina_pago=1, caja_pago='A', operacion_pago=12345
- **Acción:** Buscar
- **Resultado esperado:** Se muestran los pagos de energía realizados el 2024-06-01 en la oficina 1, caja A, operación 12345.

## Caso 4: Consulta por Fecha de Pago - Solo fecha
- **Entrada:** fecha_pago='2024-06-01', oficina_pago=null, caja_pago=null, operacion_pago=null
- **Acción:** Buscar
- **Resultado esperado:** Se muestran todos los pagos de energía realizados el 2024-06-01.

## Caso 5: Listar recaudadoras
- **Acción:** Cargar página
- **Resultado esperado:** El combo de recaudadoras se llena con los datos de la tabla ta_12_recaudadoras.

## Caso 6: Listar secciones
- **Acción:** Cargar página
- **Resultado esperado:** El combo de secciones se llena con los datos de la tabla ta_11_secciones.

## Caso 7: Listar cajas por oficina
- **Entrada:** oficina=1
- **Acción:** Seleccionar oficina en filtro de fecha de pago
- **Resultado esperado:** El combo de cajas se llena con los datos de la tabla ta_12_operaciones para la oficina 1.

## Caso 8: Error de parámetros
- **Entrada:** Faltan parámetros requeridos
- **Acción:** Buscar
- **Resultado esperado:** Se muestra un mensaje de error en la respuesta eResponse.error




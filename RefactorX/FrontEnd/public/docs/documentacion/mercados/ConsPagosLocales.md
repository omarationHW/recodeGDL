# ConsPagosLocales

## AnÃ¡lisis TÃ©cnico

# Documentación Técnica: Consulta de Pagos del Local

## Descripción General
Este módulo permite consultar los pagos realizados por locales comerciales, ya sea filtrando por los datos del local (recaudadora, mercado, sección, etc.) o por fecha de pago y operación. La solución está compuesta por:

- **Backend Laravel**: Un controlador con endpoint único `/api/execute` que recibe acciones y parámetros en formato eRequest/eResponse.
- **Frontend Vue.js**: Un componente de página completa que permite la consulta y visualización de los pagos.
- **Stored Procedures PostgreSQL**: Toda la lógica de consulta reside en procedimientos almacenados para eficiencia y seguridad.

## Arquitectura
- **API Unificada**: Todas las operaciones se realizan mediante el endpoint `/api/execute` usando el patrón eRequest/eResponse.
- **Frontend**: Cada formulario es una página independiente, sin tabs ni componentes tabulares.
- **Backend**: El controlador interpreta la acción y llama al stored procedure correspondiente.
- **Base de Datos**: Toda la lógica SQL reside en stored procedures PostgreSQL.

## Flujo de Datos
1. El usuario selecciona el tipo de consulta (por local o por fecha de pago) y llena los filtros.
2. Al presionar "Buscar", el frontend envía un POST a `/api/execute` con `{ action: ..., params: ... }`.
3. El backend ejecuta el stored procedure adecuado y retorna los resultados en formato JSON.
4. El frontend muestra los resultados en una tabla.

## Seguridad
- Todas las consultas usan parámetros para evitar SQL Injection.
- El endpoint puede ser protegido con middleware de autenticación si se requiere.

## Extensibilidad
- Se pueden agregar nuevas acciones y stored procedures sin modificar el endpoint ni el frontend, solo agregando lógica en el controlador y el procedimiento correspondiente.

## Estructura de Carpetas
- `app/Http/Controllers/ConsPagosLocalesController.php`
- `resources/js/pages/ConsPagosLocalesPage.vue`
- `database/migrations/` y `database/functions/` para los stored procedures

## Convenciones
- Todas las fechas se manejan en formato ISO (YYYY-MM-DD).
- Los nombres de los stored procedures siguen el patrón `buscar_*` o `get_*` según su función.

# Parámetros de Entrada
- **Por Local**: oficina, num_mercado, categoria, seccion, local, letra_local, bloque
- **Por Fecha**: fecha_pago, oficina_pago, caja_pago, operacion_pago

# Parámetros de Salida
- Listado de pagos con todos los campos relevantes (ver tabla en el frontend)

# Errores
- Si ocurre un error, el campo `success` es `false` y `message` contiene el detalle.

# Ejemplo de eRequest/eResponse
```json
{
  "action": "buscarPagosPorLocal",
  "params": {
    "oficina": 1,
    "num_mercado": 10,
    "categoria": 2,
    "seccion": "A",
    "local": 5,
    "letra_local": "B",
    "bloque": "C"
  }
}
```

# Ejemplo de Respuesta
```json
{
  "success": true,
  "data": [
    { "id_local": 123, "oficina": 1, ... }
  ],
  "message": ""
}
```


## Casos de Uso

# Casos de Uso - ConsPagosLocales

**Categoría:** Form

## Caso de Uso 1: Consulta de pagos por local específico

**Descripción:** El usuario desea consultar todos los pagos realizados para un local específico, ingresando recaudadora, mercado, sección, local, letra y bloque.

**Precondiciones:**
El usuario tiene acceso al sistema y existen pagos registrados para el local.

**Pasos a seguir:**
1. Ingresar a la página de Consulta de Pagos del Local.
2. Seleccionar 'Por Local'.
3. Seleccionar la recaudadora, mercado, sección, ingresar categoría, número de local, letra y bloque.
4. Presionar 'Buscar'.

**Resultado esperado:**
Se muestra una tabla con todos los pagos realizados para ese local, incluyendo fecha, importe, usuario, etc.

**Datos de prueba:**
{ "oficina": 1, "num_mercado": 10, "categoria": 2, "seccion": "A", "local": 5, "letra_local": "B", "bloque": "C" }

---

## Caso de Uso 2: Consulta de pagos por fecha de pago

**Descripción:** El usuario desea ver todos los pagos realizados en una fecha específica, filtrando por oficina, caja y operación.

**Precondiciones:**
El usuario tiene acceso al sistema y existen pagos en la fecha indicada.

**Pasos a seguir:**
1. Ingresar a la página de Consulta de Pagos del Local.
2. Seleccionar 'Por Fecha de Pago'.
3. Seleccionar la fecha, oficina, caja y operación.
4. Presionar 'Buscar'.

**Resultado esperado:**
Se muestra una tabla con todos los pagos realizados en esa fecha y filtros.

**Datos de prueba:**
{ "fecha_pago": "2024-06-01", "oficina_pago": 2, "caja_pago": "A", "operacion_pago": 12345 }

---

## Caso de Uso 3: Validación de campos obligatorios

**Descripción:** El usuario intenta buscar pagos sin seleccionar ningún filtro.

**Precondiciones:**
El usuario está en la página de Consulta de Pagos del Local.

**Pasos a seguir:**
1. No seleccionar ningún filtro.
2. Presionar 'Buscar'.

**Resultado esperado:**
El sistema muestra un mensaje de error indicando que debe seleccionar una opción de búsqueda.

**Datos de prueba:**
{}

---



## Casos de Prueba

# Casos de Prueba: Consulta de Pagos del Local

## Caso 1: Consulta exitosa por local
- **Entrada:**
  - oficina: 1
  - num_mercado: 10
  - categoria: 2
  - seccion: 'A'
  - local: 5
  - letra_local: 'B'
  - bloque: 'C'
- **Acción:** buscarPagosPorLocal
- **Resultado esperado:**
  - success: true
  - data: lista de pagos con los campos correctos
  - message: ''

## Caso 2: Consulta exitosa por fecha
- **Entrada:**
  - fecha_pago: '2024-06-01'
  - oficina_pago: 2
  - caja_pago: 'A'
  - operacion_pago: 12345
- **Acción:** buscarPagosPorFecha
- **Resultado esperado:**
  - success: true
  - data: lista de pagos con los campos correctos
  - message: ''

## Caso 3: Filtros incompletos
- **Entrada:**
  - (ningún filtro)
- **Acción:** buscarPagosPorLocal
- **Resultado esperado:**
  - success: false
  - data: null
  - message: 'Seleccione una opción de búsqueda.'

## Caso 4: Error en stored procedure
- **Entrada:**
  - oficina: 'ZZZ' (valor inválido)
- **Acción:** buscarPagosPorLocal
- **Resultado esperado:**
  - success: false
  - data: null
  - message: error de base de datos

## Caso 5: Consulta sin resultados
- **Entrada:**
  - oficina: 99
  - num_mercado: 99
  - categoria: 9
  - seccion: 'Z'
  - local: 9999
- **Acción:** buscarPagosPorLocal
- **Resultado esperado:**
  - success: true
  - data: []
  - message: ''




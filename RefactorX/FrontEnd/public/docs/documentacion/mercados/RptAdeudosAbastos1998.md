# RptAdeudosAbastos1998

## AnÃ¡lisis TÃ©cnico

# Documentación Técnica: Adeudos Abastos 1998

## Descripción General
Este módulo permite consultar el listado de adeudos de mercados del año 1998 para una oficina y periodo determinados. Incluye la lógica de cálculo de meses de adeudo, totales, y desglose de renta E/A y S/D. La solución está compuesta por:

- **Laravel Controller**: expone un endpoint unificado `/api/execute` para recibir eRequest y devolver eResponse.
- **Vue.js Component**: página independiente para consulta y visualización de los adeudos.
- **Stored Procedures PostgreSQL**: encapsulan la lógica de consulta y cálculo en la base de datos.
- **API Unificada**: todas las operaciones se realizan a través de `/api/execute`.

## Arquitectura

- **Frontend**: Vue.js (SPA), cada formulario es una página independiente.
- **Backend**: Laravel, controlador único para el endpoint `/api/execute`.
- **Base de Datos**: PostgreSQL, lógica encapsulada en stored procedures.

## Flujo de Datos
1. El usuario accede a la página de Adeudos Abastos 1998.
2. Selecciona año, oficina y periodo.
3. El frontend envía un POST a `/api/execute` con `{ action: 'get_adeudos_abastos_1998', params: { ... } }`.
4. Laravel recibe la petición, despacha al stored procedure correspondiente y retorna los datos.
5. El frontend muestra la tabla y totales.

## Detalles Técnicos
- **Stored Procedures**: encapsulan la lógica de negocio y cálculo de campos derivados (meses, totmeses, renta_ea, renta_sd).
- **API**: utiliza un solo endpoint para todas las operaciones, siguiendo el patrón eRequest/eResponse.
- **Vue.js**: utiliza Axios para consumir la API, muestra mensajes de error y loading.
- **Laravel**: el controlador mapea la acción solicitada a la función correspondiente.

## Seguridad
- Validación de parámetros en backend.
- Manejo de errores y logging en Laravel.

## Extensibilidad
- Para agregar nuevas acciones, basta con agregar un nuevo case en el controlador y el stored procedure correspondiente.

## Ejemplo de eRequest/eResponse

**Request:**
```json
{
  "action": "get_adeudos_abastos_1998",
  "params": {
    "axo": 1998,
    "oficina": 5,
    "periodo": 12
  }
}
```

**Response:**
```json
{
  "success": true,
  "data": [ ... ],
  "message": ""
}
```

## Consideraciones
- El frontend no usa tabs ni componentes tabulares, cada formulario es una página independiente.
- El backend puede ser extendido para otros formularios siguiendo el mismo patrón.


## Casos de Uso

# Casos de Uso - RptAdeudosAbastos1998

**Categoría:** Form

## Caso de Uso 1: Consulta de Adeudos de Abastos 1998 para Cruz del Sur

**Descripción:** El usuario desea consultar todos los adeudos del año 1998 para la oficina Cruz del Sur (oficina 5) hasta el periodo 12.

**Precondiciones:**
El usuario tiene acceso al sistema y permisos para consultar adeudos.

**Pasos a seguir:**
1. El usuario accede a la página 'Adeudos Abastos 1998'.
2. Selecciona año 1998, oficina 'Cruz del Sur', periodo 12.
3. Presiona el botón 'Buscar'.
4. El sistema muestra la tabla de adeudos, meses, totales y desglose de renta.

**Resultado esperado:**
Se muestra el listado completo de adeudos de la oficina Cruz del Sur para el año 1998, con totales y desglose correcto.

**Datos de prueba:**
{ "axo": 1998, "oficina": 5, "periodo": 12 }

---

## Caso de Uso 2: Consulta de Renta para Local Específico

**Descripción:** El usuario desea consultar la renta de un local específico en 1998.

**Precondiciones:**
El usuario conoce los valores de categoría, sección y clave de cuota.

**Pasos a seguir:**
1. El usuario accede a la funcionalidad de consulta de renta.
2. Ingresa año 1998, categoría 2, sección 'SS', clave de cuota 4.
3. El sistema consulta y muestra la información de renta.

**Resultado esperado:**
Se muestra la información de renta correspondiente al local solicitado.

**Datos de prueba:**
{ "vaxo": 1998, "vcat": 2, "vsec": "SS", "vcve": 4 }

---

## Caso de Uso 3: Consulta de Meses de Adeudo para Local

**Descripción:** El usuario desea ver los meses de adeudo de un local específico en 1998.

**Precondiciones:**
El usuario conoce el id_local.

**Pasos a seguir:**
1. El usuario accede a la funcionalidad de consulta de meses de adeudo.
2. Ingresa id_local 1234 y año 1998.
3. El sistema consulta y muestra los meses y montos de adeudo.

**Resultado esperado:**
Se muestra la lista de meses y montos de adeudo para el local solicitado.

**Datos de prueba:**
{ "vid_local": 1234, "vaxo": 1998 }

---



## Casos de Prueba

# Casos de Prueba: Adeudos Abastos 1998

## Caso 1: Consulta exitosa de adeudos
- **Entrada:** axo=1998, oficina=5, periodo=12
- **Acción:** POST /api/execute con action=get_adeudos_abastos_1998
- **Resultado esperado:**
  - Código HTTP 200
  - success=true
  - data: array con al menos un registro
  - Cada registro contiene campos: datoslocal, nombre, superficie, adeudo, meses, totmeses, renta_ea, renta_sd, recaudadora, descripcion

## Caso 2: Consulta de renta para local
- **Entrada:** vaxo=1998, vcat=2, vsec='SS', vcve=4
- **Acción:** POST /api/execute con action=get_renta_1998
- **Resultado esperado:**
  - Código HTTP 200
  - success=true
  - data: array con un registro con los campos de renta

## Caso 3: Consulta de meses de adeudo para local
- **Entrada:** vid_local=1234, vaxo=1998
- **Acción:** POST /api/execute con action=get_meses_adeudo_1998
- **Resultado esperado:**
  - Código HTTP 200
  - success=true
  - data: array con los meses y montos de adeudo

## Caso 4: Parámetros inválidos
- **Entrada:** axo=1997, oficina=5, periodo=12
- **Acción:** POST /api/execute con action=get_adeudos_abastos_1998
- **Resultado esperado:**
  - Código HTTP 200
  - success=true
  - data: array vacío

## Caso 5: Acción no soportada
- **Entrada:** action=unknown_action
- **Acción:** POST /api/execute
- **Resultado esperado:**
  - Código HTTP 200
  - success=false
  - message: 'Acción no soportada'




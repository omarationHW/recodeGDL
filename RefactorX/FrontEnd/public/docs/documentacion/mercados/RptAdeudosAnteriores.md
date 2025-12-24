# RptAdeudosAnteriores

## AnÃ¡lisis TÃ©cnico

# Documentación Técnica: Listado de Adeudos Anteriores (RptAdeudosAnteriores)

## Descripción General
Este módulo permite consultar y visualizar el listado de adeudos de años anteriores a 1996 para los mercados municipales, agrupando por local y año, mostrando información relevante como meses adeudados, renta, importe total, y datos del local.

## Arquitectura
- **Backend**: Laravel Controller con endpoint único `/api/execute` usando patrón eRequest/eResponse.
- **Frontend**: Componente Vue.js como página independiente.
- **Base de Datos**: PostgreSQL, lógica encapsulada en stored procedures.
- **API**: Todas las operaciones se realizan mediante el endpoint `/api/execute`.

## Flujo de Datos
1. El usuario ingresa los parámetros (año, oficina, periodo) en el formulario Vue.
2. Vue envía un POST a `/api/execute` con `{ action: 'get_report', params: { axo, oficina, periodo } }`.
3. Laravel Controller recibe la petición, valida parámetros y ejecuta el stored procedure `rpt_adeudos_anteriores`.
4. El resultado se retorna como JSON y Vue lo muestra en una tabla.

## Endpoints
- **POST /api/execute**
  - **action**: `get_report` (para obtener el listado principal)
  - **params**: `{ axo, oficina, periodo }`
  - **action**: `get_mes_adeudo` (para obtener meses de adeudo de un local)
  - **params**: `{ id_local, axo }`

## Stored Procedures
- `rpt_adeudos_anteriores(axo, oficina, periodo)`
- `rpt_mes_adeudo_ant(id_local, axo)`

## Validaciones
- Todos los parámetros son obligatorios y deben ser numéricos.
- El año debe ser razonable (ej. 1992-1995).
- El periodo debe estar entre 1 y 12.
- La oficina debe existir en catálogo.

## Seguridad
- El endpoint debe estar protegido por autenticación (middleware Laravel).
- Los parámetros deben validarse en backend.

## Manejo de Errores
- Si los parámetros son inválidos, se retorna `success: false` y un mensaje de error.
- Si ocurre un error en la base de datos, se retorna el mensaje de excepción.

## Extensibilidad
- El endpoint `/api/execute` puede ser extendido para otras acciones relacionadas.
- Los stored procedures pueden ser reutilizados por otros reportes.

## Ejemplo de Request
```json
{
  "action": "get_report",
  "params": {
    "axo": 1994,
    "oficina": 2,
    "periodo": 7
  }
}
```

## Ejemplo de Response
```json
{
  "success": true,
  "data": [
    {
      "id_local": 123,
      "oficina": 2,
      "num_mercado": 5,
      "categoria": 1,
      "seccion": "A",
      "local": 10,
      "letra_local": "B",
      "bloque": "1",
      "nombre": "JUAN PEREZ",
      "axo": 1994,
      "totade": 1,
      "clave_cuota": 4,
      "adeudo": 1500.00,
      "recaudadora": "ZONA OLIMPICA",
      "descripcion": "MERCADO OLIMPICA",
      "renta": 150.00,
      "meses": "1,2,3,4,5,6,7",
      "datoslocal": "2 5 1 A 10 B 1"
    }
  ]
}
```

## Notas
- El frontend puede consultar los meses de adeudo de cada local usando el action `get_mes_adeudo`.
- El reporte puede ser exportado a Excel desde el frontend si se requiere.


## Casos de Uso

# Casos de Uso - RptAdeudosAnteriores

**Categoría:** Form

## Caso de Uso 1: Consulta de Adeudos Anteriores por Año y Oficina

**Descripción:** El usuario desea obtener el listado de adeudos de años anteriores a 1996 para una oficina y año específico.

**Precondiciones:**
El usuario está autenticado y tiene permisos de consulta.

**Pasos a seguir:**
1. El usuario accede a la página 'Listado de Adeudos Anteriores'.
2. Ingresa el año (ej. 1994), la oficina (ej. 2), y el periodo (ej. 7).
3. Presiona el botón 'Consultar'.
4. El sistema muestra la tabla con los resultados.

**Resultado esperado:**
Se muestra una tabla con los locales, datos, meses adeudados, renta y adeudo total para los parámetros seleccionados.

**Datos de prueba:**
{ "axo": 1994, "oficina": 2, "periodo": 7 }

---

## Caso de Uso 2: Detalle de Meses de Adeudo de un Local

**Descripción:** El usuario desea ver los meses específicos de adeudo para un local en el año consultado.

**Precondiciones:**
El usuario ya realizó una consulta general y tiene el ID del local.

**Pasos a seguir:**
1. El usuario hace clic en el botón de detalle de meses (o similar) en la fila de un local.
2. El frontend envía un request con action 'get_mes_adeudo' y los parámetros correspondientes.
3. El sistema retorna los meses y montos adeudados.

**Resultado esperado:**
Se muestra un listado de los meses y montos adeudados para el local seleccionado.

**Datos de prueba:**
{ "id_local": 123, "axo": 1994 }

---

## Caso de Uso 3: Validación de Parámetros Inválidos

**Descripción:** El usuario intenta consultar el reporte con parámetros inválidos (ej. año vacío o texto).

**Precondiciones:**
El usuario está autenticado.

**Pasos a seguir:**
1. El usuario deja el campo año vacío o ingresa un texto no numérico.
2. Presiona 'Consultar'.
3. El sistema valida y retorna un mensaje de error.

**Resultado esperado:**
El sistema muestra un mensaje de error indicando que el año es obligatorio y debe ser numérico.

**Datos de prueba:**
{ "axo": "", "oficina": 2, "periodo": 7 }

---



## Casos de Prueba

# Casos de Prueba: Listado de Adeudos Anteriores

| Caso | Descripción | Entrada | Resultado Esperado |
|------|-------------|---------|-------------------|
| TC01 | Consulta exitosa de adeudos | axo=1994, oficina=2, periodo=7 | Respuesta JSON con success=true y arreglo de datos con campos id_local, datoslocal, nombre, axo, meses, renta, adeudo, etc. |
| TC02 | Consulta de meses de adeudo de un local | id_local=123, axo=1994 | Respuesta JSON con success=true y arreglo de meses y montos adeudados |
| TC03 | Parámetro año vacío | axo="", oficina=2, periodo=7 | Respuesta JSON con success=false y mensaje de error "The axo field is required." |
| TC04 | Parámetro oficina no numérico | axo=1994, oficina="abc", periodo=7 | Respuesta JSON con success=false y mensaje de error |
| TC05 | Año fuera de rango | axo=1800, oficina=2, periodo=7 | Respuesta JSON con success=true y data vacía |
| TC06 | Consulta sin resultados | axo=1992, oficina=99, periodo=1 | Respuesta JSON con success=true y data vacía |
| TC07 | SQL Injection attempt | axo="1994; DROP TABLE ta_11_adeudo_local;--", oficina=2, periodo=7 | Respuesta JSON con success=false y mensaje de error |




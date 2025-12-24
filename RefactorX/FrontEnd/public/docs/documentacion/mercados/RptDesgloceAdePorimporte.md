# RptDesgloceAdePorimporte

## AnÃ¡lisis TÃ©cnico

# Documentación Técnica: Migración de Formulario RptDesgloceAdeporImporte

## 1. Descripción General
Este módulo corresponde a la migración del formulario Delphi `RptDesgloceAdeporImporte` a una arquitectura moderna basada en Laravel (backend/API), Vue.js (frontend SPA) y PostgreSQL (base de datos). El objetivo es consultar y mostrar un reporte de locales con adeudos vencidos, desglosado por año y filtrado por importe mínimo, año y periodo.

## 2. Arquitectura
- **Backend:** Laravel API, endpoint único `/api/execute` (patrón eRequest/eResponse)
- **Frontend:** Vue.js SPA, página independiente para el formulario
- **Base de Datos:** PostgreSQL, lógica encapsulada en stored procedure `spd_11_ade_axo`

## 3. Flujo de Datos
1. El usuario ingresa los parámetros (año, periodo, importe mínimo) en la página Vue.
2. Vue envía un POST a `/api/execute` con `eRequest: 'RptDesgloceAdeporImporte'` y los parámetros.
3. El controlador Laravel recibe la petición, valida parámetros y ejecuta el stored procedure PostgreSQL.
4. El resultado se retorna en formato JSON bajo la clave `data`.
5. Vue muestra el reporte tabular, con totales y formato monetario.

## 4. Detalle de Componentes
### 4.1. Stored Procedure PostgreSQL
- **Nombre:** `spd_11_ade_axo`
- **Entradas:**
  - `parm_axo` (año, smallint)
  - `parm_mes` (periodo/mes, smallint)
  - `parm_cuota` (importe mínimo, numeric)
- **Salida:**
  - Tabla con campos de identificación del local y adeudos por año (ant, 2004-2008) y total.
- **Lógica:**
  - Filtra los locales con adeudo total mayor o igual al importe indicado, hasta el año y periodo seleccionados.
  - Devuelve los datos agrupados y ordenados por oficina, mercado, etc.

### 4.2. Laravel Controller
- **Ruta:** `/api/execute` (POST)
- **Patrón:** eRequest/eResponse
- **Lógica:**
  - Recibe `eRequest` y `eParams`.
  - Si `eRequest` es `RptDesgloceAdeporImporte`, ejecuta el SP con los parámetros.
  - Devuelve JSON con `success`, `data` y `message`.

### 4.3. Vue.js Component
- **Página completa** (no tab, no modal)
- **Formulario de parámetros** (año, periodo, importe)
- **Tabla de resultados** con totales y formato monetario
- **Mensajes de carga, error y vacío**
- **Breadcrumb de navegación**

## 5. Consideraciones Técnicas
- El SP debe adaptarse a la estructura real de la base de datos (tablas `locales`, `adeudos`).
- El endpoint `/api/execute` puede ser extendido para otros formularios/reports.
- El frontend es responsivo y accesible.
- El formato monetario usa `toLocaleString` para MXN.

## 6. Seguridad
- Validación de parámetros en backend.
- El endpoint debe estar protegido por autenticación (no incluido aquí por simplicidad).

## 7. Extensibilidad
- El patrón eRequest/eResponse permite agregar más reportes y operaciones sin crear nuevos endpoints.
- El componente Vue puede ser reutilizado para otros reportes similares.

## 8. Pruebas
- Se incluyen casos de uso y escenarios de prueba para asegurar la funcionalidad y robustez del módulo.


## Casos de Uso

# Casos de Uso - RptDesgloceAdeporImporte

**Categoría:** Form

## Caso de Uso 1: Consulta de reporte con parámetros válidos

**Descripción:** El usuario consulta el reporte de adeudos vencidos para el año 2023, periodo 6 (junio), con importe mínimo de $1000.

**Precondiciones:**
Existen locales con adeudos mayores o iguales a $1000 hasta junio de 2023.

**Pasos a seguir:**
1. Ingresar año 2023, periodo 6, importe 1000 en el formulario.
2. Presionar 'Consultar'.
3. Esperar la carga y visualizar la tabla de resultados.

**Resultado esperado:**
Se muestra una tabla con los locales que cumplen el criterio, incluyendo totales por columna.

**Datos de prueba:**
{ year: 2023, period: 6, amount: 1000 }

---

## Caso de Uso 2: Consulta sin resultados

**Descripción:** El usuario consulta el reporte para un importe mínimo muy alto, donde no existen adeudos.

**Precondiciones:**
No existen locales con adeudos mayores o iguales a $1,000,000.

**Pasos a seguir:**
1. Ingresar año 2023, periodo 6, importe 1000000 en el formulario.
2. Presionar 'Consultar'.

**Resultado esperado:**
Se muestra un mensaje de 'No se encontraron resultados para los parámetros indicados.'

**Datos de prueba:**
{ year: 2023, period: 6, amount: 1000000 }

---

## Caso de Uso 3: Error por parámetros insuficientes

**Descripción:** El usuario intenta consultar el reporte sin ingresar el año.

**Precondiciones:**
El campo año está vacío o no es válido.

**Pasos a seguir:**
1. Dejar el campo año vacío.
2. Ingresar periodo 6, importe 1000.
3. Presionar 'Consultar'.

**Resultado esperado:**
Se muestra un mensaje de error indicando 'Parámetros insuficientes'.

**Datos de prueba:**
{ year: null, period: 6, amount: 1000 }

---



## Casos de Prueba

## Casos de Prueba para RptDesgloceAdeporImporte

| #  | Descripción | Entrada | Resultado Esperado |
|----|-------------|---------|-------------------|
| 1  | Consulta exitosa con datos | year=2023, period=6, amount=1000 | Tabla con resultados y totales |
| 2  | Consulta sin resultados | year=2023, period=6, amount=1000000 | Mensaje de 'No se encontraron resultados...' |
| 3  | Parámetro año faltante | year=null, period=6, amount=1000 | Mensaje de error 'Parámetros insuficientes' |
| 4  | Parámetro periodo fuera de rango | year=2023, period=13, amount=1000 | Mensaje de error o validación frontend |
| 5  | Importe negativo | year=2023, period=6, amount=-500 | Mensaje de error o validación frontend |
| 6  | Consulta con caracteres no numéricos | year='abcd', period=6, amount=1000 | Mensaje de error de validación |
| 7  | Consulta con todos los campos en cero | year=0, period=0, amount=0 | Mensaje de error o sin resultados |
| 8  | Consulta con año futuro | year=2100, period=1, amount=1000 | Tabla vacía o sin resultados |

### Notas:
- Todos los casos deben probarse tanto en frontend (validación de formulario) como en backend (respuesta de la API).
- Los casos 4, 5, 6 y 7 deben ser bloqueados por validación en el frontend, pero si llegan al backend, deben retornar error adecuado.




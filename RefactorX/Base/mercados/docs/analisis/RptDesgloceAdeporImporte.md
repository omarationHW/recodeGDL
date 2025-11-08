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

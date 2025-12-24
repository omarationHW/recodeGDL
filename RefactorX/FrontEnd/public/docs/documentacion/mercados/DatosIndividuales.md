# DatosIndividuales

## AnÃ¡lisis TÃ©cnico

# Documentación Técnica: Migración Formulario DatosIndividuales (Delphi) a Laravel + Vue.js + PostgreSQL

## Arquitectura General
- **Backend**: Laravel (PHP 8+), PostgreSQL
- **Frontend**: Vue.js 3 SPA (Single Page Application)
- **API**: Único endpoint `/api/execute` (patrón eRequest/eResponse)
- **Base de datos**: PostgreSQL, toda la lógica SQL encapsulada en stored procedures

## Flujo de Datos
1. **Frontend** solicita datos individuales de un local vía `/api/execute` con acción `getDatosIndividuales` y parámetros `{ id_local }`.
2. **Backend** (Laravel Controller) recibe la petición, despacha a la función correspondiente, que ejecuta el stored procedure adecuado en PostgreSQL.
3. **Stored Procedures** devuelven los datos en formato tabla, que el backend retorna como JSON.
4. **Frontend** renderiza la información en la página Vue.js.

## Endpoints y Acciones
- `/api/execute` (POST)
  - `action`: Nombre de la acción (ej: `getDatosIndividuales`, `getAdeudos`, etc)
  - `params`: Parámetros requeridos para la acción

### Acciones Soportadas
- `getDatosIndividuales`: Datos generales del local
- `getAdeudos`: Adeudos del local
- `getRequerimientos`: Requerimientos del local
- `getMovimientos`: Movimientos históricos del local
- `getMercado`: Datos del mercado
- `getCuota`: Cuota vigente del local
- `getUsuario`: Usuario responsable
- `getTianguis`: Datos de tianguis (si aplica)

## Stored Procedures
- Todos los queries SQL se migran a stored procedures en PostgreSQL.
- Cada procedimiento recibe los parámetros necesarios y retorna un conjunto de resultados (tabla).
- La lógica de cálculo de recargos, descuentos, etc., se implementa en los SPs.

## Vue.js
- Cada formulario es una página independiente (NO tabs).
- Navegación mediante rutas (ej: `/datos-individuales/:id_local`)
- Breadcrumb para navegación contextual.
- Cada sección (Mercado, Adeudos, Requerimientos, Movimientos) es un bloque visual.
- Lógica de carga de datos: secuencial, con manejo de errores y loading.

## API Unificada (eRequest/eResponse)
- Todas las operaciones se realizan vía `/api/execute`.
- El controlador Laravel despacha la acción y parámetros a la función correspondiente.
- El resultado se retorna en formato `{ success, data, message }`.

## Seguridad
- Validación de parámetros en backend.
- Manejo de errores y mensajes claros.
- (Opcional) Autenticación JWT o session para producción.

## Extensibilidad
- Para agregar nuevas acciones, basta con:
  1. Crear el stored procedure en PostgreSQL
  2. Agregar el método correspondiente en el controlador Laravel
  3. Consumirlo desde el frontend

## Ejemplo de Petición API
```json
{
  "action": "getDatosIndividuales",
  "params": { "id_local": 123 }
}
```

## Ejemplo de Respuesta API
```json
{
  "success": true,
  "data": { ... },
  "message": ""
}
```

## Notas de Migración
- Los cálculos de recargos, descuentos y totales se realizan en los SPs para mantener la lógica de negocio en la base de datos.
- El frontend sólo muestra los datos y permite navegación entre vistas.
- El endpoint es único y flexible para facilitar integración y pruebas.

# Estructura de Carpetas
- `app/Http/Controllers/DatosIndividualesController.php`
- `resources/js/pages/DatosIndividualesPage.vue`
- `database/migrations/` y `database/stored_procedures/` para los SPs

# Pruebas
- Se recomienda usar Postman para probar el endpoint `/api/execute` con diferentes acciones y parámetros.
- El frontend puede ser probado con Cypress o Jest para pruebas de integración.


## Casos de Uso

# Casos de Uso - DatosIndividuales

**Categoría:** Form

## Caso de Uso 1: Consulta de Datos Individuales de un Local

**Descripción:** El usuario consulta toda la información relevante de un local específico, incluyendo datos generales, adeudos, requerimientos y movimientos.

**Precondiciones:**
El usuario tiene acceso al sistema y conoce el ID del local.

**Pasos a seguir:**
1. El usuario accede a la página de consulta individual.
2. Ingresa el ID del local o navega desde una lista.
3. El sistema realiza una petición a /api/execute con action 'getDatosIndividuales' y el id_local.
4. El sistema carga y muestra los datos generales, adeudos, requerimientos y movimientos.

**Resultado esperado:**
Se muestran correctamente todos los datos del local, incluyendo tablas de adeudos, requerimientos y movimientos.

**Datos de prueba:**
{ "id_local": 123 }

---

## Caso de Uso 2: Consulta de Adeudos de un Local

**Descripción:** El usuario desea ver el detalle de los adeudos de un local.

**Precondiciones:**
El usuario tiene acceso y el local tiene adeudos registrados.

**Pasos a seguir:**
1. El usuario accede a la sección de adeudos desde la página de datos individuales.
2. El sistema realiza una petición a /api/execute con action 'getAdeudos' y el id_local.
3. El sistema muestra la tabla de adeudos.

**Resultado esperado:**
Se muestra la lista de adeudos con año, mes, importe y recargos.

**Datos de prueba:**
{ "id_local": 123 }

---

## Caso de Uso 3: Consulta de Requerimientos de un Local

**Descripción:** El usuario revisa los requerimientos fiscales asociados a un local.

**Precondiciones:**
El usuario tiene acceso y el local tiene requerimientos registrados.

**Pasos a seguir:**
1. El usuario accede a la sección de requerimientos desde la página de datos individuales.
2. El sistema realiza una petición a /api/execute con action 'getRequerimientos' y el id_local.
3. El sistema muestra la tabla de requerimientos.

**Resultado esperado:**
Se muestra la lista de requerimientos con folio, fecha, importe multa, importe gastos y vigencia.

**Datos de prueba:**
{ "id_local": 123 }

---



## Casos de Prueba

# Casos de Prueba para DatosIndividuales

## Caso 1: Consulta exitosa de datos individuales
- **Input:**
  - action: getDatosIndividuales
  - params: { id_local: 123 }
- **Expected:**
  - success: true
  - data: objeto con todos los campos del local
  - message: ""

## Caso 2: Consulta de adeudos con local inexistente
- **Input:**
  - action: getAdeudos
  - params: { id_local: 999999 }
- **Expected:**
  - success: true
  - data: [] (lista vacía)
  - message: ""

## Caso 3: Consulta de requerimientos sin parámetro obligatorio
- **Input:**
  - action: getRequerimientos
  - params: { }
- **Expected:**
  - success: false
  - data: null
  - message: "id_local es requerido"

## Caso 4: Consulta de movimientos con error de base de datos
- **Simulación:** Forzar error en SP o conexión
- **Expected:**
  - success: false
  - data: null
  - message: "Error ..."

## Caso 5: Consulta de datos de tianguis para local con num_mercado=214
- **Input:**
  - action: getTianguis
  - params: { folio: 555 }
- **Expected:**
  - success: true
  - data: objeto con campos de tianguis
  - message: ""




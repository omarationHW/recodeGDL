# Documentación Técnica: fechasegfrm

## Análisis Técnico

# Documentación Técnica: Migración de Formulario fechasegfrm (Delphi) a Laravel + Vue.js + PostgreSQL

## 1. Descripción General
Este módulo corresponde a la migración del formulario Delphi `fechasegfrm` a una arquitectura moderna basada en Laravel (backend/API), Vue.js (frontend) y PostgreSQL (base de datos). El formulario permite al usuario seleccionar una fecha y capturar un número de oficio, guardando ambos datos en la base de datos y mostrando los registros recientes.

## 2. Estructura de la Solución
- **Backend (Laravel):**
  - Controlador unificado `ExecuteController` que expone el endpoint `/api/execute`.
  - Toda la lógica de negocio se delega a procedimientos almacenados en PostgreSQL.
  - El patrón de comunicación es eRequest/eResponse.
- **Frontend (Vue.js):**
  - Componente de página independiente `FechasegfrmPage`.
  - Formulario para captura de fecha y oficio.
  - Tabla para mostrar los registros recientes.
- **Base de Datos (PostgreSQL):**
  - Tabla `fechasegfrm` (debe existir con campos: id, fecha, oficio, created_at).
  - Procedimientos almacenados: `fechasegfrm_save`, `fechasegfrm_list`.

## 3. API Unificada
- **Endpoint:** `/api/execute`
- **Método:** POST
- **Request:**
  - `eRequest`: Nombre de la operación (ej: `fechasegfrm.save`, `fechasegfrm.list`)
  - `params`: Parámetros específicos de la operación
- **Response:**
  - `eResponse`:
    - `success`: true/false
    - `message`: Mensaje de resultado
    - `data`: Datos devueltos (si aplica)

## 4. Stored Procedures
- **fechasegfrm_save(p_fecha DATE, p_oficio VARCHAR):** Inserta un registro y retorna el registro insertado.
- **fechasegfrm_list():** Retorna los últimos 20 registros ordenados por fecha de creación descendente.

## 5. Validaciones
- El campo `fecha` es obligatorio y debe ser una fecha válida.
- El campo `oficio` es obligatorio y de máximo 255 caracteres.

## 6. Frontend
- El formulario es una página completa, no usa tabs.
- Incluye navegación breadcrumb.
- Muestra mensajes de éxito/error.
- Muestra tabla de registros recientes.

## 7. Consideraciones de Seguridad
- Validación de datos en backend y frontend.
- Uso de procedimientos almacenados para evitar SQL Injection.
- El endpoint `/api/execute` debe estar protegido según la política de autenticación/autorización de la aplicación.

## 8. Tabla Base de Datos (Ejemplo)
```sql
CREATE TABLE fechasegfrm (
    id SERIAL PRIMARY KEY,
    fecha DATE NOT NULL,
    oficio VARCHAR(255) NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT NOW()
);
```

## 9. Extensibilidad
- Se pueden agregar más operaciones al endpoint unificado agregando nuevos casos en el switch del controlador y nuevos procedimientos almacenados.

## 10. Flujo de Uso
1. El usuario accede a la página del formulario.
2. Selecciona una fecha y captura el oficio.
3. Al hacer clic en "Aceptar", los datos se envían a `/api/execute` con `eRequest: 'fechasegfrm.save'`.
4. El backend valida y guarda los datos usando el SP correspondiente.
5. Se muestra mensaje de éxito/error y se actualiza la tabla de registros recientes.

## Casos de Prueba

# Casos de Prueba: Formulario fechasegfrm

| Caso | Descripción | Datos de Entrada | Resultado Esperado |
|------|-------------|------------------|-------------------|
| TC01 | Guardar registro válido | fecha: 2024-07-01, oficio: OF-1234 | Registro guardado, mensaje de éxito, aparece en la tabla |
| TC02 | Guardar sin oficio | fecha: 2024-07-01, oficio: (vacío) | Mensaje de error, no se guarda registro |
| TC03 | Guardar sin fecha | fecha: (vacío), oficio: OF-1234 | Mensaje de error, no se guarda registro |
| TC04 | Oficio demasiado largo | fecha: 2024-07-01, oficio: (256 caracteres) | Mensaje de error, no se guarda registro |
| TC05 | Visualizar registros recientes | - | Se muestran los últimos 20 registros en la tabla |
| TC06 | Cancelar formulario | (cualquier dato) | Los campos se limpian, no se envía nada al backend |

## Casos de Uso

# Casos de Uso - fechasegfrm

**Categoría:** Form

## Caso de Uso 1: Registrar una nueva fecha y oficio

**Descripción:** El usuario ingresa una fecha y un número de oficio válido y guarda el registro.

**Precondiciones:**
El usuario tiene acceso a la página del formulario y la tabla 'fechasegfrm' existe.

**Pasos a seguir:**
1. Acceder a la página 'Formulario Fecha Seguimiento'.
2. Seleccionar una fecha válida en el campo de fecha.
3. Ingresar un texto válido en el campo 'Oficio'.
4. Hacer clic en el botón 'Aceptar'.

**Resultado esperado:**
El registro se guarda correctamente y aparece en la tabla de registros recientes. Se muestra un mensaje de éxito.

**Datos de prueba:**
{ "fecha": "2024-07-01", "oficio": "OF-1234" }

---

## Caso de Uso 2: Intentar guardar sin ingresar oficio

**Descripción:** El usuario intenta guardar el formulario sin ingresar el campo 'Oficio'.

**Precondiciones:**
El usuario tiene acceso a la página del formulario.

**Pasos a seguir:**
1. Acceder a la página 'Formulario Fecha Seguimiento'.
2. Seleccionar una fecha válida.
3. Dejar el campo 'Oficio' vacío.
4. Hacer clic en el botón 'Aceptar'.

**Resultado esperado:**
El sistema muestra un mensaje de error indicando que el campo 'Oficio' es obligatorio. No se guarda ningún registro.

**Datos de prueba:**
{ "fecha": "2024-07-01", "oficio": "" }

---

## Caso de Uso 3: Visualizar registros recientes

**Descripción:** El usuario accede a la página y visualiza la tabla de los últimos registros guardados.

**Precondiciones:**
Existen registros previos en la tabla 'fechasegfrm'.

**Pasos a seguir:**
1. Acceder a la página 'Formulario Fecha Seguimiento'.
2. Observar la tabla de registros recientes en la parte inferior.

**Resultado esperado:**
Se muestran los últimos 20 registros ordenados por fecha de creación descendente.

**Datos de prueba:**
No se requiere datos de entrada.

---

# Documentación Técnica: frmRep_Und_Recolec

## Análisis

# Documentación Técnica: Migración Formulario Unidades de Recolección (Delphi → Laravel + Vue.js + PostgreSQL)

## 1. Descripción General
Este módulo corresponde a la migración del formulario de impresión y consulta de Unidades de Recolección (`frmRep_Und_Recolec`) del sistema Delphi a una arquitectura moderna basada en Laravel (backend/API), Vue.js (frontend SPA) y PostgreSQL (base de datos y lógica de negocio).

## 2. Arquitectura
- **Backend:** Laravel API, expone un endpoint único `/api/execute` que recibe peticiones eRequest/eResponse.
- **Frontend:** Vue.js SPA, cada formulario es una página independiente (no tabs), con navegación y breadcrumbs.
- **Base de Datos:** PostgreSQL, toda la lógica SQL se encapsula en stored procedures.

## 3. API Unificada
- **Endpoint:** `POST /api/execute`
- **Request:**
  ```json
  {
    "action": "und_recolec_report",
    "params": {
      "ejercicio": 2024,
      "order": 1
    }
  }
  ```
- **Response:**
  ```json
  {
    "success": true,
    "data": [ ... ],
    "message": ""
  }
  ```
- **Acciones soportadas:**
  - `und_recolec_list`: Listado general
  - `und_recolec_report`: Reporte para impresión/vista previa
  - `und_recolec_create`: Alta
  - `und_recolec_update`: Modificación
  - `und_recolec_delete`: Baja

## 4. Stored Procedures
- Toda la lógica de consulta, ordenamiento y CRUD se realiza en stored procedures PostgreSQL.
- El ordenamiento dinámico se realiza usando `EXECUTE format(...)` para evitar SQL injection.
- Las operaciones de alta/baja verifican restricciones de integridad (no permitir borrar si hay contratos referenciando la unidad).

## 5. Frontend (Vue.js)
- Página independiente `/unidades-recoleccion`.
- Permite seleccionar ejercicio y tipo de ordenamiento.
- Muestra tabla con los resultados del reporte.
- Botón "Vista Previa" ejecuta la consulta y muestra los datos.
- Botón "Salir" regresa a la página anterior.
- Breadcrumbs para navegación.
- Soporte para loading y errores.

## 6. Backend (Laravel)
- Controlador `UndRecolecController` maneja todas las acciones relacionadas.
- Utiliza el endpoint unificado `/api/execute`.
- Cada acción llama al stored procedure correspondiente.
- Manejo de errores y respuestas estándar.

## 7. Seguridad
- El endpoint debe estar protegido por autenticación (ej: JWT o session).
- Los parámetros son validados en el frontend y backend.
- El backend valida que los parámetros sean del tipo esperado antes de ejecutar el SP.

## 8. Pruebas y Casos de Uso
- Se proveen casos de uso y escenarios de prueba para asegurar la funcionalidad y robustez del módulo.

## 9. Extensibilidad
- El patrón eRequest/eResponse permite agregar nuevas acciones sin modificar el endpoint.
- Los stored procedures pueden ser versionados y auditados en la base de datos.

## 10. Notas de Migración
- El reporte "Vista Previa" corresponde a la funcionalidad de QuickReport en Delphi, ahora se muestra como tabla en la SPA.
- El ordenamiento por "Control", "Clave", "Descripción", "Costo de Unidad" se respeta.
- El ejercicio se puede seleccionar manualmente.
- El backend puede ser extendido para exportar a PDF/Excel si se requiere.


## Casos de Uso

# Casos de Uso - frmRep_Und_Recolec

**Categoría:** Form

## Caso de Uso 1: Consulta de Unidades de Recolección por Ejercicio y Orden

**Descripción:** El usuario desea visualizar el listado de unidades de recolección para el ejercicio 2024, ordenadas por descripción.

**Precondiciones:**
El usuario está autenticado y tiene permisos de consulta.

**Pasos a seguir:**
1. Accede a la página 'Unidades de Recolección'.
2. Selecciona el ejercicio 2024.
3. Selecciona 'Descripción' como criterio de orden.
4. Presiona 'Vista Previa'.

**Resultado esperado:**
Se muestra una tabla con todas las unidades de recolección del ejercicio 2024, ordenadas alfabéticamente por descripción.

**Datos de prueba:**
{ "ejercicio": 2024, "order": 3 }

---

## Caso de Uso 2: Intento de Eliminación de Unidad de Recolección Referenciada

**Descripción:** El usuario intenta eliminar una unidad de recolección que está referenciada en al menos un contrato.

**Precondiciones:**
Existe al menos un contrato que utiliza la unidad a eliminar.

**Pasos a seguir:**
1. Accede a la página de administración de unidades.
2. Selecciona la unidad referenciada.
3. Presiona 'Eliminar'.

**Resultado esperado:**
El sistema responde con un mensaje de error indicando que no se puede borrar porque existen contratos asociados.

**Datos de prueba:**
{ "ctrol": 101 }

---

## Caso de Uso 3: Alta de Nueva Unidad de Recolección

**Descripción:** El usuario da de alta una nueva unidad de recolección para el ejercicio 2025.

**Precondiciones:**
No existe una unidad con la misma clave para el ejercicio 2025.

**Pasos a seguir:**
1. Accede a la página de administración de unidades.
2. Ingresa los datos: ejercicio=2025, clave='Z', descripción='Zona Nueva', costo_unidad=150.00, costo_exed=200.00.
3. Presiona 'Guardar'.

**Resultado esperado:**
El sistema responde con éxito y la nueva unidad aparece en el listado.

**Datos de prueba:**
{ "ejercicio": 2025, "cve": "Z", "descripcion": "Zona Nueva", "costo_unidad": 150.00, "costo_exed": 200.00 }

---



## Casos de Prueba

## Casos de Prueba para Unidades de Recolección

### 1. Consulta básica
- **Entrada:** ejercicio=2024, order=1
- **Acción:** POST /api/execute { action: 'und_recolec_report', params: { ejercicio: 2024, order: 1 } }
- **Esperado:** Respuesta success=true, data con lista ordenada por ctrol_recolec

### 2. Consulta ordenada por descripción
- **Entrada:** ejercicio=2024, order=3
- **Acción:** POST /api/execute { action: 'und_recolec_report', params: { ejercicio: 2024, order: 3 } }
- **Esperado:** Respuesta success=true, data ordenada por descripción ascendente

### 3. Alta de unidad duplicada
- **Entrada:** ejercicio=2024, cve='A', descripcion='Unidad A', costo_unidad=100, costo_exed=120
- **Acción:** POST /api/execute { action: 'und_recolec_create', params: { ... } }
- **Esperado:** Respuesta success=true, data=['YA EXISTE']

### 4. Baja de unidad referenciada
- **Entrada:** ctrol=101 (referenciado en contratos)
- **Acción:** POST /api/execute { action: 'und_recolec_delete', params: { ctrol: 101 } }
- **Esperado:** Respuesta success=true, data=['NO SE PUEDE BORRAR: EXISTEN CONTRATOS']

### 5. Modificación de unidad
- **Entrada:** ctrol=102, descripcion='Modificada', costo_unidad=200, costo_exed=250
- **Acción:** POST /api/execute { action: 'und_recolec_update', params: { ... } }
- **Esperado:** Respuesta success=true, data=['OK']

### 6. Consulta sin resultados
- **Entrada:** ejercicio=2099, order=1
- **Acción:** POST /api/execute { action: 'und_recolec_report', params: { ejercicio: 2099, order: 1 } }
- **Esperado:** Respuesta success=true, data=[]



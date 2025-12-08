# Documentación Técnica: sQRptEmpresas

## Análisis

# Documentación Técnica: Migración de Formulario sQRptEmpresas

## 1. Descripción General
Este módulo corresponde a la migración del formulario de reporte de empresas (sQRptEmpresas) desde Delphi a una arquitectura moderna basada en Laravel (backend/API), Vue.js (frontend) y PostgreSQL (base de datos). El reporte permite visualizar el catálogo de empresas con diferentes criterios de clasificación.

## 2. Arquitectura
- **Backend:** Laravel 10+, API RESTful, endpoint unificado `/api/execute`.
- **Frontend:** Vue.js 3+, componente de página independiente.
- **Base de Datos:** PostgreSQL, lógica de reporte encapsulada en stored procedure.

## 3. API Unificada
- **Endpoint:** `/api/execute`
- **Método:** POST
- **Request:**
  ```json
  {
    "eRequest": "getEmpresasReport",
    "params": { "opcion": 1 }
  }
  ```
- **Response:**
  ```json
  {
    "eResponse": {
      "success": true,
      "data": [ ... ],
      "message": ""
    }
  }
  ```
- **Parámetro `opcion`:**
  - 1: Número de Empresa
  - 2: Tipo de Empresa
  - 3: Nombre
  - 4: Representante

## 4. Stored Procedure
- **Nombre:** `rpt_empresas`
- **Parámetro:** `opcion` (integer)
- **Retorna:** Tabla con columnas: num_empresa, ctrol_emp, descripcion, representante, tipo_empresa, descripcion_1
- **Ordenamiento:** Dinámico según la opción seleccionada.

## 5. Frontend (Vue.js)
- Página independiente con selector de clasificación, tabla de resultados y breadcrumb de navegación.
- Llama al endpoint `/api/execute` con el eRequest y parámetros adecuados.
- Muestra fecha/hora de impresión.

## 6. Backend (Laravel)
- Controlador `ExecuteController` maneja todas las solicitudes a `/api/execute`.
- Ejecuta el stored procedure y retorna los resultados en formato JSON.

## 7. Seguridad
- Se recomienda proteger el endpoint con autenticación (ej. Sanctum o Passport) en ambientes productivos.

## 8. Consideraciones
- El reporte es de solo lectura.
- El frontend es responsivo y puede integrarse en cualquier SPA Vue.js.
- El stored procedure puede ser extendido para más criterios si es necesario.

## 9. Dependencias
- Laravel 10+
- Vue.js 3+
- PostgreSQL 12+
- Axios (frontend)

## 10. Ejemplo de Uso
Ver sección de Casos de Uso y Casos de Prueba.


## Casos de Uso

# Casos de Uso - sQRptEmpresas

**Categoría:** Form

## Caso de Uso 1: Visualizar catálogo de empresas ordenado por número de empresa

**Descripción:** El usuario accede a la página de reporte y selecciona la opción 'Número de Empresa' para visualizar el catálogo ordenado por este campo.

**Precondiciones:**
El usuario tiene acceso a la aplicación y existen registros en las tablas ta_16_empresas y ta_16_tipos_emp.

**Pasos a seguir:**
1. Ingresar a la página 'Catálogo de Tipos de Empresas'.
2. Seleccionar 'Número de Empresa' en el selector de clasificación.
3. Esperar a que se cargue la tabla de resultados.

**Resultado esperado:**
La tabla muestra todas las empresas ordenadas por el campo 'num_empresa'.

**Datos de prueba:**
Empresas con num_empresa: 100, 101, 102, 103.

---

## Caso de Uso 2: Visualizar catálogo de empresas ordenado por tipo de empresa

**Descripción:** El usuario selecciona la opción 'Tipo de Empresa' para ver el catálogo agrupado y ordenado por tipo.

**Precondiciones:**
Existen al menos dos tipos de empresa y empresas asociadas a cada tipo.

**Pasos a seguir:**
1. Ingresar a la página de reporte.
2. Seleccionar 'Tipo de Empresa' en el selector.
3. Observar el ordenamiento de la tabla.

**Resultado esperado:**
Las empresas se agrupan y ordenan primero por tipo_empresa y luego por num_empresa.

**Datos de prueba:**
Tipos: 1 (Industrial), 2 (Comercial). Empresas: A (tipo 1), B (tipo 2), C (tipo 1).

---

## Caso de Uso 3: Visualizar catálogo de empresas ordenado por representante

**Descripción:** El usuario selecciona 'Representante' para ver el catálogo ordenado alfabéticamente por el nombre del representante.

**Precondiciones:**
Existen empresas con diferentes representantes.

**Pasos a seguir:**
1. Ingresar a la página de reporte.
2. Seleccionar 'Representante' en el selector.
3. Revisar el orden de la tabla.

**Resultado esperado:**
Las empresas aparecen ordenadas alfabéticamente por el campo 'representante'.

**Datos de prueba:**
Empresas: X (representante: Ana), Y (representante: Luis), Z (representante: Beatriz).

---



## Casos de Prueba

# Casos de Prueba: Catálogo de Tipos de Empresas

## Caso 1: Consulta por Número de Empresa
- **Entrada:**
  - eRequest: getEmpresasReport
  - params: { opcion: 1 }
- **Acción:**
  - Realizar POST a /api/execute
- **Resultado esperado:**
  - Respuesta JSON con empresas ordenadas por num_empresa ascendente.

## Caso 2: Consulta por Tipo de Empresa
- **Entrada:**
  - eRequest: getEmpresasReport
  - params: { opcion: 2 }
- **Acción:**
  - Realizar POST a /api/execute
- **Resultado esperado:**
  - Respuesta JSON con empresas agrupadas y ordenadas por tipo_empresa, luego num_empresa.

## Caso 3: Consulta por Nombre
- **Entrada:**
  - eRequest: getEmpresasReport
  - params: { opcion: 3 }
- **Acción:**
  - Realizar POST a /api/execute
- **Resultado esperado:**
  - Respuesta JSON con empresas ordenadas por descripcion (nombre), luego num_empresa.

## Caso 4: Consulta por Representante
- **Entrada:**
  - eRequest: getEmpresasReport
  - params: { opcion: 4 }
- **Acción:**
  - Realizar POST a /api/execute
- **Resultado esperado:**
  - Respuesta JSON con empresas ordenadas por representante, luego num_empresa.

## Caso 5: Sin datos en la base
- **Precondición:** Tablas vacías.
- **Acción:**
  - Realizar cualquier consulta.
- **Resultado esperado:**
  - Respuesta JSON con data vacía (array vacío), success=true.

## Caso 6: Parámetro inválido
- **Entrada:**
  - eRequest: getEmpresasReport
  - params: { opcion: 99 }
- **Acción:**
  - Realizar POST a /api/execute
- **Resultado esperado:**
  - Respuesta JSON con data vacía o sin error, success=true.

## Caso 7: eRequest desconocido
- **Entrada:**
  - eRequest: unknownRequest
- **Acción:**
  - Realizar POST a /api/execute
- **Resultado esperado:**
  - Respuesta JSON con success=false y mensaje de error.



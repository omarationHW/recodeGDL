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

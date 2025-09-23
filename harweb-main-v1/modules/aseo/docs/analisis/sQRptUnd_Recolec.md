# Documentación Técnica: Migración de Formulario sQRptUnd_Recolec (Delphi) a Laravel + Vue.js + PostgreSQL

## 1. Descripción General
Este módulo corresponde al catálogo de claves de recolección, originalmente implementado en Delphi como un reporte QuickReport. La migración implementa:
- Backend API en Laravel (endpoint único `/api/execute`)
- Lógica SQL encapsulada en stored procedures PostgreSQL
- Frontend como página Vue.js independiente

## 2. Backend (Laravel)
- **Controlador:** `App\Http\Controllers\Api\ExecuteController`
- **Endpoint:** `POST /api/execute`
- **Patrón:** Recibe un objeto `{ eRequest, params }` y responde `{ eResponse: { success, data, error } }`
- **eRequest soportados:**
  - `get_unidades_recolec`: Consulta el catálogo filtrado por ejercicio y ordenado por campo
  - `get_ejercicios`: Devuelve los ejercicios disponibles para selección
- **Seguridad:** Se recomienda proteger el endpoint con autenticación según la política de la aplicación.

## 3. Stored Procedures (PostgreSQL)
- **sp_get_unidades_recolec**: Devuelve los registros de `ta_16_unidades` filtrados por ejercicio y ordenados dinámicamente por el campo solicitado.
- **Parámetros:**
  - `p_ejercicio` (integer): Ejercicio fiscal
  - `p_order_by` (text): Campo de ordenamiento (`ctrol_recolec`, `cve_recolec`, `descripcion`, `costo_unidad`)
- **Retorno:** Tabla con los campos principales del catálogo.

## 4. Frontend (Vue.js)
- **Componente:** Página independiente, no usa tabs.
- **Funcionalidad:**
  - Selección de ejercicio y criterio de clasificación
  - Consulta y despliegue en tabla
  - Breadcrumb de navegación
  - Mensajes de carga, error y vacío
- **API:** Consume `/api/execute` con los eRequest mencionados

## 5. Flujo de Datos
1. El usuario selecciona ejercicio y clasificación y presiona "Consultar"
2. El frontend envía `{ eRequest: 'get_unidades_recolec', params: { ejercicio, order_by } }` a `/api/execute`
3. Laravel ejecuta el stored procedure y retorna los datos
4. El frontend muestra los resultados en tabla

## 6. Consideraciones
- El endpoint es unificado para facilitar integración y trazabilidad
- El ordenamiento es seguro, validado en backend
- El frontend es responsivo y puede integrarse en cualquier SPA Vue.js

## 7. Extensibilidad
- Se pueden agregar más eRequest en el controlador para futuras funcionalidades
- El stored procedure puede ampliarse para filtros adicionales

## 8. Seguridad
- Validar que los parámetros recibidos sean válidos y no permitan inyección
- Se recomienda agregar autenticación y autorización en producción

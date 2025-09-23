# Documentación Técnica: Migración Formulario consuem400 (Delphi) a Laravel + Vue.js + PostgreSQL

## 1. Descripción General
El formulario consuem400 permite consultar registros históricos del sistema UEM-400 (AS400) a partir de tres parámetros: recaudadora, ur y cuenta. La migración implementa una arquitectura moderna basada en Laravel (backend/API), Vue.js (frontend SPA), y PostgreSQL (base de datos), centralizando la lógica de negocio en stored procedures y exponiendo la funcionalidad a través de un endpoint API unificado.

## 2. Arquitectura
- **Backend:** Laravel 10+, controlador API RESTful, endpoint único `/api/execute`.
- **Frontend:** Vue.js 3+, componente de página independiente, sin tabs.
- **Base de Datos:** PostgreSQL, lógica de consulta encapsulada en stored procedure.
- **Comunicación:** Patrón eRequest/eResponse, entrada y salida JSON.

## 3. API Unificada
- **Endpoint:** `POST /api/execute`
- **Entrada:**
  ```json
  {
    "eRequest": {
      "action": "search",
      "params": {
        "recaud": 1,
        "ur": 0,
        "cuenta": 12345
      }
    }
  }
  ```
- **Salida:**
  ```json
  {
    "eResponse": {
      "success": true,
      "message": "Registros encontrados",
      "data": [ ... ]
    }
  }
  ```

## 4. Backend (Laravel)
- **Controlador:** `Consuem400Controller`
- **Métodos:**
  - `execute(Request $request)`: Recibe la acción y parámetros, ejecuta la lógica correspondiente.
  - Soporta acciones: `search` (consulta), `close` (cierre de sesión/limpieza frontend).
- **Seguridad:**
  - Validación de parámetros.
  - Manejo de errores y mensajes claros.
- **Llamada a base de datos:**
  - Utiliza DB::select para ejecutar la consulta parametrizada.
  - Puede adaptarse para llamar el stored procedure PostgreSQL si se requiere.

## 5. Frontend (Vue.js)
- **Componente:** `Consuem400Page.vue`
- **Características:**
  - Página independiente, sin tabs.
  - Formulario con tres campos: recaud, ur, cuenta.
  - Botón Buscar, validación básica.
  - Tabla de resultados dinámica (columnas automáticas).
  - Mensajes de éxito/error.
  - Breadcrumb de navegación.
- **UX:**
  - Navegación por enter entre campos.
  - Mensajes claros y tabla responsive.

## 6. Stored Procedure (PostgreSQL)
- **Nombre:** `sp_consume400_search`
- **Entradas:** `p_recaud integer, p_ur integer, p_cuenta integer`
- **Salida:** Tabla con todos los campos de la tabla `historico`.
- **Ventajas:**
  - Encapsula la lógica de consulta.
  - Permite reutilización y seguridad.

## 7. Flujo de Datos
1. Usuario ingresa parámetros y presiona Buscar.
2. Vue.js envía petición POST a `/api/execute` con acción `search` y parámetros.
3. Laravel recibe la petición, valida y ejecuta la consulta (directa o vía SP).
4. Devuelve los resultados en formato JSON.
5. Vue.js muestra los resultados en tabla.

## 8. Consideraciones de Seguridad
- Validación de parámetros en backend.
- Sanitización de entrada.
- Manejo de errores controlado.
- (Opcional) Autenticación JWT o session para acceso restringido.

## 9. Extensibilidad
- El endpoint `/api/execute` puede ampliarse para soportar más acciones (CRUD, reportes, etc).
- El frontend puede adaptarse para otros formularios siguiendo el mismo patrón.

## 10. Migración de Datos
- Se asume que la tabla `historico` ya existe en PostgreSQL y contiene los mismos campos que en el sistema original.
- Si hay diferencias de tipos de datos, ajustar el SP y el modelo de datos.

## 11. Pruebas
- Ver sección de Casos de Uso y Casos de Prueba.

# Documentación Técnica: Migración Formulario Cons_Cves_operacion (Delphi) a Laravel + Vue.js + PostgreSQL

## 1. Arquitectura General
- **Backend:** Laravel (PHP 8+), API RESTful, endpoint único `/api/execute` (patrón eRequest/eResponse)
- **Frontend:** Vue.js (SPA, componente de página independiente)
- **Base de Datos:** PostgreSQL, lógica de negocio en stored procedures
- **Seguridad:** Validación de entrada, control de errores, protección contra SQL Injection

## 2. API Unificada (eRequest/eResponse)
- **Endpoint:** `POST /api/execute`
- **Request:**
  ```json
  {
    "eRequest": {
      "action": "list|create|update|delete|export_excel",
      "data": { ... }
    }
  }
  ```
- **Response:**
  ```json
  {
    "eResponse": {
      "status": "success|error",
      "message": "Mensaje de resultado",
      "data": [ ... ]
    }
  }
  ```

## 3. Controlador Laravel
- **Métodos:**
  - `list`: Devuelve listado de claves de operación, ordenado por campo solicitado
  - `create`: Inserta nueva clave (llama SP)
  - `update`: Actualiza descripción (llama SP)
  - `delete`: Elimina clave si no tiene pagos (llama SP)
  - `export_excel`: (Placeholder, no implementado en API)
- **Validaciones:**
  - Todos los campos requeridos
  - Sanitización de ordenamiento
  - Manejo de errores y mensajes claros

## 4. Componente Vue.js
- **Página independiente** (NO tabs)
- **Funcionalidad:**
  - Listado con orden dinámico
  - Crear, editar, eliminar (modales)
  - Exportar Excel (placeholder)
  - Navegación breadcrumb
  - Mensajes de error y éxito
- **UX:**
  - Botones claros, validación en formulario
  - Modal para crear/editar, confirmación para eliminar

## 5. Stored Procedures PostgreSQL
- **sp16_operacion_create:** Inserta clave, valida unicidad y nulos
- **sp16_operacion_update:** Actualiza descripción por ctrol_operacion
- **sp16_operacion_delete:** Borra clave si no tiene pagos asociados
- **Todos devuelven:** status (0=ok, 1=error), leyenda

## 6. Seguridad
- **API:**
  - Validación de parámetros
  - Sanitización de campos de orden
  - Manejo de errores controlado
- **SP:**
  - Validación de existencia y unicidad
  - Mensajes claros de error

## 7. Integración
- **Frontend** llama a `/api/execute` con acción y datos
- **Backend** enruta a SP correspondiente y retorna resultado
- **Frontend** actualiza UI según respuesta

## 8. Exportación a Excel
- **Nota:**
  - En la API no se implementa exportación real (por seguridad y alcance)
  - Puede implementarse en backend o frontend según requerimiento futuro

## 9. Pruebas y Casos de Uso
- Ver sección de casos de uso y pruebas para ejemplos detallados

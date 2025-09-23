# Documentación Técnica: Migración Formulario consdesc (Delphi) a Laravel + Vue.js + PostgreSQL

## 1. Descripción General
Este módulo corresponde a la consulta de descuentos prediales (formulario consdesc de Delphi) migrado a una arquitectura moderna:
- **Backend:** Laravel (PHP) + PostgreSQL
- **Frontend:** Vue.js SPA (Single Page Application)
- **API:** Unificada bajo endpoint `/api/execute` usando patrón eRequest/eResponse
- **Base de datos:** PostgreSQL, lógica SQL en stored procedures

## 2. Arquitectura
- **API Unificada:** Todas las operaciones (listado, búsqueda, catálogo, detalle) se ejecutan vía POST `/api/execute` con un objeto `eRequest` que indica la acción y los parámetros.
- **Controlador Laravel:** Un solo controlador (`ConsDescController`) que enruta la acción y ejecuta la lógica correspondiente, llamando a los stored procedures de PostgreSQL.
- **Stored Procedures:** Toda la lógica de consulta reside en funciones SQL en PostgreSQL, optimizadas para filtros y paginación.
- **Frontend Vue.js:** Página independiente, sin tabs, con búsqueda avanzada, tabla de resultados y modal de detalle.

## 3. API eRequest/eResponse
- **Endpoint:** `/api/execute`
- **Método:** POST
- **Entrada:**
  ```json
  {
    "eRequest": {
      "action": "list|search|instituciones|detalle",
      "params": { ... }
    }
  }
  ```
- **Salida:**
  ```json
  {
    "eResponse": {
      "status": "success|error",
      "data": [ ... ],
      "message": "..."
    }
  }
  ```

## 4. Stored Procedures
- **sp_consdesc_list:** Listado general de descuentos, con filtros opcionales (recaud, cuenta, propietario)
- **sp_consdesc_search:** Búsqueda avanzada (propietario, folio, recaud, identificación, solicitante, institución)
- **sp_consdesc_instituciones:** Catálogo de instituciones
- **sp_consdesc_detalle:** Detalle de descuento por folio

## 5. Seguridad
- Todas las consultas usan parámetros para evitar SQL Injection.
- El endpoint `/api/execute` puede protegerse con middleware de autenticación Laravel.

## 6. Frontend Vue.js
- Página independiente, sin tabs ni componentes tabulares.
- Formulario de búsqueda avanzada.
- Tabla de resultados con paginación (si se requiere, agregar en el futuro).
- Modal de detalle para cada descuento.
- Navegación breadcrumb opcional.

## 7. Consideraciones de Migración
- Los queries Delphi se migran a funciones SQL en PostgreSQL.
- Los DataSource y DBGrid se reemplazan por llamadas AJAX y tablas HTML.
- Los combos de instituciones se llenan vía API.
- El endpoint es único y flexible para futuras acciones.

## 8. Ejemplo de eRequest
```json
{
  "eRequest": {
    "action": "search",
    "params": {
      "propi": "JUAN PEREZ",
      "foliodesc": "12345"
    }
  }
}
```

## 9. Extensibilidad
- Se pueden agregar acciones (alta, baja, modificación) siguiendo el mismo patrón.
- El frontend puede crecer a otras páginas independientes.

## 10. Pruebas y Validación
- Se recomienda usar Postman para probar el endpoint `/api/execute`.
- El frontend Vue.js puede probarse con Jest o Cypress.

---

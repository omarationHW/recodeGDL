# Documentación Técnica: Migración de Formulario Reactiva_Folios (Delphi) a Laravel + Vue.js + PostgreSQL

## 1. Descripción General
Este módulo permite reactivar folios migrando registros de la tabla histórica (`ta14_folios_histo`) a la tabla de adeudos (`ta14_folios_adeudo`) y eliminando los registros correspondientes en las tablas históricas y de condonados. El proceso puede realizarse buscando por Placa+Folio o Año+Folio.

## 2. Arquitectura
- **Frontend:** Vue.js (SPA, página independiente)
- **Backend:** Laravel (API RESTful, endpoint unificado `/api/execute`)
- **Base de Datos:** PostgreSQL (lógica encapsulada en stored procedures)

## 3. Flujo de Trabajo
1. El usuario selecciona el tipo de búsqueda (Placa+Folio o Año+Folio) y proporciona los datos requeridos.
2. El frontend llama a `/api/execute` con `eRequest: 'reactiva_folios_buscar'` para validar la existencia del folio.
3. Si existe, el frontend llama a `/api/execute` con `eRequest: 'reactiva_folios_aplicar'` para ejecutar la reactivación.
4. El backend ejecuta el stored procedure correspondiente y retorna el resultado en `eResponse`.

## 4. API Unificada
- **Endpoint:** `/api/execute`
- **Método:** POST
- **Body:**
  ```json
  {
    "eRequest": "reactiva_folios_aplicar|reactiva_folios_buscar",
    "params": { ... }
  }
  ```
- **Respuesta:**
  ```json
  {
    "eResponse": {
      "success": true|false,
      "message": "...",
      "data": [ ... ]
    }
  }
  ```

## 5. Stored Procedures
- **sp_reactiva_folios_buscar:** Busca el folio en la tabla histórica según los parámetros.
- **sp_reactiva_folios_aplicar:** Realiza la migración del folio de histórico a adeudo y elimina los registros relacionados.

## 6. Validaciones
- El frontend valida que los campos requeridos estén completos según el tipo de búsqueda.
- El backend valida la existencia del folio antes de aplicar la reactivación.
- Todas las operaciones críticas se realizan dentro de una transacción en el stored procedure.

## 7. Seguridad
- El endpoint `/api/execute` debe estar protegido por autenticación (ej. JWT o sesión Laravel).
- Los parámetros son validados y sanitizados en el backend.

## 8. Manejo de Errores
- Los errores de negocio y de base de datos se retornan en el campo `message` de `eResponse`.
- El frontend muestra mensajes claros al usuario.

## 9. Pruebas
- Se incluyen casos de uso y escenarios de prueba para validar la funcionalidad y los errores.

## 10. Navegación
- El componente Vue es una página independiente, con breadcrumbs y sin tabs.

---

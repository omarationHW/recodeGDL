# Documentación Técnica: Migración de Formulario Mannto_Zonas (Delphi) a Laravel + Vue.js + PostgreSQL

## 1. Arquitectura General
- **Backend:** Laravel 10+ (PHP 8), API RESTful, endpoint único `/api/execute` (patrón eRequest/eResponse)
- **Frontend:** Vue.js 3 SPA, cada formulario es una página independiente (NO tabs)
- **Base de Datos:** PostgreSQL 13+, lógica de negocio en stored procedures
- **Seguridad:** Validación de datos en backend y frontend, manejo de errores unificado

## 2. API Unificada (eRequest/eResponse)
- **Endpoint:** `POST /api/execute`
- **Request:**
  ```json
  {
    "action": "ZONAS_CREATE", // o ZONAS_LIST, ZONAS_UPDATE, ZONAS_DELETE, ZONAS_GET
    "payload": { ... }
  }
  ```
- **Response:**
  ```json
  {
    "success": true|false,
    "data": [ ... ],
    "message": "Mensaje de error o éxito"
  }
  ```

## 3. Métodos soportados
- `ZONAS_LIST`: Listar todas las zonas
- `ZONAS_GET`: Obtener una zona específica (por zona y sub_zona)
- `ZONAS_CREATE`: Alta de zona
- `ZONAS_UPDATE`: Modificación de zona
- `ZONAS_DELETE`: Baja de zona (solo si no tiene empresas dependientes)
- `ZONAS_EMPRESA_DEPENDENCY`: Consulta de empresas dependientes de una zona

## 4. Validaciones
- **Zona y Sub-Zona**: Requeridos, numéricos, únicos en combinación
- **Descripción**: Requerida, máximo 80 caracteres
- **No se puede eliminar una zona si existen empresas con esa zona**

## 5. Stored Procedures
- Toda la lógica de inserción, actualización y borrado está en stored procedures PostgreSQL:
  - `sp_zonas_create(zona, sub_zona, descripcion)`
  - `sp_zonas_update(zona, sub_zona, descripcion)`
  - `sp_zonas_delete(ctrol_zona)`

## 6. Frontend (Vue.js)
- Página independiente `/catalogo/zonas`
- Tabla de zonas con acciones de editar y eliminar
- Formulario modal para alta/edición
- Confirmación modal para eliminación
- Mensajes de error y éxito
- Navegación breadcrumb

## 7. Seguridad y Manejo de Errores
- Validación en backend y frontend
- Mensajes claros en caso de error (por ejemplo, si la zona ya existe o tiene dependencias)
- Todas las operaciones son transaccionales

## 8. Pruebas y Casos de Uso
- Casos de uso y pruebas detalladas para alta, edición, eliminación y validación de dependencias

## 9. Extensibilidad
- El patrón eRequest/eResponse permite agregar nuevas acciones fácilmente
- Los stored procedures pueden ser versionados y auditados

## 10. Consideraciones de Migración
- El campo `ctrol_zona` es autoincremental (serial) en PostgreSQL
- Las validaciones de negocio (existencia, dependencias) se trasladan a los stored procedures
- El frontend no usa tabs ni componentes tabulares: cada formulario es una página

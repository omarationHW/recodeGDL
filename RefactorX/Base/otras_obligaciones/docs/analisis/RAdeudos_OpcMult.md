# Documentación Técnica: Migración de Formulario RAdeudos_OpcMult

## 1. Arquitectura General
- **Backend**: Laravel 10+, PostgreSQL
- **Frontend**: Vue.js 3 (SPA, página independiente)
- **API**: Endpoint único `/api/execute` usando patrón eRequest/eResponse
- **Base de Datos**: PostgreSQL, lógica de negocio en stored procedures

## 2. API Unificada
- **Endpoint**: `POST /api/execute`
- **Entrada**: `{ eRequest: { action: string, params: object } }`
- **Salida**: `{ eResponse: { ... } }`
- **Acciones soportadas**:
  - `search_local`: Busca local por número y letra
  - `get_adeudos`: Obtiene adeudos por id_datos
  - `execute_opc`: Ejecuta la opción seleccionada sobre los adeudos marcados
  - `get_recaudadoras`: Catálogo de recaudadoras
  - `get_cajas`: Catálogo de cajas

## 3. Stored Procedures
- Toda la lógica de negocio (consultas y procesos) se implementa en stored procedures PostgreSQL.
- Ejemplo: `con34_rdetade_021` para obtener adeudos, `upd34_ade_01` para actualizar status.

## 4. Frontend (Vue.js)
- Página independiente, sin tabs.
- Permite buscar local, mostrar datos, listar adeudos, seleccionar y ejecutar opción.
- Navegación simple, breadcrumbs opcional.
- Validaciones en frontend y backend.

## 5. Seguridad
- Validación de parámetros en backend.
- Transacciones en procesos críticos (ejecución de opciones).
- Manejo de errores y mensajes claros para el usuario.

## 6. Pruebas
- Casos de uso y escenarios de prueba detallados.
- Pruebas de integración frontend-backend.

## 7. Extensibilidad
- El endpoint `/api/execute` puede ampliarse para soportar más acciones.
- Los stored procedures pueden evolucionar sin afectar la interfaz API.

## 8. Consideraciones
- El frontend asume que el usuario tiene permisos para ejecutar las acciones.
- El backend puede auditar las operaciones si se requiere.

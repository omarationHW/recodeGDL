# Documentación Técnica: Migración Formulario reghfrm (Delphi) a Laravel + Vue.js + PostgreSQL

## 1. Descripción General
El formulario `reghfrm` permite consultar el historial de movimientos (históricos) de una cuenta catastral. La migración implementa:
- Un endpoint API unificado `/api/execute` (Laravel Controller)
- Un componente Vue.js de página completa (sin tabs)
- Stored Procedures en PostgreSQL para toda la lógica de consulta
- Patrón eRequest/eResponse para la API

## 2. Arquitectura
- **Backend**: Laravel 10+, PostgreSQL 13+
- **Frontend**: Vue.js 2/3 compatible, Axios para llamadas API
- **API**: Único endpoint `/api/execute` que recibe un objeto `eRequest` y responde con `eResponse`
- **Base de datos**: Todas las consultas históricas se resuelven vía stored procedures

## 3. API Unificada
- **Endpoint**: `/api/execute`
- **Método**: POST
- **Entrada**:
  ```json
  {
    "eRequest": {
      "action": "list|show|search|filter|history",
      "params": { ... }
    }
  }
  ```
- **Salida**:
  ```json
  {
    "eResponse": {
      "success": true|false,
      "data": [...],
      "message": "..."
    }
  }
  ```

## 4. Stored Procedures
- Todas las consultas históricas se resuelven mediante funciones SQL en PostgreSQL.
- Los procedimientos aceptan parámetros y devuelven tablas (RETURNS TABLE)
- Los procedimientos de búsqueda y filtrado aceptan parámetros JSON para máxima flexibilidad

## 5. Laravel Controller
- El controlador `RegHfrmController` expone el método `execute` que despacha según el campo `action`.
- Cada acción llama a un stored procedure específico usando DB::select
- El controlador valida parámetros y estructura la respuesta en el patrón eResponse

## 6. Vue.js Component
- Página independiente `/reghfrm` (ejemplo de ruta)
- Permite ingresar el número de cuenta y consultar el historial
- Muestra tabla de movimientos históricos
- Permite ver detalle de cada movimiento
- Usa Axios para consumir la API
- Incluye breadcrumbs y mensajes de error/carga

## 7. Seguridad
- El endpoint debe protegerse con autenticación JWT o sesión Laravel
- Los parámetros deben validarse y sanearse
- Los stored procedures sólo permiten lectura

## 8. Extensibilidad
- El patrón eRequest/eResponse permite agregar nuevas acciones sin cambiar el endpoint
- Los stored procedures pueden ampliarse para nuevos filtros o reportes

## 9. Consideraciones de Migración
- El formulario Delphi usaba un DBGrid vinculado a la tabla `h_catastro` (histórico de catastro)
- La migración respeta los campos principales: año (`axocomp`), número de comprobante (`nocomp`), tipo de movimiento (`cvemov`), fecha de captura (`feccap`), capturista, observación, vigente
- No se migran acciones de edición/eliminación (sólo consulta)

## 10. Ejemplo de Uso
- El usuario ingresa el número de cuenta catastral
- El sistema muestra el historial de movimientos
- El usuario puede ver el detalle de cada movimiento

---

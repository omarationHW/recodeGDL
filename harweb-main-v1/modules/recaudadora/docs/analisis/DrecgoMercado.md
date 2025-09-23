# Documentación Técnica: Migración de Formulario DrecgoMercado (Delphi) a Laravel + Vue.js + PostgreSQL

## 1. Descripción General
Este módulo permite la gestión de descuentos de recargos para locales de mercados municipales. Incluye:
- Consulta de locales y sus adeudos.
- Alta y cancelación de descuentos de recargos.
- Consulta de recaudadoras, mercados, secciones y funcionarios autorizados.
- Validación de permisos y reglas de negocio.

## 2. Arquitectura
- **Backend:** Laravel Controller con endpoint único `/api/execute` (API Unificada, patrón eRequest/eResponse).
- **Frontend:** Componente Vue.js como página independiente.
- **Base de Datos:** PostgreSQL, lógica de negocio en stored procedures.

## 3. API Unificada
- **Endpoint:** `POST /api/execute`
- **Request:**
  ```json
  {
    "action": "nombreAccion",
    "params": { ... }
  }
  ```
- **Response:**
  ```json
  {
    "data": ...,
    "success": true|false,
    "error": "mensaje"
  }
  ```

### Acciones soportadas
- `buscarLocal`: Busca local en el mercado con filtros.
- `consultarDescuento`: Consulta descuentos vigentes para un local.
- `altaDescuento`: Aplica un descuento de recargos.
- `cancelarDescuento`: Cancela un descuento vigente.
- `consultarRecaudadoras`, `consultarMercados`, `consultarSecciones`, `consultarFuncionarios`: Catálogos auxiliares.

## 4. Validaciones y Seguridad
- El backend valida que el usuario tenga permisos para aplicar/cancelar descuentos.
- El porcentaje de descuento no puede exceder el tope del funcionario autorizado.
- No se permite aplicar descuentos a locales sin adeudo vencido, conveniados o bloqueados.

## 5. Stored Procedure
- Toda la lógica de inserción/cancelación de descuentos está en el SP `sp_ins_recarmerc`.
- El SP asegura atomicidad y reglas de negocio.

## 6. Frontend
- El componente Vue.js es una página completa, sin tabs.
- Permite búsqueda, visualización y alta/cancelación de descuentos.
- Muestra mensajes de error y éxito.

## 7. Consideraciones
- El endpoint `/api/execute` debe estar protegido por autenticación (JWT/Sanctum).
- El usuario autenticado se utiliza para registrar quién aplica/cancela descuentos.
- El frontend debe manejar correctamente los estados de error y éxito.

## 8. Migración de Queries
- Todas las queries Delphi se migraron a SQL parametrizado en Laravel y SP en PostgreSQL.
- Los catálogos se consultan vía API.

## 9. Pruebas
- Se deben probar los escenarios de alta, cancelación y consulta de descuentos, así como validaciones de reglas de negocio.


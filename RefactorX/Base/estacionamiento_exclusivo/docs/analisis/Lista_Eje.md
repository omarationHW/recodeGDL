# Documentación Técnica: Migración Formulario Lista_Eje (Delphi) a Laravel + Vue.js + PostgreSQL

## 1. Descripción General
Este módulo corresponde al catálogo de ejecutores fiscales. Permite consultar, filtrar (vigentes/todos), imprimir y exportar la lista de ejecutores. La migración se realiza a una arquitectura Laravel (backend/API), Vue.js (frontend SPA), y PostgreSQL (base de datos).

## 2. Arquitectura
- **Backend**: Laravel 10+ (PHP 8), expone un endpoint único `/api/execute` que recibe un objeto eRequest con acción y parámetros.
- **Frontend**: Vue.js 3 SPA, cada formulario es una página independiente (no tabs), navegación por rutas.
- **Base de datos**: PostgreSQL, toda la lógica SQL encapsulada en stored procedures (SPs).

## 3. API Unificada
- **Endpoint**: `/api/execute` (POST)
- **Entrada**: `{ action: string, params: object }`
- **Salida**: `{ status: 'success'|'error', data: any, message: string }`
- **Patrón**: eRequest/eResponse

### Acciones soportadas para Lista_Eje
- `get_lista_eje`: Obtiene la lista de ejecutores. Parámetros: `{ rec: int, rec1: int, vigentes: bool }`
- `export_lista_eje_excel`: Exporta la lista a Excel (simulado en este ejemplo)
- `print_lista_eje`: Genera impresión (simulado)

## 4. Stored Procedures
Toda la lógica de consulta se encapsula en SPs. Ejemplo:
- `sp_lista_eje_get(p_rec int, p_rec1 int)`

## 5. Frontend (Vue.js)
- Página independiente `/catalogos/ejecutores`.
- Tabla con todos los campos relevantes.
- Filtros: Todos/Vigentes (radio buttons).
- Botones: Imprimir, Exportar Excel, Salir.
- Navegación: Cada formulario es una página, no tabs.

## 6. Seguridad
- El endpoint `/api/execute` debe estar protegido por autenticación JWT o session según la política de la aplicación.
- Los parámetros recibidos deben ser validados en el backend.

## 7. Exportación e Impresión
- Exportación a Excel puede implementarse con [maatwebsite/excel](https://docs.laravel-excel.com/) en Laravel.
- Impresión puede ser PDF o impresión directa desde el navegador (simulado en este ejemplo).

## 8. Consideraciones de Migración
- Los filtros Delphi (filtered, Filter) se implementan en el frontend (Vue) o en el SP según el caso.
- Los procedimientos de impresión/exportación se simulan en este ejemplo, pero pueden implementarse según los requerimientos reales.
- El endpoint es extensible para otras acciones del sistema.

## 9. Pruebas y Casos de Uso
- Se proveen casos de uso y escenarios de prueba para asegurar la funcionalidad y migración correcta.

## 10. Extensibilidad
- El patrón eRequest/eResponse permite agregar nuevas acciones sin modificar la estructura del endpoint.
- Los SPs pueden ser versionados y auditados en la base de datos.

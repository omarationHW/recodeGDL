# Documentación Técnica: Migración Rep_Tipos_Aseo (Delphi → Laravel + Vue.js + PostgreSQL)

## 1. Descripción General
Este módulo implementa la funcionalidad de impresión y consulta de Tipos de Aseo, migrando el formulario Delphi `Rep_Tipos_Aseo` a una arquitectura moderna basada en Laravel (backend/API), Vue.js (frontend SPA) y PostgreSQL (base de datos y lógica de negocio).

## 2. Arquitectura
- **Backend**: Laravel Controller expone un endpoint único `/api/execute` que recibe peticiones eRequest/eResponse.
- **Frontend**: Componente Vue.js como página independiente, sin tabs, con navegación breadcrumb y tabla de resultados.
- **Base de Datos**: Toda la lógica SQL se encapsula en stored procedures PostgreSQL.

## 3. API Unificada (eRequest/eResponse)
- **Endpoint**: `POST /api/execute`
- **Request**:
  ```json
  {
    "action": "getTiposAseoReport",
    "params": { "order": 1 }
  }
  ```
- **Response**:
  ```json
  {
    "success": true,
    "data": [ { "ctrol_aseo": 1, "tipo_aseo": "O", "descripcion": "Ordinario" }, ... ],
    "message": ""
  }
  ```

## 4. Stored Procedure
- **sp_rep_tipos_aseo_report(order)**: Devuelve el listado de tipos de aseo ordenado por Control, Tipo o Descripción según parámetro.
- **Parámetro**: `order` (1=Control, 2=Tipo, 3=Descripción)
- **Retorno**: Tabla con columnas `ctrol_aseo`, `tipo_aseo`, `descripcion`.

## 5. Frontend (Vue.js)
- Página independiente `/rep-tipos-aseo`.
- Permite seleccionar el orden del reporte (Control, Tipo, Descripción).
- Botón "Vista Previa" ejecuta la consulta y muestra los resultados en tabla.
- Botón "Salir" regresa a la página anterior.
- Breadcrumb para navegación.
- Mensajes de error y loading.

## 6. Backend (Laravel)
- Controlador `RepTiposAseoController` con método `execute`.
- Llama al stored procedure vía DB::select.
- Soporta acciones:
  - `getTiposAseoReport` (principal)
  - `getTiposAseoOptions` (para combos, si se requiere)
- Manejo de errores y logging.

## 7. Seguridad
- El endpoint debe estar protegido por autenticación (middleware Laravel).
- Validar que el parámetro `order` sea 1, 2 o 3.

## 8. Extensibilidad
- El patrón eRequest/eResponse permite agregar nuevas acciones sin crear nuevos endpoints.
- El frontend puede extenderse para exportar a Excel, imprimir, etc.

## 9. Consideraciones de Migración
- El reporte QuickReport de Delphi se reemplaza por una tabla HTML en Vue.js.
- No se implementa impresión directa; para impresión avanzada, se recomienda exportar a PDF o usar librerías JS.
- No se usan tabs ni componentes tabulares: cada formulario es una página independiente.

## 10. Ejemplo de Uso
- El usuario accede a `/rep-tipos-aseo`, selecciona el orden, pulsa "Vista Previa" y ve el listado ordenado.


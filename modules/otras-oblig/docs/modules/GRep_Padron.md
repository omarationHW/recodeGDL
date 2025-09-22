# Documentación Técnica: Migración de Formulario GRep_Padron (Delphi) a Laravel + Vue.js + PostgreSQL

## 1. Arquitectura General
- **Backend:** Laravel 10+ (API RESTful, endpoint único `/api/execute`)
- **Frontend:** Vue.js 3 (SPA, cada formulario es una página independiente)
- **Base de Datos:** PostgreSQL 13+ (Stored Procedures para lógica de negocio)
- **Patrón API:** eRequest/eResponse (todas las acciones por un solo endpoint, discriminadas por `action` y `params`)

## 2. Endpoint API Unificado
- **Ruta:** `POST /api/execute`
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
    "success": true|false,
    "data": [ ... ],
    "message": "..."
  }
  ```

## 3. Controlador Laravel
- **Archivo:** `app/Http/Controllers/Api/ExecuteController.php`
- **Métodos:**
  - `getPadronConAdeudos`: Llama a `sp34_padron` para obtener el padrón filtrado.
  - `getPadronAdeudosDetalle`: Llama a `con34_gdetade_01` para obtener detalle de adeudos.
  - `getVigenciasConcesion`: Llama a `sp34_vigencias_concesion` para obtener vigencias.
  - `getEtiquetasTabla`: Llama a `sp34_etiq_tabla` para obtener etiquetas.
  - `getNombreTabla`: Llama a `sp34_nombre_tabla` para obtener el nombre del rubro.
- **Manejo de errores:** Devuelve `success: false` y mensaje de error en caso de excepción.

## 4. Stored Procedures PostgreSQL
- **sp34_padron:** Devuelve el padrón de concesiones con adeudos según tabla y vigencia.
- **con34_gdetade_01:** Devuelve el detalle de adeudos de una concesión.
- **sp34_vigencias_concesion:** Devuelve las vigencias disponibles para la tabla.
- **sp34_etiq_tabla:** Devuelve las etiquetas de la tabla para los encabezados.
- **sp34_nombre_tabla:** Devuelve el nombre del rubro/tabla.

## 5. Componente Vue.js
- **Archivo:** `PadronConAdeudosPage.vue`
- **Características:**
  - Página independiente (no tab)
  - Formulario de filtros (vigencia, periodo, año, mes)
  - Tabla de resultados (padrón)
  - Detalle de adeudos por concesión (modal o sección expandible)
  - Botón de impresión (usa `window.print()`)
  - Breadcrumb de navegación
  - Manejo de loading y errores
  - Filtros de moneda

## 6. Flujo de Datos
1. Al cargar la página, se consultan nombre de tabla, etiquetas y vigencias.
2. Al buscar, se consulta el padrón según filtros.
3. Al ver detalle, se consulta el detalle de adeudos para la concesión y periodo.
4. Todo se realiza vía `/api/execute` con la acción correspondiente.

## 7. Seguridad
- Validar y sanitizar todos los parámetros recibidos en el backend.
- Limitar acceso a usuarios autenticados (middleware Laravel, no incluido aquí).

## 8. Consideraciones
- Los nombres de los stored procedures y parámetros deben coincidir exactamente con los usados en el frontend y backend.
- El frontend debe manejar correctamente los estados de carga y error.
- El endpoint único permite fácil extensión para otros formularios.

## 9. Ejemplo de Request/Response
### Obtener padrón:
```json
{
  "action": "getPadronConAdeudos",
  "params": { "par_tabla": 3, "par_vigencia": "TODOS" }
}
```
### Obtener detalle:
```json
{
  "action": "getPadronAdeudosDetalle",
  "params": { "par_tab": 3, "par_control": 123, "par_rep": "V", "par_fecha": "2024-06" }
}
```

## 10. Extensión
- Para agregar nuevos formularios, basta con agregar nuevas acciones y stored procedures, y crear el componente Vue correspondiente.

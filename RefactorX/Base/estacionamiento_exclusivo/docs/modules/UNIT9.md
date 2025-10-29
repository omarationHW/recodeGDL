# Documentación Técnica: Migración de Formulario UNIT9 (Delphi) a Laravel + Vue.js + PostgreSQL

## 1. Descripción General
El formulario UNIT9 de Delphi es una vista previa de reportes con navegación de páginas, zoom, carga/guardado de reportes y simulación de impresión. La migración implementa:
- Backend: Laravel (API unificada /api/execute, patrón eRequest/eResponse)
- Frontend: Vue.js (componente de página completa, navegación tipo breadcrumb)
- Base de datos: PostgreSQL (stored procedures y tabla de archivos simulada)

## 2. API Unificada
- **Endpoint:** `/api/execute`
- **Método:** POST
- **Entrada:** JSON `{ eRequest: string, params?: object }`
- **Salida:** JSON `{ eResponse: { success, data, message } }`

### eRequest soportados:
- `UNIT9_REPORT_PREVIEW`: Obtiene la vista previa del reporte (simulado)
- `UNIT9_REPORT_LOAD`: Carga un reporte guardado (`params: { filename }`)
- `UNIT9_REPORT_SAVE`: Guarda el reporte actual (`params: { filename, report_data }`)
- `UNIT9_REPORT_PRINT`: Simula la impresión del reporte

## 3. Stored Procedures
- **sp_unit9_report_preview:** Devuelve páginas de ejemplo (simulación de reporte)
- **sp_unit9_report_load:** Carga un reporte guardado desde la tabla `unit9_reports`
- **sp_unit9_report_save:** Guarda o actualiza un reporte en la tabla `unit9_reports`
- **sp_unit9_report_print:** Simula la impresión (solo mensaje)

### Tabla de apoyo
```sql
CREATE TABLE IF NOT EXISTS unit9_reports (
  id serial PRIMARY KEY,
  file_name text UNIQUE NOT NULL,
  report_data text NOT NULL, -- JSON serializado
  created_at timestamp,
  updated_at timestamp
);
```

## 4. Vue.js Componente
- Página completa, sin tabs.
- Barra de navegación (breadcrumb).
- Botones para navegación de páginas, zoom, cargar/guardar, imprimir y cerrar.
- Modal para ingresar nombre de archivo al cargar/guardar.
- Preview de páginas usando HTML recibido del backend.

## 5. Controlador Laravel
- Un solo método `execute` que despacha según `eRequest`.
- Llama a los stored procedures y retorna el resultado en formato eResponse.

## 6. Seguridad
- Validación de parámetros en backend.
- No se permite acceso a archivos fuera de la tabla simulada.

## 7. Consideraciones
- La lógica de preview, navegación, zoom y carga/guardado es simulada (no hay motor de reportes real).
- La impresión es simulada (mensaje o impresión del navegador).

## 8. Extensión
- Para un motor de reportes real, reemplazar los SP y lógica de preview por integración con el motor deseado.

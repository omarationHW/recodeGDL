# Documentación Técnica: Migración Formulario Rep_Zonas (Delphi) a Laravel + Vue.js + PostgreSQL

## 1. Descripción General
El formulario **Rep_Zonas** permite generar un reporte de las zonas registradas en el sistema, ordenadas por diferentes criterios (Control, Zona, Sub-Zona, Descripción). La migración implica:
- Backend en Laravel (API RESTful, endpoint único `/api/execute`)
- Frontend en Vue.js (componente de página independiente)
- Lógica de consulta/reportes en stored procedures PostgreSQL
- Comunicación bajo patrón eRequest/eResponse

## 2. Arquitectura
- **Backend**: Laravel Controller (`RepZonasController`) con endpoint `/api/execute`.
- **Frontend**: Componente Vue.js (`RepZonasPage.vue`) como página completa.
- **Base de Datos**: Stored Procedures en PostgreSQL para lógica de consulta y reporte.
- **API**: Único endpoint `/api/execute` que recibe `{ eRequest: { action, params } }` y responde `{ eResponse: { success, data, message } }`.

## 3. Detalle de Componentes
### 3.1. Laravel Controller
- **Método principal**: `execute(Request $request)`
- **Acciones soportadas**:
    - `getZonas`: Devuelve la lista de zonas ordenadas según parámetro `order` (1=Control, 2=Zona, 3=Sub-Zona, 4=Descripción)
    - `getZonasReport`: Devuelve el reporte de zonas (idéntico a getZonas, pero pensado para vista previa/impresión)
- **Llama a los stored procedures** usando DB::select
- **Manejo de errores** y logging

### 3.2. Vue.js Component
- Página independiente `/rep-zonas`
- Permite seleccionar el criterio de orden (radio group)
- Botón "Vista Previa" ejecuta la consulta y muestra el reporte en tabla
- Botón "Salir" regresa al menú principal
- Muestra mensajes de carga y error
- No usa tabs ni componentes tabulares anidados

### 3.3. Stored Procedures PostgreSQL
- `sp_rep_zonas_get(p_order smallint)`: Devuelve zonas ordenadas
- `sp_rep_zonas_report(p_order smallint)`: Devuelve zonas ordenadas (idéntico, pero separado para lógica de reportes si se requiere en el futuro)
- Ambos usan EXECUTE dynamic SQL para permitir orden flexible

### 3.4. API Unificada
- Endpoint: `/api/execute`
- Entrada: `{ eRequest: { action: string, params: object } }`
- Salida: `{ eResponse: { success: bool, data: any, message: string } }`
- Todas las acciones de Rep_Zonas se canalizan por este endpoint

## 4. Seguridad
- Validación de parámetros en backend
- Manejo de errores y logging
- El endpoint debe estar protegido por autenticación (middleware Laravel)

## 5. Navegación y UX
- Cada formulario es una página independiente
- Breadcrumb para navegación
- Botón "Salir" regresa al menú principal
- Tabla de resultados sólo aparece tras ejecutar la consulta

## 6. Pruebas y Casos de Uso
- Ver sección de casos de uso y casos de prueba

## 7. Extensibilidad
- El patrón eRequest/eResponse permite agregar nuevas acciones fácilmente
- Los stored procedures pueden extenderse para filtros adicionales

## 8. Notas de Migración
- El reporte visual (QuickReport) se reemplaza por tabla HTML en la vista previa
- Para impresión avanzada, se recomienda exportar a PDF desde el frontend o backend

---

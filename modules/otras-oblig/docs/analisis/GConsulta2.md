# Documentación Técnica: Migración de Formulario GConsulta2 (Delphi) a Laravel + Vue.js + PostgreSQL

## 1. Arquitectura General
- **Backend**: Laravel API con endpoint único `/api/execute` que recibe peticiones eRequest/eResponse.
- **Frontend**: Vue.js SPA, cada formulario es una página independiente.
- **Base de Datos**: PostgreSQL, toda la lógica SQL encapsulada en stored procedures.

## 2. Flujo de la Página GConsulta2
1. **Carga inicial**: Se consultan las etiquetas y el nombre de la tabla según el parámetro de tabla (`glo_Opc`).
2. **Selección de tipo de búsqueda**: El usuario elige el campo por el cual buscar (control, concesionario, etc).
3. **Búsqueda**: Al ingresar el dato y presionar Enter o Buscar, se llama al SP de búsqueda de controles coincidentes.
4. **Selección de control**: Al seleccionar un control, se consulta el detalle del registro y sus adeudos.
5. **Visualización**: Se muestran los datos principales, el detalle de adeudos, los totales y los pagos realizados.
6. **Acciones**: Botones para ver pagos realizados y apremios (si aplica).

## 3. API Unificada
- **Endpoint**: `/api/execute`
- **Método**: POST
- **Parámetros**:
  - `action`: Nombre de la acción (ej: `gconsulta2.getEtiquetas`)
  - `params`: Objeto con los parámetros requeridos por el SP
- **Respuesta**:
  - `success`: boolean
  - `data`: array de resultados
  - `message`: mensaje de error si aplica

## 4. Stored Procedures
- Todos los SP reciben parámetros tipados y devuelven tablas (RETURNS TABLE).
- La lógica de búsqueda flexible (LIKE, JOIN, etc) se implementa en PL/pgSQL.
- Los SP pueden ser llamados desde Laravel usando DB::select.

## 5. Vue.js
- El componente es una página completa, sin tabs.
- Usa axios para consumir el endpoint `/api/execute`.
- Maneja el estado de búsqueda, selección y visualización de datos.
- Usa filtros para formatear moneda.
- Permite navegación entre controles encontrados.

## 6. Seguridad
- El endpoint debe validar autenticación (middleware Laravel, no mostrado aquí).
- Los SP deben validar tipos y evitar SQL injection (uso de parámetros tipados).

## 7. Extensibilidad
- Para agregar nuevas acciones, basta con crear el SP y mapearlo en el controlador.
- El frontend puede agregar nuevas opciones de búsqueda o visualización fácilmente.

## 8. Notas
- El SP de apremios no está implementado aquí, pero puede agregarse siguiendo el mismo patrón.
- Los nombres de SP y parámetros siguen el estándar del sistema original.

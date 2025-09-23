# Documentación Técnica: Migración Formulario Apremios (Delphi → Laravel + Vue.js + PostgreSQL)

## 1. Arquitectura General
- **Backend**: Laravel API con endpoint único `/api/execute` que recibe un `eRequest` y parámetros.
- **Frontend**: Vue.js SPA, cada formulario es una página independiente (no tabs).
- **Base de Datos**: PostgreSQL, toda la lógica SQL encapsulada en stored procedures.

## 2. API Unificada
- **Endpoint**: `/api/execute` (POST)
- **Entrada**: JSON con campos:
  - `eRequest`: nombre de la operación (ej: `get_apremios`, `create_apremio`, etc.)
  - `params`: objeto con parámetros requeridos por la operación
- **Salida**: JSON `{ eResponse: { success, data, message } }`

## 3. Stored Procedures
- Toda la lógica de consulta, inserción, actualización y borrado de apremios y periodos está en SPs.
- Los SPs devuelven los datos en formato tabla o VOID según corresponda.

## 4. Controlador Laravel
- Un solo controlador (`ExecuteController`) maneja todas las operaciones.
- Usa `DB::select('CALL ...')` para invocar los SPs.
- Mapea cada `eRequest` a un SP.

## 5. Componente Vue.js
- Página independiente `/apremios`.
- Carga datos de apremio y periodos requeridos al montar.
- Permite crear/editar apremios y muestra periodos relacionados.
- Botón "Salir" regresa a la página principal.

## 6. Seguridad
- Se recomienda proteger el endpoint con autenticación JWT o similar.
- Validar y sanear los parámetros en el backend antes de pasarlos a los SPs.

## 7. Consideraciones de Migración
- Los campos y lógica del formulario Delphi se han mapeado 1:1 a los campos del modelo y SPs.
- El grid de periodos se muestra como tabla en Vue.js.
- El botón "Salir" cierra la página y regresa al inicio.

## 8. Pruebas
- Se proveen casos de uso y escenarios de prueba para validar la funcionalidad.

## 9. Extensibilidad
- Para agregar nuevas operaciones, crear un nuevo SP y mapearlo en el controlador.
- El frontend puede invocar cualquier operación usando el mismo endpoint.

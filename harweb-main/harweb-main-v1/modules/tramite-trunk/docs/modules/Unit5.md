# Documentación Técnica - Migración Formulario Unit5 (Delphi) a Laravel + Vue.js + PostgreSQL

## Arquitectura General
- **Backend:** Laravel Controller con endpoint único `/api/execute` (patrón eRequest/eResponse)
- **Frontend:** Componente Vue.js como página independiente (Unit5FormPage.vue)
- **Base de Datos:** PostgreSQL con stored procedures para lógica de negocio y catálogos
- **API:** Todas las operaciones (consultas, guardado, catálogos) se realizan vía `/api/execute`

## Flujo de Datos
1. **Carga Inicial:**
   - El frontend solicita `getFormData` con el parámetro `cvecuenta`.
   - El backend retorna datos de la cuenta, catálogos (notarios, municipios, naturalezas), y avaluos externos.
2. **Selección de Año/Bimestre:**
   - Al cambiar año/bimestre, el frontend solicita avaluos externos filtrados y valores referenciados.
3. **Guardado:**
   - Al guardar, el frontend envía todos los datos del formulario con acción `saveTransmision`.
   - El backend valida y ejecuta el SP `sp_save_transmision_pat`.

## Validaciones
- Año de efectos: 1960 <= año <= 3000
- Bimestre: 1 <= bimestre <= 6
- Porcentaje: 0 <= porcentaje <= 100
- Notario, lugar, naturaleza, escritura, valor transmisión: obligatorios
- Fechas: según naturaleza del acto, se habilitan/deshabilitan campos

## Stored Procedures
- Todos los catálogos y procesos principales están encapsulados en SPs.
- El SP principal de guardado recibe un JSON con todos los datos y realiza la inserción y lógica asociada.

## API eRequest/eResponse
- **Request:** `{ action: 'nombreAccion', params: { ... } }`
- **Response:** `{ success: true|false, message: '', data: { ... } }`

## Seguridad
- El endpoint requiere autenticación (middleware Laravel)
- El usuario autenticado se pasa al SP si es necesario para auditoría

## Extensibilidad
- Se pueden agregar nuevas acciones al controlador y nuevos SPs sin modificar la estructura del endpoint

## Frontend
- El componente Vue es una página completa, sin tabs, con validación reactiva y mensajes de error/success.
- Los catálogos se cargan dinámicamente.
- El formulario es reactivo y muestra/oculta campos según la naturaleza del acto.

## Pruebas
- Se proveen casos de uso y escenarios de prueba para QA manual y automatizada.

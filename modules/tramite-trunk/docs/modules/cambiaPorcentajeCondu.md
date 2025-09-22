# Documentación Técnica: Migración de Formulario CambiaPorcentajeCondu

## Descripción General
Este módulo permite la consulta y actualización de los porcentajes de copropiedad de los condueños de una cuenta catastral. Incluye validaciones de negocio para asegurar que:
- El total de porcentajes sea exactamente 100%.
- Solo un contribuyente encabece.
- Las calidades sean válidas según catálogo.

## Arquitectura
- **Backend:** Laravel Controller con endpoint único `/api/execute` (patrón eRequest/eResponse).
- **Frontend:** Componente Vue.js como página independiente.
- **Base de Datos:** PostgreSQL, lógica de negocio en stored procedures.

## Flujo de Datos
1. **Consulta:**
   - El frontend solicita la lista de propietarios y calidades vía `/api/execute` con acción `getPropietarios` y `getCalidades`.
2. **Edición:**
   - El usuario edita porcentajes, encabeza y calidad.
   - Al guardar, se envía la acción `updatePorcentajes` con los datos.
3. **Validación y Actualización:**
   - El stored procedure valida reglas y actualiza los registros.
   - Se puede registrar una observación.

## API (eRequest/eResponse)
- **Endpoint:** `/api/execute`
- **Método:** POST
- **Entrada:**
  ```json
  {
    "eRequest": {
      "action": "getPropietarios|getCalidades|updatePorcentajes",
      "params": { ... }
    }
  }
  ```
- **Salida:**
  ```json
  {
    "success": true|false,
    "message": "...",
    "data": [ ... ]
  }
  ```

## Stored Procedures
- `sp_get_propietarios(cvecuenta, cveregprop)`
- `sp_get_calidades()`
- `sp_update_porcentajes(cvecuenta, cveregprop, propietarios_json, observacion)`

## Validaciones de Negocio
- Total de porcentajes = 100
- Solo un encabeza = 'S'
- Calidades válidas
- Observación opcional

## Seguridad
- Todas las operaciones requieren autenticación (middleware Laravel).
- Validación de datos en backend y frontend.

## Errores Comunes
- Total de porcentajes distinto de 100.
- Más de un encabeza o ninguno.
- Calidad no válida.

## Extensibilidad
- El endpoint y stored procedures pueden ampliarse para otros formularios similares.

## Integración
- El componente Vue puede integrarse en cualquier SPA con Vue Router.
- El backend puede ser extendido para otros catálogos o procesos.

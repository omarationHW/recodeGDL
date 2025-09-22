# Documentación Técnica: Mantenimiento de Intereses (InteresesMtto)

## Descripción General
Este módulo permite la administración de los porcentajes de interés de mantenimiento por año y mes. Incluye operaciones de alta, modificación, eliminación y consulta de los registros.

- **Backend:** Laravel Controller con endpoint unificado `/api/execute` (patrón eRequest/eResponse)
- **Frontend:** Componente Vue.js como página independiente
- **Base de Datos:** PostgreSQL, lógica encapsulada en stored procedures

## API Unificada
- **Endpoint:** `POST /api/execute`
- **Formato de entrada:**
  ```json
  {
    "action": "interesesmtto.create|interesesmtto.update|interesesmtto.delete|interesesmtto.list",
    "params": { ... }
  }
  ```
- **Formato de salida:**
  ```json
  {
    "success": true|false,
    "message": "...",
    "data": [ ... ]
  }
  ```

### Acciones soportadas
- `interesesmtto.list`: Lista todos los registros
- `interesesmtto.create`: Crea un nuevo registro
- `interesesmtto.update`: Modifica un registro existente
- `interesesmtto.delete`: Elimina un registro

## Stored Procedures
- `sp_interesesmtto_create(axo, mes, porcentaje, id_usuario)`
- `sp_interesesmtto_update(axo, mes, porcentaje, id_usuario)`
- `sp_interesesmtto_delete(axo, mes)`

## Validaciones
- No se permite crear registros duplicados para el mismo año y mes.
- El porcentaje debe ser mayor a 0.01.
- El año debe ser >= 1995, el mes entre 1 y 12.

## Seguridad
- El endpoint requiere autenticación (no incluida aquí, pero debe integrarse en producción).
- El id_usuario debe ser validado en el backend según la sesión.

## Frontend
- Página Vue.js independiente, sin tabs.
- Listado y formulario de alta/edición en la misma página.
- Validación de campos en frontend y backend.
- Mensajes de éxito y error claros.

## Integración
- El frontend se comunica con `/api/execute` usando fetch/AJAX.
- El backend enruta la acción al stored procedure correspondiente.

## Ejemplo de Request
```json
{
  "action": "interesesmtto.create",
  "params": {
    "axo": 2024,
    "mes": 6,
    "porcentaje": 1.25,
    "id_usuario": 5
  }
}
```

## Ejemplo de Response
```json
{
  "success": true,
  "message": "",
  "data": [ { "result": "OK" } ]
}
```

## Errores comunes
- Si ya existe el registro: `"Ya existe un registro para ese año y mes"`
- Si no existe para update/delete: `"No existe el registro para ese año y mes"`

## Estructura de la tabla
```sql
CREATE TABLE ta_12_intereses (
  axo integer NOT NULL,
  mes integer NOT NULL,
  porcentaje numeric(12,8) NOT NULL,
  id_usuario integer NOT NULL,
  fecha_actual timestamp NOT NULL DEFAULT now(),
  PRIMARY KEY (axo, mes)
);
```

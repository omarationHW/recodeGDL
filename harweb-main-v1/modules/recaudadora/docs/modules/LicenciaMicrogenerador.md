# Documentación Técnica: LicenciaMicrogenerador

## Descripción General
Este módulo permite consultar, registrar y cancelar el estatus de microgenerador para licencias o trámites en el sistema. La lógica se implementa en un stored procedure de PostgreSQL y se expone mediante un endpoint API unificado en Laravel. El frontend es una página Vue.js independiente.

## Arquitectura
- **Backend**: Laravel Controller con endpoint único `/api/execute` usando patrón eRequest/eResponse.
- **Frontend**: Componente Vue.js como página completa, sin tabs.
- **Base de Datos**: PostgreSQL, lógica central en stored procedure `lic_registro_microgenerador`.

## API
### Endpoint
`POST /api/execute`

#### Request Body
```json
{
  "action": "consulta|alta|cancelar",
  "params": {
    "tipo": "L|T", // L=Licencia, T=Trámite
    "licencia": 123, // si tipo=L
    "tramite": 456,  // si tipo=T
    "id": 123,       // id_licencia o id_tramite para alta/cancelar
    "anio": 2024,    // opcional, default año actual
    "usuario": "usuario" // opcional, tomado del usuario autenticado si existe
  }
}
```

#### Respuesta
```json
{
  "estatus": 1, // 1=exitoso, 2=no existe, 0=error
  "mensaje": "Texto descriptivo",
  "licencia": { ... } // si aplica
}
```

## Stored Procedure
- **lic_registro_microgenerador**: Maneja consulta, alta y cancelación de microgenerador para licencias o trámites.
- Tabla sugerida: `lic_microgenerador(id_ref integer, anio smallint, usuario_alta varchar, fecha_alta timestamp, usuario_baja varchar, fecha_baja timestamp, vigente char(1))`

## Frontend
- Página Vue.js independiente
- Selección de tipo (Licencia/Trámite)
- Consulta, alta y cancelación con feedback visual
- Navegación simple, sin tabs

## Seguridad
- El usuario se toma del contexto autenticado o del parámetro `usuario`.
- Validaciones de existencia y estado en el stored procedure.

## Flujo de Trabajo
1. El usuario selecciona tipo y número de licencia/trámite.
2. Consulta el estatus actual.
3. Si no existe como microgenerador, puede dar de alta.
4. Si ya existe, puede cancelar.

## Errores y Mensajes
- Mensajes claros para cada acción y error.
- El estatus y mensaje se muestran en el frontend.

## Integración
- El endpoint `/api/execute` puede ser usado por cualquier frontend o sistema externo.
- El stored procedure centraliza la lógica de negocio y puede ser reutilizado por otros módulos.

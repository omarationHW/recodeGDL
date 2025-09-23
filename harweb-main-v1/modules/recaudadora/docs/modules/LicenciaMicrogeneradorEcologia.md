# Documentación Técnica: Licencia Microgenerador Ecología

## Descripción General
Este módulo permite autorizar, consultar y cancelar el registro de microgenerador para licencias y trámites de ecología. La migración Delphi → Laravel + Vue.js + PostgreSQL se realiza usando un endpoint unificado `/api/execute` bajo el patrón eRequest/eResponse.

## Arquitectura
- **Backend:** Laravel Controller (LicenciaMicrogeneradorEcologiaController)
- **Frontend:** Vue.js (SPA, página independiente)
- **Base de Datos:** PostgreSQL (Stored Procedures y Vistas)
- **API:** Único endpoint `/api/execute`

## Flujo de Operación
1. El usuario selecciona el tipo (Trámite o Licencia) y captura el número correspondiente.
2. El frontend consulta los datos del trámite/licencia y verifica si ya es microgenerador.
3. El usuario puede autorizar (alta) o cancelar el microgenerador según el estado.
4. Todas las operaciones se ejecutan vía el SP `sp_licencia_microgenerador_ecologia`.

## Endpoints
- **POST /api/execute**
  - **Body:**
    ```json
    {
      "action": "consulta|alta|cancela|tramite|licencia",
      "data": { ... }
    }
    ```
  - **Acciones:**
    - `consulta`: Consulta si el trámite/licencia es microgenerador.
    - `alta`: Da de alta como microgenerador.
    - `cancela`: Cancela el microgenerador.
    - `tramite`: Consulta datos del trámite.
    - `licencia`: Consulta datos de la licencia.

## Stored Procedures y Vistas
- **sp_licencia_microgenerador_ecologia**: Maneja alta, consulta y cancelación.
- **vw_tramite_microgenerador**: Vista para mostrar datos de trámite.
- **vw_licencia_microgenerador**: Vista para mostrar datos de licencia.

## Validaciones
- El tipo debe ser 'L' (licencia) o 'T' (trámite).
- El ID debe existir y ser numérico.
- No se puede dar de alta si ya existe como microgenerador vigente.
- No se puede cancelar si no existe como microgenerador vigente.

## Seguridad
- El usuario se toma del contexto de autenticación o del campo `usuario` en el request.
- Todas las operaciones quedan registradas con usuario y fecha.

## Manejo de Errores
- El SP retorna estatus y mensaje.
- El controlador captura excepciones y las retorna en el campo `message` del eResponse.

## Integración Vue.js
- El componente es una página completa, sin tabs.
- Permite consultar, autorizar y cancelar microgenerador.
- Muestra mensajes claros según el resultado del SP.

## Base de Datos
- Tabla principal: `lic_microgenerador_ecologia`
  - id_licencia (nullable)
  - id_tramite (nullable)
  - anio
  - usuario_alta
  - fecha_alta
  - usuario_baja
  - fecha_baja
  - vigente ('V' o 'C')

## Ejemplo de Request/Response
### Alta
```json
{
  "action": "alta",
  "data": { "tipo": "L", "id": 12345 }
}
```
### Respuesta
```json
{
  "success": true,
  "data": [ { "estatus": 1, "mensaje": "Alta exitosa, Licencia registrada como microgenerador." } ]
}
```

## Notas
- El endpoint es único y centraliza todas las operaciones.
- El frontend es desacoplado y puede ser usado como página independiente.

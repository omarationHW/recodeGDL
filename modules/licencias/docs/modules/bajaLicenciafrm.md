# Documentación Técnica: Baja de Licencia

## Descripción General
Este módulo permite realizar la baja administrativa de una licencia y sus anuncios ligados, asegurando que no existan bloqueos ni adeudos pendientes, y actualizando el estatus en la base de datos. Incluye:
- API unificada (eRequest/eResponse) en `/api/execute`
- Controlador Laravel para orquestar la lógica
- Componente Vue.js como página independiente
- Stored Procedures en PostgreSQL para la lógica de negocio

## Flujo de Proceso
1. **Búsqueda de Licencia**: El usuario ingresa el número de licencia y el sistema muestra los datos principales, adeudos y anuncios ligados.
2. **Validación de Adeudos y Bloqueos**: El sistema verifica que la licencia esté vigente, no esté bloqueada y que los anuncios ligados tampoco estén bloqueados.
3. **Confirmación de Baja**: El usuario ingresa el motivo, año y folio de baja (o marca baja por error si aplica).
4. **Ejecución de Baja**: Se ejecuta el stored procedure `sp_baja_licencia`, que:
   - Cancela adeudos de la licencia y anuncios
   - Cambia el estatus de la licencia y anuncios a cancelado
   - Registra la bitácora de baja
   - Recalcula el saldo de la licencia

## API Unificada
- **Endpoint**: `/api/execute`
- **Método**: POST
- **Formato**:
  ```json
  {
    "action": "bajaLicencia",
    "params": {
      "id_licencia": 12345,
      "motivo": "Cierre de negocio",
      "anio": 2024,
      "folio": 123,
      "baja_error": false
    }
  }
  ```
- **Respuesta**:
  ```json
  {
    "success": true,
    "message": "Licencia dada de baja correctamente."
  }
  ```

## Validaciones
- La licencia debe existir y estar vigente
- No debe estar bloqueada (bloqueado < 5)
- Ningún anuncio ligado debe estar bloqueado
- Si hay adeudos, sólo usuarios autorizados pueden continuar (según reglas de negocio)

## Seguridad
- El usuario debe estar autenticado (JWT o sesión)
- El usuario y su nivel se obtienen del token/session y se pasan al SP para bitácora

## Stored Procedures
- Toda la lógica de baja está en el SP `sp_baja_licencia`
- El recálculo de saldos se delega a `calc_sdosl`

## Frontend
- El componente Vue.js es una página completa, sin tabs, con navegación y validaciones en tiempo real
- El formulario de baja sólo se habilita si la licencia cumple las condiciones

## Notas
- El endpoint `/api/execute` puede ser usado por otros formularios siguiendo el patrón eRequest/eResponse
- El SP puede ser extendido para bitácora, logs, o reglas adicionales

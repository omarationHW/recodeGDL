# Documentación Técnica: bajaLicenciafrm

## Análisis Técnico

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

## Casos de Prueba

# Casos de Prueba: Baja de Licencia

## Caso 1: Baja exitosa sin adeudos
- Ingresar licencia válida y vigente sin adeudos ni anuncios bloqueados
- Ingresar motivo, año y folio
- Confirmar baja
- Verificar en BD que licencia y anuncios quedan con vigente = 'C', adeudos cvepago = 999999

## Caso 2: Baja rechazada por anuncio bloqueado
- Ingresar licencia con al menos un anuncio ligado bloqueado
- Intentar baja
- El sistema debe mostrar mensaje de error y no modificar la BD

## Caso 3: Baja por error administrativa
- Ingresar licencia válida y vigente
- Marcar 'Baja por error'
- Ingresar motivo
- Confirmar baja
- Verificar que la baja se realiza sin requerir año/folio y se registra en bitácora

## Caso 4: Baja de licencia ya cancelada
- Ingresar licencia con vigente <> 'V'
- Intentar baja
- El sistema debe rechazar la operación

## Caso 5: Baja con adeudos y usuario no autorizado
- Ingresar licencia con adeudos
- Usuario sin permisos intenta baja
- El sistema debe rechazar la operación

## Casos de Uso

# Casos de Uso - bajaLicenciafrm

**Categoría:** Form

## Caso de Uso 1: Baja de Licencia con Adeudos Pagados

**Descripción:** El usuario da de baja una licencia que no tiene adeudos ni anuncios bloqueados.

**Precondiciones:**
La licencia existe, está vigente, no tiene adeudos ni anuncios bloqueados.

**Pasos a seguir:**
- El usuario ingresa el número de licencia y busca.
- El sistema muestra los datos y confirma que no hay adeudos.
- El usuario ingresa el motivo, año y folio de baja.
- El usuario confirma la baja.
- El sistema ejecuta la baja y muestra mensaje de éxito.

**Resultado esperado:**
La licencia y sus anuncios quedan con estatus cancelado, los adeudos se cancelan y se registra la bitácora.

**Datos de prueba:**
licencia: 12345, motivo: 'Cierre definitivo', anio: 2024, folio: 100

---

## Caso de Uso 2: Intento de Baja con Anuncio Bloqueado

**Descripción:** El usuario intenta dar de baja una licencia pero uno de los anuncios ligados está bloqueado.

**Precondiciones:**
La licencia existe, está vigente, pero al menos un anuncio ligado tiene bloqueado > 0.

**Pasos a seguir:**
- El usuario ingresa el número de licencia y busca.
- El sistema muestra los datos y la lista de anuncios.
- El usuario intenta confirmar la baja.
- El sistema rechaza la operación y muestra mensaje de error.

**Resultado esperado:**
No se realiza la baja y se informa que hay anuncios bloqueados.

**Datos de prueba:**
licencia: 54321, motivo: 'Cierre', anio: 2024, folio: 101

---

## Caso de Uso 3: Baja por Error Administrativa

**Descripción:** Un usuario autorizado realiza la baja por error administrativo, sin requerir año y folio.

**Precondiciones:**
La licencia existe, está vigente, el usuario tiene nivel suficiente y marca baja por error.

**Pasos a seguir:**
- El usuario ingresa el número de licencia y busca.
- El sistema muestra los datos.
- El usuario marca la opción 'Baja por error'.
- El usuario ingresa el motivo y confirma la baja.
- El sistema ejecuta la baja sin requerir año y folio.

**Resultado esperado:**
La licencia queda cancelada, se registra el motivo y la bitácora.

**Datos de prueba:**
licencia: 67890, motivo: 'Captura errónea', baja_error: true

---

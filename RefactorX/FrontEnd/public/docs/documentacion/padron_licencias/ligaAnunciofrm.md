# Documentación Técnica: ligaAnunciofrm

## Análisis Técnico

# Documentación Técnica: Liga de Anuncios a Licencias

## Descripción General
Este módulo permite ligar (asociar) un anuncio existente a una licencia o empresa, actualizando los datos de ubicación del anuncio y recalculando los saldos correspondientes. La migración se realizó desde Delphi a Laravel (backend) y Vue.js (frontend), usando PostgreSQL y un API unificada.

## Arquitectura
- **Backend:** Laravel Controller con endpoint único `/api/execute` (patrón eRequest/eResponse).
- **Frontend:** Componente Vue.js como página independiente.
- **Base de Datos:** PostgreSQL, lógica de negocio en stored procedures.
- **API:** Todas las acciones (buscar, ligar, etc.) se ejecutan vía `/api/execute` con parámetros `{ action, params }`.

## Flujo de Trabajo
1. El usuario busca una licencia o empresa (según el checkbox).
2. El usuario busca el anuncio a ligar.
3. El sistema valida la vigencia de los registros.
4. Si el anuncio ya está ligado, solicita confirmación.
5. Al aceptar, ejecuta el stored procedure `sp_ligar_anuncio` que actualiza los datos y recalcula saldos.
6. El frontend muestra mensajes de éxito o error.

## Seguridad y Validaciones
- Solo se permite ligar anuncios y licencias/empresas vigentes.
- Si el anuncio ya está ligado, requiere confirmación explícita.
- Todas las operaciones son transaccionales.

## API: Ejemplo de Request
```json
{
  "action": "ligarAnuncio",
  "params": {
    "anuncio_id": 123,
    "licencia_id": 456,
    "empresa_id": null,
    "isEmpresa": false,
    "user": "usuario_actual"
  }
}
```

## API: Ejemplo de Response
```json
{
  "success": true,
  "message": "Anuncio ligado correctamente"
}
```

## Stored Procedures
- `sp_ligar_anuncio`: Lógica principal de ligadura.
- `calc_sdosl`: Recalcula saldos (debe implementarse según reglas de negocio).

## Frontend
- Página Vue.js independiente, sin tabs.
- Permite buscar por licencia o empresa, buscar anuncio, y ligar.
- Mensajes claros de error/éxito.
- Solicita confirmación si el anuncio ya está ligado.

## Pruebas y Casos de Uso
- Incluye validaciones de campos, confirmaciones y mensajes de error.

## Extensibilidad
- El endpoint `/api/execute` puede ser usado para otras acciones relacionadas.
- Los stored procedures pueden ampliarse para lógica adicional.

## Casos de Prueba

# Casos de Prueba: Liga de Anuncios a Licencias

## Caso 1: Ligar anuncio a licencia vigente
- Ingresar licencia válida y vigente
- Ingresar anuncio válido y vigente
- Click en 'Ligar Anuncio'
- Esperar mensaje de éxito

## Caso 2: Ligar anuncio cancelado
- Ingresar licencia válida y vigente
- Ingresar anuncio cancelado (vigente != 'V')
- Click en 'Ligar Anuncio'
- Esperar mensaje de error: 'No se puede ligar un anuncio cancelado.'

## Caso 3: Ligar anuncio ya ligado a otra licencia
- Ingresar licencia válida y vigente
- Ingresar anuncio con id_licencia > 0
- Click en 'Ligar Anuncio'
- Confirmar en el diálogo
- Esperar mensaje de éxito

## Caso 4: Ligar a empresa
- Seleccionar 'Buscar por Empresa'
- Ingresar empresa válida y vigente
- Ingresar anuncio válido y vigente
- Click en 'Ligar Anuncio'
- Esperar mensaje de éxito

## Caso 5: Error de datos insuficientes
- No ingresar licencia/empresa o anuncio
- Click en 'Ligar Anuncio'
- Esperar mensaje de error: 'Datos insuficientes'

## Casos de Uso

# Casos de Uso - ligaAnunciofrm

**Categoría:** Form

## Caso de Uso 1: Ligar un anuncio a una licencia vigente

**Descripción:** El usuario liga un anuncio existente a una licencia vigente, actualizando los datos de ubicación y recalculando saldos.

**Precondiciones:**
El anuncio y la licencia existen y ambos están vigentes.

**Pasos a seguir:**
1. El usuario ingresa el número de licencia y busca.
2. El sistema muestra los datos de la licencia.
3. El usuario ingresa el número de anuncio y busca.
4. El sistema muestra los datos del anuncio.
5. El usuario hace clic en 'Ligar Anuncio'.
6. El sistema ejecuta el proceso y muestra mensaje de éxito.

**Resultado esperado:**
El anuncio queda ligado a la licencia, los datos de ubicación se actualizan y los saldos se recalculan.

**Datos de prueba:**
{ "licencia": "10001", "anuncio": "20001" }

---

## Caso de Uso 2: Intentar ligar un anuncio cancelado

**Descripción:** El usuario intenta ligar un anuncio que ya está cancelado.

**Precondiciones:**
El anuncio existe pero su campo 'vigente' es distinto de 'V'.

**Pasos a seguir:**
1. El usuario ingresa el número de licencia y busca.
2. El usuario ingresa el número de anuncio cancelado y busca.
3. El usuario intenta ligar el anuncio.
4. El sistema muestra mensaje de error.

**Resultado esperado:**
El sistema no permite ligar el anuncio y muestra el mensaje 'No se puede ligar un anuncio cancelado.'

**Datos de prueba:**
{ "licencia": "10001", "anuncio": "30001" }

---

## Caso de Uso 3: Ligar un anuncio ya ligado a otra licencia (requiere confirmación)

**Descripción:** El usuario intenta ligar un anuncio que ya está ligado a otra licencia. El sistema solicita confirmación.

**Precondiciones:**
El anuncio tiene un id_licencia > 0.

**Pasos a seguir:**
1. El usuario ingresa el número de licencia y busca.
2. El usuario ingresa el número de anuncio ya ligado y busca.
3. El usuario hace clic en 'Ligar Anuncio'.
4. El sistema solicita confirmación.
5. El usuario acepta.
6. El sistema liga el anuncio.

**Resultado esperado:**
El anuncio queda ligado a la nueva licencia y se recalculan los saldos.

**Datos de prueba:**
{ "licencia": "10001", "anuncio": "40001" }

---

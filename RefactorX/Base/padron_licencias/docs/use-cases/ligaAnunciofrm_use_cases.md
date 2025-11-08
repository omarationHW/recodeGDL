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


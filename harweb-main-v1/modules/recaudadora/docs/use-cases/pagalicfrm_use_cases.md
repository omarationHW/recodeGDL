# Casos de Uso - pagalicfrm

**Categoría:** Form

## Caso de Uso 1: Marcar una Licencia como Pagada

**Descripción:** El usuario desea marcar como pagada una licencia con adeudos pendientes para un año específico.

**Precondiciones:**
La licencia existe, está vigente y tiene adeudos pendientes para el año seleccionado.

**Pasos a seguir:**
1. El usuario selecciona 'Licencia'.
2. Ingresa el número de licencia y el año.
3. Presiona 'Buscar'.
4. El sistema muestra los datos de la licencia y los adeudos.
5. El usuario presiona 'Marcar como Pagado'.
6. El sistema actualiza los registros y recalcula los saldos.

**Resultado esperado:**
La licencia es marcada como pagada, los adeudos desaparecen y se muestra un mensaje de éxito.

**Datos de prueba:**
numero: 1234, axo: 2024 (licencia vigente con adeudos)

---

## Caso de Uso 2: Intentar Marcar una Licencia Inexistente

**Descripción:** El usuario intenta buscar una licencia que no existe.

**Precondiciones:**
El número de licencia no existe en la base de datos.

**Pasos a seguir:**
1. El usuario selecciona 'Licencia'.
2. Ingresa un número de licencia inexistente y el año.
3. Presiona 'Buscar'.

**Resultado esperado:**
El sistema muestra un mensaje de error indicando que no existe ese número de licencia.

**Datos de prueba:**
numero: 999999, axo: 2024

---

## Caso de Uso 3: Marcar un Anuncio como Pagado

**Descripción:** El usuario marca como pagado un anuncio con adeudos pendientes.

**Precondiciones:**
El anuncio existe, está vigente y tiene adeudos pendientes para el año seleccionado.

**Pasos a seguir:**
1. El usuario selecciona 'Anuncio'.
2. Ingresa el número de anuncio y el año.
3. Presiona 'Buscar'.
4. El sistema muestra los datos del anuncio y los adeudos.
5. El usuario presiona 'Marcar como Pagado'.
6. El sistema actualiza los registros y recalcula los saldos.

**Resultado esperado:**
El anuncio es marcado como pagado, los adeudos desaparecen y se muestra un mensaje de éxito.

**Datos de prueba:**
numero: 5678, axo: 2024 (anuncio vigente con adeudos)

---


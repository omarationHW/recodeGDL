# Casos de Uso - ImpLicenciaReglamentadaFrm

**Categoría:** Form

## Caso de Uso 1: Consulta e impresión de licencia reglamentada vigente

**Descripción:** El usuario consulta una licencia vigente, válida y de giro clasificación D, y procede a imprimir el detalle de adeudo.

**Precondiciones:**
La licencia existe, está vigente, no está bloqueada y su giro es de clasificación 'D'.

**Pasos a seguir:**
1. El usuario ingresa el número de licencia en el formulario y presiona Enter o Buscar.
2. El sistema muestra los datos de la licencia, giro, ubicación, propietario, etc.
3. El usuario presiona el botón Imprimir.
4. El sistema ejecuta el cálculo de adeudo y muestra el detalle en tabla.

**Resultado esperado:**
Se muestran correctamente los datos de la licencia y el detalle de adeudo. El botón Imprimir está habilitado y la impresión se simula exitosamente.

**Datos de prueba:**
licencia = 12345 (vigente, no bloqueada, giro clasificación D)

---

## Caso de Uso 2: Intento de consulta de licencia bloqueada

**Descripción:** El usuario intenta consultar una licencia que está bloqueada.

**Precondiciones:**
La licencia existe, está vigente, pero tiene el campo bloqueado = 1.

**Pasos a seguir:**
1. El usuario ingresa el número de licencia bloqueada y presiona Buscar.
2. El sistema valida y muestra un mensaje de error indicando que la licencia está bloqueada.

**Resultado esperado:**
El sistema no permite imprimir ni consultar detalle, mostrando el mensaje de error correspondiente.

**Datos de prueba:**
licencia = 54321 (vigente, bloqueado = 1)

---

## Caso de Uso 3: Consulta de licencia con giro no permitido

**Descripción:** El usuario consulta una licencia cuyo giro no es de clasificación D.

**Precondiciones:**
La licencia existe, está vigente, no está bloqueada, pero su giro es de clasificación diferente a 'D'.

**Pasos a seguir:**
1. El usuario ingresa el número de licencia y presiona Buscar.
2. El sistema valida y muestra un mensaje de error indicando que el giro no es permitido.

**Resultado esperado:**
El sistema no permite imprimir ni consultar detalle, mostrando el mensaje de error correspondiente.

**Datos de prueba:**
licencia = 67890 (vigente, no bloqueada, giro clasificación 'B')

---


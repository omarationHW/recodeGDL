# Casos de Uso - sfrm_calificacionQR

**Categoría:** Form

## Caso de Uso 1: Consulta de Calificación QR por ID de Multa

**Descripción:** El usuario desea consultar la información completa de una multa específica, incluyendo datos principales, artículos relacionados y el código QR.

**Precondiciones:**
El usuario tiene acceso al sistema y conoce el ID de la multa.

**Pasos a seguir:**
1. Acceder a la página de Calificación QR.
2. Ingresar el ID de la multa en el formulario.
3. Presionar el botón 'Buscar'.

**Resultado esperado:**
Se muestran los datos principales de la multa, los artículos relacionados y el código QR generado.

**Datos de prueba:**
id_multa: 12345

---

## Caso de Uso 2: Intento de Consulta con ID de Multa Inexistente

**Descripción:** El usuario ingresa un ID de multa que no existe en la base de datos.

**Precondiciones:**
El usuario tiene acceso al sistema.

**Pasos a seguir:**
1. Acceder a la página de Calificación QR.
2. Ingresar un ID de multa inexistente (por ejemplo, 999999).
3. Presionar el botón 'Buscar'.

**Resultado esperado:**
El sistema muestra un mensaje de error indicando que no hay multa con ese dato.

**Datos de prueba:**
id_multa: 999999

---

## Caso de Uso 3: Impresión de Calificación QR

**Descripción:** El usuario consulta una multa válida y desea imprimir la información mostrada.

**Precondiciones:**
El usuario ha realizado una consulta exitosa de una multa.

**Pasos a seguir:**
1. Consultar una multa válida.
2. Presionar el botón 'Imprimir'.

**Resultado esperado:**
Se abre el diálogo de impresión del navegador con la información formateada para impresión.

**Datos de prueba:**
id_multa: 12345

---


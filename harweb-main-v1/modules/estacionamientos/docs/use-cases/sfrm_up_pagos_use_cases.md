# Casos de Uso - sfrm_up_pagos

**Categoría:** Form

## Caso de Uso 1: Carga exitosa de archivo de pagos

**Descripción:** El usuario selecciona un archivo de pagos válido y todos los registros se actualizan correctamente en la base de datos.

**Precondiciones:**
El usuario tiene acceso a la página y el archivo contiene registros válidos existentes en la base de datos.

**Pasos a seguir:**
1. Acceder a la página de actualización de pagos.
2. Seleccionar un archivo de texto con registros válidos.
3. Hacer clic en 'Aplicar la actualización'.
4. Esperar el procesamiento y revisar el resultado.

**Resultado esperado:**
Todos los registros del archivo son actualizados. El sistema muestra el total de registros leídos, actualizados y cero errores.

**Datos de prueba:**
Archivo con líneas como: 20231234567      230501

---

## Caso de Uso 2: Archivo con registros inexistentes

**Descripción:** El usuario sube un archivo donde algunos registros no existen en la base de datos.

**Precondiciones:**
El usuario tiene acceso y el archivo contiene registros válidos y algunos inexistentes.

**Pasos a seguir:**
1. Acceder a la página.
2. Seleccionar un archivo con registros válidos y algunos con folios inexistentes.
3. Hacer clic en 'Aplicar la actualización'.

**Resultado esperado:**
El sistema muestra el número de registros leídos, cuántos fueron actualizados y cuántos fallaron, mostrando detalles de los errores.

**Datos de prueba:**
Archivo con líneas: 20231234567      230501 (existe), 20239999999      230501 (no existe)

---

## Caso de Uso 3: Archivo con formato incorrecto

**Descripción:** El usuario sube un archivo con líneas mal formateadas o con datos no numéricos.

**Precondiciones:**
El usuario tiene acceso y el archivo contiene líneas con errores de formato.

**Pasos a seguir:**
1. Acceder a la página.
2. Seleccionar un archivo con líneas mal formateadas.
3. Hacer clic en 'Aplicar la actualización'.

**Resultado esperado:**
El sistema procesa las líneas válidas y reporta errores detallados para las líneas mal formateadas.

**Datos de prueba:**
Archivo con líneas: ABCDEFGHIJK      230501 (inválido), 20231234567      230501 (válido)

---


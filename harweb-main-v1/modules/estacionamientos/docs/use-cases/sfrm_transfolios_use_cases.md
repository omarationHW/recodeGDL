# Casos de Uso - sfrm_transfolios

**Categoría:** Form

## Caso de Uso 1: Carga masiva de Altas de Multas de Estacionómetros

**Descripción:** El usuario carga un archivo TXT con registros de multas para dar de alta en el sistema.

**Precondiciones:**
El usuario tiene acceso al sistema y cuenta con un archivo TXT válido con datos de multas.

**Pasos a seguir:**
1. Ingresar a la página de Altas de Multas de Estacionómetros.
2. Seleccionar el archivo TXT desde el equipo.
3. Visualizar la vista previa de los datos.
4. Hacer clic en 'Procesar Archivo'.
5. Hacer clic en 'Enviar a Servidor'.

**Resultado esperado:**
Todos los registros del archivo son insertados en la tabla ta14_folios_adeudo. El usuario ve un mensaje de éxito y cada registro muestra 'OK' o 'error' según el resultado.

**Datos de prueba:**
Archivo TXT con líneas tipo: '20231234ABC1234...'

---

## Caso de Uso 2: Baja de Multas de Estacionómetros con opción Municipio/Estado

**Descripción:** El usuario realiza la baja de multas seleccionando la opción Municipio/Estado.

**Precondiciones:**
El usuario tiene acceso y un archivo TXT con folios a dar de baja.

**Pasos a seguir:**
1. Ingresar a la página de Bajas de Multas de Estacionómetros.
2. Seleccionar el archivo TXT.
3. Marcar la casilla 'Municipio / Estado (Marcado)'.
4. Procesar y enviar los datos.

**Resultado esperado:**
Los folios son actualizados a estado de baja (estado=99). El usuario ve el resultado por registro.

**Datos de prueba:**
Archivo TXT con líneas tipo: '20231234ABC1234...'

---

## Caso de Uso 3: Altas de Calcomanías sin Propietario

**Descripción:** El usuario da de alta calcomanías sin propietario mediante archivo TXT.

**Precondiciones:**
El usuario tiene acceso y un archivo TXT con datos de calcomanías.

**Pasos a seguir:**
1. Ingresar a la página de Altas de Calcomanías.
2. Seleccionar el archivo TXT.
3. Procesar y enviar los datos.

**Resultado esperado:**
Las calcomanías son insertadas en ta14_calco. El usuario ve el resultado por registro.

**Datos de prueba:**
Archivo TXT con líneas tipo: '0000001234TIPO1TURNO1...'

---


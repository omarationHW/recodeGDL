# Casos de Uso - sfrm_trans_pub

**Categoría:** Form

## Caso de Uso 1: Carga e inserción masiva de registros desde archivo HP3000

**Descripción:** Un usuario carga un archivo de texto plano exportado del HP3000, visualiza los datos parseados y los inserta en la base de datos PostgreSQL.

**Precondiciones:**
El usuario tiene acceso al sistema y un archivo de texto válido con datos de estacionamientos públicos.

**Pasos a seguir:**
1. El usuario accede a la página de transferencia de estacionamientos públicos.
2. Hace clic en 'Abrir Archivo' y selecciona el archivo .txt exportado.
3. El sistema muestra el nombre del archivo y permite procesarlo.
4. El usuario hace clic en 'Pasar Datos'.
5. El sistema muestra una tabla previa con los datos parseados.
6. El usuario hace clic en 'Altas'.
7. El sistema envía los registros al backend y muestra un mensaje de éxito.

**Resultado esperado:**
Todos los registros válidos del archivo son insertados en la tabla ta_15_publicos. El usuario ve un mensaje de confirmación.

**Datos de prueba:**
Archivo de texto con al menos 10 líneas válidas, cada una con los campos en las posiciones fijas especificadas.

---

## Caso de Uso 2: Actualización de fechas de póliza para registros existentes

**Descripción:** El usuario actualiza el campo pol_fec_ven de los registros existentes usando los datos del archivo cargado.

**Precondiciones:**
Existen registros previos en ta_15_publicos con los mismos sector, categoría y número.

**Pasos a seguir:**
1. El usuario carga un archivo con datos actualizados.
2. Procesa el archivo y visualiza los datos.
3. Hace clic en 'Actualizar Fechas'.
4. El sistema envía las actualizaciones al backend.
5. El sistema muestra un mensaje de éxito.

**Resultado esperado:**
Los campos pol_fec_ven de los registros correspondientes son actualizados correctamente.

**Datos de prueba:**
Archivo con al menos 3 líneas donde pol_fec (fecha de póliza) es diferente a la almacenada.

---

## Caso de Uso 3: Manejo de errores en archivo malformado

**Descripción:** El usuario intenta cargar un archivo con líneas incompletas o malformadas.

**Precondiciones:**
El usuario tiene un archivo con líneas de menos de 155 caracteres o con campos vacíos.

**Pasos a seguir:**
1. El usuario carga el archivo malformado.
2. Procesa el archivo.
3. El sistema ignora las líneas inválidas y muestra solo las válidas.
4. El usuario intenta insertar los registros.
5. El sistema inserta solo los registros válidos y muestra un mensaje de advertencia.

**Resultado esperado:**
Solo los registros válidos son procesados e insertados. El usuario es notificado de las líneas ignoradas.

**Datos de prueba:**
Archivo con 5 líneas, 2 de ellas con menos de 155 caracteres.

---


# Casos de Prueba: Gen_ArcDiario

## Caso 1: Generación exitosa de archivo diario
- **Precondición:** Existen registros en ta14_datos_mpio para el periodo seleccionado.
- **Pasos:**
  1. Acceder a la página.
  2. Seleccionar fechas válidas.
  3. Ejecutar remesa.
  4. Verificar que se muestran folios > 0.
  5. Generar archivo.
  6. Descargar y revisar el archivo.
- **Resultado esperado:** Archivo generado y descargado con los datos correctos.

## Caso 2: Generación sin registros
- **Precondición:** No existen registros para el periodo.
- **Pasos:**
  1. Acceder a la página.
  2. Seleccionar periodo sin registros.
  3. Ejecutar remesa.
  4. Intentar generar archivo.
- **Resultado esperado:** Mensaje de error "No hubo registros para generar el archivo de texto, intenta con otro".

## Caso 3: Error en SP de remesa
- **Precondición:** El SP retorna status=1 (error).
- **Pasos:**
  1. Acceder a la página.
  2. Seleccionar periodo que cause error en SP.
  3. Ejecutar remesa.
- **Resultado esperado:** Mensaje de error del SP, no se permite generar archivo.

## Caso 4: Validación de fechas
- **Precondición:** El usuario selecciona fechas de inicio mayores a las de fin.
- **Pasos:**
  1. Seleccionar D_Inicio > D_Fin.
  2. Ejecutar remesa.
- **Resultado esperado:** Mensaje de validación en frontend.

## Caso 5: Descarga de archivo inexistente
- **Precondición:** Intentar descargar un archivo que no existe.
- **Pasos:**
  1. Manipular URL de descarga.
  2. Intentar descargar archivo.
- **Resultado esperado:** Error 404 "Archivo no encontrado".

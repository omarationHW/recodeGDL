# Casos de Prueba para Cga_ArcEdoEx

## Caso 1: Carga y aplicación exitosa
- **Preparación**: Archivo .txt con 3 líneas válidas.
- **Pasos**:
  1. Cargar archivo.
  2. Descargar datos.
  3. Grabar registros.
  4. Aplicar remesa.
- **Esperado**: Todos los registros insertados, remesa aplicada, bitácora registrada, mensajes de éxito.

## Caso 2: Archivo con errores
- **Preparación**: Archivo .txt con 1 línea válida y 1 línea con folio vacío.
- **Pasos**:
  1. Cargar archivo.
  2. Descargar datos.
  3. Grabar registros.
- **Esperado**: Mensaje de error para registro inválido, sólo los válidos insertados, no permite aplicar remesa hasta corregir.

## Caso 3: Aplicar sin grabar
- **Preparación**: No cargar archivo.
- **Pasos**:
  1. Acceder a la página.
  2. Intentar aplicar remesa.
- **Esperado**: Botón 'APLICAR' deshabilitado, no se ejecuta acción.

## Caso 4: Error de base de datos
- **Preparación**: Simular caída de base de datos.
- **Pasos**:
  1. Cargar archivo válido.
  2. Grabar registros.
- **Esperado**: Mensaje de error general, ningún registro insertado.

## Caso 5: Archivo vacío
- **Preparación**: Archivo .txt vacío.
- **Pasos**:
  1. Cargar archivo.
  2. Descargar datos.
- **Esperado**: Mensaje 'No hay datos cargados', botones deshabilitados.

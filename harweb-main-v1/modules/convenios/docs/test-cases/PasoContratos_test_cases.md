# Casos de Prueba PasoContratos

## Caso 1: Importación exitosa de archivo
- **Dado**: Un archivo de texto con 1 o más líneas válidas, cada una con 38 campos separados por '|'.
- **Cuando**: El usuario importa el archivo.
- **Entonces**: Todos los registros se insertan en la tabla de paso, la respuesta indica éxito y el número de insertados.

## Caso 2: Archivo con líneas incompletas
- **Dado**: Un archivo donde algunas líneas tienen menos de 38 campos.
- **Cuando**: El usuario importa el archivo.
- **Entonces**: Las líneas incompletas se saltan, la respuesta indica cuántas fueron insertadas y cuántas saltadas.

## Caso 3: Limpieza de tabla de paso
- **Dado**: La tabla de paso contiene datos.
- **Cuando**: El usuario ejecuta la acción 'limpiarTablaPaso'.
- **Entonces**: La tabla queda vacía, la respuesta indica éxito.

## Caso 4: Preview de tabla de paso
- **Dado**: La tabla de paso contiene datos.
- **Cuando**: El usuario ejecuta la acción 'getPasoContratosPreview'.
- **Entonces**: Se devuelven los primeros 100 registros en formato JSON.

## Caso 5: Archivo vacío
- **Dado**: El usuario selecciona un archivo vacío.
- **Cuando**: Intenta importar.
- **Entonces**: La respuesta indica 0 insertados, 0 saltados, sin error.

## Caso 6: Error de conexión a BD
- **Dado**: La base de datos está caída.
- **Cuando**: El usuario intenta importar o limpiar.
- **Entonces**: La respuesta indica error y mensaje de excepción.

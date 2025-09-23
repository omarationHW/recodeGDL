## Casos de Prueba para RptColonias

### Caso 1: Visualización exitosa del catálogo
- **Descripción**: El usuario accede a la página y ve la lista completa de colonias.
- **Precondiciones**: Hay al menos 3 colonias en la base de datos.
- **Pasos**:
  1. Acceder a la ruta '/colonias'.
  2. Verificar que la tabla muestra todas las colonias y el total es correcto.
- **Resultado esperado**: La tabla muestra los datos correctos y el total coincide con el número de registros.

### Caso 2: Error de base de datos
- **Descripción**: El stored procedure no existe o la base de datos está caída.
- **Precondiciones**: El stored procedure 'rpt_colonias_list' no existe.
- **Pasos**:
  1. Acceder a la página '/colonias'.
  2. Observar el mensaje de error en pantalla.
- **Resultado esperado**: Se muestra un mensaje de error amigable y no se muestra la tabla.

### Caso 3: eRequest no soportado
- **Descripción**: Se envía un eRequest no implementado.
- **Precondiciones**: Acceso a la API.
- **Pasos**:
  1. Enviar POST a '/api/execute' con `{ "eRequest": "NoExiste", "params": {} }`.
  2. Observar la respuesta.
- **Resultado esperado**: La respuesta contiene `eResponse: 'ERROR'` y mensaje 'eRequest not supported'.

### Caso 4: Validación de formato de respuesta
- **Descripción**: Verificar que la respuesta contiene los campos esperados.
- **Precondiciones**: Petición exitosa.
- **Pasos**:
  1. Acceder a '/colonias'.
  2. Inspeccionar la respuesta de la API.
- **Resultado esperado**: La respuesta contiene 'eResponse', 'message', y 'data' con 'colonias' y 'total'.

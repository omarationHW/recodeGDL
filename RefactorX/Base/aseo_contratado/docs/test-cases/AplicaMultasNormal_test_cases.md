## Casos de Prueba: AplicaMultasNormal

### Caso 1: Consulta de configuración actual
- **Acción:** GET (POST /api/execute con action 'get_aplicareq')
- **Esperado:** Respuesta con los campos descripcion, aplica, porc.
- **Validación:** Los valores corresponden a la base de datos.

### Caso 2: Cambio a aplicación normal
- **Acción:** POST /api/execute con action 'update_aplicareq', aplica='S', porc=0
- **Esperado:** Mensaje 'La Aplicación Normal Realizada'.
- **Validación:** En la base de datos, aplica='S', porc=0.

### Caso 3: Cambio a no aplicación normal con porcentaje
- **Acción:** POST /api/execute con action 'update_aplicareq', aplica='N', porc=30
- **Esperado:** Mensaje 'La NO Aplicación Normal CON PORCENTAJE Realizada'.
- **Validación:** En la base de datos, aplica='N', porc=30.

### Caso 4: Error por porcentaje faltante
- **Acción:** POST /api/execute con action 'update_aplicareq', aplica='N', porc=0
- **Esperado:** Mensaje de error 'Falta el porcentaje de Aplicación de Multa'.
- **Validación:** No se actualiza la base de datos.

### Caso 5: Error por acción no soportada
- **Acción:** POST /api/execute con action 'no_existente'
- **Esperado:** Mensaje de error 'Acción no soportada'.
- **Validación:** No se realiza ningún cambio.
# Casos de Prueba: Transferencia Estado-Municipio

## Caso 1: Carga exitosa de archivo
- **Precondición:** Archivo CSV válido disponible.
- **Acción:** Subir archivo vía formulario.
- **Esperado:** Mensaje de éxito, tabla de remesas actualizada, datos insertados en base.

## Caso 2: Carga de archivo inválido
- **Precondición:** Archivo no es CSV o estructura incorrecta.
- **Acción:** Subir archivo erróneo.
- **Esperado:** Mensaje de error, ningún dato insertado.

## Caso 3: Visualización de remesas sin datos
- **Precondición:** Tabla ta14_datos_edo vacía.
- **Acción:** Acceder a la página.
- **Esperado:** Tabla muestra mensaje 'No hay remesas registradas.'

## Caso 4: Eliminación de registro existente
- **Precondición:** Registro con folio y placa existe.
- **Acción:** Llamar API con eRequest 'procesar_delesta01' y opc=1.
- **Esperado:** Mensaje 'Registro eliminado', registro ya no existe en base.

## Caso 5: Eliminación de registro inexistente
- **Precondición:** Registro no existe.
- **Acción:** Llamar API con eRequest 'procesar_delesta01' y opc=1.
- **Esperado:** Mensaje 'Registro eliminado', sin error, sin cambios en base.

# Casos de Prueba: Catálogo de Tipos de Empresas

## Caso 1: Visualización inicial ordenada por número de control
- **Precondición:** Existen al menos 2 registros en ta_16_tipos_emp con diferentes valores en ctrol_emp.
- **Acción:** Acceder a la página del catálogo.
- **Esperado:** La tabla muestra los registros ordenados por ctrol_emp ascendente.

## Caso 2: Cambio de ordenamiento a 'Tipo'
- **Precondición:** Existen registros con diferentes valores en tipo_empresa.
- **Acción:** Seleccionar 'Tipo' en el selector de clasificación.
- **Esperado:** La tabla se actualiza y muestra los registros ordenados por tipo_empresa ascendente.

## Caso 3: Cambio de ordenamiento a 'Descripción'
- **Precondición:** Existen registros con diferentes valores en descripcion.
- **Acción:** Seleccionar 'Descripción' en el selector de clasificación.
- **Esperado:** La tabla se actualiza y muestra los registros ordenados por descripcion ascendente.

## Caso 4: Tabla vacía
- **Precondición:** La tabla ta_16_tipos_emp no tiene registros.
- **Acción:** Acceder a la página del catálogo.
- **Esperado:** Se muestra el mensaje 'No hay registros para mostrar.'

## Caso 5: Error de comunicación con el backend
- **Precondición:** El backend no está disponible.
- **Acción:** Acceder a la página del catálogo.
- **Esperado:** Se muestra un mensaje de error al usuario.

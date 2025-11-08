# Casos de Prueba: Alta de Locales (RNuevos)

## Caso 1: Alta exitosa
- **Entrada**: Todos los campos válidos, control único.
- **Acción**: Enviar formulario.
- **Esperado**: Mensaje de éxito, registro creado en BD.

## Caso 2: Control duplicado
- **Entrada**: Número y letra de local ya existentes.
- **Acción**: Enviar formulario.
- **Esperado**: Mensaje de error 'Ya existe LOCAL con este dato, intentalo de nuevo'.

## Caso 3: Falta de campos obligatorios
- **Entrada**: Dejar vacío el campo concesionario.
- **Acción**: Enviar formulario.
- **Esperado**: Mensaje de error 'Falta el dato del CONCESIONARIO DEL LOCAL, intentalo de nuevo'.

## Caso 4: Año de alta inválido
- **Entrada**: Año fuera de rango permitido.
- **Acción**: Enviar formulario.
- **Esperado**: Mensaje de error 'Revisar el año de alta del LOCAL'.

## Caso 5: Superficie igual a 0
- **Entrada**: Superficie = 0.
- **Acción**: Enviar formulario.
- **Esperado**: Mensaje de error 'Falta el dato de la SUPERFICIE DEL LOCAL, intentalo de nuevo'.

## Caso 6: Error de servidor
- **Simulación**: Desconectar BD.
- **Acción**: Enviar formulario.
- **Esperado**: Mensaje de error de comunicación.

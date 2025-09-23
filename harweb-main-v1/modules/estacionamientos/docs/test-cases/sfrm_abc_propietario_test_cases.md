# Casos de Prueba para Registro de Propietarios

## Caso 1: Registro exitoso de persona física
- **Entradas**: RFC: XEXX010101AAA, Sociedad: F, Nombre: JUAN PEREZ, Apellido Paterno: PEREZ, Apellido Materno: LOPEZ, IFE: 123456789012345, Dirección: AV. PRINCIPAL 123, Usuario: 1
- **Acción**: Completar formulario y presionar 'Aceptar'.
- **Resultado esperado**: Mensaje de éxito, formulario limpio, registro insertado en la base de datos.

## Caso 2: Registro con RFC duplicado
- **Entradas**: RFC: TOHI691108LFA (ya existente), Sociedad: M, Nombre: EMPRESA SA DE CV, Usuario: 1
- **Acción**: Completar formulario y presionar 'Aceptar'.
- **Resultado esperado**: Mensaje de error "Este RFC ya está registrado, verifique." y no se inserta registro.

## Caso 3: Cancelación de registro
- **Entradas**: RFC: ABCD123456XYZ, Sociedad: F, Nombre: MARIA GARCIA, Usuario: 1
- **Acción**: Llenar algunos campos y presionar 'Cancelar'.
- **Resultado esperado**: Formulario limpio, mensaje "Operación cancelada".

## Caso 4: RFC menor a 9 caracteres
- **Entradas**: RFC: ABC123, Sociedad: F, Nombre: TEST, Usuario: 1
- **Acción**: Completar formulario y presionar 'Aceptar'.
- **Resultado esperado**: Mensaje de error "Verificar el RFC (mínimo 9 caracteres)."

## Caso 5: Nombre vacío
- **Entradas**: RFC: XEXX010101AAA, Sociedad: F, Nombre: (vacío), Usuario: 1
- **Acción**: Completar formulario y presionar 'Aceptar'.
- **Resultado esperado**: Mensaje de error "El nombre o razón social es obligatorio."

# Casos de Prueba: Formulario Mensajes

| # | Escenario | Entrada | Acción | Resultado Esperado |
|---|-----------|---------|--------|--------------------|
| 1 | Mostrar mensaje informativo | mensaje='Hola', imagen=1 | Acceder a /mensajes?mensaje=Hola&imagen=1 | Se muestra el mensaje 'Hola' con icono informativo |
| 2 | Guardar mensaje válido | mensaje='Prueba', imagen=2 | Click en 'Guardar Mensaje' | Mensaje guardado, aparece en historial |
| 3 | Guardar mensaje vacío | mensaje='', imagen=1 | Click en 'Guardar Mensaje' | Error de validación: 'mensaje es requerido' |
| 4 | Listar historial | - | Acceder a /mensajes?list=1 | Se muestra la lista de mensajes guardados |
| 5 | Mostrar mensaje sin imagen | mensaje='Solo texto', imagen=null | Acceder a /mensajes?mensaje=Solo texto | Se muestra mensaje sin icono |
| 6 | Guardar mensaje con imagen inválida | mensaje='Test', imagen=99 | Click en 'Guardar Mensaje' | Mensaje guardado, sin icono asociado |

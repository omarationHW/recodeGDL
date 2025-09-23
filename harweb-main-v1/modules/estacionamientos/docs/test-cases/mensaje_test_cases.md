## Casos de Prueba para Formulario 'mensaje'

| # | Descripción | Entrada | Resultado Esperado |
|---|-------------|---------|--------------------|
| 1 | Mostrar mensaje de error crítico | tipo=Error, msg='Ocurrió un error inesperado.', icono=alto | Se muestra el mensaje con ícono 'alto' y botón 'Aceptar'. |
| 2 | Mostrar mensaje de confirmación | tipo=Confirmación, msg='¿Está seguro de continuar?', icono=pregunta | Se muestra el mensaje con ícono 'pregunta' y botón 'Aceptar'. |
| 3 | Mostrar mensaje informativo | tipo=Información, msg='La operación se realizó correctamente.', icono=informacion | Se muestra el mensaje con ícono 'informacion' y botón 'Aceptar'. |
| 4 | Parámetros faltantes | tipo= (vacío), msg= (vacío), icono= (vacío) | Se muestra mensaje por defecto y el ícono 'informacion'. |
| 5 | Ícono inválido | tipo=Alerta, msg='Mensaje de prueba', icono=desconocido | No se muestra ningún ícono, solo el mensaje. |
| 6 | Llamada API con error de red | - | Se muestra mensaje de error de comunicación. |
| 7 | Llamada API con acción no soportada | action=unknown_action | Se muestra mensaje de error 'Acción no soportada.' |

# Casos de Prueba: Ubicación del Predio

| Caso | Descripción | Entrada | Resultado Esperado |
|------|-------------|---------|--------------------|
| TC01 | Clave catastral válida | cvecatastro: '1234567890' | Se muestra el visor con la ubicación correspondiente |
| TC02 | Clave catastral vacía | cvecatastro: '' | Mensaje de error: 'Debe ingresar la clave catastral.' |
| TC03 | Clave catastral con caracteres especiales | cvecatastro: 'ABC@#123!' | Se genera la URL, el visor puede no mostrar datos, pero no hay error en backend/frontend |
| TC04 | Petición directa a API sin parámetro | POST /api/execute con action 'getPredioCartoUrl' y data vacío | Respuesta con success: false y mensaje de error |
| TC05 | Navegación: Botón 'Cerrar' | Usuario presiona 'Cerrar' | Redirección a la página de inicio |

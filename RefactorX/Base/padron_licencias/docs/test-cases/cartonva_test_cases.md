# Casos de Prueba para Cartografía Predial (cartonva)

## Caso 1: Consulta exitosa de cuenta catastral
- **Entrada:** cvecuenta = 123456
- **Acción:** Buscar
- **Resultado esperado:**
  - Se muestran los datos de la cuenta (campos principales no vacíos)
  - El iframe del visor carga la URL con la clave catastral correspondiente

## Caso 2: Cuenta catastral inexistente
- **Entrada:** cvecuenta = 99999999
- **Acción:** Buscar
- **Resultado esperado:**
  - Se muestra mensaje de error: "Cuenta no encontrada"
  - No se muestra el iframe del visor

## Caso 3: Visualización directa del visor
- **Entrada:** cvecatnva = 'A1234567890'
- **Acción:** Llamar a la acción getVisorUrl vía API
- **Resultado esperado:**
  - Se recibe una URL válida del visor
  - El iframe o ventana muestra el visor con la clave catastral

## Caso 4: Validación de campos vacíos
- **Entrada:** cvecuenta = ''
- **Acción:** Buscar
- **Resultado esperado:**
  - El frontend no permite enviar el formulario
  - El backend responde con error de parámetro requerido si se fuerza la petición

## Caso 5: Respuesta de error del backend
- **Simulación:** Forzar un error en la base de datos
- **Acción:** Buscar cualquier cuenta
- **Resultado esperado:**
  - El frontend muestra un mensaje de error general
  - El backend responde con success: false y un mensaje de error

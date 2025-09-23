# Casos de Prueba para RptCaratulaDatos

## 1. Consulta Exitosa de Contrato Vigente
- **Entrada:** ID Contrato válido y vigente
- **Acción:** Buscar contrato
- **Esperado:** Se muestran todos los datos, pagos y ampliación de plazo

## 2. Consulta de Contrato Inexistente
- **Entrada:** ID Contrato inexistente
- **Acción:** Buscar contrato
- **Esperado:** Mensaje de error 'No se encontró el contrato'

## 3. Consulta de Contrato Cancelado
- **Entrada:** ID Contrato cancelado
- **Acción:** Buscar contrato
- **Esperado:** Se muestran los datos y el estado 'CANCELADO'

## 4. Validación de Parámetros
- **Entrada:** ID Contrato vacío o no numérico
- **Acción:** Buscar contrato
- **Esperado:** Mensaje de error 'Parámetro contrato requerido'

## 5. Consulta de Pagos Detalle
- **Entrada:** ID Contrato válido
- **Acción:** Buscar pagos detalle
- **Esperado:** Se muestra la tabla de pagos con todos los campos

## 6. Consulta de Ampliación de Plazo
- **Entrada:** ID Contrato con ampliación vigente
- **Acción:** Buscar ampliación de plazo
- **Esperado:** Se muestra la información de la última ampliación

## 7. Contrato sin Pagos
- **Entrada:** ID Contrato válido sin pagos
- **Acción:** Buscar contrato
- **Esperado:** Se muestran los datos principales y la tabla de pagos vacía

# Casos de Prueba EdoCuenta

## 1. Consulta de Convenios Existentes
- **Entrada**: tipo=14, subtipo=1
- **Acción**: getEdoCuenta
- **Esperado**: Lista de convenios no vacía, cada convenio tiene campos manzana, lote, letra, nombre, etc.

## 2. Consulta de Pagos y Adeudos de Convenio
- **Entrada**: id_conv_resto=12345
- **Acción**: getPagos, getAdeudos
- **Esperado**: Pagos y adeudos correspondientes al convenio, recargos calculados correctamente.

## 3. Cálculo de Recargos
- **Entrada**: alov=2022, mesv=3, alo=2024, mes=6, dia=15, diav=10
- **Acción**: getRecargos
- **Esperado**: Porcentaje de recargos correcto según la lógica migrada.

## 4. Validación de Parámetros Inválidos
- **Entrada**: tipo=null
- **Acción**: getEdoCuenta
- **Esperado**: status=error, message indica parámetro faltante.

## 5. Seguridad
- **Entrada**: Usuario no autenticado
- **Acción**: cualquier acción
- **Esperado**: status=error, message indica falta de autenticación.

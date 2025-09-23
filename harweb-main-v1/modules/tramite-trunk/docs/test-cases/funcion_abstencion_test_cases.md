# Casos de Prueba para funcion_abstencion

## 1. Registrar abstención válida
- **Entrada:**
  - cvecuenta: 10001
  - anio: 2024
  - bimestre: 3
  - observacion: "Prueba registro"
  - usuario: "tester"
- **Acción:** add_abstencion
- **Esperado:** status=success, message="Abstención registrada correctamente."

## 2. Registrar abstención duplicada
- **Precondición:** Ya existe abstención para cvecuenta=10001, anio=2024, bimestre=3
- **Entrada:** Igual al anterior
- **Acción:** add_abstencion
- **Esperado:** status=error, message="Ya existe una abstención para esta cuenta, año y bimestre."

## 3. Eliminar abstención existente
- **Entrada:**
  - cvecuenta: 10001
  - anio: 2024
  - bimestre: 3
  - usuario: "tester"
- **Acción:** remove_abstencion
- **Esperado:** status=success, message="Abstención eliminada correctamente."

## 4. Eliminar abstención inexistente
- **Entrada:**
  - cvecuenta: 99999
  - anio: 2022
  - bimestre: 1
  - usuario: "tester"
- **Acción:** remove_abstencion
- **Esperado:** status=error, message="No existe abstención para esta cuenta, año y bimestre."

## 5. Consultar abstenciones de cuenta
- **Entrada:**
  - cvecuenta: 10001
- **Acción:** get_abstencion_by_cuenta
- **Esperado:** status=success, data=[...]

## 6. Consultar todas las abstenciones
- **Entrada:**
  - (sin parámetros)
- **Acción:** get_abstenciones
- **Esperado:** status=success, data=[...]

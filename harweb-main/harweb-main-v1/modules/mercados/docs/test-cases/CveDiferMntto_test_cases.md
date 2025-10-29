# Casos de Prueba: Mantenimiento Claves de Diferencias

## 1. Alta exitosa
- **Input:** clave_diferencia=300, descripcion="DIFERENCIA TEST", cuenta_ingreso=44510, id_usuario=2
- **Acción:** insert_cve_diferencia
- **Esperado:** success=true, mensaje de éxito, registro aparece en listado

## 2. Alta duplicada
- **Input:** clave_diferencia=300, descripcion="DIFERENCIA DUPLICADA", cuenta_ingreso=44510, id_usuario=2
- **Acción:** insert_cve_diferencia
- **Esperado:** success=false, mensaje de error "ya existe"

## 3. Modificación exitosa
- **Input:** clave_diferencia=300, descripcion="DIFERENCIA MODIFICADA", cuenta_ingreso=44511, id_usuario=2
- **Acción:** update_cve_diferencia
- **Esperado:** success=true, mensaje de éxito, registro actualizado

## 4. Modificación inexistente
- **Input:** clave_diferencia=9999, descripcion="NO EXISTE", cuenta_ingreso=44512, id_usuario=2
- **Acción:** update_cve_diferencia
- **Esperado:** success=false, mensaje de error "no existe"

## 5. Validación de campos vacíos
- **Input:** clave_diferencia=301, descripcion="", cuenta_ingreso=0, id_usuario=2
- **Acción:** insert_cve_diferencia
- **Esperado:** success=false, mensaje de error de validación

## 6. Consulta de listado
- **Acción:** list_cve_diferencias
- **Esperado:** success=true, data es array de registros

## 7. Consulta de cuentas
- **Acción:** list_cuentas
- **Esperado:** success=true, data es array de cuentas

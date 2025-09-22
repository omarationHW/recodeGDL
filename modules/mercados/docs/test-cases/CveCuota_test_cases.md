# Casos de Prueba: Catálogo de Claves de Cuota

## 1. Alta de clave de cuota válida
- **Input:** clave_cuota=10, descripcion="ANUAL"
- **Acción:** createCveCuota
- **Resultado esperado:** Clave agregada, success=true

## 2. Alta de clave de cuota duplicada
- **Input:** clave_cuota=1, descripcion="DUPLICADO"
- **Acción:** createCveCuota
- **Resultado esperado:** Error de clave duplicada, success=false

## 3. Modificación de descripción
- **Input:** clave_cuota=1, descripcion="MENSUAL ACTUALIZADO"
- **Acción:** updateCveCuota
- **Resultado esperado:** Descripción actualizada, success=true

## 4. Eliminación de clave existente
- **Input:** clave_cuota=10
- **Acción:** deleteCveCuota
- **Resultado esperado:** Clave eliminada, success=true

## 5. Consulta de clave específica
- **Input:** clave_cuota=2
- **Acción:** getCveCuota
- **Resultado esperado:** Devuelve registro con clave_cuota=2

## 6. Consulta de todas las claves
- **Input:** (sin parámetros)
- **Acción:** listCveCuota
- **Resultado esperado:** Lista completa de claves de cuota

## 7. Validación de campos obligatorios
- **Input:** clave_cuota=null, descripcion=""
- **Acción:** createCveCuota
- **Resultado esperado:** Error de validación, success=false

# Casos de Prueba Catálogo de Requisitos

## 1. Alta de requisito válido
- **Entrada:** { "descripcion": "Copia de comprobante de domicilio reciente" }
- **Acción:** create
- **Resultado esperado:** success=true, data contiene nuevo req y descripción

## 2. Alta de requisito sin descripción
- **Entrada:** { "descripcion": "" }
- **Acción:** create
- **Resultado esperado:** success=false, message indica que la descripción es obligatoria

## 3. Edición de requisito existente
- **Entrada:** { "req": 2, "descripcion": "Copia de acta constitutiva actualizada" }
- **Acción:** update
- **Resultado esperado:** success=true, data contiene req=2 y nueva descripción

## 4. Eliminación de requisito existente
- **Entrada:** { "req": 4 }
- **Acción:** delete
- **Resultado esperado:** success=true, data contiene req eliminado

## 5. Búsqueda de requisitos por texto
- **Entrada:** { "descripcion": "copia" }
- **Acción:** search
- **Resultado esperado:** success=true, data contiene todos los requisitos que contienen 'copia' en la descripción

## 6. Listado general
- **Entrada:** {}
- **Acción:** list
- **Resultado esperado:** success=true, data contiene todos los requisitos ordenados por número

## 7. Impresión de listado
- **Entrada:** {}
- **Acción:** print
- **Resultado esperado:** success=true, data contiene todos los requisitos (igual que list)

# Casos de Prueba: CuotasMdoMntto

## 1. Alta exitosa de cuota
- **Input:**
  - axo: 2024
  - categoria: 1
  - seccion: 'A'
  - clave_cuota: 1001
  - importe: 1234.56
  - id_usuario: 1
- **Acción:** create
- **Esperado:**
  - success: true
  - message: 'Registro creado correctamente'
  - La cuota aparece en el listado

## 2. Alta duplicada (misma combinación año/categoría/sección/clave_cuota)
- **Input:** (igual que el anterior)
- **Acción:** create
- **Esperado:**
  - success: false
  - message: 'Registro duplicado' o similar

## 3. Modificación exitosa
- **Input:**
  - id_cuotas: 5
  - axo: 2024
  - categoria: 1
  - seccion: 'A'
  - clave_cuota: 1001
  - importe: 1500.00
  - id_usuario: 1
- **Acción:** update
- **Esperado:**
  - success: true
  - message: 'Registro actualizado correctamente'
  - El importe se actualiza en el listado

## 4. Eliminación exitosa
- **Input:**
  - id_cuotas: 7
- **Acción:** delete
- **Esperado:**
  - success: true
  - message: 'Registro eliminado correctamente'
  - La cuota desaparece del listado

## 5. Eliminación de registro inexistente
- **Input:**
  - id_cuotas: 9999
- **Acción:** delete
- **Esperado:**
  - success: false
  - message: 'Error al eliminar registro' o similar

## 6. Validación de importe cero
- **Input:**
  - importe: 0
- **Acción:** create
- **Esperado:**
  - success: false
  - message: 'El campo importe debe ser mayor a cero' o similar

## 7. Listado de cuotas
- **Acción:** list
- **Esperado:**
  - success: true
  - data: array de cuotas

## 8. Consulta de catálogos
- **Acción:** catalogs
- **Esperado:**
  - success: true
  - data: { categorias, secciones, claves }

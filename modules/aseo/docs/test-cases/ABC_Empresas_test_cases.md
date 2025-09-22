# Casos de Prueba: Catálogo de Empresas

## 1. Alta de empresa válida
- Enviar a /api/execute:
  ```json
  { "action": "create", "payload": { "ctrol_emp": 9, "descripcion": "EMPRESA TEST", "representante": "TEST USER" } }
  ```
- Esperar: success=true, data contiene num_empresa y ctrol_emp

## 2. Alta de empresa sin descripción
- Enviar a /api/execute:
  ```json
  { "action": "create", "payload": { "ctrol_emp": 9, "descripcion": "", "representante": "TEST USER" } }
  ```
- Esperar: success=false, message indica campo requerido

## 3. Edición de empresa existente
- Enviar a /api/execute:
  ```json
  { "action": "update", "payload": { "num_empresa": 1, "ctrol_emp": 9, "descripcion": "EMPRESA MOD", "representante": "MOD USER" } }
  ```
- Esperar: success=true

## 4. Eliminación de empresa sin contratos
- Enviar a /api/execute:
  ```json
  { "action": "delete", "payload": { "num_empresa": 2, "ctrol_emp": 9 } }
  ```
- Esperar: success=true

## 5. Eliminación de empresa con contratos
- Enviar a /api/execute:
  ```json
  { "action": "delete", "payload": { "num_empresa": 10, "ctrol_emp": 9 } }
  ```
- Esperar: success=false, message indica que no se puede eliminar

## 6. Búsqueda por nombre
- Enviar a /api/execute:
  ```json
  { "action": "search", "payload": { "descripcion": "EMPRESA" } }
  ```
- Esperar: success=true, data contiene empresas cuyo nombre contiene 'EMPRESA'

## 7. Listado general
- Enviar a /api/execute:
  ```json
  { "action": "list" }
  ```
- Esperar: success=true, data contiene todas las empresas

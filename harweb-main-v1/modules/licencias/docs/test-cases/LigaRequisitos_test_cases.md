# Casos de Prueba: Liga de Requisitos a Giros

## 1. Alta de requisito exitoso
- **Input:** { "action": "add_requisito", "params": { "id_giro": 1201, "req": 7 } }
- **Resultado esperado:** { "success": true, "message": "Requisito agregado" }
- **Verificación:** El registro existe en la tabla giro_req.

## 2. Alta de requisito duplicado
- **Input:** { "action": "add_requisito", "params": { "id_giro": 1201, "req": 7 } } (si ya existe)
- **Resultado esperado:** { "success": false, "message": "El requisito ya está ligado a este giro" }

## 3. Baja de requisito exitoso
- **Input:** { "action": "remove_requisito", "params": { "id_giro": 1201, "req": 7 } }
- **Resultado esperado:** { "success": true, "message": "Requisito eliminado" }
- **Verificación:** El registro ya no existe en giro_req.

## 4. Baja de requisito inexistente
- **Input:** { "action": "remove_requisito", "params": { "id_giro": 1201, "req": 999 } }
- **Resultado esperado:** { "success": false, "message": "El requisito no está ligado a este giro" }

## 5. Consulta de requisitos ligados
- **Input:** { "action": "get_requisitos_ligados", "params": { "id_giro": 1201 } }
- **Resultado esperado:** Lista de requisitos ligados a ese giro.

## 6. Consulta de requisitos disponibles
- **Input:** { "action": "get_requisitos_disponibles", "params": { "id_giro": 1201 } }
- **Resultado esperado:** Lista de requisitos no ligados a ese giro.

## 7. Búsqueda de giros
- **Input:** { "action": "search_giros", "params": { "descripcion": "ALIMENTOS" } }
- **Resultado esperado:** Lista de giros que contienen "ALIMENTOS" en la descripción.

## 8. Búsqueda de requisitos
- **Input:** { "action": "search_requisitos", "params": { "descripcion": "RFC" } }
- **Resultado esperado:** Lista de requisitos que contienen "RFC" en la descripción.

## 9. Reporte
- **Input:** { "action": "print_report", "params": {} }
- **Resultado esperado:** { "success": true, "url": "/api/reports/liga-requisitos.pdf" }

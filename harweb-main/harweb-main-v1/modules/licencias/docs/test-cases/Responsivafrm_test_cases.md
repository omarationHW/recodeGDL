# Casos de Prueba para Responsivas

## 1. Alta de Responsiva
- **Entrada:** {"action": "crearResponsiva", "payload": {"id_licencia": 1, "tipo": "R", "usuario": "admin"}}
- **Esperado:** Respuesta success=true, data con axo, folio, id_licencia, tipo, vigente='V', feccap, capturista

## 2. Cancelación de Responsiva
- **Entrada:** {"action": "cancelarResponsiva", "payload": {"axo": 2024, "folio": 12, "motivo": "Duplicada", "usuario": "admin"}}
- **Esperado:** Respuesta success=true, data con axo, folio, vigente='C', observacion='Duplicada'

## 3. Búsqueda por Folio
- **Entrada:** {"action": "buscarPorFolio", "payload": {"axo": 2024, "folio": 12, "tipo": "R"}}
- **Esperado:** Respuesta success=true, data con responsiva correspondiente

## 4. Búsqueda por Licencia
- **Entrada:** {"action": "buscarPorLicencia", "payload": {"licencia": 12345, "tipo": "R"}}
- **Esperado:** Respuesta success=true, data con lista de responsivas

## 5. Validación de No Duplicidad de Folio
- **Entrada:** Dos altas consecutivas de responsiva para el mismo tipo y año
- **Esperado:** El folio se incrementa automáticamente, no se repite

## 6. Cancelación sin Motivo
- **Entrada:** {"action": "cancelarResponsiva", "payload": {"axo": 2024, "folio": 12, "motivo": "", "usuario": "admin"}}
- **Esperado:** Respuesta success=false, message indicando que el motivo es requerido

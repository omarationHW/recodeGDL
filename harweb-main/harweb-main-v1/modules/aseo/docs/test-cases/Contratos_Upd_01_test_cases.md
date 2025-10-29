# Casos de Prueba para Contratos_Upd_01

## 1. Buscar Contrato Existente
- **Entrada:** { "eRequest": { "action": "buscarContrato", "data": { "num_contrato": 1234, "ctrol_aseo": 9 } } }
- **Esperado:** Respuesta contiene datos del contrato.

## 2. Actualizar Cantidad de Unidades a Recolectar
- **Entrada:** { "eRequest": { "action": "actualizarContrato", "data": { "control_cont": 1001, "cant_recolec": 5, "opcion": 2 } } }
- **Esperado:** status=0, concepto='Cantidad de unidades actualizada'.

## 3. Cambio de Zona
- **Entrada:** { "eRequest": { "action": "actualizarContrato", "data": { "control_cont": 1001, "ctrol_zona": 2002, "opcion": 5 } } }
- **Esperado:** status=0, concepto='Zona actualizada'.

## 4. Relacionar Licencia de Giro
- **Entrada:** { "eRequest": { "action": "aplicarLicenciaGiro", "data": { "opc": "A", "licencia_giro": 12345, "control_contrato": 1001 } } }
- **Esperado:** status=0, leyenda='Licencia activada o reactivada'.

## 5. Buscar Empresas por Nombre
- **Entrada:** { "eRequest": { "action": "buscarEmpresas", "data": { "nombre": "S.A. de C.V." } } }
- **Esperado:** Lista de empresas cuyo nombre contiene 'S.A. de C.V.'.

## 6. Error por Opción Inválida
- **Entrada:** { "eRequest": { "action": "actualizarContrato", "data": { "control_cont": 1001, "opcion": 99 } } }
- **Esperado:** status=1, concepto='Opción no válida'.

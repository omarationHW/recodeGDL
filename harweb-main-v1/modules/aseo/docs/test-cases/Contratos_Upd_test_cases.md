# Casos de Prueba: Contratos_Upd

## 1. Actualización exitosa de contrato
- **Entrada:** Todos los campos requeridos, valores válidos
- **Acción:** POST /api/execute con action=update
- **Resultado esperado:** status=ok, mensaje de éxito, datos actualizados en BD

## 2. Contrato no existe
- **Entrada:** control_contrato inexistente
- **Acción:** POST /api/execute con action=update
- **Resultado esperado:** status=error, mensaje="Contrato no encontrado"

## 3. Validación de cantidad de recolección
- **Entrada:** cantidad_recolec=0
- **Acción:** POST /api/execute con action=update
- **Resultado esperado:** status=error, mensaje="El campo cantidad_recolec debe ser al menos 1."

## 4. Validación de sector
- **Entrada:** sector='Z'
- **Acción:** POST /api/execute con action=update
- **Resultado esperado:** status=error, mensaje="El campo sector debe ser uno de H,J,R,L."

## 5. Registro de historial
- **Entrada:** Actualización válida
- **Acción:** POST /api/execute con action=update
- **Resultado esperado:** status=ok, registro insertado en ta_16_contratos_historial

## 6. Carga de catálogos
- **Acción:** POST /api/execute con action=catalogs
- **Resultado esperado:** status=ok, data contiene arrays de tipoAseo, zonas, recaudadoras, sectores

## 7. Búsqueda de contrato
- **Entrada:** num_contrato y ctrol_aseo válidos
- **Acción:** POST /api/execute con action=load
- **Resultado esperado:** status=ok, data.contrato contiene datos del contrato

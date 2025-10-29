# Casos de Prueba para Contratos_UpdxCont

## 1. Buscar Contrato Existente
- **Entrada:** num_contrato=1234, ctrol_aseo=9
- **Acción:** POST /api/execute { eRequest: { operation: 'buscarContrato', num_contrato: 1234, ctrol_aseo: 9 } }
- **Resultado esperado:** eResponse.found=true, eResponse.contrato contiene los datos del contrato

## 2. Buscar Contrato Inexistente
- **Entrada:** num_contrato=999999, ctrol_aseo=9
- **Acción:** POST /api/execute { eRequest: { operation: 'buscarContrato', num_contrato: 999999, ctrol_aseo: 9 } }
- **Resultado esperado:** eResponse.found=false, eResponse.message='No existe contrato con el dato capturado'

## 3. Alta de Empresa Nueva
- **Entrada:** nombre='EMPRESA NUEVA S.A.'
- **Acción:** POST /api/execute { eRequest: { operation: 'altaEmpresa', nombre: 'EMPRESA NUEVA S.A.' } }
- **Resultado esperado:** eResponse.empresa.num_empresa > 0, eResponse.empresa.descripcion = 'EMPRESA NUEVA S.A.'

## 4. Actualizar Contrato con Datos Correctos
- **Entrada:** control_contrato=1, num_empresa=2, ctrol_emp=9, domicilio='Calle 123', sector='H', ctrol_zona=1001, id_rec=1, documento='DR/2024/001', descripcion_docto='Cambio de domicilio', usuario=1
- **Acción:** POST /api/execute { eRequest: { operation: 'actualizarContrato', ... } }
- **Resultado esperado:** eResponse.updated=true, eResponse.message='Contrato actualizado correctamente'

## 5. Actualizar Contrato con Campo Obligatorio Vacío
- **Entrada:** control_contrato=1, num_empresa=2, ctrol_emp=9, domicilio='Calle 123', sector='H', ctrol_zona=1001, id_rec=1, documento='', descripcion_docto='Cambio de domicilio', usuario=1
- **Acción:** POST /api/execute { eRequest: { operation: 'actualizarContrato', ... } }
- **Resultado esperado:** eResponse.error indica que falta el campo 'documento'

## 6. Listar Tipos de Aseo
- **Acción:** POST /api/execute { eRequest: { operation: 'listarTipoAseo' } }
- **Resultado esperado:** eResponse es un array con los tipos de aseo

## 7. Listar Zonas
- **Acción:** POST /api/execute { eRequest: { operation: 'listarZonas' } }
- **Resultado esperado:** eResponse es un array con las zonas

## 8. Listar Recaudadoras
- **Acción:** POST /api/execute { eRequest: { operation: 'listarRecaudadoras' } }
- **Resultado esperado:** eResponse es un array con las recaudadoras

## 9. Listar Sectores
- **Acción:** POST /api/execute { eRequest: { operation: 'listarSectores' } }
- **Resultado esperado:** eResponse es un array con los sectores ['H','J','R','L']
